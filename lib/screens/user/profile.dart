import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:loading_overlay_pro/loading_overlay_pro.dart';
import 'package:prohelp_app/components/button/custombutton.dart';
import 'package:prohelp_app/components/dialog/info_dialog.dart';
import 'package:prohelp_app/components/drawer/custom_drawer.dart';
import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/helper/constants/constants.dart';
import 'package:prohelp_app/helper/preference/preference_manager.dart';
import 'package:prohelp_app/helper/service/api_service.dart';
import 'package:prohelp_app/helper/socket/socket_manager.dart';
import 'package:prohelp_app/helper/state/state_manager.dart';
import 'package:prohelp_app/screens/connections/connection.dart';
import 'package:prohelp_app/screens/reviews/reviews.dart';

import 'components/block_report.dart';
import 'components/conectedinfo.dart';
import 'components/contactinfo.dart';
import 'components/guest_education_section.dart';
import 'components/guest_experience_section.dart';
import 'components/verifications.dart';

class UserProfile extends StatefulWidget {
  final PreferenceManager manager;
  final bool triggerHire;
  var data;
  UserProfile({
    Key? key,
    required this.manager,
    required this.data,
    required this.triggerHire,
  }) : super(key: key);

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _controller = Get.find<StateController>();

  bool _isLiked = false;
  bool _isConnected = false;
  bool _isConnectionRequestSent = false;
  bool _iBlockedUser = false;
  bool _userBlockedMe = false;
  bool _showContent = false;

  String _professionBanner = "";
  var _connectionCount = 0;
  var _reviewsCount = 0;
  var userData;

  _likeUser() async {
    _controller.setLoading(true);
    Map _payload = {
      "userId": "${widget.data['id']}",
    };
    try {
      final resp = await APIService().likeUser(_payload,
          widget.manager.getAccessToken(), widget.manager.getUser()['email']);
      debugPrint("Like RESPONSE >> ${resp.body}");
      _controller.setLoading(false);
      if (resp.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(resp.body);
        Constants.toast(map['message']);
        if (map['message'].toString().contains("unliked")) {
          setState(() {
            _isLiked = false;
          });
        } else {
          setState(() {
            _isLiked = true;
          });
        }
        _controller.userData.value = map['data'];
        String userStr = jsonEncode(map['data']);
        widget.manager.setUserData(userStr);
      }
    } catch (e) {
      _controller.setLoading(false);
      debugPrint("ERROR LIKING >>> $e");
    }
  }

  _checkLiked() {
    for (var element in widget.manager.getUser()['savedPros']) {
      if (element.toString() == (widget.data['id'] ?? widget.data['_id'])) {
        setState(() {
          _isLiked = true;
        });
      } else {
        setState(() {
          _isLiked = false;
        });
      }
    }
  }

  _checkConnection() {
    for (var element in widget.manager.getUser()['pendingSentConnect']) {
      if (element == widget.data['id']) {
        setState(() {
          _isConnectionRequestSent = true;
        });
      }
    }
  }

  _checkOnlineStatus() {
    final socket = SocketManager().socket;
    socket.emit('checkOnline', _controller.userData.value['id']);
  }

  _onConnected(val) {
    setState(() {
      _isConnected = val;
    });
  }

  _setBanner() {
    if (_controller.allProfessions.value.isNotEmpty) {
      var pro = _controller.allProfessions.value.where((item) =>
          item['name'].toLowerCase() ==
          widget.data['profession']?.toLowerCase());
      try {
        if (mounted) {
          setState(() {
            _professionBanner = "${pro.first['image']}";
          });
        }
      } catch (e) {
        print("$e");
      }
    }
  }

  _connectionState() {
    // Connection Declined
    final socket = SocketManager().socket;

    socket.on("connection-declined", (data) async {
      Map<String, dynamic> map = jsonDecode(jsonEncode(data));
      // Constants.toast("CONNECTION DECLINED!!!");

      // print("CONNECTION DECLINED USER :::  $map['user']['email']");
      print("CONNECTION DECLINED DECLINEDBY :::  $map['declinedBy']['email']");
      final userId = map['user']['id'].toString();
      final otherUserId = map['declinedBy']['id'].toString();
      if (userId == widget.manager.getUser()['id']) {
        print('THEY DECLINED MY REQUEST OH USER');
        setState(() {
          _isConnectionRequestSent = false;
        });
      } else {
        print('ME THE USER');
      }
    });

    socket.on(
      "connection-accepted",
      (data) {
        Map<String, dynamic> map = jsonDecode(jsonEncode(data));
        // Constants.toast("CONNECTION DECLINED!!!");

        print("CONNECTION ACCEPTED :::  $map['user']['email']");
        print("CONNECTION ACCEPTEDBY :::  $map['acceptedBy']['email']");
        final userId = map['user']['id'].toString();
        final acceptingUserId = map['acceptedBy']['id'].toString();
        if (userId == widget.manager.getUser()['id']) {
          print('THEY ACCEPTED MY REQUEST!!');
          setState(() {
            _isConnected = true;
            _isConnectionRequestSent = false;
          });
        } else {
          print('ME THE USER');
        }
        _controller.onInit();
      },
    );

    socket.on(
      "connection-cancelled",
      (data) {
        _controller.onInit();
      },
    );

    socket.on(
      "connection-requested",
      (data) async {
        print("CONNECTION REQUESTED $data");
        Map<String, dynamic> map = jsonDecode(jsonEncode(data));
        final requestedBy = map['requestBy']['id'].toString();
        if (requestedBy != widget.manager.getUser()['id']) {
          Constants.toast('REQUEST SENT BBY ME');
          setState(() {
            _isConnectionRequestSent = true;
          });
        } else {
          Constants.toast("BY ANOTHER REQUESTED!!!");
        }

        _controller.onInit();
      },
    );

    socket.on("user-blocked", (data) {
      print("BLOCKED USER DATA :: ${jsonEncode(data)}");

      Map<String, dynamic> map = jsonDecode(jsonEncode(data));
      final blockedBy = map['blockedBy']['_id'].toString();
      if (blockedBy != widget.manager.getUser()['id']) {
        // Constants.toast('USER JUST BLOCKED ME');
        if (mounted) {
          setState(() {
            _userBlockedMe = true;
          });
        }
      } else {
        // Constants.toast("I JUST BLOCKED THIS GUY!");
        if (mounted) {
          setState(() {
            _iBlockedUser = true;
          });
        }
      }
    });

    socket.on("user-unblocked", (data) {
      print("UNBLOCKED USER DATA :: ${jsonEncode(data)}");

      Map<String, dynamic> map = jsonDecode(jsonEncode(data));
      final unblockedBy = map['unblockedBy']['id'].toString();
      if (unblockedBy != widget.manager.getUser()['id']) {
        // Constants.toast('USER JUST UNBLOCKED ME');
        if (mounted) {
          setState(() {
            _userBlockedMe = false;
          });
        }
      } else {
        // Constants.toast("I JUST UNBLOCKED THIS GUY!");
        if (mounted) {
          setState(() {
            _iBlockedUser = false;
          });
        }
      }
    });
  }

  @override
  void initState() {
    if (mounted) {
      setState(() {
        userData = widget.data;
      });
    }
    _checkOnlineStatus();
    super.initState();
    _setBanner();
    _checkConnection();
    _checkLiked();

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _showContent = true;
      });
    });

    // print("CURENT USE  :: ${} ");

    _connectionState();

    if (widget.data['authType'] != "google") {
      APIService()
          .getUserConnectionsStreamed(
        accessToken: widget.manager.getAccessToken(),
        email: widget.data['email'],
      )
          .listen((event) {
        Map<String, dynamic> map = jsonDecode(event.body);
        print("CONNECTIONS STREAM LISTENER ::: ${jsonEncode(map)}");
        setState(() {
          _connectionCount = 0;
        });
        if (mounted) {
          setState(() {
            _connectionCount = map['totalDocs'] ?? 0;
          });
        }

        for (var element in map['docs']) {
          if ((element['user']['_id'] == widget.data['id'] &&
                  element['guest']['_id'] == widget.manager.getUser()['id']) ||
              (element['user']['_id'] == widget.manager.getUser()['id'] &&
                  element['guest']['_id'] == widget.data['id'])) {
            setState(() {
              _isConnected = true;
            });
          }
        }
      });
    }

    if (widget.data['authType'] != "google") {
      APIService()
          .getProfileStreamed(
        accessToken: widget.manager.getAccessToken(),
        email: widget.data['email'],
      )
          .listen((event) {
        Map<String, dynamic> map = jsonDecode(event.body);
        print("PROFILE STREAM LISTENER ::: ${jsonEncode(map)}");
        final _userData = map['data'];

        if (mounted) {
          setState(() {
            userData = map['data'];
          });
        }

        for (var element in _userData['blockedUsers']) {
          if ((element == widget.manager.getUser()['id'])) {
            // Constants.toast("THIS USER BLCOKED ME OH!!");
            setState(() {
              _userBlockedMe = true;
            });
          }
        }
      });
    }

    // For CURRENT LOGGED IN USER::
    APIService()
        .getProfileStreamed(
      accessToken: widget.manager.getAccessToken(),
      email: widget.manager.getUser()['email'],
    )
        .listen((event) {
      Map<String, dynamic> map = jsonDecode(event.body);
      print("PROFILE STREAM LISTENER ::: ${jsonEncode(map)}");
      final _userData = map['data'];

      for (var element in _userData['blockedUsers']) {
        if ((element == (widget.data['id'] ?? widget.data['_id']))) {
          // Constants.toast("I BLOCKED THIS USER OH!!");
          setState(() {
            _iBlockedUser = true;
          });
        }
      }
    });

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (widget.triggerHire) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return SizedBox(
              height: 200,
              width: MediaQuery.of(context).size.width * 0.98,
              child: InfoDialog(
                body: _isConnected
                    ? ConnectedInfoContent(
                        manager: widget.manager,
                        guestData: widget.data,
                      )
                    : ContactInfoContent(
                        manager: widget.manager,
                        guestData: widget.data,
                        onConnected: _onConnected,
                      ),
              ),
            );
          },
        );
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  _unblockUser() async {
    _controller.setLoading(true);
    Get.back();
    try {
      Map _payload = {
        "userId": widget.data['id'],
      };

      final _resp = await APIService().unblockUser(
        accessToken: widget.manager.getAccessToken(),
        email: widget.manager.getUser()['email'],
        payload: _payload,
      );

      // print("UNBLOCKED RESPONSE ::: :: ${_resp.body}");

      _controller.setLoading(false);

      if (_resp.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(_resp.body);
        Constants.toast(map['message']);
      }
    } catch (e) {
      _controller.setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return !_showContent
        ? Container(
            color: Colors.white,
            child: const Center(
              child: CircularProgressIndicator.adaptive(),
            ),
          )
        : GetBuilder<StateController>(builder: (controller) {
            return LoadingOverlayPro(
              isLoading: controller.isLoading.value,
              backgroundColor: Colors.black54,
              progressIndicator: const CircularProgressIndicator.adaptive(),
              child: Scaffold(
                key: _scaffoldKey,
                endDrawer: CustomDrawer(
                  manager: widget.manager,
                ),
                body: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ListView(
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            SizedBox(
                              width: double.infinity,
                              height: MediaQuery.of(context).size.height * 0.25,
                              child: Image.network(
                                _professionBanner,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              bottom: 0.0,
                              left: 0.0,
                              right: 0.0,
                              top: 8.0,
                              child: Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color.fromARGB(200, 0, 0, 0),
                                      Color.fromARGB(0, 0, 0, 0)
                                    ],
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 56.0,
                                  horizontal: 20.0,
                                ),
                                child: const SizedBox(
                                  height: 48.0,
                                ),
                              ),
                            ),
                            Positioned(
                              left: 12,
                              bottom: -Constants.avatarRadius,
                              child: CircleAvatar(
                                backgroundColor: Constants.secondaryColor,
                                radius: Constants.avatarRadius,
                                child: ClipOval(
                                  child: Container(
                                    // width: 100,
                                    // height: 100,
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(Constants.avatarRadius),
                                      ),
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 1.0,
                                      ),
                                    ),
                                    child: CachedNetworkImage(
                                      imageUrl: userData['bio']['image'],
                                      placeholder: (context, url) =>
                                          const CircularProgressIndicator(),
                                      errorWidget: (context, url, error) =>
                                          SvgPicture.asset(
                                        "assets/images/personal_icon.svg",
                                        width: Constants.avatarRadius + 40,
                                        height: Constants.avatarRadius + 40,
                                      ),
                                      fit: BoxFit.cover,
                                      width: Constants.avatarRadius + 48,
                                      height: Constants.avatarRadius + 48,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: -Constants.avatarRadius + 24,
                              left: (Constants.avatarRadius * 2) - 6,
                              child: ClipOval(
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.white,
                                  ),
                                  child: Center(
                                    child: Container(
                                      width: 18,
                                      height: 18,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(9),
                                        color: !widget.data['isVerified']
                                            ? Constants.golden
                                            : Colors.green,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 2.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: (Constants.avatarRadius * 2) + 12,
                              ),
                              Expanded(
                                flex: 2,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 8.0),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        !widget.data['isVerified']
                                            ? TextPoppins(
                                                text: " Not verified",
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                color: Constants.golden,
                                              )
                                            : TextPoppins(
                                                text: " Verified",
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.green,
                                              ),
                                        const SizedBox(
                                          width: 4.0,
                                        ),
                                        InkWell(
                                          onTap: () => _likeUser(),
                                          child: Padding(
                                            padding: const EdgeInsets.all(1.2),
                                            child: Icon(
                                              _isLiked
                                                  ? CupertinoIcons.heart_fill
                                                  : CupertinoIcons.heart,
                                              color: _isLiked
                                                  ? Colors.red
                                                  : Colors.grey,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 21.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 1.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextPoppins(
                                text:
                                    "${widget.data['bio']['firstname']} ${widget.data['bio']['middlename']} ${widget.data['bio']['lastname']}"
                                        .capitalize,
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                              ),
                              widget.data['accountType'] != "recruiter"
                                  ? TextPoppins(
                                      text: "${widget.data['profession']}"
                                          .capitalize,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    )
                                  : const SizedBox(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      RatingBar.builder(
                                        initialRating:
                                            "${widget.data['rating']}"
                                                    .contains(".")
                                                ? widget.data['rating']
                                                : (widget.data['rating'] ?? 1)
                                                        .toDouble() ??
                                                    0.0, //widget.data.rating,
                                        minRating: 1,
                                        direction: Axis.horizontal,
                                        allowHalfRating: true,
                                        ignoreGestures: true,
                                        itemCount: 5,
                                        itemSize: 21,
                                        itemPadding: const EdgeInsets.symmetric(
                                            horizontal: 0.0),
                                        itemBuilder: (context, _) => const Icon(
                                          Icons.star,
                                          size: 18,
                                          color: Colors.amber,
                                        ),
                                        onRatingUpdate: (rating) {
                                          debugPrint("$rating");
                                        },
                                      ),
                                      const SizedBox(
                                        width: 4.0,
                                      ),
                                      TextPoppins(
                                        text:
                                            "(${widget.data['reviews']?.length ?? 0} reviews)",
                                        fontSize: 12,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    width: 4.0,
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Get.to(
                                        ViewReviews(
                                          manager: widget.manager,
                                          data: widget.data,
                                        ),
                                        transition: Transition.cupertino,
                                      );
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.all(4.0),
                                      child: Icon(
                                        CupertinoIcons.forward,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              widget.data['accountType'] == "recruiter" &&
                                      !_isConnected
                                  ? const SizedBox()
                                  : Wrap(
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      children: [
                                        TextPoppins(
                                          text:
                                              "${userData['address']['state']}, ${userData['address']['country']}"
                                                  .capitalize,
                                          fontSize: 13,
                                          color: Colors.black54,
                                        ),
                                        const SizedBox(
                                          width: 5.0,
                                        ),
                                        const SizedBox(
                                          width: 5.0,
                                        ),
                                        TextPoppins(
                                          text:
                                              "$_connectionCount ${_connectionCount > 1 ? "Connections " : "Connection"}",
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: Constants.primaryColor,
                                        ),
                                        const SizedBox(
                                          width: 6.0,
                                        ),
                                        2 > 1
                                            ? const SizedBox()
                                            : InkWell(
                                                onTap: () {
                                                  Get.to(
                                                    Connection(
                                                      caller: "guest",
                                                      data: widget.data,
                                                      manager: widget.manager,
                                                    ),
                                                    transition:
                                                        Transition.cupertino,
                                                  );
                                                },
                                                child: const Text(
                                                  "See more",
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    decoration: TextDecoration
                                                        .underline,
                                                    fontStyle: FontStyle.italic,
                                                    fontWeight: FontWeight.w500,
                                                    color:
                                                        Constants.primaryColor,
                                                  ),
                                                ),
                                              )
                                      ],
                                    ),
                              const SizedBox(
                                height: 8.0,
                              ),
                              Wrap(
                                spacing: 0,
                                runSpacing: -8,
                                alignment: WrapAlignment.start,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  for (var e = 0;
                                      e < widget.data['skills']?.length;
                                      e++)
                                    Chip(
                                      label: TextPoppins(
                                        text: widget.data['skills'][e]['name'],
                                        fontSize: 12,
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(
                                height: 8.0,
                              ),
                              SizedBox(
                                height: 36,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: CustomButton(
                                        borderRadius: 36.0,
                                        paddingY: 1.0,
                                        bgColor: _userBlockedMe || _iBlockedUser
                                            ? Constants.accentColor
                                            : Constants.primaryColor,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            TextPoppins(
                                              text: _isConnectionRequestSent
                                                  ? "Request Sent"
                                                  : _isConnected
                                                      ? "Contact Info"
                                                      : "Connect",
                                              fontSize: 11,
                                              color: Colors.white,
                                            )
                                          ],
                                        ),
                                        borderColor: Colors.transparent,
                                        foreColor: Colors.white,
                                        onPressed: _isConnectionRequestSent ||
                                                _userBlockedMe ||
                                                _iBlockedUser
                                            ? null
                                            : () {
                                                showDialog(
                                                  context: context,
                                                  barrierDismissible: false,
                                                  builder: (context) {
                                                    return SizedBox(
                                                      height: 200,
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.98,
                                                      child: InfoDialog(
                                                        body: _isConnected
                                                            ? ConnectedInfoContent(
                                                                manager: widget
                                                                    .manager,
                                                                guestData:
                                                                    widget.data,
                                                              )
                                                            : ContactInfoContent(
                                                                manager: widget
                                                                    .manager,
                                                                guestData:
                                                                    widget.data,
                                                                onConnected:
                                                                    _onConnected,
                                                              ),
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                        variant: "Filled",
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 2.0,
                                    ),
                                    _isConnectionRequestSent
                                        ? Expanded(
                                            child: CustomButton(
                                              borderRadius: 36.0,
                                              paddingY: 1.0,
                                              bgColor: Constants.primaryColor,
                                              child: TextPoppins(
                                                text: "Cancel Request",
                                                fontSize: 11,
                                                align: TextAlign.center,
                                                color: Colors.white,
                                              ),
                                              borderColor: Colors.transparent,
                                              foreColor: Colors.white,
                                              onPressed: () {},
                                              variant: "Filled",
                                            ),
                                          )
                                        : const SizedBox(),
                                    _isConnectionRequestSent
                                        ? const SizedBox(
                                            width: 3.0,
                                          )
                                        : const SizedBox(),
                                    !_isConnected
                                        ? const SizedBox()
                                        : Expanded(
                                            child: CustomButton(
                                              borderRadius: 36.0,
                                              paddingY: 1.0,
                                              bgColor: Colors.grey.shade400,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    _userBlockedMe
                                                        ? Icons.block
                                                        : Icons.flag,
                                                    size: 14,
                                                  ),
                                                  const SizedBox(
                                                    width: 5.0,
                                                  ),
                                                  TextPoppins(
                                                    text: _iBlockedUser
                                                        ? "unBlock"
                                                        : _userBlockedMe
                                                            ? "Blocked"
                                                            : "Block",
                                                    fontSize: 11,
                                                  )
                                                ],
                                              ),
                                              borderColor: Colors.transparent,
                                              foreColor: Colors.black,
                                              onPressed: _userBlockedMe
                                                  ? null
                                                  : _iBlockedUser
                                                      ? () {
                                                          // Unblock user here
                                                          Constants
                                                              .showConfirmDialog(
                                                            context: context,
                                                            message:
                                                                "Are you sure you want to unblock ${widget.data['bio']['firstname'].toString().capitalize} ${widget.data['bio']['lastname'].toString().capitalize}? ",
                                                            onPressed: () {
                                                              _unblockUser();
                                                            },
                                                          );
                                                        }
                                                      : () {
                                                          showDialog(
                                                            context: context,
                                                            barrierDismissible:
                                                                false,
                                                            builder: (context) {
                                                              return SizedBox(
                                                                height: 200,
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    0.98,
                                                                child:
                                                                    InfoDialog(
                                                                  body:
                                                                      BlockReport(
                                                                    data: widget
                                                                        .data,
                                                                    manager: widget
                                                                        .manager,
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          );
                                                        },
                                              variant: "Filled",
                                            ),
                                          ),
                                    const SizedBox(
                                      width: 3.0,
                                    ),
                                    Expanded(
                                      child: CustomButton(
                                        borderRadius: 36.0,
                                        paddingY: 1.0,
                                        bgColor: const Color(0xFF07B4B4),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Icon(
                                              widget.data['accountType'] ==
                                                      "recruiter"
                                                  ? CupertinoIcons.person_3_fill
                                                  : Icons.edit_document,
                                              size: 14,
                                              color: Colors.white,
                                            ),
                                            const SizedBox(
                                              width: 5.0,
                                            ),
                                            TextPoppins(
                                              text:
                                                  widget.data['accountType'] ==
                                                          "recruiter"
                                                      ? "Connects"
                                                      : "Docs",
                                              fontSize: 11,
                                            ),
                                          ],
                                        ),
                                        borderColor: Colors.transparent,
                                        foreColor: Colors.white,
                                        onPressed: widget.data['accountType'] ==
                                                "recruiter"
                                            ? () {
                                                Get.to(
                                                  Connection(
                                                    caller: "guest",
                                                    manager: widget.manager,
                                                    data: widget.data,
                                                  ),
                                                  transition:
                                                      Transition.cupertino,
                                                );
                                              }
                                            : 3 > 2
                                                ? () {
                                                    Constants.toast(
                                                        "Coming soon!");
                                                  }
                                                : () {
                                                    showDialog(
                                                      context: context,
                                                      barrierDismissible: false,
                                                      builder: (context) {
                                                        return SizedBox(
                                                          height: 200,
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.98,
                                                          child: InfoDialog(
                                                            body:
                                                                VerificationsContent(
                                                              documents: [],
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  },
                                        variant: "Filled",
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 16.0,
                              ),
                              widget.data['accountType'] == "recruiter"
                                  ? const SizedBox()
                                  : Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(16.0),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey,
                                          width: 0.75,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(16.0),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          TextPoppins(
                                            text: "About",
                                            fontSize: 16,
                                            color: Colors.black,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          const SizedBox(
                                            height: 4.0,
                                          ),
                                          TextPoppins(
                                            text: widget.data['bio']['about'],
                                            fontSize: 12,
                                          ),
                                        ],
                                      ),
                                    ),
                              widget.data['accountType']
                                          .toString()
                                          .toLowerCase() ==
                                      "recruiter"
                                  ? const SizedBox()
                                  : const SizedBox(
                                      height: 16.0,
                                    ),
                              widget.data['accountType']
                                          .toString()
                                          .toLowerCase() ==
                                      "recruiter"
                                  ? const SizedBox()
                                  : GuestExperienceSection(
                                      data: widget.data['experience'],
                                    ),
                              const SizedBox(
                                height: 16.0,
                              ),
                              widget.data['accountType'] == "recruiter"
                                  ? const SizedBox()
                                  : GuestEducationSection(
                                      data: widget.data['education'],
                                    ),
                              const SizedBox(
                                height: 36.0,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      top: 36,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            icon: const Icon(
                              CupertinoIcons.arrow_left_circle,
                              color: Colors.white,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              if (!_scaffoldKey.currentState!.isEndDrawerOpen) {
                                _scaffoldKey.currentState?.openEndDrawer();
                                // Scaffold.of(context).openEndDrawer();
                              }
                            },
                            icon: SvgPicture.asset(
                              'assets/images/menu_icon.svg',
                              color: Constants.secondaryColor,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          });
  }
}

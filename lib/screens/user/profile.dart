import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:prohelp_app/components/button/custombutton.dart';
import 'package:prohelp_app/components/dialog/info_dialog.dart';
import 'package:prohelp_app/components/drawer/custom_drawer.dart';
import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/helper/constants/constants.dart';
import 'package:prohelp_app/helper/preference/preference_manager.dart';
import 'package:prohelp_app/helper/service/api_service.dart';
import 'package:prohelp_app/helper/state/state_manager.dart';
import 'package:prohelp_app/screens/reviews/reviews.dart';
import 'package:prohelp_app/screens/user/edits/manage_connections.dart';

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

  _likeUser() async {
    _controller.setLoading(true);
    Map _payload = {
      "guestId": "${widget.data['_id']}",
      "guestName": "${widget.data['bio']['fullname']}",
      "userId": "${widget.manager.getUser()['_id']}",
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
      if (element == widget.data['_id']) {
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
    for (var element in _controller.userData.value['connections']) {
      if (element == widget.data['_id']) {
        debugPrint("TRUE");
        setState(() {
          _isConnected = true;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _checkConnection();
    _checkLiked();
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
    // _checkConnection();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    // _checkConnection();

    return Scaffold(
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
                    child: Image.asset(
                      "assets/images/profile_bg.png",
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
                          child: Image.network(
                            widget.data['bio']['image'],
                            fit: BoxFit.cover,
                            width: Constants.avatarRadius + 36,
                            height: Constants.avatarRadius + 36,
                            errorBuilder: (context, error, stackTrace) =>
                                SvgPicture.asset(
                              "assets/images/personal_icon.svg",
                              width: Constants.avatarRadius + 40,
                              height: Constants.avatarRadius + 40,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
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
                          const SizedBox(height: 6.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Wrap(
                                children: [
                                  TextInter(
                                    text: "${widget.data['bio']['fullname']}"
                                        .capitalize,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ],
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
                                    color: _isLiked ? Colors.red : Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 5.0,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  RatingBar.builder(
                                    initialRating:
                                        "${widget.data['rating']}".contains(".")
                                            ? widget.data['rating']
                                            : (widget.data['rating'] ?? 0)
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
                                        "(${widget.data['reviews']?.length} reviews)",
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
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 8.0,
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 1.0),
                child: Column(
                  children: [
                    widget.data['accountType'] == "recruiter"
                        ? const SizedBox()
                        : Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              TextPoppins(
                                text:
                                    "${widget.data['address']['state']}, ${widget.data['address']['country']}"
                                        .capitalize,
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                              const SizedBox(
                                width: 5.0,
                              ),
                              const Icon(
                                Icons.circle,
                                size: 6,
                                color: Colors.black87,
                              ),
                              const SizedBox(
                                width: 5.0,
                              ),
                              TextPoppins(
                                text:
                                    " ${widget.data['connections']?.length} Connections",
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Constants.primaryColor,
                              ),
                              const SizedBox(
                                width: 6.0,
                              ),
                              InkWell(
                                onTap: () {
                                  Get.to(
                                    ManageConnections(
                                      caller: "guest",
                                      data: widget.data,
                                      connections: widget.data['connections'],
                                      manager: widget.manager,
                                    ),
                                    transition: Transition.cupertino,
                                  );
                                },
                                child: const Text(
                                  "See more",
                                  style: TextStyle(
                                    fontSize: 13,
                                    decoration: TextDecoration.underline,
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.w500,
                                    color: Constants.primaryColor,
                                  ),
                                ),
                              )
                            ],
                          ),
                    const SizedBox(
                      height: 8.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        for (var e = 0; e < widget.data['skills']?.length; e++)
                          Container(
                            padding: const EdgeInsets.all(2.0),
                            margin: const EdgeInsets.all(1.5),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            child: TextPoppins(
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: CustomButton(
                              borderRadius: 36.0,
                              paddingY: 1.0,
                              bgColor: Constants.primaryColor,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.visibility,
                                    size: 13,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(
                                    width: 2.0,
                                  ),
                                  TextPoppins(
                                    text: "Contact Info",
                                    fontSize: 11,
                                    color: Colors.white,
                                  )
                                ],
                              ),
                              borderColor: Colors.transparent,
                              foreColor: Colors.white,
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) {
                                    return SizedBox(
                                      height: 200,
                                      width: MediaQuery.of(context).size.width *
                                          0.98,
                                      child: InfoDialog(
                                        body: _isConnected
                                            ? ConnectedInfoContent(
                                                manager: widget.manager,
                                                guestData: widget.data,
                                              )
                                            : ContactInfoContent(
                                                manager: widget.manager,
                                                guestData: widget.data,
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
                                        const Icon(
                                          Icons.flag,
                                          size: 14,
                                        ),
                                        const SizedBox(
                                          width: 5.0,
                                        ),
                                        TextPoppins(
                                          text: "Report/Block",
                                          fontSize: 11,
                                        )
                                      ],
                                    ),
                                    borderColor: Colors.transparent,
                                    foreColor: Colors.black,
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (context) {
                                          return SizedBox(
                                            height: 200,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.98,
                                            child: InfoDialog(
                                              body: BlockReport(
                                                data: widget.data,
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
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    widget.data['accountType'] == "recruiter"
                                        ? CupertinoIcons.person_3_fill
                                        : Icons.edit_document,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(
                                    width: 5.0,
                                  ),
                                  TextPoppins(
                                    text: widget.data['accountType'] ==
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
                                        ManageConnections(
                                          caller: "guest",
                                          connections:
                                              widget.data['connections'],
                                          manager: widget.manager,
                                          data: widget.data,
                                        ),
                                        transition: Transition.cupertino,
                                      );
                                    }
                                  : () {
                                      showDialog(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (context) {
                                          return SizedBox(
                                            height: 200,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.98,
                                            child: InfoDialog(
                                              body: VerificationsContent(
                                                documents:
                                                    widget.data['documents'],
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
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                    widget.data['accountType'].toString().toLowerCase() ==
                            "recruiter"
                        ? const SizedBox()
                        : const SizedBox(
                            height: 16.0,
                          ),
                    widget.data['accountType'].toString().toLowerCase() ==
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
                        : GuestEducationSection(data: widget.data['education']),
                    const SizedBox(
                      height: 36.0,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 48,
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
                const SizedBox(
                  width: 16.0,
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
    );
  }
}

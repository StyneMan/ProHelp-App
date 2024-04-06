import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:prohelp_app/components/button/custombutton.dart';
import 'package:prohelp_app/components/dialog/info_dialog.dart';
import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/helper/constants/constants.dart';
import 'package:prohelp_app/helper/preference/preference_manager.dart';
import 'package:prohelp_app/helper/service/api_service.dart';
import 'package:prohelp_app/helper/state/state_manager.dart';
import 'package:prohelp_app/screens/user/profile_connected.dart';

class ProfessionalsConnectionCard extends StatefulWidget {
  var data;
  final int index;
  final String type;
  var connectionId;
  final PreferenceManager manager;
  ProfessionalsConnectionCard({
    Key? key,
    required this.data,
    required this.index,
    required this.manager,
    required this.connectionId,
    this.type = "",
  }) : super(key: key);

  @override
  State<ProfessionalsConnectionCard> createState() =>
      _ProfessionalsConnectionCardState();
}

class _ProfessionalsConnectionCardState
    extends State<ProfessionalsConnectionCard> {
  final _controller = Get.find<StateController>();

  bool _isLiked = false, triggerHire = false, _isConnected = false;
  double? _rating = 0.0;
  late PreferenceManager _prefManager;

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
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _checkLiked();
    _prefManager = PreferenceManager(context);
    // _checkConnection();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StateController>(builder: (controller) {
      return Card(
        elevation: 1.0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipOval(
                        child: Image.network(
                          '${widget.data['bio']['image']}',
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              SvgPicture.asset(
                            "assets/images/personal_icon.svg",
                            width: 64,
                            height: 64,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    width: 8.0,
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.person_2,
                              size: 18,
                            ),
                            const SizedBox(
                              width: 4.0,
                            ),
                            Expanded(
                              child: Text(
                                "${widget.data['bio']['firstname']} ${widget.data['bio']['middlename']} ${widget.data['bio']['lastname']}"
                                    .capitalize!,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 5.0,
                            ),
                          ],
                        ),
                        widget.data['accountType'] == "recruiter"
                            ? const SizedBox()
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.card_travel,
                                    size: 18,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(
                                    width: 4.0,
                                  ),
                                  TextPoppins(
                                    text: "${widget.data['profession']}"
                                        .capitalize,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ],
                              ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 18,
                              color: Colors.grey,
                            ),
                            const SizedBox(
                              width: 4.0,
                            ),
                            Expanded(
                              child: Text(
                                "${widget.data['address']['city']}, ${widget.data['address']['state']}"
                                    .capitalize!,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                        widget.data['accountType'] != "recruiter"
                            ? const SizedBox()
                            : Wrap(
                                children: [
                                  SizedBox(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.location_on_outlined),
                                        const SizedBox(
                                          width: 4.0,
                                        ),
                                        TextPoppins(
                                          text:
                                              "${widget.data['address']['city']} ${widget.data['address']['state']}, ${widget.data['address']['country']}"
                                                  .capitalize,
                                          fontSize: 13,
                                          color: Constants.primaryColor,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            RatingBar.builder(
                              initialRating: "${widget.data['rating']}"
                                      .contains(".")
                                  ? widget.data['rating']
                                  : (widget.data['rating'] ?? 0).toDouble() ??
                                      1.0,
                              minRating: 1,
                              direction: Axis.horizontal,
                              allowHalfRating: true,
                              ignoreGestures: true,
                              itemCount: 5,
                              itemSize: 24,
                              itemPadding:
                                  const EdgeInsets.symmetric(horizontal: 0.0),
                              itemBuilder: (context, _) => const Icon(
                                Icons.star,
                                size: 16,
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
                              fontSize: 11,
                            ),
                          ],
                        ),
                        // const SizedBox(height: 4.0),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _likeUser(),
                    icon: Icon(
                      _isLiked
                          ? CupertinoIcons.heart_fill
                          : CupertinoIcons.heart,
                      color: _isLiked ? Colors.red : Colors.grey,
                    ),
                  ),
                ],
              ),
              widget.data['accountType'] == "recruiter"
                  ? const SizedBox()
                  : const SizedBox(
                      height: 1.0,
                    ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  for (var e = 0; e < widget.data['skills']?.length; e++)
                    Container(
                      padding: const EdgeInsets.all(2.0),
                      margin: const EdgeInsets.all(1.5),
                      child: Chip(
                        label: TextPoppins(
                          text:
                              "${widget.data['skills'][e]['name'].toString().length > 16 ? widget.data['skills'][e]['name'].toString().substring(0, 15) : widget.data['skills'][e]['name']}"
                                  .capitalize,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(
                height: 8.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 2,
                    child: CustomButton(
                      bgColor: Colors.transparent,
                      child: TextPoppins(
                        text: widget.data['accountType'] == "recruiter"
                            ? "View"
                            : "View",
                        fontSize: 14,
                        color: Constants.primaryColor,
                      ),
                      borderColor: Constants.primaryColor,
                      foreColor: Constants.primaryColor,
                      onPressed: () {
                        Get.to(
                          UserProfileConnected(
                            manager: widget.manager,
                            triggerHire: triggerHire,
                            data: widget.data,
                          ),
                          transition: Transition.cupertino,
                        );
                      },
                      variant: "Outlined",
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    flex: 2,
                    child: CustomButton(
                      bgColor: Constants.primaryColor,
                      child: TextPoppins(
                        text: "Disconnect",
                        fontSize: 14,
                        color: Colors.white,
                      ),
                      borderColor: Constants.primaryColor,
                      foreColor: Colors.white,
                      onPressed: () {
                        Constants.showConfirmDialog(
                          context: context,
                          message:
                              "Are you sure you want to disconnect from this connection? ",
                          onPressed: () {
                            _disconnectRequest();
                          },
                        );
                      },
                      variant: "Filled",
                    ),
                  ),
                  widget.data['accountType'] == "recruiter"
                      ? const SizedBox()
                      : const SizedBox(
                          width: 8.0,
                        ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  _disconnectRequest() async {
    _controller.setLoading(true);
    Get.back();
    try {
      print("PAYJKD :: ${widget.data}");
      Map _payload = {
        'userId': widget.data['_id'],
      };

      final resp = await APIService().disconnectConnection(
        accessToken: widget.manager.getAccessToken(),
        email: widget.manager.getUser()['email'],
        payload: _payload,
        connectionId: widget.connectionId,
      );
      print("DISCONNECTION RESPONSE :::  ${resp.body}");

      _controller.setLoading(false);

      if (resp.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(resp.body);
        Constants.toast(map['message']);
      }
    } catch (e) {
      print("$e");
      _controller.setLoading(false);
    }
  }
}

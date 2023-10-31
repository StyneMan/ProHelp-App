import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:prohelp_app/components/button/custombutton.dart';
import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/helper/constants/constants.dart';
import 'package:prohelp_app/helper/preference/preference_manager.dart';
import 'package:prohelp_app/helper/service/api_service.dart';
import 'package:prohelp_app/helper/state/state_manager.dart';
import 'package:prohelp_app/screens/user/my_profile.dart';
import 'package:prohelp_app/screens/user/profile.dart';

class ProfessionalsCard extends StatefulWidget {
  var data;
  final int index;
  final String type;
  final PreferenceManager manager;
  ProfessionalsCard(
      {Key? key,
      required this.data,
      required this.index,
      required this.manager,
      this.type = ""})
      : super(key: key);

  @override
  State<ProfessionalsCard> createState() => _ProfessionalsCardState();
}

class _ProfessionalsCardState extends State<ProfessionalsCard> {
  final _controller = Get.find<StateController>();

  bool _isLiked = false, triggerHire = false, _isConnected = false;
  double? _rating = 0.0;

  _likeUser() async {
    _controller.setLoading(true);
    Map _payload = {
      "guestId": "${widget.data['id']}",
      "guestName": "${widget.data['bio']['fullname']}",
      "userId": "${widget.manager.getUser()['id']}",
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
      if (element == widget.data['id']) {
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
    for (var element in widget.manager.getUser()['connections']) {
      if (element == widget.data['id']) {
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
    _checkLiked();
    _checkConnection();
  }

  @override
  Widget build(BuildContext context) {
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
                                  text:
                                      "${widget.data['profession']}".capitalize,
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
                                    mainAxisAlignment: MainAxisAlignment.start,
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
                            initialRating:
                                "${widget.data['rating']}".contains(".")
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
                            text: "(${widget.data['reviews']?.length} reviews)",
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
                    _isLiked ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
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
                  flex: 4,
                  child: CustomButton(
                    bgColor: Colors.transparent,
                    child: TextPoppins(
                      text: "View Profile",
                      fontSize: 16,
                      color: Constants.primaryColor,
                    ),
                    borderColor: Constants.primaryColor,
                    foreColor: Constants.primaryColor,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => widget.data['id'] ==
                                  widget.manager.getUser()['id']
                              ? MyProfile(
                                  manager: widget.manager,
                                )
                              : UserProfile(
                                  manager: widget.manager,
                                  triggerHire: triggerHire,
                                  data: widget.data,
                                ),
                        ),
                      );
                    },
                    variant: "Outlined",
                  ),
                ),
                widget.data['accountType'] == "recruiter"
                    ? const SizedBox()
                    : const SizedBox(
                        width: 8.0,
                      ),
                widget.data['accountType'] == "recruiter" ||
                        widget.manager.getUser()['accountType'] != "recruiter"
                    ? const SizedBox()
                    : Expanded(
                        flex: 2,
                        child: CustomButton(
                          bgColor: Constants.primaryColor,
                          child: TextPoppins(
                            text: "Hire ${widget.type}",
                            fontSize: 16,
                            color: Colors.white,
                          ),
                          borderColor: Colors.transparent,
                          foreColor: Constants.secondaryColor,
                          onPressed: () {
                            setState(() {
                              triggerHire = true;
                            });

                            Future.delayed(const Duration(milliseconds: 500),
                                () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => widget.data['id'] ==
                                          widget.manager.getUser()['id']
                                      ? MyProfile(
                                          manager: widget.manager,
                                        )
                                      : UserProfile(
                                          manager: widget.manager,
                                          triggerHire: triggerHire,
                                          data: widget.data,
                                        ),
                                ),
                              );
                            });
                          },
                          variant: "Filled",
                        ),
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

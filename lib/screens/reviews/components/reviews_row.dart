import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:prohelp_app/components/inputfield/textarea.dart';
import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/helper/constants/constants.dart';
import 'package:prohelp_app/helper/preference/preference_manager.dart';
import 'package:prohelp_app/helper/service/api_service.dart';
import 'package:prohelp_app/helper/state/state_manager.dart';

class ReviewRow extends StatelessWidget {
  final PreferenceManager manager;
  var data, userData;
  ReviewRow({
    Key? key,
    required this.manager,
    required this.data,
    required this.userData,
  }) : super(key: key);

  final _replyController = TextEditingController();
  final _controller = Get.find<StateController>();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.0,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipOval(
                  child: Image.network(
                    data['reviewer']['photo'],
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
                          TextPoppins(
                            text: "${data['reviewer']['name']}".capitalize,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          TextInter(
                            text:
                                " ${data['reviewer']['id'] == manager.getUser()['id'] ? "(You)" : ""}",
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 2.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          RatingBar.builder(
                            initialRating: "${data['rating']}".contains(".")
                                ? data['rating']
                                : data['rating'].toDouble(),
                            minRating: 1,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            ignoreGestures: true,
                            itemCount: 5,
                            itemSize: 19,
                            itemPadding:
                                const EdgeInsets.symmetric(horizontal: 0.0),
                            itemBuilder: (context, _) => const Icon(
                              Icons.star,
                              size: 18,
                              color: Colors.amber,
                            ),
                            onRatingUpdate: (rating) {
                              debugPrint("$rating");
                            },
                          ),
                          const SizedBox(width: 1.0),
                          Text(
                            "(${data['rating']}/5.0)",
                            style: const TextStyle(
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 10.0),
                          Text(
                            DateFormat('dd/MM/yy')
                                .format(DateTime.parse(data['createdAt'])),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 4.0,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.5,
                        child: Wrap(
                          children: [
                            TextPoppins(
                              text: "${data['comment']}",
                              fontSize: 13,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                manager.getUser()['id'] == data['reviewer']['id'] ||
                        (manager.getUser()['id'] == data['userId'] &&
                            (data['reply'] == null ||
                                data['reply'].toString().isEmpty ||
                                data['reply'].toString() == "{}"))
                    ? PopupMenuButton(
                        child: const Icon(
                          CupertinoIcons.ellipsis_vertical,
                        ),
                        onSelected: (result) {
                          if (result == 0) {
                            showCupertinoDialog(
                              context: context,
                              builder: (context) => CupertinoAlertDialog(
                                title: TextPoppins(
                                  text: "Take Down Review",
                                  fontSize: 18,
                                ),
                                content: SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.96,
                                  height: 100,
                                  child: Column(
                                    children: [
                                      const SizedBox(
                                        height: 24,
                                      ),
                                      RichText(
                                        textAlign: TextAlign.center,
                                        text: TextSpan(
                                          text: "I ",
                                          style: const TextStyle(
                                            color: Colors.black45,
                                            fontSize: 16,
                                          ),
                                          children: [
                                            TextSpan(
                                              text:
                                                  "${manager.getUser()['bio']['firstname']} ${manager.getUser()['bio']['middlename']} ${manager.getUser()['bio']['lastname']}"
                                                      .capitalize,
                                              style: const TextStyle(
                                                color: Constants.primaryColor,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 18,
                                              ),
                                            ),
                                            const TextSpan(
                                              text: " confirm that I want to ",
                                              style: TextStyle(
                                                color: Colors.black45,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const TextSpan(
                                              text: "delete",
                                              style: TextStyle(
                                                color: Colors.red,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 18,
                                              ),
                                            ),
                                            const TextSpan(
                                              text: " my review of ",
                                              style: TextStyle(
                                                color: Colors.black45,
                                                fontSize: 16,
                                              ),
                                            ),
                                            TextSpan(
                                              text:
                                                  "${userData['bio']['firstname']} ${manager.getUser()['bio']['middlename']} ${manager.getUser()['bio']['lastname']}"
                                                      .capitalize,
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 18,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                actions: [
                                  Padding(
                                    padding: const EdgeInsets.all(7.0),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.white54,
                                          foregroundColor:
                                              Constants.primaryColor),
                                      child: TextRoboto(
                                        text: "Cancel",
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        // Navigator.pop(context);
                                        // Get.back();
                                        _removeReview();
                                      },
                                      child: TextRoboto(
                                        text: "Take Down",
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            showBarModalBottomSheet(
                              expand: true,
                              context: context,
                              backgroundColor: Colors.white,
                              builder: (context) => Container(
                                padding: const EdgeInsets.all(16.0),
                                child: ListView(
                                  children: [
                                    TextPoppins(
                                      text: "Reply ${data['reviewer']['name']}"
                                          .capitalize,
                                      fontSize: 21,
                                      align: TextAlign.center,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    const SizedBox(
                                      height: 16.0,
                                    ),
                                    Form(
                                      key: _formKey,
                                      child: ListView(
                                        shrinkWrap: true,
                                        children: [
                                          Text(
                                            "Note that your reply to ${data['reviewer']['name'].toString().capitalize} as well as your profile will be available to the public for their review and decision making",
                                            textAlign: TextAlign.justify,
                                          ),
                                          const SizedBox(
                                            height: 16,
                                          ),
                                          CustomTextArea(
                                            hintText: "Write your reply",
                                            maxLength: 200,
                                            maxLines: 10,
                                            autoFocus: true,
                                            onChanged: (val) {},
                                            controller: _replyController,
                                            validator: (value) {
                                              if (value == null ||
                                                  value.toString().isEmpty) {
                                                return "Your reply is required";
                                              }
                                              return null;
                                            },
                                            inputType: TextInputType.text,
                                            capitalization:
                                                TextCapitalization.sentences,
                                          ),
                                          const SizedBox(
                                            height: 16.0,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: ElevatedButton(
                                                  onPressed: _controller
                                                          .isLoading.value
                                                      ? null
                                                      : () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                  child: TextRoboto(
                                                    text: "Cancel",
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: ElevatedButton(
                                                  onPressed: _controller
                                                          .isLoading.value
                                                      ? null
                                                      : () {
                                                          // Navigator.pop(context);
                                                          _reply();
                                                        },
                                                  child: TextRoboto(
                                                    text: "Reply",
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              topControl: ClipOval(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(
                                        16,
                                      ),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.close,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                        itemBuilder: (BuildContext bc) {
                          return manager.getUser()['id'] ==
                                  data['reviewer']['id']
                              ? [
                                  const PopupMenuItem(
                                    child: Text("Delete"),
                                    value: 0,
                                  )
                                ]
                              : (manager.getUser()['id'] == data['userId'] &&
                                      (data['reply'] == null ||
                                          data['reply'].toString().isEmpty ||
                                          data['reply'].toString() == "{}"))
                                  ? [
                                      const PopupMenuItem(
                                        child: Text("Reply"),
                                        value: 1,
                                      )
                                    ]
                                  : [];
                        },
                      )
                    : const SizedBox(),
              ],
            ),
            const SizedBox(
              height: 10.0,
            ),
            data['reply'] == null
                ? const SizedBox()
                : Container(
                    color: Colors.grey.shade200,
                    padding: const EdgeInsets.all(16.0),
                    child: Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const SizedBox(
                            height: 2.0,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "Reply by ${userData['bio']['firstname'].toString().capitalize} ${userData['bio']['lastname'].toString().capitalize} on ",
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                DateFormat('dd/MM/yy').format(
                                    DateTime.parse(data['reply']['createdAt'])),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 4.0,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.5,
                            child: Wrap(
                              children: [
                                TextPoppins(
                                  text: "${data['reply']['message']}",
                                  fontSize: 13,
                                  align: TextAlign.end,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
          ],
        ),
      ),
    );
  }

  _removeReview() async {
    // _controller.setLoading(true);
    Map _payload = {
      "userId": data['userId'],
      "reviewerId": data['reviewer']['id'],
      "reviewId": data['_id'],
      "rating": data['rating']
    };

    // debugPrint("RES REVIEW >> $_payload");

    try {
      final res = await APIService().deleteReview(
        accessToken: manager.getAccessToken(),
        email: manager.getUser()['email'],
        payload: _payload,
      );

      _controller.setLoading(false);
      // debugPrint("RES REVIEW DEL >> ${res.body}");

      if (res.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(res.body);
        Constants.toast(map['message']);
      } else {
        _controller.setLoading(false);
      }
    } catch (e) {
      _controller.setLoading(false);
      debugPrint("ERROR ?>> ${e.toString()}");
    }
  }

  _reply() async {
    // Get.back();
    _controller.setLoading(true);
    Map _payload = {
      "replyBody": {
        "message": _replyController.text,
        "createdAt": DateTime.now().toIso8601String()
      },
      "reviewerId": data['reviewer']['id'],
      "reviewId": data['_id'],
      "rating": data['rating']
    };

    try {
      final res = await APIService().replyReview(
          accessToken: manager.getAccessToken(),
          email: manager.getUser()['email'],
          payload: _payload);

      _controller.setLoading(false);
      debugPrint("REPLY REVIEW RESPONSE >> ${res.body}");

      if (res.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(res.body);
        Constants.toast(map['message']);

        //
      } else {
        Map<String, dynamic> map = jsonDecode(res.body);
        Constants.toast(map['message']);
        // Get.back();
      }
    } catch (e) {
      debugPrint("ERROR ?>> ${e.toString()}");
      _controller.setLoading(false);
    }
  }
}

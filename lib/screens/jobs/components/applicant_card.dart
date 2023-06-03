import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:prohelp_app/components/button/custombutton.dart';
import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/helper/constants/constants.dart';
import 'package:prohelp_app/helper/preference/preference_manager.dart';
import 'package:prohelp_app/helper/service/api_service.dart';
import 'package:prohelp_app/helper/state/state_manager.dart';
import 'package:prohelp_app/screens/jobs/apply_job.dart';
import 'package:prohelp_app/screens/jobs/view_application.dart';
import 'package:prohelp_app/screens/jobs/viewjob.dart';
import 'package:timeago/timeago.dart' as timeago;

class ApplicantCard extends StatefulWidget {
  var data;
  final int index;
  final String type;
  final PreferenceManager manager;
  ApplicantCard(
      {Key? key,
      required this.data,
      required this.index,
      required this.manager,
      this.type = ""})
      : super(key: key);

  @override
  State<ApplicantCard> createState() => _ApplicantCardState();
}

class _ApplicantCardState extends State<ApplicantCard> {
  final _controller = Get.find<StateController>();

  bool _isSaved = false, triggerHire = false, _isApplied = false;
  double? _rating = 0.0;

  // _saveJob() async {
  //   _controller.setLoading(true);
  //   Map _payload = {
  //     "jobId": "${widget.data['id']}",
  //     "userId": "${widget.manager.getUser()['_id']}",
  //   };
  //   try {
  //     final resp = await APIService().saveJob(_payload,
  //         widget.manager.getAccessToken(), widget.manager.getUser()['email']);
  //     debugPrint("SAVE JOB RESPONSE >> ${resp.body}");
  //     _controller.setLoading(false);
  //     if (resp.statusCode == 200) {
  //       Map<String, dynamic> map = jsonDecode(resp.body);
  //       Constants.toast(map['message']);
  //       if (map['message'].toString().contains("unliked")) {
  //         setState(() {
  //           _isSaved = false;
  //         });
  //       } else {
  //         setState(() {
  //           _isSaved = true;
  //         });
  //       }
  //       _controller.userData.value = map['data'];
  //       String userStr = jsonEncode(map['data']);
  //       widget.manager.setUserData(userStr);
  //     }
  //   } catch (e) {
  //     _controller.setLoading(false);
  //     debugPrint("ERROR LIKING >>> $e");
  //   }
  // }

  _checkSaved() {
    for (var element in widget.manager.getUser()['savedJobs']) {
      if (element == widget.data['id']) {
        setState(() {
          _isSaved = true;
        });
      } else {
        setState(() {
          _isSaved = false;
        });
      }
    }
  }

  _checkApplied() {
    // debugPrint(
    //     "JOB APP => ${widget.manager.getUser()['myJobApplications']}  CURR ID => ${widget.data['id']}");
    for (var element in widget.manager.getUser()['myJobApplications']) {
      if (element == widget.data['id']) {
        // debugPrint("YESSS >>> ${element},  ${widget.data['id']}");
        setState(() {
          _isApplied = true;
        });
      } else {
        setState(() {
          _isApplied = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // _checkApplied();
    // _checkSaved();
  }

  String timeUntil(DateTime date) {
    return timeago.format(date, locale: "en", allowFromNow: true);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.0,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
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
                        widget.data['applicant']['photo'],
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
                          TextPoppins(
                            text: "${widget.data['applicant']['name']}"
                                .capitalize,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          const SizedBox(
                            width: 3.0,
                          ),
                        ],
                      ),
                      TextPoppins(
                        text:
                            "Applied on ${DateFormat('dd/MM/yyyy').format(DateTime.parse(widget.data['createdAt']))} (${timeUntil(DateTime.parse("${widget.data['createdAt']}"))})"
                                .replaceAll("about", "")
                                .replaceAll("minute", "min"),
                        fontSize: 13,
                      ),
                      // TextPoppins(
                      //   text:
                      //       "${widget.data['Applied']} (${widget.data['workplaceType']})"
                      //           .capitalize,
                      //   fontSize: 14,
                      // ),
                    ],
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
                Expanded(
                  flex: 2,
                  child: CustomButton(
                    bgColor: Colors.transparent,
                    child: TextPoppins(
                      text: "View",
                      fontSize: 16,
                      color: Constants.primaryColor,
                    ),
                    borderColor: Constants.primaryColor,
                    foreColor: Constants.primaryColor,
                    onPressed: () {
                      Get.to(
                        ViewApplication(
                          manager: widget.manager,
                          data: widget.data,
                        ),
                        transition: Transition.cupertino,
                      );
                    },
                    variant: "Outlined",
                  ),
                ),
                const SizedBox(
                  width: 8.0,
                ),
                widget.manager.getUser()['accountType'] == "recruiter" &&
                        widget.data['job']['recruiter']['id'] ==
                            widget.manager.getUser()['_id']
                    ? Expanded(
                        flex: 2,
                        child: CustomButton(
                          bgColor: widget.data['status'] != "submitted"
                              ? Colors.grey
                              : Constants.primaryColor,
                          child: widget.data['job']['recruiter']['id'] ==
                                  widget.manager.getUser()['_id']
                              ? TextPoppins(
                                  text: widget.data['status'] == "submitted"
                                      ? "Accept"
                                      : "${widget.data['status']}".capitalize,
                                  fontSize: 16,
                                  color: Colors.white,
                                )
                              : const SizedBox(),
                          borderColor: Colors.transparent,
                          foreColor: Constants.secondaryColor,
                          onPressed: widget.data['status'] != "submitted"
                              ? null
                              : () {
                                  showCupertinoDialog(
                                    context: context,
                                    builder: (context) => CupertinoAlertDialog(
                                      title: TextPoppins(
                                        text: "Accept Application",
                                        fontSize: 18,
                                      ),
                                      content: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.96,
                                        height: 130,
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
                                                  color: Colors.black,
                                                ),
                                                children: [
                                                  TextSpan(
                                                    text:
                                                        "${widget.manager.getUser()['bio']['fullname']}"
                                                            .capitalize,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      color: Constants
                                                          .primaryColor,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  const TextSpan(
                                                    text:
                                                        " confirm that I want to ",
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  const TextSpan(
                                                    text: " ACCEPT ",
                                                    style: TextStyle(
                                                      color: Colors.green,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text:
                                                        "${widget.data['applicant']['name']}'s"
                                                            .capitalize,
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 17,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  const TextSpan(
                                                    text:
                                                        " application.\nOnce accepted, others will be automatically declined.",
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w500,
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
                                          padding: const EdgeInsets.all(8.0),
                                          child: ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
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
                                              Navigator.pop(context);
                                              _acceptApplication();
                                            },
                                            child: TextRoboto(
                                              text: "Accept",
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                          variant: "Filled",
                        ),
                      )
                    : const SizedBox(),
                const SizedBox(
                  width: 8.0,
                ),
                Expanded(
                  flex: 2,
                  child: CustomButton(
                    bgColor: Colors.green,
                    child: TextPoppins(
                      text: "Contact",
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    borderColor: Colors.transparent,
                    foreColor: Constants.secondaryColor,
                    onPressed: widget.data['status'] != "accepting"
                        ? null
                        : widget.data['job']['recruiter']['id'] !=
                                widget.manager.getUser()['_id']
                            ? () {
                                //Apply for job here
                                Get.to(
                                  ApplyJob(
                                    manager: widget.manager,
                                    data: widget.data,
                                  ),
                                  transition: Transition.cupertino,
                                );
                              }
                            : () {
                                showBarModalBottomSheet(
                                  expand: false,
                                  context: context,
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
                                  backgroundColor: Colors.white,
                                  builder: (context) => SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.86,
                                    // child: AddJobForm(
                                    //   manager: manager,
                                    // ),
                                  ),
                                );

                                // setState(() {
                                //   triggerHire = true;
                                // });

                                // Future.delayed(const Duration(milliseconds: 500),
                                //     () {
                                //   Navigator.push(
                                //     context,
                                //     MaterialPageRoute(
                                //       builder: (context) => widget.data['_id'] ==
                                //               widget.manager.getUser()['_id']
                                //           ? MyProfile(
                                //               manager: widget.manager,
                                //             )
                                //           : UserProfile(
                                //               manager: widget.manager,
                                //               triggerHire: triggerHire,
                                //               data: widget.data,
                                //             ),
                                //     ),
                                //   );
                                // });
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

  _deleteJob() async {
    _controller.setLoading(true);
    try {
      final resp = await APIService().deleteJob(
          accessToken: widget.manager.getAccessToken(),
          email: widget.manager.getUser()['email'],
          jobId: widget.data['_id']);
      _controller.setLoading(false);
      debugPrint("DEL JOBS RESPONSE ==> ${resp.body}");
      if (resp.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(resp.body);
        Constants.toast(map['message']);
        _controller.onInit();
      }
    } catch (e) {
      _controller.setLoading(false);
    }
  }

  _acceptApplication() async {
    _controller.setLoading(true);
    Map _payload = {
      "applicationId": widget.data['_id'],
      "jobId": widget.data['jobId']
    };
    try {
      final resp = await APIService().acceptJobApplication(
        _payload,
        widget.manager.getAccessToken(),
        widget.manager.getUser()['email'],
      );

      _controller.setLoading(false);
      debugPrint("ACCEPT JOB APPLICATION RESPONSE ==> ${resp.body}");
      if (resp.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(resp.body);
        Constants.toast(map['message']);
        _controller.onInit();
      }
    } catch (e) {
      _controller.setLoading(false);
    }
  }
}

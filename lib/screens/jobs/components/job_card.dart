import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:prohelp_app/components/button/custombutton.dart';
import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/helper/constants/constants.dart';
import 'package:prohelp_app/helper/preference/preference_manager.dart';
import 'package:prohelp_app/helper/service/api_service.dart';
import 'package:prohelp_app/helper/state/state_manager.dart';
import 'package:prohelp_app/screens/account/components/wallet.dart';
import 'package:prohelp_app/screens/jobs/apply_job.dart';
import 'package:prohelp_app/screens/jobs/viewjob.dart';
import 'package:timeago/timeago.dart' as timeago;

class JobCard extends StatefulWidget {
  var data;
  final int index;
  final String type;
  final PreferenceManager manager;
  JobCard(
      {Key? key,
      required this.data,
      required this.index,
      required this.manager,
      this.type = ""})
      : super(key: key);

  @override
  State<JobCard> createState() => _JobCardState();
}

class _JobCardState extends State<JobCard> {
  final _controller = Get.find<StateController>();

  bool _isSaved = false, triggerHire = false, _isApplied = false;
  double? _rating = 0.0;

  _saveJob() async {
    _controller.setLoading(true);
    Map _payload = {
      "jobId": "${widget.data['id']}",
      "userId": "${widget.manager.getUser()['id']}",
    };
    try {
      final resp = await APIService().saveJob(_payload,
          widget.manager.getAccessToken(), widget.manager.getUser()['email']);
      debugPrint("SAVE JOB RESPONSE >> ${resp.body}");
      _controller.setLoading(false);
      if (resp.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(resp.body);
        Constants.toast(map['message']);
        if (map['message'].toString().contains("unliked")) {
          setState(() {
            _isSaved = false;
          });
        } else {
          setState(() {
            _isSaved = true;
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
    for (var element in _controller.myJobsApplied.value) {
      if (element['jobId'] == widget.data['id']) {
        setState(() {
          _isApplied = true;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _checkApplied();
    _checkSaved();
  }

  String timeUntil(DateTime date) {
    return timeago.format(date, locale: "en", allowFromNow: true);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.0,
      child: Padding(
        padding: const EdgeInsets.all(9.0),
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
                        widget.data['recruiter']['photo'],
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
                            text: "${widget.data['jobTitle']}".capitalize,
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
                            "${widget.data['company']} (${widget.data['workplaceType']})"
                                .capitalize,
                        fontSize: 14,
                      ),
                      Wrap(
                        children: [
                          SizedBox(
                            child: TextPoppins(
                              text:
                                  "${widget.data['jobLocation']['state']} state, ${widget.data['jobLocation']['country']}"
                                      .capitalize,
                              fontSize: 13,
                              color: Constants.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: widget.data['recruiter']['id'] ==
                          widget.manager.getUser()['id']
                      ? () {
                          showCupertinoDialog(
                            context: context,
                            builder: (context) => CupertinoAlertDialog(
                              title: TextPoppins(
                                text: "Delete Job",
                                fontSize: 18,
                              ),
                              content: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.96,
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
                                          color: Colors.black,
                                        ),
                                        children: [
                                          TextSpan(
                                            text:
                                                "${widget.manager.getUser()['bio']['firstname']} ${widget.manager.getUser()['bio']['lastname']}"
                                                    .capitalize,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Constants.primaryColor,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const TextSpan(
                                            text: " confirm that I want to ",
                                            style: TextStyle(
                                              color: Colors.black,
                                            ),
                                          ),
                                          const TextSpan(
                                            text: " delete ",
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const TextSpan(
                                            text: " this job. ",
                                            style: TextStyle(
                                              color: Colors.black,
                                            ),
                                          ),
                                          const TextSpan(
                                            text:
                                                "\nRemember action can not be reversed. ",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w500,
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
                                      _deleteJob();
                                    },
                                    child: TextRoboto(
                                      text: "Delete Job",
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      : () {
                          _saveJob();
                        },
                  icon: widget.data['recruiter']['id'] ==
                          widget.manager.getUser()['id']
                      ? const Icon(
                          CupertinoIcons.delete_simple,
                          color: Colors.grey,
                        )
                      : Icon(
                          _isSaved
                              ? CupertinoIcons.bookmark_fill
                              : CupertinoIcons.bookmark,
                          color:
                              _isSaved ? Constants.primaryColor : Colors.grey,
                        ),
                ),
              ],
            ),
            const SizedBox(
              height: 5.0,
            ),
            widget.data['jobStatus'] == 'accepting'
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.track_changes_rounded,
                        color: Constants.primaryColor,
                        size: 32,
                      ),
                      const SizedBox(
                        width: 4.0,
                      ),
                      TextPoppins(text: "Actively recruiting", fontSize: 13),
                      const SizedBox(
                        width: 4.0,
                      ),
                      const TextInter(
                        text: "|",
                        fontSize: 18,
                        color: Constants.primaryColor,
                      ),
                      const SizedBox(
                        width: 4.0,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.36,
                        child: TextPoppins(
                          text:
                              "Posted ${timeUntil(DateTime.parse("${widget.data['createdAt']}"))}"
                                  .replaceAll("about", "")
                                  .replaceAll("minute", "min"),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  )
                : const SizedBox(),
            const SizedBox(
              height: 16.0,
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
                      text: "View Job",
                      fontSize: 16,
                      color: Constants.primaryColor,
                    ),
                    borderColor: Constants.primaryColor,
                    foreColor: Constants.primaryColor,
                    onPressed: () {
                      Get.to(
                        ViewJob(
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
                widget.manager.getUser()['accountType'] == "recruiter"
                    ? Expanded(
                        flex: 4,
                        child: CustomButton(
                          bgColor: widget.data['jobStatus'] != "accepting"
                              ? Colors.grey
                              : Constants.primaryColor,
                          child: widget.data['recruiter']['id'] ==
                                  widget.manager.getUser()['id']
                              ? TextPoppins(
                                  text: widget.data['jobStatus'] != "accepting"
                                      ? "Closed"
                                      : "Close",
                                  fontSize: 16,
                                  color: Colors.white,
                                )
                              : TextPoppins(
                                  text: widget.data['jobStatus'] != "accepting"
                                      ? "Closed"
                                      : _isApplied
                                          ? "Applied"
                                          : "Apply",
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                          borderColor: Colors.transparent,
                          foreColor: Constants.secondaryColor,
                          onPressed: widget.data['jobStatus'] != "accepting"
                              ? null
                              : () {
                                  showCupertinoDialog(
                                    context: context,
                                    builder: (context) => CupertinoAlertDialog(
                                      title: TextPoppins(
                                        text: "Close Job",
                                        fontSize: 18,
                                      ),
                                      content: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.96,
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
                                                    text: " close ",
                                                    style: TextStyle(
                                                      color: Constants.golden,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  const TextSpan(
                                                    text: " this job. ",
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  const TextSpan(
                                                    text:
                                                        "\nRemember action can not be reversed. ",
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
                                              _closeJob();
                                            },
                                            child: TextRoboto(
                                              text: "Close Job",
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
                widget.data['recruiter']['id'] == widget.manager.getUser()['id']
                    ? const SizedBox()
                    : Expanded(
                        flex: 2,
                        child: CustomButton(
                          bgColor: widget.data['jobStatus'] != "accepting" ||
                                  _isApplied
                              ? Colors.grey
                              : Constants.primaryColor,
                          child: TextPoppins(
                            text: widget.data['jobStatus'] != "accepting"
                                ? "Closed"
                                : _isApplied
                                    ? "Applied"
                                    : "Apply",
                            fontSize: 16,
                            color: Colors.white,
                          ),
                          borderColor: Colors.transparent,
                          foreColor: Constants.secondaryColor,
                          onPressed: widget.data['jobStatus'] != "accepting" ||
                                  _isApplied
                              ? null
                              : widget.data['recruiter']['id'] !=
                                      widget.manager.getUser()['id']
                                  ? (_controller.userData.value['wallet']
                                                  ['balance'] ??
                                              0) >=
                                          200
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
                                          //Show out of coins alert here
                                          Constants.toast(
                                              "You are out of coins. Topup to continue posting and connecting!");
                                          Get.to(
                                            MyWallet(manager: widget.manager),
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
                                                borderRadius:
                                                    BorderRadius.circular(
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
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.86,
                                          // child: AddJobForm(
                                          //   manager: manager,
                                          // ),
                                        ),
                                      );
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
          jobId: widget.data['id']);
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

  _closeJob() async {
    _controller.setLoading(true);
    Map _payload = {"jobStatus": "closed"};
    try {
      final resp = await APIService().updateJob(
        accessToken: widget.manager.getAccessToken(),
        email: widget.manager.getUser()['email'],
        jobId: widget.data['id'],
        payload: _payload,
      );

      _controller.setLoading(false);
      debugPrint("CLOSE JOB RESPONSE ==> ${resp.body}");
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

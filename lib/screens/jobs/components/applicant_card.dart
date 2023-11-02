import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:prohelp_app/components/button/custombutton.dart';
import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/helper/constants/constants.dart';
import 'package:prohelp_app/helper/preference/preference_manager.dart';
import 'package:prohelp_app/helper/service/api_service.dart';
import 'package:prohelp_app/helper/state/state_manager.dart';
import 'package:prohelp_app/screens/jobs/view_application.dart';
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

  bool triggerHire = false;

  @override
  void initState() {
    super.initState();
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
                    ],
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
                            widget.manager.getUser()['id']
                    ? Expanded(
                        flex: 2,
                        child: CustomButton(
                          bgColor: widget.data['status'] != "submitted"
                              ? Colors.grey
                              : Constants.primaryColor,
                          child: TextPoppins(
                            text: widget.data['status'] == "submitted"
                                ? "Accept"
                                : "${widget.data['status']}".capitalize,
                            fontSize: 16,
                            color: Colors.white,
                          ),
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
                    bgColor: Color(0xFF4CAF50),
                    child: TextPoppins(
                      text: "Contact",
                      fontSize: 16,
                      color: Colors.white,
                    ),
                    borderColor: Colors.transparent,
                    foreColor: Constants.secondaryColor,
                    onPressed: () {
                      print("DATA RIOS :: ${widget.data['id']}");
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

  _acceptApplication() async {
    _controller.setLoading(true);
    debugPrint("DATA RIOS :: ${widget.data}");
    Map _payload = {
      "applicationId": widget.data['id'],
      "jobId": widget.data['jobId']
    };
    try {
      final resp = await APIService().acceptJobApplication(
        _payload,
        widget.manager.getAccessToken(),
        widget.manager.getUser()['email'],
      );

      _controller.setLoading(false);
      Navigator.pop(context);
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

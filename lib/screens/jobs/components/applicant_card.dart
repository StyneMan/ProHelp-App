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
import 'package:url_launcher/url_launcher.dart';

class ApplicantCard extends StatefulWidget {
  var data;
  final int index;
  final String type;
  final PreferenceManager manager;
  ApplicantCard({
    Key? key,
    required this.data,
    required this.index,
    required this.manager,
    this.type = "",
  }) : super(key: key);

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

  // String timeUntil(DateTime date) {
  //   return timeago.format(date, locale: "en", allowFromNow: true);
  // }

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
                        widget.data['applicant']['bio']['image'],
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
                            text:
                                "${widget.data['applicant']['bio']['firstname']} ${widget.data['applicant']['bio']['lastname']}"
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
                            "Applied on ${DateFormat('dd/MM/yyyy').format(DateTime.parse(widget.data['createdAt']))} (${Constants.timeUntil(DateTime.parse("${widget.data['createdAt']}"))})"
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
                      fontSize: 13,
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
                Expanded(
                  flex: 2,
                  child: CustomButton(
                    bgColor: const Color(0xFF4CAF50),
                    child: TextPoppins(
                      text: "Contact",
                      fontSize: 13,
                      color: Colors.white,
                    ),
                    borderColor: Colors.transparent,
                    foreColor: Constants.secondaryColor,
                    onPressed: () {
                      _makePhoneCall(
                          "${widget.data['applicant']['bio']['phone']}");
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

  _makePhoneCall(String phoneNumber) {
    // Use `Uri` to ensure that `phoneNumber` is properly URL-encoded.
    // Just using 'tel:$phoneNumber' would create invalid URLs in some cases,
    // such as spaces in the input, which would cause `launch` to fail on some
    // platforms.
    canLaunch('tel:123').then((bool result) async {
      final Uri launchUri = Uri(
        scheme: 'tel',
        path: phoneNumber,
      );
      await launch(launchUri.toString());
    });
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

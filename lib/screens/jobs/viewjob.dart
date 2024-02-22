import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:loading_overlay_pro/loading_overlay_pro.dart';
import 'package:prohelp_app/components/button/roundedbutton.dart';
import 'package:prohelp_app/components/drawer/custom_drawer.dart';
import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/helper/constants/constants.dart';
import 'package:prohelp_app/helper/preference/preference_manager.dart';
import 'package:prohelp_app/helper/service/api_service.dart';
import 'package:prohelp_app/helper/state/state_manager.dart';
import 'package:prohelp_app/screens/jobs/applications.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'apply_job.dart';

class ViewJob extends StatefulWidget {
  final PreferenceManager manager;
  var data;
  ViewJob({
    Key? key,
    required this.manager,
    required this.data,
  }) : super(key: key);

  @override
  State<ViewJob> createState() => _ViewJobState();
}

class _ViewJobState extends State<ViewJob> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _controller = Get.find<StateController>();
  bool _isApplied = false, _isSaved = false;
  bool _isCountLoaded = false;
  int _applicationCount = 0;

  _checkApplied() {
    for (var element in _controller.myJobsApplied.value) {
      if (element['jobId'] == widget.data['id']) {
        setState(() {
          _isApplied = true;
        });
      }
    }
  }

  _getApplications() async {
    try {
      final resp = await APIService().getCurrentJobApplications(
        email: widget.manager.getUser()['email'],
        jobId: widget.data['id'],
      );

      debugPrint("RJNK ${resp.body}");
      Map<String, dynamic> map = jsonDecode(resp.body);
      setState(() {
        _isCountLoaded = true;
        _applicationCount = map['docs']?.length;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    _checkApplied();
    _checkSaved();
    _getApplications();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String timeUntil(DateTime date) {
    return timeago.format(date, locale: "en", allowFromNow: true);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => LoadingOverlayPro(
        isLoading: _controller.isLoading.value,
        backgroundColor: Colors.black45,
        progressIndicator: const CircularProgressIndicator.adaptive(),
        child: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            elevation: 0.0,
            foregroundColor: Constants.secondaryColor,
            backgroundColor: Constants.primaryColor,
            automaticallyImplyLeading: false,
            leading: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 16.0,
                ),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Icon(
                    CupertinoIcons.arrow_left_circle,
                  ),
                ),
                const SizedBox(
                  width: 4.0,
                ),
              ],
            ),
            title: TextPoppins(
              text: "Job information".toUpperCase(),
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Constants.secondaryColor,
            ),
            centerTitle: true,
            actions: [
              IconButton(
                onPressed: () {
                  if (!_scaffoldKey.currentState!.isEndDrawerOpen) {
                    _scaffoldKey.currentState!.openEndDrawer();
                  }
                },
                icon: SvgPicture.asset(
                  'assets/images/menu_icon.svg',
                  color: Constants.secondaryColor,
                ),
              ),
            ],
          ),
          endDrawer: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: CustomDrawer(
              manager: widget.manager,
            ),
          ),
          body: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(16.0),
            children: [
              const SizedBox(height: 10.0),
              TextPoppins(
                text: "${widget.data['jobTitle']}".toUpperCase(),
                fontSize: 25,
                fontWeight: FontWeight.w500,
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Image.network(
                      widget.data['recruiter']['bio']['image'],
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          SvgPicture.asset(
                        "assets/images/personal_icon.svg",
                        width: 50,
                        height: 50,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextPoppins(
                          text:
                              "${widget.data['recruiter']['bio']['firstname']} ${widget.data['recruiter']['bio']['lastname']}"
                                  .capitalize,
                          fontSize: 16),
                      const SizedBox(height: 2.0),
                      TextPoppins(
                        text:
                            "${widget.data['jobLocation']['state']}, ${widget.data['jobLocation']['country']} (${widget.data['workplaceType']})"
                                .capitalize,
                        fontSize: 16,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextPoppins(
                    text:
                        "Posted ${timeUntil(DateTime.parse("${widget.data['createdAt']}"))}",
                    fontSize: 14,
                  ),
                  const SizedBox(
                    width: 10.0,
                  ),
                  const Icon(CupertinoIcons.circle_fill,
                      color: Colors.black, size: 8),
                  const SizedBox(
                    width: 10.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TextPoppins(
                        text:
                            "${_isCountLoaded ? _applicationCount : 'Loading...'} ${_isCountLoaded ? _pluralize(widget.data['applicants']?.length) : ""}",
                        fontSize: 14,
                      ),
                      const SizedBox(
                        width: 16.0,
                      ),
                      _applicationCount > 0 &&
                              widget.manager.getUser()['id'] ==
                                  widget.data['recruiter']['_id']
                          ? InkWell(
                              onTap: () {
                                Get.to(
                                  JobApplications(
                                    manager: widget.manager,
                                    data: widget.data,
                                  ),
                                  transition: Transition.cupertino,
                                );
                              },
                              child: const Text(
                                "View all",
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  decoration: TextDecoration.underline,
                                  color: Constants.primaryColor,
                                ),
                              ),
                            )
                          : const SizedBox()
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 21.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    CupertinoIcons.bag_fill,
                    color: Colors.black54,
                    size: 28,
                  ),
                  const SizedBox(
                    width: 16.0,
                  ),
                  TextPoppins(
                    text: "${widget.data['jobType']}".capitalize,
                    fontSize: 16,
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.track_changes_rounded,
                    color: Colors.black54,
                    size: 28,
                  ),
                  const SizedBox(
                    width: 16.0,
                  ),
                  TextPoppins(
                    text: "${widget.data['jobStatus']}".capitalize,
                    fontSize: 16,
                  ),
                ],
              ),
              const SizedBox(height: 10.0),
              const Divider(),
              const SizedBox(height: 10.0),
              TextPoppins(
                text: "Description",
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              Text(
                "${widget.data['description']}".capitalizeFirst!,
              ),
              const SizedBox(height: 21.0),
              TextPoppins(
                text: "Minimun qualification",
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              Text(
                "${widget.data['minimumQualification']}".capitalizeFirst!,
              ),
              const SizedBox(height: 21.0),
              TextPoppins(
                text: "Requirements",
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              for (var k = 0; k < widget.data['requirements']?.length; k++)
                Container(
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("${k + 1}."),
                      const SizedBox(width: 10.0),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.start,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.80,
                            child: Text(
                              "${widget.data['requirements'][k]}",
                              softWrap: true,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 21.0),
              widget.data['recruiter']['_id'] == widget.manager.getUser()['id']
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextPoppins(
                          text: "Screening Questions",
                          fontSize: 20,
                          align: TextAlign.left,
                          fontWeight: FontWeight.w600,
                        ),
                        for (var k = 0;
                            k < widget.data['screeningQuestions']?.length;
                            k++)
                          Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("${k + 1}."),
                                const SizedBox(width: 10.0),
                                Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.80,
                                      child: Text(
                                        "${widget.data['screeningQuestions'][k]}",
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )
                      ],
                    )
                  : const SizedBox(),
              const SizedBox(height: 21.0),
              widget.manager.getUser()['accountType'] != "recruiter"
                  ? SizedBox(
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: RoundedButton(
                              bgColor: Colors.transparent,
                              child: TextInter(
                                text: _isSaved ? "Job Saved" : "Save Job ",
                                fontSize: 16,
                              ),
                              borderColor: _isSaved
                                  ? Colors.grey
                                  : Constants.primaryColor,
                              foreColor: _isSaved
                                  ? Colors.grey
                                  : Constants.primaryColor,
                              onPressed: _isSaved
                                  ? null
                                  : () {
                                      _saveJob();
                                    },
                              variant: "Outlined",
                            ),
                          ),
                          const SizedBox(
                            width: 10.0,
                          ),
                          Expanded(
                            child: RoundedButton(
                              bgColor:
                                  widget.data['jobStatus'] != "accepting" ||
                                          _isApplied
                                      ? Colors.grey
                                      : Constants.primaryColor,
                              child: TextInter(
                                text: widget.data['jobStatus'] != "accepting"
                                    ? "Closed"
                                    : _isApplied
                                        ? "Applied"
                                        : "Apply",
                                fontSize: 16,
                              ),
                              borderColor: Colors.transparent,
                              foreColor: Colors.white,
                              onPressed:
                                  widget.data['jobStatus'] != "accepting" ||
                                          _isApplied
                                      ? null
                                      : () {
                                          //Apply for job here
                                          Get.to(
                                            ApplyJob(
                                              manager: widget.manager,
                                              data: widget.data,
                                            ),
                                            transition: Transition.cupertino,
                                          );
                                        },
                              variant: "Filled",
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox()
            ],
          ),
        ),
      ),
    );
  }

  _pluralize(val) {
    return val > 1 ? "Applicants" : "Applicant";
  }

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
}

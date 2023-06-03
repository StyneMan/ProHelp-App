import 'dart:convert';
import 'dart:io';

import 'package:easy_stepper/easy_stepper.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
import 'package:prohelp_app/screens/jobs/components/apply_step1.dart';
import 'package:prohelp_app/screens/jobs/components/apply_step2.dart';
import 'package:prohelp_app/screens/jobs/components/apply_step3.dart';
import 'package:prohelp_app/screens/pros/pros.dart';
import 'package:timeago/timeago.dart' as timeago;

class ApplyJob extends StatefulWidget {
  final PreferenceManager manager;
  var data;
  ApplyJob({
    Key? key,
    required this.manager,
    required this.data,
  }) : super(key: key);

  @override
  State<ApplyJob> createState() => _ApplyJobState();
}

class _ApplyJobState extends State<ApplyJob> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _controller = Get.find<StateController>();

  int _totalSteps = 3;
  final _formKey = GlobalKey<FormState>();
  Map _step1Payload = {};
  Map _step2Payload = {};
  Map _step3Payload = {};
  bool _isNotPicked = true;
  String _resumeUrl = "";

  _onStep1Completed(Map data) {
    debugPrint("STEP ONE DATA >> $data");
    // setState(() {
    _step1Payload = data;
    // });
  }

  _onStep2Completed(Map data) {
    debugPrint("STEP TWO DATA >> $data");
    // setState(() {
    _step2Payload = data;

    if (data.isEmpty) {
      setState(() => _isNotPicked = true);
    } else {
      setState(() => _isNotPicked = false);
    }
    // });
  }

  _onStep3Completed(Map data) {
    debugPrint("STEP THREE DATA >> $data");
    // setState(() {
    _step3Payload = data;
    // });
  }

  _saveStep1ToState() {
    _controller.applicationEmail.value = _step1Payload['email'];
    _controller.applicationPhone.value = _step1Payload['phone'];
  }

  @override
  void initState() {
    super.initState();
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
          body: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(18.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 5.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextPoppins(
                      text:
                          "STEP ${_controller.currentApplicationStep.value + 1}/$_totalSteps",
                      fontSize: 14,
                      color: Constants.primaryColor,
                      fontWeight: FontWeight.w400,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10.0,
                ),
                EasyStepper(
                  activeStep: _controller.currentApplicationStep.value,
                  lineLength: MediaQuery.of(context).size.width * 0.36,
                  defaultLineColor: Constants.accentColor,
                  borderThickness: 2,
                  // loadingAnimation: 'assets/loading_circle.json',
                  lineSpace: 0,
                  enableStepTapping: false,
                  lineType: LineType.normal,
                  finishedLineColor: Constants.primaryColor,
                  activeStepTextColor: Colors.grey,
                  finishedStepTextColor: Colors.black87,
                  internalPadding: 0,
                  showLoadingAnimation: false,
                  stepRadius: 8,
                  showStepBorder: false,
                  lineDotRadius: 1.5,
                  disableScroll: true,
                  steps: [
                    EasyStep(
                      customStep: CircleAvatar(
                        radius: 8,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 7,
                          backgroundColor:
                              _controller.currentApplicationStep.value >= 0
                                  ? Constants.primaryColor
                                  : Colors.grey.shade400,
                        ),
                      ),
                      title: '',
                    ),
                    EasyStep(
                      customStep: CircleAvatar(
                        radius: 8,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 7,
                          backgroundColor:
                              _controller.currentApplicationStep.value >= 1
                                  ? Constants.primaryColor
                                  : Colors.grey.shade400,
                        ),
                      ),
                      title: '',
                      topTitle: true,
                    ),
                    EasyStep(
                      customStep: CircleAvatar(
                        radius: 8,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 7,
                          backgroundColor:
                              _controller.currentApplicationStep.value >= 2
                                  ? Constants.primaryColor
                                  : Colors.grey.shade400,
                        ),
                      ),
                      title: '',
                      topTitle: true,
                    ),
                  ],
                  onStepReached: (index) =>
                      _controller.currentApplicationStep.value += index,
                ),
                Form(
                  key: _formKey,
                  child: Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shrinkWrap: true,
                      children: [
                        _controller.currentApplicationStep.value == 0
                            ? ApplyJobStep1(
                                data: widget.data,
                                manager: widget.manager,
                                onStep1Completed: _onStep1Completed,
                              )
                            : _controller.currentApplicationStep.value == 1
                                ? ApplyJobStep2(
                                    isError: _isNotPicked,
                                    onStep2Completed: _onStep2Completed,
                                    data: widget.data,
                                  )
                                : ApplyJobStep3(
                                    onStep3Completed: _onStep3Completed,
                                    data: widget.data,
                                  ),
                        const SizedBox(
                          height: 16.0,
                        ),
                        RoundedButton(
                          bgColor: Constants.primaryColor,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              TextPoppins(
                                text:
                                    _controller.currentApplicationStep.value ==
                                            2
                                        ? "Submit Application".toUpperCase()
                                        : "Next".toUpperCase(),
                                fontSize: 18,
                              ),
                              const SizedBox(
                                width: 16.0,
                              ),
                              const Icon(
                                CupertinoIcons.arrow_right,
                                color: Colors.white,
                              ),
                            ],
                          ),
                          borderColor: Colors.transparent,
                          foreColor: Colors.white,
                          onPressed: () {
                            if (_controller.currentApplicationStep.value < 2) {
                              if (_controller.currentApplicationStep.value ==
                                  0) {
                                if (_formKey.currentState!.validate()) {
                                  _saveStep1ToState();
                                  _controller.currentApplicationStep.value += 1;
                                }
                              } else if (_controller
                                      .currentApplicationStep.value ==
                                  1) {
                                if (_formKey.currentState!.validate() &&
                                    !_isNotPicked &&
                                    _step2Payload['fileSize'] < 500.0) {
                                  // _saveStep2ToState();
                                  _controller.currentApplicationStep.value += 1;
                                }
                              }
                            } else {
                              if (_formKey.currentState!.validate()) {
                                Future.delayed(
                                  const Duration(milliseconds: 500),
                                  () => _submitApplication(),
                                );
                              }
                            }
                          },
                          variant: "Filled",
                        ),
                        const SizedBox(
                          height: 16.0,
                        ),
                        _controller.currentApplicationStep.value > 0
                            ? RoundedButton(
                                bgColor: Colors.transparent,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      CupertinoIcons.arrow_left,
                                      color: Constants.primaryColor,
                                    ),
                                    const SizedBox(
                                      width: 16.0,
                                    ),
                                    TextPoppins(
                                      text: "Back".toUpperCase(),
                                      fontSize: 18,
                                    ),
                                  ],
                                ),
                                borderColor: Constants.primaryColor,
                                foreColor: Constants.primaryColor,
                                onPressed: () {
                                  if (_controller.currentApplicationStep.value >
                                      0) {
                                    _controller.currentApplicationStep.value -=
                                        1;
                                    // setState(() => _currStep -= 1);
                                  }
                                },
                                variant: "Outlined",
                              )
                            : const SizedBox(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 16.0,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _uploadResume() async {
    try {
      final file = File(_step2Payload['pickedFile'].path);
      final storageRef = FirebaseStorage.instance.ref();

      final uploadTask = storageRef
          .child("resumes")
          .child(
              "${widget.manager.getUser()['_id']}_resume${_step2Payload['pickedFile']?.extension}")
          .putFile(file);

      uploadTask.then((p0) async {
        final _url = await p0.ref.getDownloadURL();

        debugPrint("DOWNLOAD URLS AT >>>>> $_url}");

        setState(() {
          _resumeUrl = _url;
        });
      });
    } on FirebaseException catch (e) {
      _controller.setLoading(true);
      debugPrint(e.toString());
    }
  }

  List<Map<String, dynamic>> _arr = [];
  _submitApplication() async {
    _controller.setLoading(true);
    try {
      await _uploadResume();

      for (var i = 0; i < widget.data['screeningQuestions']?.length; i++) {
        debugPrint(
            "QUESTIONS ==>> ${widget.data['screeningQuestions'][i]}  ANSWER ==>> ${_step3Payload['textController'][i].text} ");
        _arr.add({
          "question": widget.data['screeningQuestions'][i],
          "answer": _step3Payload['textController'][i].text,
        });
      }

      Future.delayed(const Duration(seconds: 7), () async {
        debugPrint("ARRAY VALS -->> ${_arr}");

        Map _body = {
          "jobId": widget.data['id'],
          "job": widget.data,
          "applicant": {
            "id": widget.manager.getUser()['_id'],
            "email": _step1Payload['email'],
            "phone": _step1Payload['phone'],
            "name": widget.manager.getUser()['bio']['fullname'],
            "photo": widget.manager.getUser()['bio']['image'],
          },
          "resume": _resumeUrl,
          "answers": _arr,
        };

        await APIService()
            .applyJob(
          _body,
          widget.manager.getAccessToken(),
          widget.manager.getUser()['email'],
          widget.data['id'],
        )
            .then((resp) {
          debugPrint("APPLY JOB RESPONSE ===>>> ${resp.body}");
          _controller.setLoading(false);
          if (resp.statusCode == 200) {
            Map<String, dynamic> map = jsonDecode(resp.body);
            Constants.toast(map['message']);
            //Now refetch applications and go back
            _controller.onInit();

            // Navigator.pushReplacement(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => Pros(
            //       manager: widget.manager,
            //     ),
            //   ),
            // );
            Navigator.pop(context);
            Navigator.pop(context);
          }
        }).catchError((onError) {
          debugPrint("ERROR $onError");
          _controller.setLoading(false);
        });
      });
    } catch (e) {
      _controller.setLoading(false);
      debugPrint("ERROR ++> $e");
    }
  }
}

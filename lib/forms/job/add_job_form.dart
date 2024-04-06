import 'dart:convert';

import 'package:easy_stepper/easy_stepper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_overlay_pro/loading_overlay_pro.dart';
import 'package:prohelp_app/components/button/roundedbutton.dart';
import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/helper/constants/constants.dart';
import 'package:prohelp_app/helper/preference/preference_manager.dart';
import 'package:prohelp_app/helper/service/api_service.dart';
import 'package:prohelp_app/helper/state/state_manager.dart';

import 'add_job_step1.dart';
import 'add_job_step2.dart';
import 'add_job_step3.dart';

class AddJobForm extends StatefulWidget {
  final PreferenceManager manager;
  final bool hasPayment;
  AddJobForm({
    Key? key,
    required this.manager,
    this.hasPayment = false,
  }) : super(key: key);

  @override
  State<AddJobForm> createState() => _AddJobFormState();
}

class _AddJobFormState extends State<AddJobForm> {
  int _totalSteps = 3;
  final _controller = Get.find<StateController>();
  final _formKey = GlobalKey<FormState>();
  Map _step1Payload = {};
  Map _step2Payload = {};

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
    // });
  }

  _saveStep1ToState() {
    _controller.jobCity.value = _step1Payload['city'];
    _controller.jobCompany.value = _step1Payload['company'];
    _controller.jobCountry.value = _step1Payload['country'];
    _controller.jobState.value = _step1Payload['state'];
    _controller.jobTitle.value = _step1Payload['jobTitle'];
    _controller.jobType.value = _step1Payload['jobType'];
    _controller.workplaceType.value = _step1Payload['workplaceType'];
  }

  _saveStep2ToState() {
    _controller.jobDescription.value = _step2Payload['description'];
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => LoadingOverlayPro(
        isLoading: _controller.isLoading.value,
        backgroundColor: Colors.black54,
        progressIndicator: const CircularProgressIndicator.adaptive(),
        child: Scaffold(
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
              text: "New Job".toUpperCase(),
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Constants.secondaryColor,
            ),
            centerTitle: true,
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
                          "STEP ${_controller.currentJobStep.value + 1}/$_totalSteps",
                      fontSize: 14,
                      color: Constants.primaryColor,
                      fontWeight: FontWeight.w400,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 6.0,
                ),
                const SizedBox(
                  height: 6.0,
                ),
                EasyStepper(
                  activeStep: _controller.currentJobStep.value,
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
                          backgroundColor: _controller.currentJobStep.value >= 0
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
                          backgroundColor: _controller.currentJobStep.value >= 1
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
                          backgroundColor: _controller.currentJobStep.value >= 2
                              ? Constants.primaryColor
                              : Colors.grey.shade400,
                        ),
                      ),
                      title: '',
                      topTitle: true,
                    ),
                  ],
                  onStepReached: (index) =>
                      _controller.currentJobStep.value += index,
                ),
                widget.hasPayment
                    ? const SizedBox(
                        width: double.infinity,
                        child: Text(
                          "You will be charged 200 coins for this post",
                          textAlign: TextAlign.center,
                        ),
                      )
                    : const SizedBox(),
                Form(
                  key: _formKey,
                  child: Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shrinkWrap: true,
                      children: [
                        _controller.currentJobStep.value == 0
                            ? AddJobFormStep1(
                                manager: widget.manager,
                                onStep1Completed: _onStep1Completed,
                              )
                            : _controller.currentJobStep.value == 1
                                ? AddJobFormStep2(
                                    onStep2Completed: _onStep2Completed,
                                    manager: widget.manager,
                                  )
                                : AddJobFormStep3(
                                    manager: widget.manager,
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
                                text: _controller.currentJobStep.value == 2
                                    ? "Post Job".toUpperCase()
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
                            if (_controller.currentJobStep.value < 2) {
                              if (_controller.currentJobStep.value == 0) {
                                if (_formKey.currentState!.validate()) {
                                  _saveStep1ToState();
                                  _controller.currentJobStep.value += 1;
                                }
                              }
                              if (_controller.currentJobStep.value == 1) {
                                if (_formKey.currentState!.validate()) {
                                  _saveStep2ToState();
                                  _controller.currentJobStep.value += 1;
                                }
                              }
                            } else {
                              Future.delayed(
                                const Duration(milliseconds: 500),
                                () => _postJob(),
                              );
                            }

                            // if (_formKey.currentState!.validate()) {
                            //   if (_controller.currentJobStep.value < 2) {
                            //     if (_controller.currentJobStep.value == 0) {
                            //       _saveStep1ToState();
                            //       _controller.currentJobStep.value += 1;
                            //     }
                            //     // if (_controller.currentJobStep.value == 1) {
                            //     //   _saveStep2ToState();
                            //     //   // _controller.currentJobStep.value += 1;
                            //     // }
                            //   } else {
                            //     // _saveStep2ToState();

                            //     Future.delayed(
                            //       const Duration(milliseconds: 500),
                            //       () => _postJob(),
                            //     );
                            //   }
                            // }
                          },
                          variant: "Filled",
                        ),
                        const SizedBox(
                          height: 16.0,
                        ),
                        _controller.currentJobStep.value > 0
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
                                  if (_controller.currentJobStep.value > 0) {
                                    _controller.currentJobStep.value -= 1;
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

  _postJob() async {
    _controller.setLoading(true);

    try {
      Map _payload = {
        "jobTitle": _step1Payload['jobTitle'].toString().toLowerCase(),
        "workplaceType":
            _step1Payload['workplaceType'].toString().toLowerCase(),
        "company": _step1Payload['company'].toString().toLowerCase(),
        "jobType": _step1Payload['jobType'].toString().toLowerCase(),
        "jobLocation": {
          "state": _step1Payload['state'].toString().toLowerCase(),
          "city": _step1Payload['city'].toString().toLowerCase(),
          "country": _step1Payload['country'].toString().toLowerCase(),
        },
        "recruiter": {
          "id": widget.manager.getUser()['id'],
        },
        "description": _step2Payload['description'].toString().toLowerCase(),
        "profession": _step2Payload['profession'].toString().toLowerCase(),
        "minimumQualification":
            _step2Payload['minimumQualification'].toString().toLowerCase(),
        "screeningQuestions": _controller.jobQuestions.value,
        "requirements": _controller.jobRequirements.value
      };

      final response = await APIService().postJob(
        accessToken: widget.manager.getAccessToken(),
        email: widget.manager.getUser()['email'],
        payload: _payload,
      );

      debugPrint("POST JOB RESPONSE ===>> ${response.body}");
      _controller.setLoading(false);

      if (response.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(response.body);
        //Mutate response here
        Constants.toast(map['message']);
        _controller.onInit();

        _controller.clearJobsData();
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint("ERROR --->> $e");
      _controller.setLoading(false);
    }
  }
}

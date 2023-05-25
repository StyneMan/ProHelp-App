import 'dart:convert';
import 'dart:io';

import 'package:easy_stepper/easy_stepper.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:loading_overlay_pro/loading_overlay_pro.dart';
import 'package:page_transition/page_transition.dart';
import 'package:prohelp_app/components/button/roundedbutton.dart';
import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/helper/constants/constants.dart';
import 'package:prohelp_app/helper/preference/preference_manager.dart';
import 'package:prohelp_app/helper/service/api_service.dart';
import 'package:prohelp_app/helper/socket/socket_manager.dart';
import 'package:prohelp_app/helper/state/state_manager.dart';
import 'package:prohelp_app/screens/account/components/setup_step1.dart';
import 'package:prohelp_app/screens/account/components/setup_step2.dart';
import 'package:prohelp_app/screens/account/components/setup_step3.dart';
import 'package:prohelp_app/screens/auth/account_created/successscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SetupProfile extends StatelessWidget {
  final bool? isSocial;
  final String email;
  final String? name;
  final PreferenceManager manager;
  SetupProfile({
    Key? key,
    this.isSocial = false,
    required this.manager,
    required this.email,
    this.name,
  }) : super(key: key);

  int _totalSteps = 3;

  final _controller = Get.find<StateController>();
  final _formKey = GlobalKey<FormState>();

  final _currentUser = FirebaseAuth.instance.currentUser;

  Map _step1Payload = {};
  Map _step2Payload = {};
  Map _step3Payload = {};
  List<String> _downloadURLs = [];

  final socket = SocketManager().socket;

  // _uploadDocuments() async {
  //   try {
  //     // final appDocDir = await getApplicationDocumentsDirectory();
  //     // final filePath = "${appDocDir.absolute}/path/to/mountains.jpg";

  //     // Upload file and metadata to the path 'images/mountains.jpg'

  //     for (var i = 0; i < _controller.pickedDocuments.length; i++) {
  //       final file = File(_controller.pickedDocuments.elementAt(i).path);
  //       final storageRef = FirebaseStorage.instance.ref();

  //       final uploadTask = storageRef
  //           .child(
  //               "Users/${_currentUser?.uid}/${_controller.pickedDocuments.elementAt(i).name}")
  //           .putFile(file);

  //       uploadTask.then((p0) async {
  //         final url = await p0.ref.getDownloadURL();

  //         _downloadURLs.add(url);
  //       });
  //     }
  //   } catch (e) {
  //     _controller.setLoading(true);
  //     debugPrint(e.toString());
  //   }
  // }

  _saveProfile(context) async {
    _controller.setLoading(true);
    Map _payload = {
      "accountType": "freelancer",
      "bio": {
        "fullname": _step1Payload['fullname'].toString().toLowerCase(),
        "phone": _step1Payload['phone'],
        "gender": _step1Payload['gender'].toString().toLowerCase(),
        "address": _step1Payload['address'].toString().toLowerCase(),
        "dob": _step1Payload['dob'],
      },
      "guarantor": {
        "name": _step2Payload['nokName'].toString().toLowerCase(),
        "address": _step2Payload['nokAddress'].toString().toLowerCase(),
        "email": _step2Payload['nokEmail'],
        "phone": _step2Payload['nokPhone'],
        "relationship": _step2Payload['relationship'].toString().toLowerCase()
      },
      "hasProfile": true,
      "education": [
        {
          "school": _step3Payload['school'].toString().toLowerCase(),
          "degree": _step3Payload['degree'].toString().toLowerCase(),
          "course": _step3Payload['fieldStudy'].toString().toLowerCase(),
          "schoolLogo": "",
          "endate": _step3Payload['dateGraduated'],
          "stillSchooling": false
        },
      ],
    };

    try {
      final _prefs = await SharedPreferences.getInstance();
      var _token = _prefs.getString("accessToken") ?? "";
      // widget.manager.setIsLoggedIn(true);
      final response = await APIService().updateProfile(
        accessToken: _token,
        body: _payload,
        email: email,
      );

      debugPrint("PROFILE RESPONSE freelancer >> ${response.body}");
      _controller.setLoading(false);

      if (response.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(response.body);
        Constants.toast(map['message']);

        //Nw save user's data to preference
        String userData = jsonEncode(map['data']);
        manager.setUserData(userData);
        manager.setIsLoggedIn(true);
        _controller.userData.value = map['data'];
        _controller.clearTempProfile();

        socket.emit('identity', map['data']["_id"]);

        //Fetch other data like freelancers, recruiters etc.
        _controller.onInit();

        Navigator.of(context).pushReplacement(
          PageTransition(
            type: PageTransitionType.size,
            alignment: Alignment.bottomCenter,
            child: AccountSuccess(
              firstname: "${map["data"]["bio"]["fullname"]}".split(" ")[0],
              accountType: "freelancer",
            ),
          ),
        );
      } else {
        Map<String, dynamic> map = jsonDecode(response.body);
        Constants.toast(map['message']);
      }

      // manager.setIsLoggedIn(true);
      // _controller.setLoading(false);
      // //Clear state
      // _controller.clearTempProfile();

      // Navigator.of(context).pushReplacement(
      //   PageTransition(
      //     type: PageTransitionType.size,
      //     alignment: Alignment.bottomCenter,
      //     child: const AccountSuccess(),
      //   ),
      // );
    } catch (e) {
      debugPrint(e.toString());
      Constants.toast(e.toString());
      _controller.setLoading(false);
    }
  }

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

  _onStep3Completed(Map data) {
    // setState(() {
    _step3Payload = data;
    // });
  }

  _saveStep1ToState() {
    _controller.name.value = _step1Payload['fullname'];
    _controller.address.value = _step1Payload['address'];
    _controller.dob.value = _step1Payload['dob'];
    _controller.phone.value =
        _step1Payload['phone'].toString().startsWith("+234")
            ? "0${_step1Payload['phone'].toString().substring(4)}"
            : "${_step1Payload['phone']}";
    _controller.gender.value = _step1Payload['gender'];
  }

  _saveStep2ToState() {
    _controller.nokName.value = _step2Payload['nokName'];
    _controller.nokEmail.value = _step2Payload['nokEmail'];
    _controller.nokAddress.value = _step2Payload['nokAddress'];
    _controller.nokPhone.value =
        _step2Payload['nokPhone'].toString().startsWith("+234")
            ? "0${_step2Payload['nokPhone'].toString().substring(4)}"
            : "${_step2Payload['nokPhone']}";
    _controller.nokRelationship.value = _step2Payload['relationship'];
  }

  _saveStep3ToState() {
    _controller.school.value = _step3Payload['school'];
    _controller.degree.value = _step3Payload['degree'];
    _controller.fieldStudy.value = _step3Payload['fieldStudy'];
    _controller.dateGraduated.value = _step3Payload['dateGraduated'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(
        () => LoadingOverlayPro(
          isLoading: _controller.isLoading.value,
          backgroundColor: Colors.black54,
          progressIndicator: const CircularProgressIndicator.adaptive(),
          child: SafeArea(
            child: Container(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 10.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TextPoppins(
                        text:
                            "STEP ${_controller.currentProfileStep.value + 1}/$_totalSteps",
                        fontSize: 14,
                        color: Constants.primaryColor,
                        fontWeight: FontWeight.w400,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 35.0,
                  ),
                  EasyStepper(
                    activeStep: _controller.currentProfileStep.value,
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
                                _controller.currentProfileStep.value >= 0
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
                                _controller.currentProfileStep.value >= 1
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
                                _controller.currentProfileStep.value >= 2
                                    ? Constants.primaryColor
                                    : Colors.grey.shade400,
                          ),
                        ),
                        title: '',
                      ),
                    ],
                    onStepReached: (index) =>
                        _controller.currentProfileStep.value += index,
                  ),
                  const SizedBox(
                    height: 16.0,
                  ),
                  Form(
                    key: _formKey,
                    child: Expanded(
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          _controller.currentProfileStep.value == 0
                              ? SetupStep1(
                                  name: "$name",
                                  email: email,
                                  onStep1Completed: _onStep1Completed,
                                )
                              : _controller.currentProfileStep.value == 1
                                  ? SetupStep2(
                                      onStep2Completed: _onStep2Completed,
                                    )
                                  : SetupStep3(
                                      onStep3Completed: _onStep3Completed,
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
                                      _controller.currentProfileStep.value == 2
                                          ? "Submit".toUpperCase()
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
                              if (_formKey.currentState!.validate()) {
                                if (_controller.currentProfileStep.value < 2) {
                                  if (_controller.currentProfileStep.value ==
                                      0) {
                                    if (_step1Payload['gender']
                                        .toString()
                                        .isNotEmpty) {
                                      _saveStep1ToState();
                                      Future.delayed(
                                        const Duration(milliseconds: 200),
                                        () => _controller
                                            .currentProfileStep.value += 1,
                                      );
                                    } else {
                                      Constants.toast("Gender not selected!");
                                    }
                                  } else if (_controller
                                          .currentProfileStep.value ==
                                      1) {
                                    if (_step2Payload['relationship']
                                        .toString()
                                        .isNotEmpty) {
                                      _saveStep2ToState();
                                      Future.delayed(
                                        const Duration(milliseconds: 200),
                                        () => _controller
                                            .currentProfileStep.value += 1,
                                      );
                                    } else {
                                      Constants.toast(
                                          "Guarantor relationship not selected!");
                                    }
                                  }
                                } else {
                                  _saveStep3ToState();

                                  Future.delayed(
                                    const Duration(milliseconds: 500),
                                    () => _saveProfile(context),
                                  );
                                }
                              }
                            },
                            variant: "Filled",
                          ),
                          const SizedBox(
                            height: 16.0,
                          ),
                          _controller.currentProfileStep.value > 0
                              ? RoundedButton(
                                  bgColor: Colors.transparent,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                                    if (_controller.currentProfileStep.value >
                                        0) {
                                      _controller.currentProfileStep.value -= 1;
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
      ),
    );
  }
}

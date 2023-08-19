import 'dart:convert';
import 'dart:io';

import 'package:easy_stepper/easy_stepper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:loading_overlay_pro/loading_overlay_pro.dart';
import 'package:page_transition/page_transition.dart';
import 'package:prohelp_app/components/button/custombutton.dart';
import 'package:prohelp_app/components/button/roundedbutton.dart';
import 'package:prohelp_app/components/dialog/info_dialog.dart';
import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/helper/constants/constants.dart';
import 'package:prohelp_app/helper/preference/preference_manager.dart';
import 'package:prohelp_app/helper/service/api_service.dart';
import 'package:prohelp_app/helper/socket/socket_manager.dart';
import 'package:prohelp_app/helper/state/state_manager.dart';
import 'package:prohelp_app/screens/account/components/setup_step1.dart';
import 'package:prohelp_app/screens/account/components/setup_step2.dart';
import 'package:prohelp_app/screens/account/components/setup_step3.dart';
import 'package:prohelp_app/screens/account/components/setup_step4.dart';
import 'package:prohelp_app/screens/auth/account_created/successscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'components/image_uploader.dart';

class SetupProfile extends StatefulWidget {
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

  @override
  State<SetupProfile> createState() => _SetupProfileState();
}

class _SetupProfileState extends State<SetupProfile> {
  int _totalSteps = 4;

  final _controller = Get.find<StateController>();
  final _formKey = GlobalKey<FormState>();
  final _currentUser = FirebaseAuth.instance.currentUser;

  Map _step1Payload = {};
  Map _step2Payload = {};
  Map _step3Payload = {};
  Map _step4Payload = {};

  List<String> _downloadURLs = [];
  bool _isImagePicked = false;
  String _croppedFile = "";

  final socket = SocketManager().socket;

  // _onImageSelected(var file) {
  //   setState(() {
  //     _isImagePicked = true;
  //     _croppedFile = file;
  //   });
  //   debugPrint("VALUIE::: :: $file");
  // }

  _uploadPhoto() async {
    _controller.setLoading(true);
    try {
      final storageRef = FirebaseStorage.instance.ref();
      final fileRef = storageRef
          .child("photos")
          .child("${_step1Payload['email']}".toString().toLowerCase());
      final _resp = await fileRef.putFile(File(_controller.croppedPic.value));
      final url = await _resp.ref.getDownloadURL();

      await _saveProfile(context, url);

      _controller.croppedPic.value = "";
    } catch (e) {
      debugPrint(e.toString());
      _controller.setLoading(false);
    }
  }

  _saveProfile(context, url) async {
    _controller.setLoading(true);
    Map _payload = {
      "accountType": "freelancer",
      "bio": {
        "firstname": _step1Payload['firstname'].toLowerCase() ??
            _controller.firstname.value.toLowerCase(),
        "lastname": _step1Payload['lastname'].toLowerCase() ??
            _controller.middlename.value.toLowerCase(),
        "middlename": _step1Payload['middlename'].toLowerCase() ??
            _controller.lastname.value.toLowerCase(),
        "phone": _step1Payload['phone'] ?? _controller.phone.value,
        "gender": _step1Payload['gender'].toLowerCase() ??
            _controller.gender.value.toLowerCase(),
        "dob": _step1Payload['dob'],
        "image": url
      },
      "address": {
        "street": _step1Payload['address'].toLowerCase() ??
            _controller.address.value.toLowerCase(),
        "city": _step1Payload['city'] ?? _controller.city.value.toLowerCase(),
        "country":
            "nigeria", //_step1Payload['country'].toString().toLowerCase(),
        "state": _step1Payload['state'].toLowerCase() ??
            _controller.state.value.toLowerCase(),
      },
      "profession": _step1Payload['profession'].toLowerCase() ??
          _controller.profession.value.toLowerCase(),
      "experienceYears": _step1Payload['experienceYears'].toLowerCase() ??
          _controller.experience.value.toLowerCase(),
      "guarantor": {
        "name": _step2Payload['nokName'].toLowerCase() ??
            _controller.nokName.value.toLowerCase(),
        "address": _step2Payload['nokAddress'].toLowerCase() ??
            _controller.nokAddress.value.toLowerCase(),
        "email": _step2Payload['nokEmail'] ?? _controller.nokEmail.value,
        "phone": _step2Payload['nokPhone'] ?? _controller.nokPhone.value,
        "relationship": _step2Payload['relationship'].toLowerCase() ??
            _controller.nokRelationship.value.toLowerCase(),
      },
      "hasProfile": true,
      "education": [
        {
          "school": _step3Payload['school'].toLowerCase() ??
              _controller.school.value.toLowerCase(),
          "degree": _step3Payload['degree'].toLowerCase() ??
              _controller.degree.value.toLowerCase(),
          "course": _step3Payload['fieldStudy'].toLowerCase() ??
              _controller.fieldStudy.value.toLowerCase(),
          "schoolLogo": "",
          "endate": _step3Payload['dateGraduated'],
          "stillSchooling": false
        },
      ],
      "disability": _step4Payload['disability'] ?? "none",
      "languagesSpoken": _controller.languagesSpoken.value,
      "languagesWriteSpeak": _controller.languagesSpeakWrite.value,
    };

    try {
      final _prefs = await SharedPreferences.getInstance();
      var _token = _prefs.getString("accessToken") ?? "";
      // widget.manager.setIsLoggedIn(true);
      final response = await APIService().updateProfile(
        accessToken: _token,
        body: _payload,
        email: widget.email,
      );

      debugPrint("PROFILE RESPONSE freelancer >> ${response.body}");
      _controller.setLoading(false);

      if (response.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(response.body);
        Constants.toast(map['message']);

        //Nw save user's data to preference
        String userData = jsonEncode(map['data']);
        widget.manager.setUserData(userData);
        widget.manager.setIsLoggedIn(true);
        _controller.userData.value = map['data'];
        _controller.clearTempProfile();

        socket.emit('identity', map['data']["id"]);

        //Fetch other data like freelancers, recruiters etc.
        _controller.onInit();

        Navigator.of(context).pushReplacement(
          PageTransition(
            type: PageTransitionType.size,
            alignment: Alignment.bottomCenter,
            child: AccountSuccess(
              firstname: "${map["data"]["bio"]["firstname"]}",
              accountType: "freelancer",
            ),
          ),
        );
      } else {
        Map<String, dynamic> map = jsonDecode(response.body);
        Constants.toast(map['message']);
      }
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

  _onStep4Completed(Map data) {
    // setState(() {
    _step4Payload = data;
    // });
  }

  _saveStep1ToState() {
    _controller.firstname.value = _step1Payload['firstname'];
    _controller.middlename.value = _step1Payload['middlename'];
    _controller.lastname.value = _step1Payload['lastname'];
    _controller.address.value = _step1Payload['address'];
    _controller.dob.value = _step1Payload['dob'];
    _controller.state.value = _step1Payload['state'];
    _controller.country.value = _step1Payload['country'];
    _controller.profession.value = _step1Payload['profession'];
    _controller.city.value = _step1Payload['city'];
    _controller.experience.value = _step1Payload['experienceYears'];
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
    _controller.school.value = _step3Payload['school'] ?? "";
    _controller.degree.value = _step3Payload['degree'];
    _controller.fieldStudy.value = _step3Payload['fieldStudy'] ?? "";
    _controller.dateGraduated.value = _step3Payload['dateGraduated'] ?? "";
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
                    height: 24.0,
                  ),
                  EasyStepper(
                    activeStep: _controller.currentProfileStep.value,
                    lineLength: MediaQuery.of(context).size.width * 0.225,
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
                      EasyStep(
                        customStep: CircleAvatar(
                          radius: 8,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 7,
                            backgroundColor:
                                _controller.currentProfileStep.value >= 3
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
                  Form(
                    key: _formKey,
                    child: Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        shrinkWrap: true,
                        children: [
                          _controller.currentProfileStep.value == 0
                              ? SetupStep1(
                                  name: "${widget.name}",
                                  email: widget.email,
                                  onStep1Completed: _onStep1Completed,
                                )
                              : _controller.currentProfileStep.value == 1
                                  ? SetupStep2(
                                      onStep2Completed: _onStep2Completed,
                                    )
                                  : _controller.currentProfileStep.value == 2
                                      ? SetupStep3(
                                          onStep3Completed: _onStep3Completed,
                                        )
                                      : SetupStep4(
                                          onStep4Completed: _onStep4Completed,
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
                                      _controller.currentProfileStep.value == 3
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
                                if (_controller.currentProfileStep.value < 3) {
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

                                    if (_step1Payload['city']
                                        .toString()
                                        .isEmpty) {
                                      Constants.toast("City is not selected!");
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
                                  } else if (_controller
                                          .currentProfileStep.value ==
                                      2) {
                                    _saveStep3ToState();

                                    Future.delayed(
                                      const Duration(milliseconds: 500),
                                      () => _controller
                                          .currentProfileStep.value += 1,
                                    );
                                  }
                                } else {
                                  if (_controller
                                      .languagesSpoken.value.isEmpty) {
                                    Constants.toast(
                                        "Language(s) you speak not added!");
                                  } else if (_controller
                                      .languagesSpeakWrite.value.isEmpty) {
                                    Constants.toast(
                                        "Language(s) you speak and write not added!");
                                  } else {
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (context) {
                                        return SizedBox(
                                          height: 256,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.98,
                                          child: InfoDialog(
                                            body: Wrap(
                                              children: [
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      decoration:
                                                          const BoxDecoration(
                                                        color: Constants
                                                            .primaryColor,
                                                        borderRadius:
                                                            BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                            Constants.padding,
                                                          ),
                                                          topRight:
                                                              Radius.circular(
                                                            Constants.padding,
                                                          ),
                                                        ),
                                                      ),
                                                      padding:
                                                          const EdgeInsets.all(
                                                              16.0),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: [
                                                          const TextInter(
                                                            text:
                                                                "Add Profile Picture",
                                                            fontSize: 16,
                                                            color: Colors.white,
                                                          ),
                                                          InkWell(
                                                            onTap: () =>
                                                                Navigator.pop(
                                                                    context),
                                                            child: const Icon(
                                                              Icons
                                                                  .cancel_outlined,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8.0),
                                                    Wrap(
                                                      children: [
                                                        Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(16.0),
                                                          child: Column(
                                                            children: [
                                                              const ImageUploader(),
                                                              const SizedBox(
                                                                height: 24.0,
                                                              ),
                                                              Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Expanded(
                                                                    child:
                                                                        CustomButton(
                                                                      bgColor:
                                                                          Colors
                                                                              .transparent,
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.center,
                                                                        children: const [
                                                                          TextInter(
                                                                            text:
                                                                                "Skip",
                                                                            fontSize:
                                                                                15,
                                                                            color:
                                                                                Constants.primaryColor,
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      borderColor:
                                                                          Constants
                                                                              .primaryColor,
                                                                      foreColor:
                                                                          Constants
                                                                              .primaryColor,
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.pop(
                                                                            context);
                                                                        Future
                                                                            .delayed(
                                                                          const Duration(
                                                                              milliseconds: 500),
                                                                          () =>
                                                                              _saveProfile(
                                                                            context,
                                                                            "",
                                                                          ),
                                                                        );
                                                                      },
                                                                      variant:
                                                                          "Outlined",
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 16.0,
                                                                  ),
                                                                  Expanded(
                                                                    child:
                                                                        CustomButton(
                                                                      bgColor:
                                                                          Constants
                                                                              .primaryColor,
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.center,
                                                                        children: const [
                                                                          TextInter(
                                                                            text:
                                                                                "Continue",
                                                                            fontSize:
                                                                                15,
                                                                            color:
                                                                                Colors.white,
                                                                            fontWeight:
                                                                                FontWeight.w500,
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      borderColor:
                                                                          Colors
                                                                              .transparent,
                                                                      foreColor:
                                                                          Colors
                                                                              .white,
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.pop(
                                                                            context);
                                                                        if (_controller
                                                                            .croppedPic
                                                                            .value
                                                                            .isNotEmpty) {
                                                                          _uploadPhoto();
                                                                        } else {
                                                                          Constants.toast(
                                                                              "You must select a picture to continue");
                                                                        }
                                                                      },
                                                                      variant:
                                                                          "Filled",
                                                                    ),
                                                                  ),
                                                                ],
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  }
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

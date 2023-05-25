import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/countdown_timer_controller.dart';
import 'package:flutter_countdown_timer/current_remaining_time.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:get/get.dart';
import 'package:loading_overlay_pro/loading_overlay_pro.dart';
import 'package:page_transition/page_transition.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:prohelp_app/components/button/roundedbutton.dart';
import 'package:prohelp_app/components/inputfield/textfield.dart';
import 'package:prohelp_app/helper/constants/constants.dart';
import 'package:prohelp_app/helper/service/api_service.dart';
import 'package:prohelp_app/screens/account/setup_profile.dart';
import 'package:prohelp_app/screens/account/setup_profile_employer.dart';
import 'package:prohelp_app/screens/auth/forgotpass/resetpass.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../../components/text_components.dart';
import '../../../helper/preference/preference_manager.dart';
import '../../../helper/state/state_manager.dart';

typedef void InitCallback(params);

class VerifyOTP extends StatefulWidget {
  final String caller;
  final PreferenceManager manager;
  var credential;
  InitCallback? onEntered;
  String? email, pass, phone, name, verificationId;
  VerifyOTP({
    Key? key,
    required this.caller,
    required this.manager,
    this.verificationId,
    this.onEntered,
    this.credential,
    this.email,
    this.name,
    this.pass,
    this.phone,
  }) : super(key: key);

  @override
  State<VerifyOTP> createState() => _State();
}

class _State extends State<VerifyOTP> {
  final _controller = Get.find<StateController>();
  final _otpController = TextEditingController();
  final _phoneController = TextEditingController();
  PreferenceManager? _manager;
  String _code = '';
  CountdownTimerController? _timerController;
  int endTime = DateTime.now().millisecondsSinceEpoch + 1000 * 60 * 1;

  @override
  void initState() {
    super.initState();
    _manager = PreferenceManager(context);
  }

  _resendCode() async {
    // if (widget.caller == "Login") {
    //   //Show Dialog here for phone number
    //   // showDialog(
    //   //   context: context,
    //   //   builder: (context) => AlertDialog(
    //   //     content: Column(
    //   //       children: [
    //   //         CustomTextField(
    //   //           hintText: "Phone",
    //   //           onChanged: (val) {},
    //   //           controller: _phoneController,
    //   //           validator: (value) {
    //   //             if (value == null || value.isEmpty) {
    //   //               return 'Please enter your phone';
    //   //             }
    //   //             if (value.toString().length < 11) {
    //   //               return 'Please enter a valid email';
    //   //             }
    //   //             return null;
    //   //           },
    //   //           inputType: TextInputType.phone,
    //   //         ),
    //   //         const SizedBox(
    //   //           height: 12.0,
    //   //         ),
    //   //         RoundedButton(
    //   //           bgColor: Constants.primaryColor,
    //   //           child: TextPoppins(text: "CONTINUE", fontSize: 16),
    //   //           borderColor: Colors.transparent,
    //   //           foreColor: Colors.white,
    //   //           onPressed: () async {
    //   //             _controller.setLoading(true);
    //   //             try {
    //   //               FirebaseAuth _auth = FirebaseAuth.instance;
    //   //               await _auth.verifyPhoneNumber(
    //   //                 phoneNumber: "${widget.phone}",
    //   //                 verificationCompleted: (PhoneAuthCredential credential) {
    //   //                   _controller.setLoading(false);
    //   //                   // resp.user!.updatePhoneNumber(credential);
    //   //                 },
    //   //                 verificationFailed: (FirebaseAuthException e) {
    //   //                   _controller.setLoading(false);
    //   //                   if (e.code == 'invalid-phone-number') {
    //   //                     debugPrint('The provided phone number is not valid.');
    //   //                     Constants.toast(
    //   //                         'The provided phone number is not valid.');
    //   //                   } else if (e.code == "expired-action-code") {
    //   //                     Constants.toast('The code has expired. Try again.');
    //   //                   } else if (e.code == "invalid-action-code") {
    //   //                     Constants.toast('Incorrect code entered.');
    //   //                   } else {
    //   //                     debugPrint("${e.code} - ${e.message}");
    //   //                     Constants.toast('${e.message}');
    //   //                   }
    //   //                 },
    //   //                 codeSent: (String verificationId, int? resendToken) {
    //   //                   _controller.setLoading(false);
    //   //                   //show dialog to take input from the user
    //   //                 },
    //   //                 codeAutoRetrievalTimeout: (String verificationId) {
    //   //                   _controller.setLoading(false);
    //   //                 },
    //   //               );

    //   //               _controller.setLoading(false);
    //   //             } catch (e) {
    //   //               _controller.setLoading(false);
    //   //             }
    //   //           },
    //   //           variant: "Filled",
    //   //         ),
    //   //       ],
    //   //     ),
    //   //   ),
    //   // );
    // } else {
      _controller.setLoading(true);
      try {
        final resp = await APIService().resendOTP(email: widget.email, type: "register");
        debugPrint("RESEND OTP RESPONSE:: ${resp.body}");
        _controller.setLoading(false);
        if (resp.statusCode == 200) {
          Map<String, dynamic> map = jsonDecode(resp.body);
          Constants.toast(map['message']);
        } else {
          Map<String, dynamic> map = jsonDecode(resp.body);
          Constants.toast(map['message']);
        }
      } catch (e) {
        _controller.setLoading(false);
      }
    // }
  }

  _linkAccount() async {
    _controller.setLoading(true);
    Map _params = {"code": _otpController.text, "email": widget.email};
    try {
      final resp = await APIService().verifyOTP(_params);
      _controller.setLoading(false);
      debugPrint("VERIFICATION RESP =>>>> ${resp.body}");

      if (resp.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(resp.body);
        widget.manager.saveAccessToken(map['token']);
        Constants.toast(map['message']);

        if (widget.caller != "Password") {
          Navigator.of(context).pushReplacement(
            PageTransition(
              type: PageTransitionType.size,
              alignment: Alignment.bottomCenter,
              child: _controller.accountType.value == "Boy"
                  ? SetupProfile(
                      manager: _manager!,
                      email: "${widget.email}",
                    )
                  : SetupProfileEmployer(
                      manager: _manager!,
                      email: "${widget.email}",
                    ),
            ),
          );
        } else {
          Navigator.of(context).pushReplacement(
            PageTransition(
              type: PageTransitionType.size,
              alignment: Alignment.bottomCenter,
              child: NewPassword(
                      manager: _manager!,
                      email: "${widget.email}",
                    )
                  
            ),
          );
        }
      } else {
        _controller.setLoading(false);
        Map<String, dynamic> map = jsonDecode(resp.body);
        Constants.toast(map['message']);
      }
    } catch (e) {
      _controller.setLoading(false);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _timerController?.dispose();
  }

  _pluralizer(num) {
    return num < 10 ? "0$num" : "$num";
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => LoadingOverlayPro(
        isLoading: _controller.isLoading.value,
        progressIndicator: const CircularProgressIndicator.adaptive(),
        backgroundColor: Colors.black54,
        child: Scaffold(
          body: Stack(
            clipBehavior: Clip.none,
            children: [
              SlidingUpPanel(
                maxHeight: MediaQuery.of(context).size.height * 0.64,
                minHeight: MediaQuery.of(context).size.height * 0.64,
                parallaxEnabled: true,
                defaultPanelState: PanelState.OPEN,
                renderPanelSheet: true,
                parallaxOffset: .5,
                body: Container(
                  color: Constants.primaryColor,
                  width: double.infinity,
                  height: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.48,
                          child: Image.asset(
                            'assets/images/forgot_pass_img.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 40,
                        left: 8.0,
                        child: IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(
                            CupertinoIcons.arrow_left_circle,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                panelBuilder: (sc) => _panel(sc),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24.0),
                  topRight: Radius.circular(24.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _panel(ScrollController sc) {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(18),
          topRight: Radius.circular(18),
        ),
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                width: double.infinity,
                height: 75,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  image: const DecorationImage(
                    image: AssetImage(
                      "assets/images/bottom_mark.png",
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: [
                const SizedBox(
                  height: 21,
                ),
                TextPoppins(
                  text: "VERIFY ACCOUNT",
                  fontSize: 21,
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
                const SizedBox(
                  height: 18,
                ),
                const Text(
                  "Please enter verification code sent \nto you.",
                  softWrap: true,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black54,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(
                  height: 24.0,
                ),
                PinCodeTextField(
                  appContext: context,
                  backgroundColor: Colors.white,
                  pastedTextStyle: const TextStyle(
                    color: Constants.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                  length: 6,
                  autoFocus: true,
                  obscureText: false,
                  animationType: AnimationType.fade,
                  validator: (v) {
                    if (v!.length < 3) {
                      return "I'm from validator";
                    } else {
                      return null;
                    }
                  },
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderWidth: 0.75,
                    fieldOuterPadding:
                        const EdgeInsets.symmetric(horizontal: 0.0),
                    borderRadius: BorderRadius.circular(5),
                    fieldHeight: 56,
                    fieldWidth: 40,
                    activeFillColor: Colors.white,
                    activeColor: Constants.primaryColor,
                    inactiveColor: Colors.black45,
                  ),
                  cursorColor: Colors.black,
                  animationDuration: const Duration(milliseconds: 300),
                  // enableActiveFill: true,
                  // errorAnimationController: errorController,
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  boxShadows: null,
                  // const [
                  //   BoxShadow(
                  //     offset: Offset(0, 1),
                  //     color: Colors.black12,
                  //     blurRadius: 10,
                  //   )
                  // ],
                  onCompleted: (v) {
                    debugPrint("Completed");
                  },
                  onChanged: (value) {
                    debugPrint(value);
                  },
                  beforeTextPaste: (text) {
                    debugPrint("Allowing to paste $text");
                    //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                    //but you can show anything you want here, like your pop up saying wrong paste format or etc
                    return true;
                  },
                  autoDismissKeyboard: true,
                ),
                const SizedBox(
                  height: 32.0,
                ),
                RoundedButton(
                  bgColor: Constants.primaryColor,
                  child: TextPoppins(
                    text: "VERIFY OTP",
                    fontSize: 14,
                  ),
                  borderColor: Colors.transparent,
                  foreColor: Colors.white,
                  onPressed: () {
                      _linkAccount();
                  },
                  variant: "Filled",
                ),
                const SizedBox(
                  height: 16.0,
                ),
                TextPoppins(
                  text: "Did not receive the code?",
                  fontSize: 14,
                  align: TextAlign.center,
                  color: Colors.black45,
                ),
                const SizedBox(
                  height: 16.0,
                ),
                CountdownTimer(
                  controller: _timerController,
                  endTime: endTime,
                  widgetBuilder: (_, CurrentRemainingTime? time) {
                    if (time == null) {
                      return RoundedButton(
                        bgColor: Colors.transparent,
                        child: TextPoppins(
                          text: "RESEND CODE",
                          fontSize: 14,
                        ),
                        borderColor: Constants.primaryColor,
                        foreColor: Constants.primaryColor,
                        onPressed: () {
                          _timerController?.start();
                          _controller.setLoading(true);
                          _resendCode();
                        },
                        variant: "Outlined",
                      );
                    }
                    return TextPoppins(
                      text:
                          'Resend code in ${_pluralizer(time.min ?? 0) ?? "0"} : ${_pluralizer(time.sec ?? 0)}',
                      fontSize: 15,
                      align: TextAlign.center,
                      color: Constants.primaryColor,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

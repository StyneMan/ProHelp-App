import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/instance_manager.dart';
import 'package:page_transition/page_transition.dart';
import 'package:prohelp_app/components/button/roundedbutton.dart';
import 'package:prohelp_app/components/inputfield/passwordfield.dart';
import 'package:prohelp_app/components/inputfield/textfield.dart';
import 'package:prohelp_app/helper/service/api_service.dart';
import 'package:prohelp_app/helper/socket/socket_manager.dart';
import 'package:prohelp_app/screens/account/setup_profile.dart';
import 'package:prohelp_app/screens/account/setup_profile_employer.dart';
import 'package:prohelp_app/screens/auth/otp/verifyotp.dart';

import '../../components/dashboard/dashboard.dart';
import '../../components/text_components.dart';
import '../../helper/constants/constants.dart';
import '../../helper/preference/preference_manager.dart';
import '../../helper/state/state_manager.dart';
import '../../screens/auth/forgotPass/forgotPass.dart';

class LoginForm extends StatefulWidget {
  final PreferenceManager manager;
  LoginForm({Key? key, required this.manager}) : super(key: key);

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _controller = Get.find<StateController>();

  final socket = SocketManager().socket;

  _login() async {
    FocusManager.instance.primaryFocus?.unfocus();
    _controller.setLoading(true);
    Map _payload = {
      "email": _emailController.text,
      "password": _passwordController.text,
    };
    try {
      final resp = await APIService().login(_payload);
      debugPrint("LOGIN RESPONSE:: ${resp.body}");
      _controller.setLoading(false);
      if (resp.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(resp.body);

        //Save access token
        widget.manager.saveAccessToken(map['token']);
        Constants.toast(map['message']);

        socket.emit('identity', map['data']["_id"]);

        if (!map['data']["isVerified"]) {
          Navigator.of(context).pushReplacement(
            PageTransition(
              type: PageTransitionType.size,
              alignment: Alignment.bottomCenter,
              child: VerifyOTP(
                caller: "Login",
                manager: widget.manager,
                email: map['data']['email'],
              ),
            ),
          );
        } else {
          if (!map['data']["hasProfile"]) {
            Navigator.of(context).pushReplacement(
              PageTransition(
                type: PageTransitionType.size,
                alignment: Alignment.bottomCenter,
                child: map['data']["accountType"].toString().toLowerCase() ==
                        "freelancer"
                    ? SetupProfile(
                        manager: widget.manager,
                        email: map['data']['email'],
                      )
                    : SetupProfileEmployer(
                        manager: widget.manager,
                        email: map['data']['email'],
                      ),
              ),
            );
          } else {
            String userData = jsonEncode(map['data']);
            widget.manager.setUserData(userData);
            widget.manager.setIsLoggedIn(true);
            _controller.setUserData(map['data']);

            _controller.onInit();

            Navigator.of(context).pushReplacement(
              PageTransition(
                type: PageTransitionType.size,
                alignment: Alignment.bottomCenter,
                child: Dashboard(
                  manager: widget.manager,
                ),
              ),
            );
          }
        }
      } else {
        Map<String, dynamic> map = jsonDecode(resp.body);
        Constants.toast(map['message']);
      }
    } catch (e) {
      _controller.setLoading(false);
      // print(e.message);
      Constants.toast(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextField(
            hintText: "Email",
            onChanged: (val) {},
            controller: _emailController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email or phone';
              }
              if (!RegExp('^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]')
                  .hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
            inputType: TextInputType.emailAddress,
          ),
          const SizedBox(
            height: 16.0,
          ),
          PasswordField(
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please type password';
              }
              return null;
            },
            controller: _passwordController,
            onChanged: (value) {},
          ),
          const SizedBox(
            height: 16.0,
          ),
          RoundedButton(
            bgColor: Constants.primaryColor,
            child: TextPoppins(
              text: "LOG IN",
              fontSize: 14,
            ),
            borderColor: Colors.transparent,
            foreColor: Colors.white,
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _login();
              }
            },
            variant: "Filled",
          ),
          const SizedBox(
            height: 18.0,
          ),
          Center(
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: " ",
                style: const TextStyle(
                  color: Colors.black54,
                ),
                children: [
                  TextSpan(
                    text: "Forgot Password? ",
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => Navigator.of(context).push(
                            PageTransition(
                              type: PageTransitionType.size,
                              alignment: Alignment.bottomCenter,
                              child: const ForgotPassword(),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/instance_manager.dart';
import 'package:page_transition/page_transition.dart';
import 'package:prohelp_app/components/button/roundedbutton.dart';
import 'package:prohelp_app/components/inputfield/passwordfield.dart';
import 'package:prohelp_app/components/inputfield/textfield.dart';
import 'package:prohelp_app/helper/preference/preference_manager.dart';
import 'package:prohelp_app/helper/service/api_service.dart';

import '../../components/text_components.dart';
import '../../helper/constants/constants.dart';
import '../../helper/state/state_manager.dart';
import '../../screens/auth/otp/verifyotp.dart';

typedef InitCallback(bool params);

class SignupForm extends StatefulWidget {
  final PreferenceManager manager;
  SignupForm({
    Key? key,
    required this.manager,
  }) : super(key: key);

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();

  String _countryCode = "+234";
  bool _obscureText = true, _loading = false;

  final _formKey = GlobalKey<FormState>();
  final _controller = Get.find<StateController>();
  String _number = '';

  _register() async {
    FocusManager.instance.primaryFocus?.unfocus();
    _controller.setLoading(true);

    Map _payload = {
      "email": _emailController.text,
      "password": _passwordController.text,
      "accountType": _controller.accountType.value,
    };

    try {
      debugPrint("DFDF  ${_payload}");
      final resp = await APIService().signup(_payload);
      debugPrint("DFDF  ${resp.body}");
      // Constants.toast(resp.body);
      _controller.setLoading(false);

      if (resp.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(resp.body);
        Constants.toast(map['message']);
        //Route to verification
        Navigator.of(context).pushReplacement(
          PageTransition(
            type: PageTransitionType.size,
            alignment: Alignment.bottomCenter,
            child: VerifyOTP(
              caller: "Signup",
              manager: widget.manager,
              email: _emailController.text,
            ),
          ),
        );
      } else {
        Map<String, dynamic> map = jsonDecode(resp.body);
        Constants.toast("${map['message']}");
      }
    } catch (e) {
      debugPrint("ERROR: $e");
      _controller.setLoading(false);
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
          PasswordField(
            hint: "Confirm password",
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please re-type password';
              }
              if (_passwordController.text != value) {
                return 'Password does not match';
              }
              return null;
            },
            controller: _passwordConfirmController,
            onChanged: (value) {},
          ),
          const SizedBox(
            height: 21.0,
          ),
          RoundedButton(
            bgColor: Constants.primaryColor,
            child: TextPoppins(
              text: "CREATE ACCOUNT",
              fontSize: 16,
            ),
            borderColor: Colors.transparent,
            foreColor: Colors.white,
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _register();
              }
            },
            variant: "Filled",
          ),
          const SizedBox(
            height: 21.0,
          ),
          Center(
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text:
                    "By clicking the create account button, you agree to our ",
                style: const TextStyle(
                  color: Colors.black54,
                ),
                children: [
                  TextSpan(
                    text: "terms of use.",
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: Constants.primaryColor,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => Constants.toast("Not yet implemented!"),
                    // Navigator.of(context).pushReplacement(
                    //   PageTransition(
                    //     type: PageTransitionType.size,
                    //     alignment: Alignment.bottomCenter,
                    //     child: Container(),
                    //   ),
                    // ),
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

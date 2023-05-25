import 'dart:convert';

import 'package:prohelp_app/components/button/roundedbutton.dart';
import 'package:prohelp_app/components/inputfield/textfield.dart';
import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/helper/constants/constants.dart';
import 'package:prohelp_app/helper/preference/preference_manager.dart';
import 'package:prohelp_app/helper/service/api_service.dart';
import 'package:prohelp_app/helper/state/state_manager.dart';
import 'package:prohelp_app/screens/auth/otp/verifyotp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/instance_manager.dart';
import 'package:page_transition/page_transition.dart';

class PasswordForm extends StatefulWidget {
  // final PreferenceManager manager;
  const PasswordForm({
    Key? key,
    // required this.manager,
  }) : super(key: key);

  @override
  State<PasswordForm> createState() => _PasswordFormState();
}

class _PasswordFormState extends State<PasswordForm> {
  final TextEditingController _emailController = TextEditingController();
  final _controller = Get.find<StateController>();
  final _formKey = GlobalKey<FormState>();
  PreferenceManager? _manager;

  @override
  initState() {
    super.initState();
    _manager = PreferenceManager(context);
  }

  _forgotPass() async {
    _controller.setLoading(true);
    try {
      final resp =
          await APIService().forgotPass({"email": _emailController.text});
      debugPrint("PASS RESET EMAIL : RESPONSE ${resp.body}");
      _controller.setLoading(false);

      if (resp.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(resp.body);
        Constants.toast(map['message']);

        Navigator.of(context).push(
          PageTransition(
            type: PageTransitionType.size,
            alignment: Alignment.bottomCenter,
            child: VerifyOTP(
              caller: "Password",
              manager: _manager!,
              email: _emailController.text,
            ),
          ),
        );
        
      } else {
        Map<String, dynamic> map = jsonDecode(resp.body);
        Constants.toast(map['message']);
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "user-not-found":
          Constants.toast("Email not registered on the platform");
          break;
        case "invalid-email":
          Constants.toast('Email is not valid. Try again');
          break;
        default:
          Constants.toast('${e.message}');
      }
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
                return 'Please enter your email';
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
          RoundedButton(
            bgColor: Constants.primaryColor,
            child: TextPoppins(text: "RESET PASSWORD", fontSize: 18),
            borderColor: Colors.transparent,
            foreColor: Colors.white,
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _forgotPass();
              }
            },
            variant: "Filled",
          )
        ],
      ),
    );
  }
}

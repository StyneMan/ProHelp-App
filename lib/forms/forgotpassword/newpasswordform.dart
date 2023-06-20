import 'dart:convert';

import 'package:prohelp_app/components/button/roundedbutton.dart';
import 'package:prohelp_app/components/inputfield/passwordfield.dart';
import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/helper/constants/constants.dart';
import 'package:prohelp_app/helper/preference/preference_manager.dart';
import 'package:prohelp_app/helper/service/api_service.dart';
import 'package:prohelp_app/helper/state/state_manager.dart';
import 'package:prohelp_app/screens/auth/login/login.dart';
import 'package:flutter/material.dart';
import 'package:get/instance_manager.dart';
import 'package:page_transition/page_transition.dart';

class NewPasswordForm extends StatelessWidget {
  final PreferenceManager manager;
  final String email;
  NewPasswordForm({
    Key? key,
    required this.manager,
    required this.email,
  }) : super(key: key);

  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _controller = Get.find<StateController>();

  final _formKey = GlobalKey<FormState>();

  _forgotPass(context) async {
    _controller.setLoading(true);
    try {
      final resp = await APIService()
          .resetPass({"email": email, "password": _passwordController.text});
      debugPrint("NEW PASSWORD :: ${resp.body}");
      _controller.setLoading(false);

      if (resp.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(resp.body);
        Constants.toast(map['message']);

        Navigator.of(context).push(
          PageTransition(
            type: PageTransitionType.size,
            alignment: Alignment.bottomCenter,
            child: const Login(),
          ),
        );
      } else {
        Map<String, dynamic> map = jsonDecode(resp.body);
        Constants.toast(map['message']);
      }
    } catch (e) {
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
          PasswordField(
            hint: "New Password",
            onChanged: (val) {},
            controller: _passwordController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (value.toString().length < 6) {
                return "Password must be at least 6 characters!";
              }
              return null;
            },
          ),
          const SizedBox(
            height: 16.0,
          ),
          PasswordField(
            hint: "Confirm Password",
            onChanged: (val) {},
            controller: _confirmPasswordController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (value.toString().length < 6) {
                return "Password must be at least 6 characters!";
              }
              if (_passwordController.text != value) {
                return "Password does not match!";
              }
              return null;
            },
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
                _forgotPass(context);
              }
            },
            variant: "Filled",
          )
        ],
      ),
    );
  }
}

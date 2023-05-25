import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/instance_manager.dart';
import 'package:prohelp_app/components/button/roundedbutton.dart';
import 'package:prohelp_app/components/dialog/custom_dialog.dart';
import 'package:prohelp_app/components/inputfield/passwordfield.dart';
import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/helper/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:prohelp_app/helper/state/state_manager.dart';

class ChangePasswordForm extends StatefulWidget {
  const ChangePasswordForm({Key? key}) : super(key: key);

  @override
  State<ChangePasswordForm> createState() => _ChangePasswordFormFormState();
}

class _ChangePasswordFormFormState extends State<ChangePasswordForm> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _controller = Get.find<StateController>();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PasswordField(
            hint: "Old Password",
            borderRadius: 6.0,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter new password';
              }
              return null;
            },
            controller: _oldPasswordController,
            onChanged: (val) {},
          ),
          const SizedBox(
            height: 16.0,
          ),
          PasswordField(
            hint: "New Password",
            borderRadius: 6.0,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter new password';
              }
              return null;
            },
            controller: _newPasswordController,
            onChanged: (val) {},
          ),
          const SizedBox(
            height: 16.0,
          ),
          PasswordField(
            hint: "Confirm Password",
            borderRadius: 6.0,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm new password';
              }
              if (value != _newPasswordController.text) {
                return "Password does not match!";
              }
              return null;
            },
            controller: _confirmPasswordController,
            onChanged: (val) {},
          ),
          const SizedBox(
            height: 36.0,
          ),
          RoundedButton(
            bgColor: Constants.primaryColor,
            child: TextPoppins(text: "SAVE CHANGES", fontSize: 16),
            borderColor: Colors.transparent,
            foreColor: Colors.white,
            onPressed: () {
              // if (_formKey.currentState!.validate()) {
              _changePassword();
              // }
            },
            variant: "Filled",
          )
        ],
      ),
    );
  }

  _changePassword() {
    _controller.setLoading(true);
    Future.delayed(const Duration(seconds: 1), () {
      _controller.setLoading(false);
      //Now show custom dialog
      showDialog(
        context: context,
        builder: (BuildContext context) => SizedBox(
          height: MediaQuery.of(context).size.height * 0.4,
          width: MediaQuery.of(context).size.width * 0.98,
          child: CustomDialog(
            ripple: SvgPicture.asset(
              "assets/images/check_effect.svg",
              width: (Constants.avatarRadius + 20),
              height: (Constants.avatarRadius + 20),
            ),
            avtrBg: Colors.transparent,
            avtrChild: Image.asset(
                "assets/images/checked.png",), //const Icon(CupertinoIcons.check_mark, size: 50,),
            body: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 16.0,
                horizontal: 36.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextPoppins(
                    text: "Password",
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  TextPoppins(
                    text: "Changed Successfully",
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                  ),
                  const SizedBox(
                    height: 21,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.36,
                    child: RoundedButton(
                      bgColor: Constants.primaryColor,
                      child: TextPoppins(
                        text: "CLOSE",
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                      ),
                      borderColor: Colors.transparent,
                      foreColor: Colors.white,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      variant: "Filled",
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

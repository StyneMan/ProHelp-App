import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/instance_manager.dart';
import 'package:prohelp_app/components/button/roundedbutton.dart';
import 'package:prohelp_app/components/dialog/custom_dialog.dart';
import 'package:prohelp_app/components/inputfield/textarea.dart';
import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/helper/constants/constants.dart';
import 'package:prohelp_app/helper/preference/preference_manager.dart';
import 'package:prohelp_app/helper/service/api_service.dart';
import 'package:prohelp_app/helper/state/state_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AboutForm extends StatefulWidget {
  final PreferenceManager manager;
  AboutForm({
    Key? key,
    required this.manager,
  }) : super(key: key);

  @override
  State<AboutForm> createState() => _AboutFormState();
}

class _AboutFormState extends State<AboutForm> {
  final _messageController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final _controller = Get.find<StateController>();

  @override
  initState() {
    super.initState();
    setState(() {
      _messageController.text = widget.manager.getUser()['bio']['about'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        shrinkWrap: true,
        children: [
          const SizedBox(
            height: 24,
          ),
          CustomTextArea(
            borderRadius: 8.0,
            maxLines: 12,
            hintText: "Describe yourself here",
            onChanged: (val) {},
            controller: _messageController,
            validator: (val) {},
            inputType: TextInputType.multiline,
          ),
          const SizedBox(
            height: 32,
          ),
          RoundedButton(
            bgColor: Constants.primaryColor,
            child: TextPoppins(
              text: "UPDATE PROFILE",
              fontSize: 13,
              fontWeight: FontWeight.w300,
            ),
            borderColor: Colors.transparent,
            foreColor: Colors.white,
            onPressed: () {
              _updateProfile();
            },
            variant: "Filled",
          ),
        ],
      ),
    );
  }

  _updateProfile() async {
    _controller.setLoading(true);
    Map _payload = {
      "bio": {
        ...widget.manager.getUser()['bio'],
        "about": _messageController.text,
      }
    };
    try {
      final _prefs = await SharedPreferences.getInstance();
      var _token = _prefs.getString("accessToken") ?? "";
      final resp = await APIService().updateProfile(
          accessToken: _token,
          body: _payload,
          email: widget.manager.getUser()['email']);

      debugPrint("ABOUT UPDATE:  >> ${resp.body}");
      _controller.setLoading(false);

      if (resp.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(resp.body);
        Constants.toast(map['message']);

        //Refresh user profile
        String userData = jsonEncode(map['data']);
        widget.manager.setUserData(userData);
        _controller.userData.value = map['data'];

        setState(() {
          _messageController.text = map['data']['bio']['about'];
        });

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
                "assets/images/checked.png",
              ), //const Icon(CupertinoIcons.check_mark, size: 50,),
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
                      text: "Profile Update",
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                    const SizedBox(
                      height: 5.0,
                    ),
                    TextPoppins(
                      text: "Updated successfully",
                      fontSize: 17,
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
      } else {
        Map<String, dynamic> map = jsonDecode(resp.body);
        Constants.toast(map['message']);
      }
    } catch (e) {
      _controller.setLoading(false);
      debugPrint(e.toString());
    }
  }
}

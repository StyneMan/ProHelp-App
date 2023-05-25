import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/instance_manager.dart';
import 'package:prohelp_app/components/button/roundedbutton.dart';
import 'package:prohelp_app/components/dialog/custom_dialog.dart';
import 'package:prohelp_app/components/inputfield/customdropdown.dart';
import 'package:prohelp_app/components/inputfield/textarea.dart';
import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/helper/constants/constants.dart';
import 'package:prohelp_app/helper/preference/preference_manager.dart';
import 'package:prohelp_app/helper/service/api_service.dart';
import 'package:prohelp_app/helper/state/state_manager.dart';

class SupportForm extends StatefulWidget {
  final PreferenceManager manager;
  const SupportForm({
    Key? key,
    required this.manager,
  }) : super(key: key);

  @override
  State<SupportForm> createState() => _SupportFormState();
}

class _SupportFormState extends State<SupportForm> {
  final _messageController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final _controller = Get.find<StateController>();
  String _selectedPurpose = "";

  void _onSelected(String val) {
    _selectedPurpose = val;
  }

  _showSuccessDialog() => showDialog(
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
                    text: "Support Request",
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  TextPoppins(
                    text: "Sent Successfully",
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

  _contactSupport() async {
    _controller.setLoading(true);
    Map _payload = {
      "purpose": _selectedPurpose,
      "message": _messageController.text,
      "user": {
        "fullname": widget.manager.getUser()['bio']['fullname'],
        "email": widget.manager.getUser()['email'],
        "image": widget.manager.getUser()['bio']['image'],
        "id": widget.manager.getUser()['_id'],
      },
    };

    try {
      final resp = await APIService().contactSupport(
        accessToken: widget.manager.getAccessToken(),
        body: _payload,
        email: widget.manager.getUser()['email'],
      );
      debugPrint("SUPPORT RESPONSE:: ${resp.body}");
      _controller.setLoading(false);

      if (resp.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(resp.body);
        Constants.toast(map['message']);
        _showSuccessDialog();
      } else {
        Map<String, dynamic> map = jsonDecode(resp.body);
        Constants.toast(map['message']);
      }
    } catch (e) {
      debugPrint(e.toString());
      _controller.setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        shrinkWrap: true,
        children: [
          CustomDropdown(
            borderRadius: 8.0,
            onSelected: _onSelected,
            hint: "Select purpose",
            items: const ['Support', 'Complain', 'Request'],
          ),
          const SizedBox(
            height: 24,
          ),
          CustomTextArea(
            borderRadius: 8.0,
            hintText: "Write message here",
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
              text: "SEND REQUEST",
              fontSize: 13,
              fontWeight: FontWeight.w300,
            ),
            borderColor: Colors.transparent,
            foreColor: Colors.white,
            onPressed: () {
              _contactSupport();
            },
            variant: "Filled",
          ),
        ],
      ),
    );
  }
}

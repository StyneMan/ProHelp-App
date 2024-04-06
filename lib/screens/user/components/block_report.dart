import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prohelp_app/components/button/custombutton.dart';
import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/helper/constants/constants.dart';
import 'package:prohelp_app/helper/preference/preference_manager.dart';
import 'package:prohelp_app/helper/service/api_service.dart';
import 'package:prohelp_app/helper/state/state_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BlockReport extends StatefulWidget {
  var data;
  final PreferenceManager manager;
  BlockReport({
    Key? key,
    required this.data,
    required this.manager,
  }) : super(key: key);

  @override
  State<BlockReport> createState() => _BlockReportState();
}

class _BlockReportState extends State<BlockReport> {
  bool _reportOnly = false;
  final _controller = Get.find<StateController>();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Constants.primaryColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(
                    Constants.padding,
                  ),
                  topRight: Radius.circular(
                    Constants.padding,
                  ),
                ),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextInter(
                    text:
                        "Block/Report ${widget.data['bio']['firstname']} ${widget.data['bio']['lastname']}"
                            .capitalize,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.cancel_outlined,
                      color: Colors.white,
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Wrap(
                children: [
                  TextInter(
                    text:
                        "If you block and report ${widget.data['bio']['firstname']} ${widget.data['bio']['lastname']}, you will no longer receive or send message to each other. However, you can choose to only report without blocking. ${widget.data['bio']['firstname'].toString().capitalize}  ${widget.data['bio']['lastname'].toString().capitalize} will not know you reported",
                    fontSize: 16,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Checkbox(
                    value: _reportOnly,
                    onChanged: (val) {
                      setState(() {
                        _reportOnly = val!;
                      });
                    },
                  ),
                  const SizedBox(
                    width: 4.0,
                  ),
                  const Text("Report only"),
                ],
              ),
            ),
            const SizedBox(
              height: 2.0,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Expanded(
                    child: SizedBox(),
                  ),
                  Expanded(
                    child: CustomButton(
                      bgColor: Colors.transparent,
                      child: const TextInter(text: "Cancel", fontSize: 14),
                      borderColor: Constants.primaryColor,
                      foreColor: Constants.primaryColor,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      variant: "Outlined",
                    ),
                  ),
                  const SizedBox(
                    width: 6.0,
                  ),
                  Expanded(
                    child: CustomButton(
                      bgColor: Constants.primaryColor,
                      child: const TextInter(
                        text: "Continue",
                        fontSize: 14,
                        color: Colors.white,
                      ),
                      borderColor: Constants.primaryColor,
                      foreColor: Colors.white,
                      onPressed: () {
                        // Navigator.pop(context);
                        _reportBlock();
                      },
                      variant: "Filled",
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ],
    );
  }

  _reportBlock() async {
    try {
      _controller.setLoading(true);
      Get.back();
      if (_reportOnly) {
        Map _payload = {
          "userId": widget.data['id'] ?? widget.data['_id'],
          "reason":
              "I wish to report this user to you. Please admin take note of this"
        };

        final _response = await APIService().reportUser(
          accessToken: widget.manager.getAccessToken(),
          email: widget.manager.getUser()['email'],
          payload: _payload,
        );
        print('REPORT USER RESPONSE :: ${_response.body}');

        _controller.setLoading(false);

        if (_response.statusCode == 200) {
          Map<String, dynamic> map = jsonDecode(_response.body);
          Constants.toast("${map['message']}");
        }
      } else {
        Map _payload = {
          "userId": widget.data['id'] ?? widget.data['_id'],
        };

        final _response = await APIService().blockUser(
          accessToken: widget.manager.getAccessToken(),
          email: widget.manager.getUser()['email'],
          payload: _payload,
        );
        print('BLOCK USER RESPONSE :: ${_response.body}');

        _controller.setLoading(false);

        if (_response.statusCode == 200) {
          Map<String, dynamic> map = jsonDecode(_response.body);
          Constants.toast("${map['message']}");
        }
      }
    } catch (e) {
      debugPrint(e.toString());
      _controller.setLoading(false);
    }
  }
}

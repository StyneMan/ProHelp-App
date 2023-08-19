import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:prohelp_app/components/button/roundedbutton.dart';
import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/helper/constants/constants.dart';
import 'package:prohelp_app/helper/preference/preference_manager.dart';
import 'package:prohelp_app/helper/service/api_service.dart';
import 'package:prohelp_app/helper/state/state_manager.dart';
import 'package:prohelp_app/screens/account/components/wallet.dart';

typedef void InitCallback(bool value);

class ContactInfoContent extends StatelessWidget {
  var guestData;
  final PreferenceManager manager;
  InitCallback onConnected;
  ContactInfoContent({
    Key? key,
    required this.guestData,
    required this.manager,
    required this.onConnected,
  }) : super(key: key);

  _obscurePhone(String phone) {
    var part1 =
        phone.length > 11 ? phone.substring(0, 6) : phone.substring(0, 4);
    var part2 =
        phone.length > 11 ? phone.substring(11, 14) : phone.substring(8, 11);

    return part1 + "xxxxx" + part2;
  }

  final _controller = Get.find<StateController>();

  _obscureEmail(String email) {
    var rem = email.split("@")[1];
    var secon1 = rem.split(".")[0];

    return "xxxxxx@" + secon1 + ".xxx";
  }

  _addConnection() async {
    Map _payload = {
      "guestId": "${guestData['id']}",
      "guestName":
          "${guestData['bio']['firstname']} ${guestData['bio']['lastname']}",
      "userId": "${manager.getUser()['id']}",
    };

    try {
      final _resp = await APIService().saveConnection(
          _payload, manager.getAccessToken(), manager.getUser()['email']);

      debugPrint("CONNECTION RESPONSE >> ${_resp.body}");
      _controller.setLoading(false);
      if (_resp.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(_resp.body);
        Constants.toast(map['message']);

        String userStr = jsonEncode(map['data']);
        manager.setUserData(userStr);
        _controller.userData.value = map['data'];
        onConnected(true);
        _controller.onInit();

        Get.back();
      }
    } catch (e) {
      _controller.setLoading(false);
      debugPrint(e.toString());
    }
  }

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
                  const TextInter(
                    text: "Contact Information",
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 21.0,
                  ),
                  TextInter(
                    text: "${_obscurePhone(guestData['bio']['phone'])}",
                    fontSize: 16,
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  const Divider(),
                  const SizedBox(
                    height: 10.0,
                  ),
                  TextInter(
                    text: "${_obscureEmail(guestData['email'])}",
                    fontSize: 16,
                  ),
                  const SizedBox(
                    height: 24.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16.0,
                      horizontal: 24.0,
                    ),
                    child: RoundedButton(
                      bgColor: Colors.transparent,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: const [
                          Icon(
                            CupertinoIcons.eye_slash,
                          ),
                          SizedBox(
                            width: 10.0,
                          ),
                          TextInter(
                            text: "Show contact",
                            fontSize: 15,
                            color: Constants.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ],
                      ),
                      borderColor: Constants.primaryColor,
                      foreColor: Constants.primaryColor,
                      onPressed: () {
                        Navigator.pop(context);
                        showBarModalBottomSheet(
                          expand: false,
                          context: context,
                          useRootNavigator: true,
                          backgroundColor: Colors.white,
                          topControl: ClipOval(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(
                                    16,
                                  ),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.close,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          builder: (context) => SizedBox(
                            height: 300,
                            width: MediaQuery.of(context).size.height * 0.84,
                            child: Container(
                              color: Colors.white,
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  Image.asset("assets/images/coin_gold.png",
                                      width: 48),
                                  TextPoppins(
                                    text: "Coin Alert",
                                    fontSize: 21,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  const SizedBox(
                                    height: 16.0,
                                  ),
                                  _controller.userData.value['wallet']
                                              ['balance'] >=
                                          200
                                      ? Column(
                                          children: [
                                            TextPoppins(
                                              text:
                                                  "You will be charged 200 coins from your wallet for this connection. \nDo you wish to proceed?",
                                              fontSize: 16,
                                            ),
                                            const SizedBox(
                                              height: 16.0,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Expanded(
                                                  child: RoundedButton(
                                                    bgColor: Colors.transparent,
                                                    child: const TextInter(
                                                        text: "Cancel",
                                                        fontSize: 16),
                                                    borderColor:
                                                        Constants.primaryColor,
                                                    foreColor:
                                                        Constants.primaryColor,
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    variant: "Outlined",
                                                  ),
                                                ),
                                                const SizedBox(width: 16.0),
                                                Expanded(
                                                  child: RoundedButton(
                                                    bgColor:
                                                        Constants.primaryColor,
                                                    child: const TextInter(
                                                      text: "Proceed",
                                                      fontSize: 16,
                                                    ),
                                                    borderColor:
                                                        Colors.transparent,
                                                    foreColor: Colors.white,
                                                    onPressed: () {
                                                      // Navigator.pop(context);
                                                      //Now connect user here
                                                      _addConnection();
                                                    },
                                                    variant: "Filled",
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        )
                                      : Column(
                                          children: [
                                            TextPoppins(
                                              text:
                                                  "You are out of coins. You need a minimum of 200 coins on your wallet for this connection. \n Do you wish to topup your wallet?",
                                              fontSize: 16,
                                            ),
                                            const SizedBox(
                                              height: 16.0,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Expanded(
                                                  child: RoundedButton(
                                                    bgColor: Colors.transparent,
                                                    child: const TextInter(
                                                        text: "Cancel",
                                                        fontSize: 16),
                                                    borderColor:
                                                        Constants.primaryColor,
                                                    foreColor:
                                                        Constants.primaryColor,
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    variant: "Outlined",
                                                  ),
                                                ),
                                                const SizedBox(width: 16.0),
                                                Expanded(
                                                  child: RoundedButton(
                                                    bgColor:
                                                        Constants.primaryColor,
                                                    child: const TextInter(
                                                        text: "Topup wallet",
                                                        fontSize: 16),
                                                    borderColor:
                                                        Colors.transparent,
                                                    foreColor: Colors.white,
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                      Get.to(
                                                        MyWallet(
                                                          manager: manager,
                                                        ),
                                                        transition: Transition
                                                            .cupertino,
                                                      );
                                                    },
                                                    variant: "Filled",
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        )
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      variant: "Outlined",
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

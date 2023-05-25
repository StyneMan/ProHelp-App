import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';
import 'package:prohelp_app/components/button/roundedbutton.dart';
import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/helper/constants/constants.dart';
import 'package:prohelp_app/helper/preference/preference_manager.dart';
import 'package:prohelp_app/screens/payment/pay_to_view.dart';

class ContactInfoContent extends StatelessWidget {
  var guestData;
  final PreferenceManager manager;
  ContactInfoContent({
    Key? key,
    required this.guestData,
    required this.manager,
  }) : super(key: key);

  _obscurePhone(String phone) {
    var part1 =
        phone.length > 11 ? phone.substring(0, 6) : phone.substring(0, 4);
    var part2 =
        phone.length > 11 ? phone.substring(11, 14) : phone.substring(8, 11);

    return part1 + "xxxxx" + part2;
  }

  _obscureEmail(String email) {
    var rem = email.split("@")[1];
    var secon1 = rem.split(".")[0];

    return "xxxxxx@" + secon1 + ".xxx";
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
                        Navigator.of(context).push(
                          PageTransition(
                            type: PageTransitionType.size,
                            alignment: Alignment.bottomCenter,
                            child: PayToView(
                              manager: manager,
                              data: guestData,
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

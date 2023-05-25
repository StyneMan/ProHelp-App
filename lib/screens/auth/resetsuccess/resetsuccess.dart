import 'package:flutter_svg/flutter_svg.dart';
import 'package:prohelp_app/components/button/roundedbutton.dart';
import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/helper/constants/constants.dart';
import 'package:prohelp_app/screens/auth/login/login.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class ResetSuccess extends StatelessWidget {
  const ResetSuccess({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.primaryColor,
      body: Container(
        padding: const EdgeInsets.all(21.0),
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                width: double.infinity,
                height: 60,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      "assets/images/bottom_mark_blue.png",
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset("assets/images/pass_reset_ok.svg"),
                  const SizedBox(
                    height: 16.0,
                  ),
                  RoundedButton(
                    bgColor: Colors.white,
                    child: TextPoppins(
                      text: "GO BACK TO LOGIN",
                      fontSize: 14,
                    ),
                    borderColor: Colors.transparent,
                    foreColor: Constants.primaryColor,
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        PageTransition(
                          type: PageTransitionType.size,
                          alignment: Alignment.bottomCenter,
                          child: const Login(),
                        ),
                      );
                    },
                    variant: "Filled",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

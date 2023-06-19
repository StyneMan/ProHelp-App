import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:page_transition/page_transition.dart';
import 'package:prohelp_app/components/button/roundedbutton.dart';
import 'package:prohelp_app/helper/constants/constants.dart';

import '../../../components/dashboard/dashboard.dart';
import '../../../components/text_components.dart';
import '../../../helper/preference/preference_manager.dart';

class AccountSuccess extends StatefulWidget {
  final String firstname;
  final String accountType;
  const AccountSuccess({
    Key? key,
    required this.firstname,
    required this.accountType,
  }) : super(key: key);

  @override
  State<AccountSuccess> createState() => _AccountSuccessState();
}

class _AccountSuccessState extends State<AccountSuccess> {
  PreferenceManager? _manager;

  @override
  void initState() {
    super.initState();
    _manager = PreferenceManager(context);
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// A custom Path to paint stars.
  Path drawStar(Size size) {
    // Method to convert degree to radians
    double degToRad(double deg) => deg * (pi / 180.0);

    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);

    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(halfWidth + externalRadius * cos(step),
          halfWidth + externalRadius * sin(step));
      path.lineTo(halfWidth + internalRadius * cos(step + halfDegreesPerStep),
          halfWidth + internalRadius * sin(step + halfDegreesPerStep));
    }
    path.close();
    return path;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.75,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      CupertinoIcons.check_mark_circled_solid,
                      size: 128,
                      color: Colors.green,
                    ),
                    TextInter(
                      text:
                          "Your ProHelp account has been created, ${widget.firstname.capitalize!}",
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                      align: TextAlign.center,
                    ),
                    const SizedBox(
                      height: 5.0,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.80,
                      child: TextInter(
                        text: widget.accountType == "freelancer"
                            ? "You’re one step away from being hired as a professional. "
                            : "You’re one step away from hiring a professoinal for your project/service",
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        align: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 56,
              left: 18,
              right: 18,
              child: RoundedButton(
                bgColor: Constants.primaryColor,
                child: TextPoppins(text: "Continue to Dashboard", fontSize: 16),
                borderColor: Colors.transparent,
                foreColor: Colors.white,
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    PageTransition(
                      type: PageTransitionType.size,
                      alignment: Alignment.bottomCenter,
                      child: Dashboard(manager: _manager!, showProfile: true),
                    ),
                  );
                },
                variant: "Filled",
              ),
            ),
          ],
        ),
      ),
    );
  }
}

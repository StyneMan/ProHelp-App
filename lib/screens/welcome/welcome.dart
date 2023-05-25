import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:page_transition/page_transition.dart';
import 'package:prohelp_app/components/button/roundedbutton.dart';
import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/screens/auth/account_type/account_type.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../auth/login/login.dart';

class Welcome extends StatefulWidget {
  const Welcome({Key? key}) : super(key: key);

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  _clearPreferences() async {
    final _prefs = await SharedPreferences.getInstance();
    final _token = _prefs.getBool("loggedIn") ?? false;
    if (!_token) {
      _prefs.clear();
    }
  }

  @override
  void initState() {
    super.initState();
    _clearPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          Image.asset(
            "assets/images/welcome_img.png",
            fit: BoxFit.cover,
            width: MediaQuery.of(context).size.width,
          ),
          Positioned(
            bottom: 64,
            left: 48,
            right: 48,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                RoundedButton(
                  bgColor: Colors.white,
                  child: TextPoppins(
                    text: "create Account".toUpperCase(),
                    fontSize: 16,
                  ),
                  borderColor: Colors.white,
                  foreColor: Colors.black,
                  onPressed: () {
                    Navigator.of(context).push(
                      PageTransition(
                        type: PageTransitionType.size,
                        alignment: Alignment.bottomCenter,
                        child: AccountType(),
                      ),
                    );
                  },
                  variant: "Filled",
                ),
                const SizedBox(
                  height: 21.0,
                ),
                RoundedButton(
                  bgColor: Colors.white,
                  child: TextPoppins(
                    text: "Sign In".toUpperCase(),
                    fontSize: 16,
                  ),
                  borderColor: Colors.white,
                  foreColor: Colors.white,
                  onPressed: () {
                    Navigator.of(context).push(
                      PageTransition(
                        type: PageTransitionType.size,
                        alignment: Alignment.bottomCenter,
                        child: const Login(),
                      ),
                    );
                  },
                  variant: "Outlined",
                ),
              ],
            ),
          ),
          Positioned(
            child: Center(
              child: SvgPicture.asset(
                'assets/images/logowhite.svg',
                width: MediaQuery.of(context).size.width * 0.64,
              ),
            ),
          )
        ],
      ),
    );
  }
}

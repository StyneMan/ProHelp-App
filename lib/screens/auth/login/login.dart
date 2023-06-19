import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:loading_overlay_pro/loading_overlay_pro.dart';
import 'package:page_transition/page_transition.dart';
import 'package:prohelp_app/components/button/roundedbutton.dart';
import 'package:prohelp_app/components/dashboard/dashboard.dart';
import 'package:prohelp_app/components/dividers/horz_text_divider.dart';
import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/forms/login/loginform.dart';
import 'package:prohelp_app/helper/constants/constants.dart';
import 'package:prohelp_app/helper/preference/preference_manager.dart';
import 'package:prohelp_app/helper/service/api_service.dart';
import 'package:prohelp_app/helper/state/state_manager.dart';
import 'package:prohelp_app/screens/account/setup_profile.dart';
import 'package:prohelp_app/screens/account/setup_profile_employer.dart';
import 'package:prohelp_app/screens/auth/account_type/account_type.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class Login extends StatefulWidget {
  const Login({
    Key? key,
  }) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  PreferenceManager? _manager;

  final _controller = Get.find<StateController>();

  @override
  void initState() {
    super.initState();
    _manager = PreferenceManager(context);
  }

  _signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn(
        scopes: [
          'email',
          // 'https://www.googleapis.com/auth/contacts.readonly',
        ],
      ).signIn();

      debugPrint("GOOGLE USER RESP >> ${googleUser}");

      // Obtain the auth details from the request
      final googleAuth = await googleUser?.authentication;
      debugPrint("Google ID TOKEN >> ${googleAuth?.idToken}");
      final resp = await APIService().googleAuth("${googleAuth?.idToken}");

      debugPrint("Google Server Respone >> ${resp.body}");

      Map<String, dynamic> map = jsonDecode(resp.body);
      _manager!.saveAccessToken(map['token']);
      _controller.firstname.value = "${map['data']['bio']['fullname']}".split(" ")[0].capitalize!;
      _controller.lastname.value = "${map['data']['bio']['fullname']}".split(" ")[1].capitalize!;

      if (map['message'].contains("Account created")) {
        //New account so now select user type recruiter or freelancer
        Navigator.of(context).pushReplacement(
          PageTransition(
            type: PageTransitionType.size,
            alignment: Alignment.bottomCenter,
            child: AccountType(
              isSocial: true,
              email: map['data']['email'],
              name: map['data']['bio']['fullname'],
            ),
          ),
        );
      } else {
        if (!map['data']["hasProfile"]) {
          Navigator.of(context).pushReplacement(
            PageTransition(
              type: PageTransitionType.size,
              alignment: Alignment.bottomCenter,
              child: map['data']["accountType"].toString().toLowerCase() ==
                      "freelancer"
                  ? SetupProfile(
                      manager: _manager!,
                      isSocial: true,
                      email: map['data']['email'],
                      name: map['data']['bio']['fullname'],
                    )
                  : SetupProfileEmployer(
                      manager: _manager!,
                      isSocial: true,
                      email: map['data']['email'],
                      name: map['data']['bio']['fullname'],
                    ),
            ),
          );
        } else {
          String userData = jsonEncode(map['data']);
          _manager!.setUserData(userData);
          _manager!.setIsLoggedIn(true);
          _controller.setUserData(map['data']);

          _controller.onInit();

          Navigator.of(context).pushReplacement(
            PageTransition(
              type: PageTransitionType.size,
              alignment: Alignment.bottomCenter,
              child: Dashboard(
                manager: _manager!,
              ),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("ERR >> $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => LoadingOverlayPro(
        isLoading: _controller.isLoading.value,
        progressIndicator: const CircularProgressIndicator.adaptive(),
        backgroundColor: Colors.black54,
        child: Scaffold(
          body: Stack(
            clipBehavior: Clip.none,
            children: [
              SlidingUpPanel(
                maxHeight: MediaQuery.of(context).size.height * 0.64,
                minHeight: MediaQuery.of(context).size.height * 0.64,
                parallaxEnabled: true,
                defaultPanelState: PanelState.OPEN,
                renderPanelSheet: true,
                parallaxOffset: .5,
                body: Container(
                  color: Constants.primaryColor,
                  width: double.infinity,
                  height: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.48,
                          child: Image.asset(
                            'assets/images/login_img.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 42,
                        left: 8.0,
                        child: IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(
                            CupertinoIcons.arrow_left_circle,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                panelBuilder: (sc) => _panel(sc),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24.0),
                  topRight: Radius.circular(24.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _panel(ScrollController sc) {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(18),
          topRight: Radius.circular(18),
        ),
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  image: const DecorationImage(
                    image: AssetImage(
                      "assets/images/bottom_mark.png",
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: [
                const SizedBox(
                  height: 21,
                ),
                TextPoppins(
                  text: "LOG IN",
                  fontSize: 21,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                const SizedBox(
                  height: 16.0,
                ),
                LoginForm(
                  manager: _manager!,
                ),
                const HorzTextDivider(text: "or"),
                RoundedButton(
                  bgColor: Constants.primaryColor,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset("assets/images/g_logo.svg"),
                      const SizedBox(
                        width: 8.0,
                      ),
                      TextPoppins(
                        text: "Log in with Google",
                        fontSize: 16,
                      ),
                    ],
                  ),
                  borderColor: Colors.transparent,
                  foreColor: Colors.white,
                  onPressed: () {
                    _signInWithGoogle();
                  },
                  variant: "Filled",
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

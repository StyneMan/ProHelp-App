import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:loading_overlay_pro/loading_overlay_pro.dart';
import 'package:prohelp_app/components/button/roundedbutton.dart';
import 'package:prohelp_app/components/dashboard/dashboard.dart';
import 'package:prohelp_app/components/dividers/horz_text_divider.dart';
import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/forms/login/loginform.dart';
import 'package:prohelp_app/helper/constants/constants.dart';
import 'package:prohelp_app/helper/preference/preference_manager.dart';
import 'package:prohelp_app/helper/service/api_service.dart';
import 'package:prohelp_app/helper/socket/socket_manager.dart';
import 'package:prohelp_app/helper/state/state_manager.dart';
import 'package:prohelp_app/screens/account/setup_profile.dart';
import 'package:prohelp_app/screens/account/setup_profile_employer.dart';
import 'package:prohelp_app/screens/auth/account_type/account_type.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
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
  final socket = SocketManager().socket;

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
        ],
      ).signIn();

      debugPrint("GOOGLE USER RESP >> $googleUser");

      Map _payload = {
        "name": googleUser?.displayName,
        "email": googleUser?.email,
        "firstname": googleUser?.displayName?.split(' ')[0],
        "lastname": googleUser!.displayName!.contains(' ')
            ? googleUser.displayName?.split(' ')[1]
            : "",
        "picture": googleUser.photoUrl,
        "id": googleUser.id,
      };

      final resp = await APIService().googleAuth(_payload);

      debugPrint("Google Server Respone >> ${resp.body}");

      Map<String, dynamic> map = jsonDecode(resp.body);
      _manager!.saveAccessToken(map['token']);
      _controller.firstname.value = "${map['data']['bio']['firstname']}";
      _controller.lastname.value = "${map['data']['bio']['lastname']}";

      socket.emit('identity', map['data']["_id"] ?? map['data']["id"]);

      if (map['message'].contains("Account created")) {
        //New account so now select user type recruiter or freelancer
        Get.off(
          AccountType(
            isSocial: true,
            email: map['data']['email'],
            name:
                "${map['data']['bio']['firstname']} ${map['data']['bio']['lastname']}",
          ),
          transition: Transition.cupertino,
        );
      } else {
        if (!map['data']["hasProfile"]) {
          Get.off(
            map['data']["accountType"].toString().toLowerCase() ==
                    "professional"
                ? SetupProfile(
                    manager: _manager!,
                    isSocial: true,
                    email: map['data']['email'],
                    name:
                        "${map['data']['bio']['firstname']} ${map['data']['bio']['lastname']}",
                  )
                : SetupProfileEmployer(
                    manager: _manager!,
                    isSocial: true,
                    email: map['data']['email'],
                    name:
                        "${map['data']['bio']['firstname']} ${map['data']['bio']['lastname']}",
                  ),
            transition: Transition.cupertino,
          );
        } else {
          String userData = jsonEncode(map['data']);
          _manager!.setUserData(userData);
          _manager!.setIsLoggedIn(true);
          _controller.setUserData(map['data']);

          _controller.onInit();

          Get.off(
            Dashboard(
              manager: _manager!,
            ),
            transition: Transition.cupertino,
          );
        }
      }
    } catch (e) {
      debugPrint("ERR >> $e");
    }
  }

  _signInApple() async {
    try {
      SignInWithAppleButton(
        onPressed: () async {
          final credential = await SignInWithApple.getAppleIDCredential(
            scopes: [
              AppleIDAuthorizationScopes.email,
              AppleIDAuthorizationScopes.fullName,
            ],
          );

          print(credential);

          // Now send the credential (especially `credential.authorizationCode`) to your server to create a session
          // after they have been validated with Apple (see `Integration` section for more information on how to do this)
        },
      );
    } catch (e) {
      debugPrint("HJEH :: ${e}");
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
                maxHeight: MediaQuery.of(context).size.height * 0.68,
                minHeight: MediaQuery.of(context).size.height * 0.68,
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
                height: 56,
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
                ),
                const SizedBox(height: 10.0),
                Platform.isIOS
                    ? RoundedButton(
                        bgColor: Colors.transparent,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              "assets/images/apple_logo.svg",
                              width: 21,
                              color: Constants.primaryColor,
                            ),
                            const SizedBox(
                              width: 8.0,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: TextPoppins(
                                text: "Sign up with Apple",
                                fontSize: 15,
                                color: Constants.primaryColor,
                              ),
                            ),
                          ],
                        ),
                        borderColor: Constants.primaryColor,
                        foreColor: Constants.primaryColor,
                        onPressed: () async {
                          try {
                            final credential =
                                await SignInWithApple.getAppleIDCredential(
                              scopes: [
                                AppleIDAuthorizationScopes.email,
                                AppleIDAuthorizationScopes.fullName,
                              ],
                            );

                            print(
                                "APPLE LOGIN CREDENTIAL ::: ${credential.authorizationCode}");
                            print(
                                "APPLE LOGIN CREDENTIAL 2 ::: ${credential.email}");
                            print(
                                "APPLE LOGIN CREDENTIAL 3 ::: ${credential.familyName}");
                            print(
                                "APPLE LOGIN CREDENTIAL 4 ::: ${credential.givenName}");
                            print(
                                "APPLE LOGIN CREDENTIAL 5 ::: ${credential.identityToken}");
                            print(
                                "APPLE LOGIN CREDENTIAL 6 ::: ${credential.userIdentifier}");
                          } catch (e) {
                            debugPrint(e.toString());
                          }
                        },
                        variant: "Outlined",
                      )
                    : const SizedBox(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_overlay_pro/loading_overlay_pro.dart';
import 'package:page_transition/page_transition.dart';
import 'package:prohelp_app/components/button/roundedbutton.dart';
import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/helper/constants/constants.dart';
import 'package:prohelp_app/helper/preference/preference_manager.dart';
import 'package:prohelp_app/helper/state/state_manager.dart';
import 'package:prohelp_app/screens/account/setup_profile.dart';
import 'package:prohelp_app/screens/account/setup_profile_employer.dart';
import 'package:prohelp_app/screens/auth/register/register.dart';

class AccountType extends StatefulWidget {
  final bool? isSocial;
  final String name, email;
  const AccountType({
    Key? key,
    this.isSocial = false,
    this.name = "",
    this.email = "",
  }) : super(key: key);

  @override
  State<AccountType> createState() => _AccountTypeState();
}

class _AccountTypeState extends State<AccountType> {
  final _controller = Get.find<StateController>();
  PreferenceManager? _manager;

  @override
  void initState() {
    _manager = PreferenceManager(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => LoadingOverlayPro(
        isLoading: _controller.isLoading.value,
        backgroundColor: Colors.black54,
        progressIndicator: const CircularProgressIndicator.adaptive(),
        child: Scaffold(
          backgroundColor: Constants.primaryColor,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Center(
                      child: Image.asset(
                        "assets/images/logowhite.png",
                        fit: BoxFit.contain,
                        width: MediaQuery.of(context).size.width * 0.5,
                      ),
                    ),
                    Positioned(
                      top: 56,
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
              Expanded(
                child: Stack(
                  children: [
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        width: double.infinity,
                        height: 75,
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 21.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(
                            height: 48.0,
                          ),
                          TextPoppins(
                            text: "CREATE ACCOUNT",
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          const SizedBox(
                            height: 24.0,
                          ),
                          RoundedButton(
                            bgColor: Colors.white,
                            child: TextPoppins(
                              text: "RENDER SERVICES",
                              fontSize: 16,
                            ),
                            borderColor: Colors.transparent,
                            foreColor: Constants.primaryColor,
                            onPressed: () {
                              _controller.accountType.value = "Boy";

                              // Navigator.of(context).push(
                              //   PageTransition(
                              //     type: PageTransitionType.size,
                              //     alignment: Alignment.bottomCenter,
                              //     child: SetupProfile(
                              //       email: "cretict@gmail.com",
                              //       manager: _manager!,
                              //       name: "Stan Man",
                              //     ),
                              //   ),
                              // );

                              if (widget.isSocial!) {
                                Navigator.of(context).push(
                                  PageTransition(
                                    type: PageTransitionType.size,
                                    alignment: Alignment.bottomCenter,
                                    child: SetupProfile(
                                      manager: _manager!,
                                      email: widget.email,
                                      name: widget.name,
                                    ),
                                  ),
                                );
                              } else {
                                Navigator.of(context).push(
                                  PageTransition(
                                    type: PageTransitionType.size,
                                    alignment: Alignment.bottomCenter,
                                    child: const Register(),
                                  ),
                                );
                              }
                            },
                            variant: "Filled",
                          ),
                          const SizedBox(
                            height: 21.0,
                          ),
                          RoundedButton(
                            bgColor: Colors.transparent,
                            child: TextPoppins(
                              text: "HIRE A PRO",
                              fontSize: 16,
                            ),
                            borderColor: Colors.white,
                            foreColor: Colors.white,
                            onPressed: () {
                              _controller.accountType.value = "Oga";

                              if (widget.isSocial!) {
                                Navigator.of(context).push(
                                  PageTransition(
                                    type: PageTransitionType.size,
                                    alignment: Alignment.bottomCenter,
                                    child: SetupProfileEmployer(
                                      manager: _manager!,
                                      email: widget.email,
                                      name: widget.name,
                                    ),
                                  ),
                                );
                              } else {
                                Navigator.of(context).push(
                                  PageTransition(
                                    type: PageTransitionType.size,
                                    alignment: Alignment.bottomCenter,
                                    child: const Register(),
                                  ),
                                );
                              }
                            },
                            variant: "Outlined",
                          ),
                          const Spacer()
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

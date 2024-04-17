import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:page_transition/page_transition.dart';
import 'package:prohelp_app/components/drawer/custom_drawer.dart';
import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/helper/constants/constants.dart';
import 'package:prohelp_app/helper/preference/preference_manager.dart';
import 'package:prohelp_app/helper/state/state_manager.dart';
import 'package:prohelp_app/screens/account/personal_info.dart';
import 'package:prohelp_app/screens/account/security.dart';
import 'package:prohelp_app/screens/account/support.dart';

import 'components/wallet.dart';
import 'verify_docs.dart';

class Account extends StatelessWidget {
  final PreferenceManager manager;
  var stateController;
  Account({
    Key? key,
    required this.manager,
    required this.stateController,
  }) : super(key: key);

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _controller = Get.find<StateController>();

  _pluralize(int num) {
    return num > 1 ? "s" : "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        elevation: 0.0,
        foregroundColor: Constants.secondaryColor,
        backgroundColor: Constants.primaryColor,
        automaticallyImplyLeading: false,
        leading: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              width: 16.0,
            ),
            _controller.userData.isEmpty
                ? const SizedBox()
                : ClipOval(
                    child: Image.network(
                      "${_controller.userData.value['bio']['image'] ?? ""}",
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        CupertinoIcons.person_alt,
                        size: 21,
                        color: Colors.white,
                      ),
                      width: 36,
                      height: 36,
                      fit: BoxFit.cover,
                    ),
                  ),
            const SizedBox(
              width: 4.0,
            ),
          ],
        ),
        title: TextPoppins(
          text: "account".toUpperCase(),
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Constants.secondaryColor,
        ),
        centerTitle: true,
        actions: [
          _controller.userData.isEmpty
                ? const SizedBox() : IconButton(
            onPressed: () {
              if (!_scaffoldKey.currentState!.isEndDrawerOpen) {
                _scaffoldKey.currentState!.openEndDrawer();
              }
            },
            icon: SvgPicture.asset(
              'assets/images/menu_icon.svg',
              color: Constants.secondaryColor,
            ),
          ),
        ],
      ),
      endDrawer: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: CustomDrawer(
          manager: manager,
        ),
      ),
      body: _controller.userData.isEmpty
          ? const SizedBox()
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Center(
                  child: ClipOval(
                    child: Image.network(
                      _controller.userData.value['bio']['image'],
                      errorBuilder: (context, error, stackTrace) =>
                          SvgPicture.asset(
                        "assets/images/personal.svg",
                        fit: BoxFit.cover,
                        width: MediaQuery.of(context).size.width * 0.36,
                        height: MediaQuery.of(context).size.width * 0.36,
                      ),
                      fit: BoxFit.cover,
                      width: MediaQuery.of(context).size.width * 0.36,
                      height: MediaQuery.of(context).size.width * 0.36,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 4.0,
                ),
                Center(
                  child: Column(
                    children: [
                      TextPoppins(
                        text:
                            "${_controller.userData.value['bio']['firstname']} ${_controller.userData.value['bio']['middlename']} ${_controller.userData.value['bio']['lastname']}"
                                .capitalize,
                        fontSize: 21,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      const SizedBox(
                        height: 1.0,
                      ),
                      TextPoppins(
                        text: manager.getUser()['accountType'] == "freelancer"
                            ? "Professional".toUpperCase()
                            : manager
                                .getUser()['accountType']
                                .toString()
                                .toUpperCase(),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Constants.primaryColor,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // TextPoppins(
                          //   text: "Balance:",
                          //   fontSize: 16,
                          //   fontWeight: FontWeight.w600,
                          // ),
                          Image.asset(
                            "assets/images/coin_gold.png",
                            width: 28,
                          ),
                          Text(
                            " ${Constants.formatMoney(_controller.userData.value['wallet']['balance'])} coin${_pluralize(_controller.userData.value['wallet']['balance'])}",
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 8.0,
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            PageTransition(
                              type: PageTransitionType.size,
                              alignment: Alignment.bottomCenter,
                              child: PersonalInfo(
                                manager: manager,
                              ),
                            ),
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  "assets/images/personal_icon.svg",
                                ),
                                const SizedBox(
                                  width: 16.0,
                                ),
                                TextPoppins(
                                  text: "Personal Information",
                                  fontSize: 13,
                                  color: Colors.black87,
                                )
                              ],
                            ),
                            const SizedBox(
                              width: 10.0,
                            ),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Color(0xFFB1B5C5),
                            ),
                          ],
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.all(16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.0),
                            side: const BorderSide(
                              color: Color(0xFFB1B5C5),
                              width: 1.0,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            PageTransition(
                              type: PageTransitionType.size,
                              alignment: Alignment.bottomCenter,
                              child: AccountSecurity(
                                manager: manager,
                              ),
                            ),
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  "assets/images/security_icon.svg",
                                ),
                                const SizedBox(
                                  width: 16.0,
                                ),
                                TextPoppins(
                                  text: "Security",
                                  fontSize: 13,
                                  color: Colors.black87,
                                )
                              ],
                            ),
                            const SizedBox(
                              width: 10.0,
                            ),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Color(0xFFB1B5C5),
                            ),
                          ],
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.all(16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.0),
                            side: const BorderSide(
                              color: Color(0xFFB1B5C5),
                              width: 1.0,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            PageTransition(
                              type: PageTransitionType.size,
                              alignment: Alignment.bottomCenter,
                              child: ContactSupport(
                                manager: manager,
                              ),
                            ),
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  "assets/images/support_icon.svg",
                                ),
                                const SizedBox(
                                  width: 16.0,
                                ),
                                TextPoppins(
                                  text: "Contact support",
                                  fontSize: 13,
                                  color: Colors.black87,
                                )
                              ],
                            ),
                            const SizedBox(
                              width: 10.0,
                            ),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Color(0xFFB1B5C5),
                            ),
                          ],
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.all(16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.0),
                            side: const BorderSide(
                              color: Color(0xFFB1B5C5),
                              width: 1.0,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      manager
                                  .getUser()['accountType']
                                  .toString()
                                  .toLowerCase() ==
                              "recruiter"
                          ? const SizedBox()
                          : TextButton(
                              onPressed: () {
                                Get.to(
                                  VerifyDocs(manager: manager),
                                  transition: Transition.cupertino,
                                );
                                // showBarModalBottomSheet(
                                //   expand: true,
                                //   context: context,
                                //   useRootNavigator: true,
                                //   backgroundColor: Colors.white,
                                //   topControl: ClipOval(
                                //     child: GestureDetector(
                                //       onTap: () {
                                //         Navigator.of(context).pop();
                                //       },
                                //       child: Container(
                                //         width: 32,
                                //         height: 32,
                                //         decoration: BoxDecoration(
                                //           color: Colors.white,
                                //           borderRadius: BorderRadius.circular(
                                //             16,
                                //           ),
                                //         ),
                                //         child: const Center(
                                //           child: Icon(
                                //             Icons.close,
                                //             size: 24,
                                //           ),
                                //         ),
                                //       ),
                                //     ),
                                //   ),
                                //   builder: (context) => SizedBox(
                                //     // height: MediaQuery.of(context).size.height * 0.75,
                                //     child:
                                //   ),
                                // );
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                          "assets/images/personal_icon.svg"),
                                      const SizedBox(
                                        width: 16.0,
                                      ),
                                      TextPoppins(
                                        text: "Verify Documents",
                                        fontSize: 13,
                                        color: Colors.black87,
                                      )
                                    ],
                                  ),
                                  const SizedBox(
                                    width: 10.0,
                                  ),
                                  const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    color: Color(0xFFB1B5C5),
                                  ),
                                ],
                              ),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.all(16.0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                  side: const BorderSide(
                                    color: Color(0xFFB1B5C5),
                                    width: 1.0,
                                  ),
                                ),
                              ),
                            ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      TextButton(
                        onPressed: () {
                          Get.to(
                            // SetupProfile(manager: manager, email: 'ezege@gmail.com'),
                            MyWallet(
                              manager: manager,
                            ),
                            transition: Transition.cupertino,
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                    "assets/images/personal_icon.svg"),
                                const SizedBox(
                                  width: 16.0,
                                ),
                                TextPoppins(
                                  text: "My Wallet",
                                  fontSize: 13,
                                  color: Colors.black87,
                                )
                              ],
                            ),
                            const SizedBox(
                              width: 10.0,
                            ),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Color(0xFFB1B5C5),
                            ),
                          ],
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.all(16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.0),
                            side: const BorderSide(
                              color: Color(0xFFB1B5C5),
                              width: 1.0,
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

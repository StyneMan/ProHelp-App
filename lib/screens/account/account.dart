import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get/instance_manager.dart';
import 'package:page_transition/page_transition.dart';
import 'package:prohelp_app/components/drawer/custom_drawer.dart';
import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/helper/constants/constants.dart';
import 'package:prohelp_app/helper/preference/preference_manager.dart';
import 'package:prohelp_app/helper/state/state_manager.dart';
import 'package:prohelp_app/screens/account/about.dart';
import 'package:prohelp_app/screens/account/personal_info.dart';
import 'package:prohelp_app/screens/account/security.dart';
import 'package:prohelp_app/screens/account/support.dart';

class Account extends StatelessWidget {
  final PreferenceManager manager;
  Account({Key? key, required this.manager}) : super(key: key);

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _controller = Get.find<StateController>();

  final _user = FirebaseAuth.instance.currentUser;

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
            ClipOval(
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Image.network(
                    manager.getUser()['bio']['image'] ?? "",
                    errorBuilder: (context, error, stackTrace) =>
                       const Icon(CupertinoIcons.person_alt, size: 21, color: Colors.white),
                    width: 24,
                    height: 24,
                    fit: BoxFit.cover,
                  ),
                ),
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
          IconButton(
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
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Center(
            child: ClipOval(
              child: Image.network(
                manager.getUser()['bio']['image'],
                errorBuilder: (context, error, stackTrace) => SvgPicture.asset(
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
            height: 16.0,
          ),
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFF0F8E33),
                  ),
                  child: TextPoppins(
                    text: "Account Approved",
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(
                  height: 8.0,
                ),
                TextPoppins(
                  text: "${manager.getUser()['bio']['fullname']}".capitalize,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
                const SizedBox(
                  height: 4.0,
                ),
                TextPoppins(
                  text:
                      manager.getUser()['accountType'].toString().toUpperCase(),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Constants.primaryColor,
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 32,
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
                          SvgPicture.asset("assets/images/personal_icon.svg"),
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
                          SvgPicture.asset("assets/images/security_icon.svg"),
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
                          SvgPicture.asset("assets/images/support_icon.svg"),
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
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      PageTransition(
                        type: PageTransitionType.size,
                        alignment: Alignment.bottomCenter,
                        child: AboutMe(
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
                          SvgPicture.asset("assets/images/personal_icon.svg"),
                          const SizedBox(
                            width: 16.0,
                          ),
                          TextPoppins(
                            text: "About me",
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
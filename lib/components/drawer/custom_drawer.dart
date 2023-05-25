import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get/instance_manager.dart';
import 'package:page_transition/page_transition.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/data/professionals/professionals.dart';
import 'package:prohelp_app/helper/constants/constants.dart';
import 'package:prohelp_app/helper/preference/preference_manager.dart';
import 'package:prohelp_app/helper/service/api_service.dart';
import 'package:prohelp_app/helper/state/state_manager.dart';
import 'package:prohelp_app/logout_loader.dart';
import 'package:prohelp_app/model/drawer/drawermodel.dart';
import 'package:prohelp_app/screens/account/account.dart';
import 'package:prohelp_app/screens/categories/categories.dart';
import 'package:prohelp_app/screens/earnings/earnings.dart';
import 'package:prohelp_app/screens/jobs/jobs.dart';
import 'package:prohelp_app/screens/messages/messages.dart';
import 'package:prohelp_app/screens/pros/pros.dart';
import 'package:prohelp_app/screens/user/my_profile.dart';
import 'package:prohelp_app/screens/welcome/welcome.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomDrawer extends StatefulWidget {
  final PreferenceManager manager;
  const CustomDrawer({
    Key? key,
    required this.manager,
  }) : super(key: key);

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  List<DrawerModel> drawerList = [];

  final _controller = Get.find<StateController>();
  bool _isLoggedIn = true;

  _initAuth() {
    // final prefs = await SharedPreferences.getInstance();
    // _isLoggedIn = prefs.getBool('loggedIn') ?? false;

    setState(() {
      drawerList = [
        DrawerModel(
          icon: 'assets/images/pros_icon.svg',
          title: 'Pros',
          isAction: false,
          widget: Pros(
            manager: widget.manager,
          ),
        ),
        DrawerModel(
          icon: 'assets/images/jobs_icon.svg',
          title: 'Jobs',
          isAction: false,
          widget: Jobs(
            manager: widget.manager,
          ),
        ),
        DrawerModel(
          icon: 'assets/images/messages_icon.svg',
          title: 'Messages',
          isAction: false,
          widget: Messages(
            manager: widget.manager,
          ),
        ),
        DrawerModel(
          icon: Icons.account_circle_outlined,
          title: 'My Profile',
          isAction: false,
          widget: MyProfile(
            manager: widget.manager,
          ),
        ),
        DrawerModel(
          icon: Icons.info_outline,
          title: 'About us',
          isAction: true,
          url: "https://google.com"
          // widget: Categories(
          //   manager: widget.manager,
          // ),
        ),
        // DrawerModel(
        //   icon: CupertinoIcons.money_dollar_circle,
        //   title: 'Earnings',
        //   isAction: false,
        //   widget: Earnings(
        //     manager: widget.manager,
        //   ),
        // ),
      ];
    });
  }

  @override
  void initState() {
    super.initState();
    _initAuth();
  }

  _logout() async {
    _controller.setLoading(true);
    try {
      final res = await APIService().logout(widget.manager.getAccessToken(), widget.manager.getUser()['email']);
      debugPrint("LOGOUT RESP :: ${res.body}");
      _controller.setLoading(false);

      if (res.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(res.body);
        Constants.toast(map['message']);
        widget.manager.setIsLoggedIn(false);

        Get.offAll(const Welcome());

        // Future.delayed(const Duration(seconds: 1), () {
        // Navigator.pushReplacement(context, Mater)
        // Navigator.pushReplacement(
        //   PageTransition(
        //     type: PageTransitionType.size,
        //     alignment: Alignment.bottomCenter,
        //     child: const Welcome(),
        //   ),
        // );
        // });
      } else {
        Map<String, dynamic> map = jsonDecode(res.body);
        Constants.toast(map['message']);
      }
    } catch (e) {
      Constants.toast(e.toString());
      _controller.setLoading(false);
    }
  }

  Future<void> _launchInBrowser(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
        headers: <String, String>{'my_header_key': 'my_header_value'},
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.275),
      child: Container(
        color: Colors.white,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.only(
                  top: 56.0, left: 18, right: 18, bottom: 16),
              width: double.infinity,
              color: Constants.primaryColor,
              height: MediaQuery.of(context).size.height * 0.175,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipOval(
                    child: Container(
                      height: 64,
                      width: 64,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: Image.network(
                        "${widget.manager.getUser()['bio']['image']}",
                        errorBuilder: (context, error, stackTrace) => const ClipOval(
                          child: Icon(CupertinoIcons.person_alt_circle, size: 64, color: Colors.white)
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 16.0,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextPoppins(
                        text: widget.manager.getUser()['bio']['fullname'].toString().capitalize ?? "",
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      TextPoppins(
                        text: widget.manager.getUser()['email'] ?? "",
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 24,
            ),
            Expanded(
              child: Container(
                color: Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      shrinkWrap: true,
                      itemBuilder: (context, i) {
                        return ListTile(
                          dense: true,
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              i > 2
                                  ? Icon(
                                      drawerList[i].icon,
                                      color: Constants.accentColor,
                                    )
                                  : SvgPicture.asset(
                                      drawerList[i].icon,
                                      width: 22,
                                      color: Constants.accentColor,
                                    ),
                              const SizedBox(
                                width: 21.0,
                              ),
                              TextPoppins(
                                text: drawerList[i].title,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Constants.accentColor,
                              ),
                            ],
                          ),
                          onTap: () async {
                            if (i == 0) {
                              Navigator.of(context).pop();
                              _controller.selectedIndex.value = 0;
                            } else if (i == 1) {
                              Navigator.of(context).pop();
                              _controller.selectedIndex.value = 1;
                            } else if (i == 2) {
                              Navigator.of(context).pop();
                              _controller.selectedIndex.value = 2;
                            } else {
                              if (drawerList[i].isAction) {
                                Navigator.of(context).pop();
                                _launchInBrowser("${drawerList[i].url}");
                              } else {
                                Navigator.of(context).pop();
                                Navigator.of(context).push(
                                  PageTransition(
                                    type: PageTransitionType.size,
                                    alignment: Alignment.bottomCenter,
                                    child: drawerList[i].widget!,
                                  ),
                                );
                              }
                            }
                          },
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) =>
                          const Divider(),
                      itemCount: drawerList.length,
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Divider(
                thickness: 0.75,
                color: Constants.accentColor,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              width: MediaQuery.of(context).size.width * 0.45,
              child: TextButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  _logout();
                },
                label: TextPoppins(
                  text: "Sign Out",
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  align: TextAlign.left,
                  color: Constants.primaryColor,
                ),
                icon: const Icon(Icons.login_rounded),
              ),
            ),
            const SizedBox(
              height: 21,
            ),
          ],
        ),
      ),
    );
  }
}

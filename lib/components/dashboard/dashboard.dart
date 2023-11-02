import 'dart:convert';
import 'dart:io';

// import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:prohelp_app/helper/constants/constants.dart';
import 'package:prohelp_app/helper/preference/preference_manager.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:loading_overlay_pro/loading_overlay_pro.dart';
import 'package:prohelp_app/helper/service/api_service.dart';
import 'package:prohelp_app/helper/state/state_manager.dart';
import 'package:prohelp_app/screens/account/account.dart';
import 'package:prohelp_app/screens/alerts/alerts.dart';
import 'package:prohelp_app/screens/jobs/jobs.dart';
import 'package:prohelp_app/screens/messages/messages.dart';
import 'package:prohelp_app/screens/network/no_internet.dart';
import 'package:prohelp_app/screens/pros/pros.dart';
import 'package:prohelp_app/screens/user/my_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Dashboard extends StatefulWidget {
  final PreferenceManager manager;
  final bool showProfile;
  Dashboard({Key? key, required this.manager, this.showProfile = false})
      : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  bool _isLoggedIn = false;
  // int _selectedIndex = 0;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  // String _token = "";
  final _controller = Get.find<StateController>();
  final _currentUser = FirebaseAuth.instance.currentUser;

  _initDialog() async {
    try {
      final _prefs = await SharedPreferences.getInstance();
      final _token = _prefs.getString("accessToken") ?? "";
      final _user = _prefs.getString("user") ?? "";
      final _isShown = _prefs.getBool("dialogShown") ?? false;
      Map<String, dynamic> userMap = jsonDecode(_user);

      // if (!_isShown) {
      //   Future.delayed(const Duration(seconds: 1), () {
      //     showDialog(
      //       context: context,
      //       // barrierDismissible: false,
      //       builder: (BuildContext context) => SizedBox(
      //         height: MediaQuery.of(context).size.height * 0.4,
      //         width: MediaQuery.of(context).size.width * 0.98,
      //         child: CustomDialog(
      //           ripple: SvgPicture.asset(
      //             "assets/images/feature_effect.svg",
      //             width: (Constants.avatarRadius + 20),
      //             height: (Constants.avatarRadius + 20),
      //           ),
      //           avtrBg: Colors.transparent,
      //           avtrChild: Image.asset(
      //             "assets/images/feature.png",
      //           ), //const Icon(CupertinoIcons.check_mark, size: 50,),
      //           body: Padding(
      //             padding: const EdgeInsets.symmetric(
      //               vertical: 16.0,
      //               horizontal: 36.0,
      //             ),
      //             child: Column(
      //               mainAxisSize: MainAxisSize.min,
      //               mainAxisAlignment: MainAxisAlignment.end,
      //               crossAxisAlignment: CrossAxisAlignment.center,
      //               children: [
      //                 TextPoppins(
      //                   text: "GET FEATURED",
      //                   fontSize: 21,
      //                   fontWeight: FontWeight.w600,
      //                 ),
      //                 const SizedBox(
      //                   height: 5.0,
      //                 ),
      //                 Row(
      //                   mainAxisAlignment: MainAxisAlignment.center,
      //                   crossAxisAlignment: CrossAxisAlignment.center,
      //                   children: [
      //                     Text(
      //                       "${Constants.nairaSign(context).currencySymbol}",
      //                       style: const TextStyle(
      //                         fontSize: 18,
      //                         color: Constants.primaryColor,
      //                       ),
      //                     ),
      //                     const Text(
      //                       "1,000",
      //                       style: TextStyle(
      //                         fontSize: 36,
      //                         color: Constants.primaryColor,
      //                         fontWeight: FontWeight.w600,
      //                       ),
      //                     )
      //                   ],
      //                 ),
      //                 TextPoppins(
      //                   text: "MONTHLY",
      //                   fontSize: 14,
      //                   fontWeight: FontWeight.w400,
      //                 ),
      //                 const SizedBox(
      //                   height: 18,
      //                 ),
      //                 SizedBox(
      //                   width: MediaQuery.of(context).size.width * 0.75,
      //                   child: TextPoppins(
      //                     text:
      //                         "Get more visibility and profile sent to potential employers.",
      //                     fontSize: 13,
      //                     align: TextAlign.center,
      //                   ),
      //                 ),
      //                 const SizedBox(
      //                   height: 18,
      //                 ),
      //                 SizedBox(
      //                   width: MediaQuery.of(context).size.width * 0.60,
      //                   child: Column(
      //                     children: [
      //                       RoundedButton(
      //                         bgColor: Constants.primaryColor,
      //                         child: TextPoppins(
      //                           text: "FEATURE ME",
      //                           fontSize: 14,
      //                           fontWeight: FontWeight.w300,
      //                         ),
      //                         borderColor: Colors.transparent,
      //                         foreColor: Colors.white,
      //                         onPressed: () {
      //                           // widget.manager.setShown(true);
      //                           Navigator.pop(context);
      //                         },
      //                         variant: "Filled",
      //                       ),
      //                       const SizedBox(
      //                         height: 16.0,
      //                       ),
      //                       RoundedButton(
      //                         bgColor: Colors.transparent,
      //                         child: TextPoppins(
      //                           text: "CONTINUE",
      //                           fontSize: 14,
      //                           fontWeight: FontWeight.w300,
      //                         ),
      //                         borderColor: Constants.primaryColor,
      //                         foreColor: Constants.primaryColor,
      //                         onPressed: () {
      //                           widget.manager.setShown(true);
      //                           Navigator.pop(context);
      //                         },
      //                         variant: "Outlined",
      //                       ),
      //                     ],
      //                   ),
      //                 ),
      //               ],
      //             ),
      //           ),
      //         ),
      //       ),
      //     );
      //   });
      // }

      // _controller.userData.value = widget.manager.getUser();

      // if (widget.manager.getUser()['accountType'] != "freelancer") {
      APIService().getFreelancers().then((value) {
        debugPrint("STATE GET FREELANCERS >>> ${value.body}");
        Map<String, dynamic> data = jsonDecode(value.body);
        _controller.freelancers.value = data['docs'];
      }).catchError((onError) {
        debugPrint("STATE GET freelancer ERROR >>> $onError");
        if (onError.toString().contains("rk is unreachable")) {
          _controller.hasInternetAccess.value = false;
        }
      });

      if (_token.isNotEmpty) {
        APIService()
            .getJobApplicationsByUser(
                accessToken: _token, email: userMap['email'])
            .then((value) {
          debugPrint("STATE GET APPLICATIONS >>> ${value.body}");
          Map<String, dynamic> data = jsonDecode(value.body);
          _controller.myJobsApplied.value = data['data'];
        }).catchError((onError) {
          debugPrint("STATE GET freelancer ERROR >>> $onError");
          if (onError.toString().contains("rk is unreachable")) {
            _controller.hasInternetAccess.value = false;
          }
        });
      }

      // }

      _controller.myChats.value = [];

      final chatResp = await APIService().getUsersChats(
        accessToken: _token,
        email: userMap['email'],
        userId: userMap['id'],
      );
      // debugPrint("MY CHATS RESPONSE >> ${chatResp.body}");
      if (chatResp.statusCode == 200) {
        Map<String, dynamic> chatMap = jsonDecode(chatResp.body);
        _controller.myChats.value = chatMap['data'];
      }
    } catch (e) {
      debugPrint(e.toString());
      if (e.toString().contains("rk is unreachable")) {
        _controller.hasInternetAccess.value = false;
      }
    }
  }

  String getCurrentRouteName(BuildContext context) {
    final route = ModalRoute.of(context);
    if (route != null && route.settings.name != null) {
      return route.settings.name!;
    } else {
      return 'Unknown Route';
    }
  }

  @override
  void initState() {
    super.initState();
    _initDialog();
    if (widget.showProfile) {
      Future.delayed(const Duration(milliseconds: 1200), () {
        Get.to(MyProfile(manager: widget.manager),
            transition: Transition.cupertino);
      });
    }
    // debugPrint("CURR USER STATE >> ${_controller.userData.value}");
  }

  void _onItemTapped(int index) {
    // setState(() {
    _controller.selectedIndex.value = index;
    // });
  }

  @override
  Widget build(BuildContext context) {
    DateTime pre_backpress = DateTime.now();

    // debugPrint("CURRENT ROUTE NAME  => ${getCurrentRouteName(context)}");

    return WillPopScope(
      onWillPop: () async {
        final timegap = DateTime.now().difference(pre_backpress);
        final cantExit = timegap >= const Duration(seconds: 4);
        pre_backpress = DateTime.now();
        if (cantExit) {
          Fluttertoast.showToast(
            msg: "Press again to exit",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 3,
            backgroundColor: Colors.grey[800],
            textColor: Colors.white,
            fontSize: 16.0,
          );

          return false; // false will do nothing when back press
        } else {
          // _controller.triggerAppExit(true);
          if (Platform.isAndroid) {
            exit(0);
          } else if (Platform.isIOS) {}
          return true;
        }
      },
      child: Obx(
        () => LoadingOverlayPro(
          isLoading: _controller.isLoading.value,
          progressIndicator: const CircularProgressIndicator.adaptive(),
          backgroundColor: Colors.black54,
          child: !_controller.hasInternetAccess.value
              ? const NoInternet()
              : Scaffold(
                  key: _scaffoldKey,
                  body: _buildScreens()[_controller.selectedIndex.value],
                  bottomNavigationBar: BottomNavigationBar(
                    currentIndex: _controller.selectedIndex.value,
                    onTap: _onItemTapped,
                    showUnselectedLabels: true,
                    selectedItemColor: Constants.primaryColor,
                    unselectedItemColor: Colors.grey,
                    unselectedLabelStyle: const TextStyle(color: Colors.grey),
                    type: BottomNavigationBarType.fixed,
                    items: <BottomNavigationBarItem>[
                      BottomNavigationBarItem(
                        icon: SvgPicture.asset(
                          "assets/images/pros_icon.svg",
                          color: Colors.grey,
                        ),
                        label: 'Explore',
                        activeIcon: SvgPicture.asset(
                          "assets/images/pros_icon.svg",
                          color: Constants.primaryColor,
                        ),
                      ),
                      BottomNavigationBarItem(
                        icon: SvgPicture.asset(
                          "assets/images/jobs_icon.svg",
                          color: Colors.grey,
                        ),
                        label: 'Jobs',
                        activeIcon: SvgPicture.asset(
                          "assets/images/jobs_icon.svg",
                          color: Constants.primaryColor,
                        ),
                      ),
                      BottomNavigationBarItem(
                        icon: SvgPicture.asset(
                          "assets/images/messages_icon.svg",
                          color: Colors.grey,
                        ),
                        label: 'Messages',
                        activeIcon: SvgPicture.asset(
                          "assets/images/messages_icon.svg",
                          color: Constants.primaryColor,
                        ),
                      ),
                      BottomNavigationBarItem(
                        icon: SvgPicture.asset(
                          "assets/images/alerts_icon.svg",
                          color: Colors.grey,
                        ),
                        label: 'Alerts',
                        activeIcon: SvgPicture.asset(
                          "assets/images/alerts_icon.svg",
                          color: Constants.primaryColor,
                        ),
                      ),
                      BottomNavigationBarItem(
                        icon: SvgPicture.asset(
                          "assets/images/account_icon.svg",
                          color: Colors.grey,
                        ),
                        label: 'Account',
                        activeIcon: SvgPicture.asset(
                          "assets/images/account_icon.svg",
                          color: Constants.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  List<Widget> _buildScreens() {
    return [
      Pros(
        manager: widget.manager,
      ),
      Jobs(manager: widget.manager),
      Messages(manager: widget.manager),
      Alerts(manager: widget.manager),
      Account(manager: widget.manager)
    ];
  }
}

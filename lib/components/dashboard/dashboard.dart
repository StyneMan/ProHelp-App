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
      // final _token = _prefs.getString("accessToken") ?? "";
      final _user = _prefs.getString("user") ?? "";
      final _isShown = _prefs.getBool("dialogShown") ?? false;
      Map<String, dynamic> userMap = jsonDecode(_user);

      APIService().getFreelancers().then((value) {
        debugPrint("STATE GET FREELANCERS >>> ${value.body}");
        Map<String, dynamic> data = jsonDecode("${value.body}");
        _controller.freelancers.value = data['docs'];
      }).catchError((onError) {
        debugPrint("STATE GET freelancer ERROR >>> $onError");
        if (onError.toString().contains("rk is unreachable")) {
          _controller.hasInternetAccess.value = false;
        }
      });

      // PROFILE
      final _profileResp = await APIService().getProfile(
        widget.manager.getAccessToken(),
        userMap['email'],
      );
      print("PROFILE ::: ${_profileResp.body}");
      if (_profileResp.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(_profileResp.body);

        String userData = jsonEncode(map['data']);
        widget.manager.setUserData(userData);
        _controller.setUserData(map['data']);
      }

      // JOB APPLICATIONS
      final _applicationsResp = await APIService().getJobApplicationsByUser(
        accessToken: widget.manager.getAccessToken(),
        email: userMap['email'],
      );
      print("MY JOB APPLICATIONS ::: ${_applicationsResp.body}");
      if (_applicationsResp.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(_applicationsResp.body);

        _controller.myJobApplications.value = map['applications']['docs'];
      }

      final _resp = await APIService().getSavedPros(
        widget.manager.getAccessToken(),
        userMap['email'],
      );

      print("KLKJSJ JJJKS ::: ${_resp.body}");
      if (_resp.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(_resp.body);
        _controller.savedPros.value = map['docs'];
      }

      _controller.myChats.value = [];

      final chatResp = await APIService().getUsersChats(
        accessToken: widget.manager.getAccessToken(),
        email: userMap['email'],
        // userId: userMap['id'],
      );
      // debugPrint("MY CHATS RESPONSE >> ${chatResp.body}");
      if (chatResp.statusCode == 200) {
        Map<String, dynamic> chatMap = jsonDecode(chatResp.body);
        _controller.myChats.value = chatResp.body as List;
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
        Get.to(
          MyProfile(manager: widget.manager),
          transition: Transition.cupertino,
        );
      });
    }
  }

  void _onItemTapped(int index) {
    _controller.selectedIndex.value = index;
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
      Pros(manager: widget.manager, stateController: _controller),
      Jobs(manager: widget.manager, stateController: _controller),
      Messages(manager: widget.manager, stateController: _controller),
      Alerts(manager: widget.manager, stateController: _controller),
      Account(manager: widget.manager, stateController: _controller)
    ];
  }
}

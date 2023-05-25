// import 'package:dwec_app/model/user/user_profile.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferenceManager {
  final BuildContext? context;
  static var prefs;

  void init() async {
    prefs = await SharedPreferences.getInstance();
  }

  PreferenceManager(this.context) {
    init();
  }

  void saveAccessToken(String token) {
    prefs.setString('accessToken', token);
  }

  void setUserId(String id) {
    prefs.setString('userID', id);
  }

  void setFCMToken(String token) {
    prefs.setString('fcmToken', token);
  }

  String getFCMToken() => prefs != null ? prefs!.getString('fcmToken') : '';

  void setIsLoggedIn(bool loggenIn) {
    prefs.setBool('loggedIn', loggenIn);
  }

  bool getIsLoggedIn() => prefs!.getBool('loggedIn') ?? false;

  void setShown(bool value) {
    prefs.setBool('dialogShown', value);
  }

  bool isShown() => prefs!.getBool('dialogShown') ?? false;

  String getAccessToken() =>
      prefs != null ? prefs!.getString('accessToken') : '';

  void setUserData(String rawJson) {
    prefs!.setString('user', rawJson);
  }

  void updateUserData(String rawJson) {
    prefs!.remove("user");
    Future.delayed(const Duration(seconds: 2), () {
      prefs!.setString('user', rawJson);
    });
  }

  Map getUser() {
    final rawJson = prefs.getString('user') ?? '{}';
    Map<String, dynamic> map = jsonDecode(rawJson);
    return map;
  }

  void clearProfile() {
    prefs!.clear();
  }
}

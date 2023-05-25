import 'dart:async';
import 'dart:io';

import 'package:prohelp_app/helper/constants/constants.dart';
import 'package:prohelp_app/helper/state/state_manager.dart';
import 'package:prohelp_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/instance_manager.dart';
import 'package:loading_overlay_pro/loading_overlay_pro.dart';

class NoInternet extends StatefulWidget {
  const NoInternet({Key? key}) : super(key: key);

  @override
  State<NoInternet> createState() => _NoInternetState();
}

class _NoInternetState extends State<NoInternet> {
  bool? _isConnectionSuccessful;
  final _controller = Get.find<StateController>();

  Future<void> _tryConnection() async {
    _controller.setLoading(true);

    try {
      final response = await InternetAddress.lookup('www.google.com');
      setState(() {
        _isConnectionSuccessful = response.isNotEmpty;
      });

      _controller.setLoading(false);
      //Now go to where necessary from here...
      Future.delayed(const Duration(milliseconds: 50), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MyApp(),
          ),
        );
      });
    } on SocketException catch (e) {
      _controller.setLoading(false);
      setState(() {
        _isConnectionSuccessful = false;
      });
      Constants.toast("Check your internet connection.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlayPro(
      isLoading: false,
      progressIndicator: Platform.isAndroid
          ? const CircularProgressIndicator(
              color: Colors.white,
            )
          : const CupertinoActivityIndicator(
              animating: true,
            ),
      backgroundColor: Colors.black54,
      child: Scaffold(
        body: Container(
          color: Colors.white,
          width: double.infinity,
          height: double.infinity,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.not_accessible_outlined,
                    color: Constants.primaryColor, size: 48),
                const Text("No internet connection."),
                TextButton.icon(
                  onPressed: () {
                    _tryConnection();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text("Retry"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

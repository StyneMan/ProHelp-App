import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:prohelp_app/components/drawer/custom_drawer.dart';
import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/helper/constants/constants.dart';
import 'package:prohelp_app/helper/preference/preference_manager.dart';
import 'package:prohelp_app/helper/state/state_manager.dart';

import 'components/item_row.dart';

class Alerts extends StatelessWidget {
  final PreferenceManager manager;
  var stateController;
  Alerts({
    Key? key,
    required this.manager,
    required this.stateController,
  }) : super(key: key);

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  // final _controller = Get.find<StateController>();
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
              child: Image.network(
                manager.getUser()['bio']['image'] ?? "",
                errorBuilder: (context, error, stackTrace) => const Icon(
                    CupertinoIcons.person_alt,
                    size: 21,
                    color: Colors.white),
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
          text: "Alerts".toUpperCase(),
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
      body: SafeArea(
        child: GetX<StateController>(
          builder: (stateController) {
            return stateController.allAlerts.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(16.0),
                    width: double.infinity,
                    height: double.infinity,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset('assets/images/empty.png'),
                          const Text(
                            "No data found",
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.all(16.0),
                    child: ListView.separated(
                      itemBuilder: (context, i) => AlertItemRow(
                        alert: stateController.allAlerts.value[i],
                      ),
                      separatorBuilder: (context, i) => const SizedBox(
                        height: 16,
                      ),
                      itemCount: stateController.allAlerts.value.length,
                    ),
                  );
          },
        ),
      ),
    );
  }
}

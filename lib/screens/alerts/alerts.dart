import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/instance_manager.dart';
import 'package:intl/intl.dart';
import 'package:prohelp_app/components/drawer/custom_drawer.dart';
import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/data/alerts/alerts.dart';
import 'package:prohelp_app/helper/constants/constants.dart';
import 'package:prohelp_app/helper/preference/preference_manager.dart';
import 'package:prohelp_app/helper/state/state_manager.dart';
import 'package:timeago/timeago.dart' as timeago;

class Alerts extends StatelessWidget {
  final PreferenceManager manager;
  Alerts({
    Key? key,
    required this.manager,
  }) : super(key: key);

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _controller = Get.find<StateController>();
  final _user = FirebaseAuth.instance.currentUser;

  String timeUntil(DateTime date) {
    return timeago.format(date, locale: "en", allowFromNow: true);
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
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: ListView.separated(
          itemBuilder: (context, i) => Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipOval(
                    child: Container(
                      width: 48,
                      height: 48,
                      color: alerts.elementAt(i).status == "info"
                          ? Colors.blue.shade100
                          : alerts.elementAt(i).status == "success"
                              ? Colors.green.shade100
                              : Colors.red.shade100,
                      child: Center(
                        child: Icon(
                          alerts.elementAt(i).type == "payment"
                              ? Icons.account_balance
                              : alerts.elementAt(i).type == "verification"
                                  ? alerts.elementAt(i).status == "success"
                                      ? CupertinoIcons.checkmark_shield
                                      : CupertinoIcons.xmark_shield
                                  : Icons.playlist_add_check,
                          color: alerts.elementAt(i).status == "info"
                              ? Colors.blue
                              : alerts.elementAt(i).status == "success"
                                  ? Colors.green
                                  : Colors.red,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 16.0,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.64,
                        child: TextPoppins(
                          text: alerts.elementAt(i).summary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      TextPoppins(
                        text:
                            "${DateFormat('E,d MMM yyyy HH:mm:ss').format(DateTime.parse(alerts.elementAt(i).createdAt))} (${timeUntil(DateTime.parse(alerts.elementAt(i).createdAt))})",
                        fontSize: 11,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          separatorBuilder: (context, i) => const SizedBox(
            height: 16,
          ),
          itemCount: alerts.length,
        ),
      ),
    );
  }
}

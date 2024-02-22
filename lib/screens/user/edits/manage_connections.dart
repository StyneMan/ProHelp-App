import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_overlay_pro/loading_overlay_pro.dart';
import 'package:prohelp_app/components/shimmer/pros_shimmer.dart';
import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/helper/constants/constants.dart';
import 'package:prohelp_app/helper/preference/preference_manager.dart';
import 'package:prohelp_app/helper/service/api_service.dart';
import 'package:prohelp_app/helper/state/state_manager.dart';
import 'package:http/http.dart' as http;
import 'package:prohelp_app/screens/pros/components/professional_card.dart';

class ManageConnections extends StatelessWidget {
  final List connections;
  final String caller;
  var data;
  final PreferenceManager manager;
  ManageConnections({
    Key? key,
    required this.connections,
    required this.manager,
    required this.caller,
    this.data,
  }) : super(key: key);

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final _controller = Get.find<StateController>();

  // bool _isClicked = false;
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => LoadingOverlayPro(
        isLoading: _controller.isLoading.value,
        backgroundColor: Colors.black38,
        progressIndicator: const CircularProgressIndicator.adaptive(),
        child: Scaffold(
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
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Icon(
                    CupertinoIcons.arrow_left_circle,
                  ),
                ),
                const SizedBox(
                  width: 4.0,
                ),
              ],
            ),
            title: TextPoppins(
              text: "Connections".toUpperCase(),
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Constants.secondaryColor,
            ),
            centerTitle: true,
          ),
          body: connections.isEmpty
              ? Container(
                  padding: const EdgeInsets.all(16.0),
                  width: double.infinity,
                  height: double.infinity,
                  child: const Center(
                    child: Text("No data found"),
                  ),
                )
              : FutureBuilder<http.Response>(
                  future: APIService().getConnections(
                    manager.getAccessToken(),
                    caller == "guest"
                        ? data['email']
                        : manager.getUser()['email'],
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return ListView.separated(
                        shrinkWrap: true,
                        itemCount: 3,
                        separatorBuilder: (BuildContext context, int index) {
                          return const SizedBox(height: 32.0);
                        },
                        itemBuilder: (BuildContext context, int index) {
                          return const ProsShimmer();
                        },
                      );
                    }

                    if (snapshot.hasError) {
                      return const Center(
                        child: Text(
                          "An error occurred. Checkyour internet and try again.",
                        ),
                      );
                    }

                    if (!snapshot.hasData) {
                      return const Center(
                        child: Text(
                          "No data found.",
                        ),
                      );
                    }

                    final data = snapshot.data;
                    Map<String, dynamic> map = jsonDecode(data!.body);
                    debugPrint("SAVED CONNEV RESPONSE >>> ${data.body}");

                    return ListView.separated(
                      shrinkWrap: true,
                      itemBuilder: (context, i) => ProfessionalsCard(
                        data: map['data'][i],
                        manager: manager,
                        index: i,
                      ),
                      separatorBuilder: (context, i) => const SizedBox(
                        height: 16.0,
                      ),
                      itemCount: map['data']?.length,
                    );
                  },
                ),
        ),
      ),
    );
  }
}

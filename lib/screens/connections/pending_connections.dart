import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_overlay_pro/loading_overlay_pro.dart';
import 'package:prohelp_app/components/shimmer/cart_shimmer.dart';
import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/helper/constants/constants.dart';
import 'package:prohelp_app/helper/preference/preference_manager.dart';
import 'package:prohelp_app/helper/service/api_service.dart';

import 'package:http/http.dart' as http;
import 'package:prohelp_app/helper/state/state_manager.dart';

import 'widgets/connection_row.dart';

class PendingConnections extends StatefulWidget {
  final PreferenceManager manager;
  const PendingConnections({
    Key? key,
    required this.manager,
  }) : super(key: key);

  @override
  State<PendingConnections> createState() => _PendingConnectionsState();
}

class _PendingConnectionsState extends State<PendingConnections> {
  final _controller = Get.find<StateController>();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => LoadingOverlayPro(
        isLoading: _controller.isLoading.value,
        backgroundColor: Colors.black54,
        progressIndicator: const CircularProgressIndicator.adaptive(),
        child: Scaffold(
          appBar: AppBar(
            elevation: 0.0,
            foregroundColor: Constants.secondaryColor,
            backgroundColor: Constants.primaryColor,
            automaticallyImplyLeading: true,
            title: TextPoppins(
              text: "Connection Requests",
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Constants.secondaryColor,
            ),
            centerTitle: false,
          ),
          body: SafeArea(
              child: StreamBuilder<http.Response>(
            stream: APIService().getUserPendingReceivedConnectionsRequestStream(
              accessToken: widget.manager.getAccessToken(),
              email: widget.manager.getUser()['email'],
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return ListView.separated(
                  itemBuilder: (context, index) {
                    return const CartShimmer();
                  },
                  separatorBuilder: (context, index) {
                    return const SizedBox();
                  },
                  itemCount: 5,
                );
              } else if (!snapshot.hasData || snapshot.hasError) {
                return Center(
                  child: TextPoppins(
                    text: "An error ocurred. ",
                    fontSize: 13,
                  ),
                );
              }
              final data = snapshot.data;
              Map<String, dynamic> map = jsonDecode(data!.body);
              debugPrint("CONNECTIO RESPONSE >>> ${data.body}");

              if (map['docs']?.length < 1) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/empty.png'),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 48.0),
                        child: TextInter(
                          text: "No data found",
                          fontSize: 16,
                          align: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.all(8.0),
                itemBuilder: (context, index) {
                  return ConnectionRow(
                    manager: widget.manager,
                    data: map['docs'][index],
                  );
                },
                separatorBuilder: (context, index) {
                  return const Column(
                    children: [
                      SizedBox(height: 4.0),
                      Divider(),
                      SizedBox(height: 4.0),
                    ],
                  );
                },
                itemCount: map['docs']?.length,
              );
            },
          )),
        ),
      ),
    );
  }
}

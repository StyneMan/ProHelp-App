import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:prohelp_app/components/shimmer/pros_shimmer.dart';
import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/helper/preference/preference_manager.dart';
import 'package:prohelp_app/helper/service/api_service.dart';
import 'package:http/http.dart' as http;
import 'package:prohelp_app/screens/pros/components/professional_connection_card.dart';

class PastConnections extends StatelessWidget {
  final String caller;
  var data;
  final PreferenceManager manager;
  PastConnections({
    Key? key,
    required this.manager,
    required this.caller,
    this.data,
  }) : super(key: key);

  // bool _isClicked = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: StreamBuilder<http.Response>(
        stream: APIService().getUserPastConnectionsStreamed(
          accessToken: manager.getAccessToken(),
          email: caller == "guest" ? data['email'] : manager.getUser()['email'],
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
          debugPrint("PAST CONNEC RESPONSE >>> ${data.body}");

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
                      text: "No past connections found",
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
            padding: const EdgeInsets.all(10.0),
            itemBuilder: (context, i) => ProfessionalsConnectionCard(
              data:
                  map['docs'][i]['user']['email'] == manager.getUser()['email']
                      ? map['docs'][i]['guest']
                      : map['docs'][i]['user'],
              manager: manager,
              index: i,
              connectionId: map['docs'][i]['id'],
            ),
            separatorBuilder: (context, i) => const SizedBox(
              height: 16.0,
            ),
            itemCount: map['docs']?.length,
          );
        },
      ),
    );
  }
}

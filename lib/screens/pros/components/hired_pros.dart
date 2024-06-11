import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:prohelp_app/components/shimmer/pros_shimmer.dart';
import 'package:prohelp_app/helper/preference/preference_manager.dart';

import 'package:http/http.dart' as http;
import 'package:prohelp_app/helper/service/api_service.dart';

import 'professional_card.dart';

class HiredProfessionals extends StatelessWidget {
  final PreferenceManager manager;
  const HiredProfessionals({
    Key? key,
    required this.manager,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return manager.getUser()['connections'].isEmpty
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
                    "No service providers found",
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        : FutureBuilder<http.Response>(
            future: APIService().getConnections(
              manager.getAccessToken(),
              manager.getUser()['email'],
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
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/empty.png'),
                      const Text(
                        "No hired professional found",
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              final data = snapshot.data;
              Map<String, dynamic> map = jsonDecode(data!.body);
              debugPrint("HIRED PROS RESPONSE >>> ${data.body}");

              return ListView.separated(
                shrinkWrap: true,
                itemBuilder: (context, i) => ProfessionalsCard(
                  data: map['data'][i],
                  manager: manager,
                  index: i,
                  type: "Again",
                ),
                separatorBuilder: (context, i) => const SizedBox(
                  height: 16.0,
                ),
                itemCount: map['data']?.length,
              );
            },
          );
  }
}

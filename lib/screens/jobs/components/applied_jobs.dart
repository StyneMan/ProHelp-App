import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prohelp_app/components/shimmer/pros_shimmer.dart';
import 'package:prohelp_app/helper/preference/preference_manager.dart';

import 'package:http/http.dart' as http;
import 'package:prohelp_app/helper/service/api_service.dart';
import 'package:prohelp_app/helper/state/state_manager.dart';
import 'package:prohelp_app/screens/jobs/components/job_card.dart';

class AppliedJobs extends StatelessWidget {
  final PreferenceManager manager;
  AppliedJobs({
    Key? key,
    required this.manager,
  }) : super(key: key);

  final _controller = Get.find<StateController>();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => _controller.myJobApplications.value.isEmpty
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
                      "No applied jobs found",
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : FutureBuilder<http.Response>(
              future: APIService().getJobApplicationsByUser(
                accessToken: manager.getAccessToken(),
                email: manager.getUser()['email'],
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
                  return SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset('assets/images/empty.png'),
                          const Text(
                            "No applied jobs found",
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final data = snapshot.data;
                Map<String, dynamic> map = jsonDecode(data!.body);
                debugPrint("APPLIED JOBS RESPONSE >>> ${data.body}");

                return ListView.separated(
                  shrinkWrap: true,
                  itemBuilder: (context, i) => JobCard(
                    data: map['applications']['docs'][i]['job'],
                    manager: manager,
                    usecase: "applied",
                    index: i,
                  ),
                  separatorBuilder: (context, i) => const SizedBox(
                    height: 16.0,
                  ),
                  itemCount: map['applications']['docs']?.length,
                );
              },
            ),
    );
  }
}

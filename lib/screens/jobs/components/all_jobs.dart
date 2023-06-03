import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prohelp_app/helper/preference/preference_manager.dart';
import 'package:prohelp_app/helper/state/state_manager.dart';
import 'package:prohelp_app/screens/jobs/components/job_card.dart';
import 'package:prohelp_app/screens/pros/components/professional_card.dart';

class AllJobs extends StatelessWidget {
  final PreferenceManager manager;
  AllJobs({
    Key? key,
    required this.manager,
  }) : super(key: key);

  final _controller = Get.find<StateController>();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => _controller.allJobs.isEmpty
          ? SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/empty.png'),
                    const Text(
                      "No jobs found",
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              shrinkWrap: true,
              itemBuilder: (context, i) => JobCard(
                data: _controller.allJobs.value[i],
                manager: manager,
                index: i,
              ),
              separatorBuilder: (context, i) => const SizedBox(
                height: 16.0,
              ),
              itemCount: _controller.allJobs.length,
            ),
    );
  }
}
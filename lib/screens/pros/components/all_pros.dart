import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/instance_manager.dart';
import 'package:prohelp_app/helper/preference/preference_manager.dart';
import 'package:prohelp_app/helper/state/state_manager.dart';
import 'package:prohelp_app/screens/pros/components/professional_card.dart';

class AllProfessionals extends StatelessWidget {
  final PreferenceManager manager;
  AllProfessionals({
    Key? key,
    required this.manager,
  }) : super(key: key);

  final _controller = Get.find<StateController>();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => (_controller.freelancers.isEmpty && _controller.recruiters.isEmpty)
          ? const Center(
              child: Text("No data found"),
            )
          : ListView.separated(
              shrinkWrap: true,
              itemBuilder: (context, i) => ProfessionalsCard(
                data: manager.getUser()['accountType'] == "recruiter"
                    ? _controller.freelancers.value[i]
                    : _controller.recruiters.value[i],
                manager: manager,
                index: i,
              ),
              separatorBuilder: (context, i) => const SizedBox(
                height: 16.0,
              ),
              itemCount: manager.getUser()['accountType'] == "recruiter"
                  ? (_controller.freelancers.length)
                  : (_controller.recruiters.length),
            ),
    );
  }
}

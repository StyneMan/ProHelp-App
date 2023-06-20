import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_overlay_pro/loading_overlay_pro.dart';
import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/forms/skills/skills_form.dart';
import 'package:prohelp_app/helper/constants/constants.dart';
import 'package:prohelp_app/helper/preference/preference_manager.dart';
import 'package:prohelp_app/helper/state/state_manager.dart';

class ManageSkills extends StatelessWidget {
  final List skills;
  final PreferenceManager manager;
  ManageSkills({
    Key? key,
    required this.skills,
    required this.manager,
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
              text: "My Skills".toUpperCase(),
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Constants.secondaryColor,
            ),
            centerTitle: true,
          ),
          body: skills.isEmpty && !_controller.shouldAddSkills.value
              ? Container(
                  width: double.infinity,
                  height: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset('assets/images/empty.png'),
                        const TextInter(text: "No skills found", fontSize: 16),
                        TextButton.icon(
                          onPressed: () {
                            _controller.shouldAddSkills.value = true;
                          },
                          icon: const Icon(CupertinoIcons.add),
                          label: const TextInter(
                            text: "Add skills",
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : SkillsForm(
                  manager: manager,
                ),
        ),
      ),
    );
  }
}

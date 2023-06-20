import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prohelp_app/components/inputfield/customdropdown.dart';
import 'package:prohelp_app/components/inputfield/textarea2.dart';
import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/helper/preference/preference_manager.dart';
import 'package:prohelp_app/helper/state/state_manager.dart';

typedef void InitCallback(Map data);
typedef void FormCallback(GlobalKey<FormState> formKey);

class AddJobFormStep2 extends StatefulWidget {
  final PreferenceManager manager;
  final InitCallback onStep2Completed;
  // final FormCallback onSetKey;
  AddJobFormStep2({
    Key? key,
    required this.manager,
    // required this.onSetKey,
    required this.onStep2Completed,
  }) : super(key: key);

  @override
  State<AddJobFormStep2> createState() => _AddJobFormStep2State();
}

class _AddJobFormStep2State extends State<AddJobFormStep2> {
  final _descriptionController = TextEditingController();
  final _qualificationController = TextEditingController();
  final _jobTitleController = TextEditingController();
  final _controller = Get.find<StateController>();
  final _fKey = GlobalKey<FormState>();

  String _selectedProfession = "";

  @override
  void initState() {
    super.initState();
    setState(() {
      _descriptionController.text = _controller.jobDescription.value;
      _qualificationController.text = _controller.jobMinQualification.value;
    });
    // widget.onSetKey(_fKey);
  }

  void _onSelected(String val) {
    setState(() {
      _selectedProfession = val;
    });

    widget.onStep2Completed(
      {
        "minimumQualification": _qualificationController.text,
        "profession": val,
        "description": _descriptionController.text,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextPoppins(
          text: "Let's continue. Describe job",
          fontSize: 20,
          fontWeight: FontWeight.w500,
          align: TextAlign.center,
        ),
        const SizedBox(
          height: 21.0,
        ),
        CustomDropdown(
          onSelected: _onSelected,
          hint: "Select job profession",
          items: const ['Programming', 'Baking', 'Driving', 'Catering'],
          validator: (val) {
            if (val.toString().isEmpty || val == null) {
              return "Job profession is required";
            }
            return null;
          },
        ),
        const SizedBox(
          height: 16.0,
        ),
        CustomTextArea2(
          borderRadius: 8.0,
          hintText: "Describe job here",
          maxLines: 12,
          maxLength: 500,
          onChanged: (val) {
            widget.onStep2Completed(
              {
                "description": val,
                "minimumQualification": _qualificationController.text,
                "profession": _selectedProfession,
              },
            );
          },
          controller: _descriptionController,
          validator: (val) {
            if (val.toString().isEmpty || val == null) {
              return "Description is required";
            }
            return null;
          },
          inputType: TextInputType.multiline,
        ),
        const SizedBox(
          height: 16.0,
        ),
        CustomTextArea2(
          borderRadius: 8.0,
          hintText: "Minimum qualification",
          maxLines: 2,
          maxLength: 90,
          onChanged: (val) {
            widget.onStep2Completed(
              {
                "minimumQualification": val,
                "profession": _selectedProfession,
                "description": _descriptionController.text,
              },
            );
          },
          controller: _qualificationController,
          validator: (val) {
            if (val.toString().isEmpty || val == null) {
              return "Minimum qualification is required";
            }
            return null;
          },
          inputType: TextInputType.multiline,
        ),
        const SizedBox(
          height: 16.0,
        ),
        const Divider(thickness: 1.5),
        const SizedBox(
          height: 10.0,
        ),
        // RoundedButton(
        //   bgColor: Constants.primaryColor,
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.center,
        //     crossAxisAlignment: CrossAxisAlignment.center,
        //     children: [
        //       TextPoppins(
        //         text: _controller.currentJobStep.value == 2
        //             ? "Post Job".toUpperCase()
        //             : "Next".toUpperCase(),
        //         fontSize: 18,
        //       ),
        //       const SizedBox(
        //         width: 16.0,
        //       ),
        //       const Icon(
        //         CupertinoIcons.arrow_right,
        //         color: Colors.white,
        //       ),
        //     ],
        //   ),
        //   borderColor: Colors.transparent,
        //   foreColor: Colors.white,
        //   onPressed: () {
        //     if (_fKey.currentState!.validate()) {
        //       // _saveStep1ToState();
        //       _controller.currentJobStep.value += 1;
        //     }
        //   },
        //   variant: "Filled",
        // ),
      ],
    );
  }
}

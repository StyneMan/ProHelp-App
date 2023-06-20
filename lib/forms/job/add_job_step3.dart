import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prohelp_app/components/button/roundedbutton.dart';
import 'package:prohelp_app/components/inputfield/textfield.dart';
import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/helper/constants/constants.dart';
import 'package:prohelp_app/helper/preference/preference_manager.dart';
import 'package:prohelp_app/helper/state/state_manager.dart';

typedef void InitCallback(Map data);

class AddJobFormStep3 extends StatefulWidget {
  final PreferenceManager manager;
  // final InitCallback onStep3Completed;
  const AddJobFormStep3({
    Key? key,
    required this.manager,
    // required this.onStep3Completed,
  }) : super(key: key);

  @override
  State<AddJobFormStep3> createState() => _AddJobFormStep3State();
}

class _AddJobFormStep3State extends State<AddJobFormStep3> {
  final _requirementController = TextEditingController();
  final _questionController = TextEditingController();
  final _controller = Get.find<StateController>();
  final _innerFormKey = GlobalKey<FormState>();
  final _innerFormKey2 = GlobalKey<FormState>();
  bool _isClicked = false;
  bool _isClicked2 = false;

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextPoppins(
          text: "You're almost done. Add criteria",
          fontSize: 21,
          fontWeight: FontWeight.w500,
          align: TextAlign.center,
        ),
        const SizedBox(
          height: 21.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextPoppins(
              text: !_isClicked
                  ? "Add requirements"
                  : "Job requirements",
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
            _isClicked
                ?const Text("5 max")
                : IconButton(
                    onPressed: () {
                      setState(() {
                        _isClicked = true;
                      });
                    },
                    icon: const Icon(
                      CupertinoIcons.add_circled,
                      size: 36,
                      color: Constants.primaryColor,
                    ),
                  ),
          ],
        ),
        Obx(
          () => ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) => Text(
              "${index + 1}. ${_controller.jobRequirements.value[index]}",
              style: const TextStyle(fontSize: 16),
            ),
            separatorBuilder: (context, index) => const Divider(),
            itemCount: _controller.jobRequirements.length,
          ),
        ),
        !_isClicked
            ? const SizedBox()
            : Form(
                key: _innerFormKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 16.0,
                    ),
                    CustomTextField(
                      hintText: "Requirement",
                      onChanged: (val) {},
                      controller: _requirementController,
                      validator: (val) {
                        if (val.toString().isEmpty || val == null) {
                          return "Requirement is required";
                        }
                        return null;
                      },
                      inputType: TextInputType.text,
                      capitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(
                      height: 16.0,
                    ),
                    Center(
                      child: SizedBox(
                        width: 256,
                        child: RoundedButton(
                          bgColor: Colors.transparent,
                          child: const TextInter(
                              text: "Save Requirement", fontSize: 16),
                          borderColor: Constants.primaryColor,
                          foreColor: Constants.primaryColor,
                          onPressed: () {
                            if (_innerFormKey.currentState!.validate()) {
                              //Add to list here
                              _addRequirement();
                            }
                          },
                          variant: "Outlined",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
        const SizedBox(
          height: 16.0,
        ),
        const Divider(thickness: 1.5),
        const SizedBox(
          height: 10.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextPoppins(
              text: !_isClicked2
                  ? "Add screening questions"
                  : "Screening questions",
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
            _isClicked2
                ? Text("10 max")
                : IconButton(
                    onPressed: () {
                      setState(() {
                        _isClicked2 = true;
                      });
                    },
                    icon: const Icon(
                      CupertinoIcons.add_circled,
                      size: 36,
                      color: Constants.primaryColor,
                    ),
                  ),
          ],
        ),
        Obx(
          () => ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) => Text(
              "${index + 1}. ${_controller.jobQuestions.value[index]}",
              style: const TextStyle(fontSize: 16),
            ),
            separatorBuilder: (context, index) => const Divider(),
            itemCount: _controller.jobQuestions.length,
          ),
        ),
        !_isClicked2
            ? const SizedBox()
            : Form(
                key: _innerFormKey2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 16.0,
                    ),
                    CustomTextField(
                      hintText: "Question",
                      onChanged: (val) {},
                      controller: _questionController,
                      validator: (val) {
                        if (val.toString().isEmpty || val == null) {
                          return "Question is required";
                        }
                        return null;
                      },
                      inputType: TextInputType.text,
                      capitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(
                      height: 16.0,
                    ),
                    Center(
                      child: SizedBox(
                        width: 256,
                        child: RoundedButton(
                          bgColor: Colors.transparent,
                          child: const TextInter(
                              text: "Save Question", fontSize: 16),
                          borderColor: Constants.primaryColor,
                          foreColor: Constants.primaryColor,
                          onPressed: () {
                            if (_innerFormKey2.currentState!.validate()) {
                              //Add to list here
                              _addQuestion();
                            }
                          },
                          variant: "Outlined",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
        const SizedBox(
          height: 16.0,
        ),
        const Divider(thickness: 1.5),
        const SizedBox(
          height: 10.0,
        ),
      ],
    );
  }

  _addQuestion() {
    _controller.jobQuestions.add(_questionController.text);
    _questionController.clear();
  }

  _addRequirement() {
    _controller.jobRequirements.add(_requirementController.text);
    _requirementController.clear();
  }
}

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/instance_manager.dart';
import 'package:prohelp_app/components/button/roundedbutton.dart';
import 'package:prohelp_app/components/inputfield/customautocomplete.dart';
import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/helper/constants/constants.dart';
import 'package:prohelp_app/helper/preference/preference_manager.dart';
import 'package:prohelp_app/helper/service/api_service.dart';
import 'package:prohelp_app/helper/state/state_manager.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class SkillsForm extends StatefulWidget {
  final PreferenceManager manager;
  const SkillsForm({
    Key? key,
    required this.manager,
  }) : super(key: key);

  @override
  State<SkillsForm> createState() => _SkillsFormState();
}

class _SkillsFormState extends State<SkillsForm> {
  // final _messageController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final _controller = Get.find<StateController>();

  List<String> _selectedSkills = [];
  var _filteredList = [];
  double _proficiency1 = 0,
      _proficiency2 = 0,
      _proficiency3 = 0,
      _proficiency4 = 0,
      _proficiency5 = 0;

  _initSkills() {
    for (var i = 0; i < widget.manager.getUser()['skills']?.length; i++) {
      setState(() {
        _selectedSkills.add(widget.manager.getUser()['skills'][i]['name']);
      });

      switch (i) {
        case 0:
          setState(() {
            _proficiency1 = double.parse(
                widget.manager.getUser()['skills'][i]['proficiency']);
          });
          break;
        case 1:
          setState(() {
            _proficiency2 = double.parse(
                widget.manager.getUser()['skills'][i]['proficiency']);
          });
          break;
        case 2:
          setState(() {
            _proficiency3 = double.parse(
                widget.manager.getUser()['skills'][i]['proficiency']);
          });
          break;
        case 3:
          setState(() {
            _proficiency4 = double.parse(
                widget.manager.getUser()['skills'][i]['proficiency']);
          });
          break;
        default:
          setState(() {
            _proficiency5 = double.parse(
                widget.manager.getUser()['skills'][i]['proficiency']);
          });
          break;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _initSkills();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.60,
            child: Column(
              children: [
                TextPoppins(
                  text:
                      "Search and choose your favourite skills\n5 skills max allowed",
                  fontSize: 16,
                  align: TextAlign.center,
                  fontWeight: FontWeight.w500,
                ),
                const TextInter(
                  text: "Acquire more skills to earn more",
                  fontSize: 15,
                  align: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 24.0,
          ),
          CustomAutoComplete(
            data: const [
              "Design",
              "Art Work",
              "Driving",
              "Chef",
              "Financial Analysis",
              "Baking",
              "Programming"
            ],
            onItemSelected: (val) {
              debugPrint("VALUE SELECTED:: $val");
              FocusManager.instance.primaryFocus?.unfocus();
              if (_selectedSkills.length < 6) {
                if (!_selectedSkills.contains(val)) {
                  setState(() {
                    _selectedSkills.add(val);
                  });
                } else {
                  Constants.toast("Skill already selected!");
                }
              } else {
                Constants.toast("Maximum number of skills reached!!");
              }
            },
            hintText: "Search skills",
          ),
          const SizedBox(
            height: 24.0,
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Wrap(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.275,
                        child: TextPoppins(
                          text: _selectedSkills.elementAt(index),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const TextInter(
                          text: "Proficiency",
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          align: TextAlign.center,
                        ),
                        SfSlider(
                          min: 0.0,
                          max: 100.0,
                          value: index == 0
                              ? _proficiency1
                              : index == 1
                                  ? _proficiency2
                                  : index == 2
                                      ? _proficiency3
                                      : index == 3
                                          ? _proficiency4
                                          : _proficiency5,
                          interval: 25,
                          showDividers: false,
                          showTicks: false,
                          showLabels: true,
                          enableTooltip: true,
                          tooltipShape: const SfPaddleTooltipShape(),
                          minorTicksPerInterval: 0,
                          onChanged: (dynamic value) {
                            setState(() {
                              index == 0
                                  ? _proficiency1 = (value)
                                  : index == 1
                                      ? _proficiency2 = (value)
                                      : index == 2
                                          ? _proficiency3 = (value)
                                          : index == 3
                                              ? _proficiency4 = (value)
                                              : _proficiency5 = (value);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _selectedSkills.removeAt(index);
                      });
                    },
                    child: const Icon(CupertinoIcons.delete),
                  ),
                ],
              );
            },
            separatorBuilder: (context, index) => const SizedBox(
              height: 32.0,
            ),
            itemCount: _selectedSkills.length,
          ),
          const SizedBox(
            height: 32.0,
          ),
          RoundedButton(
            bgColor: Constants.primaryColor,
            child: const TextInter(text: "SAVE CHANGES", fontSize: 16),
            borderColor: Colors.transparent,
            foreColor: Colors.white,
            onPressed: () {
              _controller.setLoading(true);

              for (var i = 0; i < _selectedSkills.length; i++) {
                _filteredList.add(
                  {
                    "name": _selectedSkills[i].toLowerCase(),
                    "proficiency": i == 0
                        ? _proficiency1
                        : i == 1
                            ? _proficiency2
                            : i == 2
                                ? _proficiency3
                                : i == 3
                                    ? _proficiency4
                                    : _proficiency5
                  },
                );
              }

              Future.delayed(const Duration(seconds: 3), () {
                _saveSkills();
              });
            },
            variant: "Filled",
          ),
        ],
      ),
    );
  }

  _saveSkills() async {
    Map _payload = {"skills": _filteredList};
    try {
      final resp = await APIService().updateProfile(
          accessToken: widget.manager.getAccessToken(),
          body: _payload,
          email: widget.manager.getUser()['email']);

      debugPrint(resp.body);
      _controller.setLoading(false);

      if (resp.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(resp.body);
        Constants.toast(map['message']);

        //Refresh user profile
        String userData = jsonEncode(map['data']);
        widget.manager.setUserData(userData);
        _controller.userData.value = map['data'];

      } else {
        Map<String, dynamic> map = jsonDecode(resp.body);
        Constants.toast(map['message']);
      }
    } catch (e) {
      debugPrint(e.toString());
      _controller.setLoading(false);
    }
  }
}

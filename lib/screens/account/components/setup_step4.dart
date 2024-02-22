import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prohelp_app/components/inputfield/customautocomplete.dart';
import 'package:prohelp_app/components/inputfield/customdropdown.dart';
import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/data/disablility/disbilities.dart';
import 'package:prohelp_app/data/languages/languages.dart';
import 'package:prohelp_app/helper/constants/constants.dart';
import 'package:prohelp_app/helper/state/state_manager.dart';

typedef void InitCallback(Map data);

class SetupStep4 extends StatefulWidget {
  InitCallback onStep4Completed;
  SetupStep4({
    Key? key,
    required this.onStep4Completed,
  }) : super(key: key);

  @override
  State<SetupStep4> createState() => _SetupStep4State();
}

class _SetupStep4State extends State<SetupStep4> {
  // final _disabilityController = TextEditingController();

  // final _title1Controller = TextEditingController();
  // final _title2Controller = TextEditingController();

  final _controller = Get.find<StateController>();
  // List<String> _selectedLanguages = [];
  List<String> _selectedLangReadWrite = [];

  bool _isDisablity = false;
  String _selectedDisability = "";

  // List<PlatformFile>? _pickedFiles = [];

  @override
  void initState() {
    // _disabilityController.text = _controller.school.value;

    super.initState();
  }

  @override
  void didChangeDependencies() {
    // _disabilityController.text = _controller.school.value;

    super.didChangeDependencies();
  }

  _onSelected(val) {
    setState(() {
      _selectedDisability = val;
    });

    widget.onStep4Completed({"disability": val});
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        children: [
          CustomAutoComplete(
            data: languages,
            onItemSelected: (val) {
              debugPrint("VALUE SELECTED:: $val");
              FocusManager.instance.primaryFocus?.unfocus();
              if (_controller.languagesSpoken.value.length < 6) {
                if (!_controller.languagesSpoken.value.contains(val)) {
                  setState(() {
                    _controller.languagesSpoken.add(val);
                  });
                } else {
                  Constants.toast("Language already selected!");
                }
              } else {
                Constants.toast("Maximum number of languages reached!!");
              }
            },
            hintText: "Add Languages spoken",
          ),
          const SizedBox(
            height: 4.0,
          ),
          _controller.languagesSpoken.value.isEmpty
              ? const SizedBox()
              : SizedBox(
                  height:
                      _controller.languagesSpoken.value.length < 4 ? 36 : 80,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(8.0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 8,
                      // width / height: fixed for *all* items
                      childAspectRatio: 3.75,
                    ),
                    // return a custom ItemCard
                    itemBuilder: (context, i) => Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(4.0),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          child: Text(
                            _controller.languagesSpoken.value[i],
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.black54),
                          ),
                        ),
                        Positioned(
                          top: 1,
                          right: -2,
                          child: ClipOval(
                            child: InkWell(
                              onTap: () {
                                _removeLanguage(i, _controller.languagesSpoken);
                              },
                              child: const Icon(
                                Icons.close,
                                size: 21,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    itemCount: _controller.languagesSpoken.value.length,
                  ),
                ),
          const SizedBox(
            height: 16.0,
          ),
          CustomAutoComplete(
            data: languages,
            onItemSelected: (val) {
              // debugPrint("VALUE SELECTED:: $val");
              FocusManager.instance.primaryFocus?.unfocus();
              if (_controller.languagesSpeakWrite.value.length < 6) {
                if (!_controller.languagesSpeakWrite.value.contains(val)) {
                  setState(() {
                    _controller.languagesSpeakWrite.add(val);
                  });
                } else {
                  Constants.toast("Language already selected!");
                }
              } else {
                Constants.toast("Maximum number of languages reached!!");
              }
            },
            hintText: "Languages you can read and write",
          ),
          const SizedBox(
            height: 4.0,
          ),
          _controller.languagesSpeakWrite.value.isEmpty
              ? const SizedBox()
              : SizedBox(
                  height: _controller.languagesSpeakWrite.value.length < 4
                      ? 36
                      : 80,
                  child: GridView.builder(
                    padding: const EdgeInsets.all(8.0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 8,
                      // width / height: fixed for *all* items
                      childAspectRatio: 3.75,
                    ),
                    // return a custom ItemCard
                    itemBuilder: (context, i) => Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(4.0),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          child: Text(
                            _controller.languagesSpeakWrite.value[i],
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.black54),
                          ),
                        ),
                        Positioned(
                          top: 1,
                          right: -2,
                          child: ClipOval(
                            child: InkWell(
                              onTap: () {
                                _removeLanguage(
                                    i, _controller.languagesSpeakWrite);
                              },
                              child: const Icon(
                                Icons.close,
                                size: 21,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    itemCount: _controller.languagesSpeakWrite.value.length,
                  ),
                ),
          const SizedBox(
            height: 16.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextPoppins(text: 'Do you have disabilities? ', fontSize: 14),
              Checkbox(
                value: !_isDisablity,
                onChanged: (val) {
                  setState(() {
                    _isDisablity = !_isDisablity;
                  });
                },
              ),
              TextPoppins(text: 'No ', fontSize: 12),
              Checkbox(
                value: _isDisablity,
                onChanged: (val) {
                  setState(() {
                    _isDisablity = !_isDisablity;
                  });
                },
              ),
              TextPoppins(text: 'Yes ', fontSize: 12),
            ],
          ),
          const SizedBox(
            height: 8.0,
          ),
          _isDisablity
              ? CustomDropdown(
                  onSelected: _onSelected,
                  hint: "Disability",
                  items: disabilities,
                )
              : const SizedBox(),
        ],
      ),
    );
  }

  _removeLanguage(int index, var list) {
    list.removeAt(index);
  }
}

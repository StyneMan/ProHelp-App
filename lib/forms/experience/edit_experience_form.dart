import 'dart:convert';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/instance_manager.dart';
import 'package:prohelp_app/components/button/roundedbutton.dart';
import 'package:prohelp_app/components/inputfield/customautocomplete.dart';
import 'package:prohelp_app/components/inputfield/datefield.dart';
import 'package:prohelp_app/components/inputfield/textfield.dart';
import 'package:prohelp_app/components/picker/img_picker.dart';
import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/data/countries/countries.dart';
import 'package:prohelp_app/data/state/nigerian_states.dart';
import 'package:prohelp_app/helper/constants/constants.dart';
import 'package:prohelp_app/helper/preference/preference_manager.dart';
import 'package:prohelp_app/helper/service/api_service.dart';
import 'package:prohelp_app/helper/state/state_manager.dart';

class EditExperienceForm extends StatefulWidget {
  final PreferenceManager manager;
  var itemData;
  int index;
  EditExperienceForm({
    Key? key,
    required this.index,
    required this.manager,
    required this.itemData,
  }) : super(key: key);

  @override
  State<EditExperienceForm> createState() => _UpdateEducationFormState();
}

class _UpdateEducationFormState extends State<EditExperienceForm> {
  final _controller = Get.find<StateController>();
  final _formKey = GlobalKey<FormState>();

  final _roleController = TextEditingController();
  final _companyController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();

  String _selectedState = "";
  String _selectedWorkType = "";
  String _selectedCountry = "";

  final double _kItemExtent = 32.0;
  bool _stillHere = false;

  bool _isImagePicked = false;
  var _croppedFile;

  final List<String> _workTypes = <String>[
    'Full-time',
    'Part-time',
    'Contract',
    'Remote'
  ];

  // String _selectedDegree = "Select Degree";

  @override
  void initState() {
    super.initState();
    setState(() {
      _companyController.text = widget.itemData['company'];
      _roleController.text = widget.itemData['role'];
      _startDateController.text = widget.itemData['startDate'];
      _endDateController.text = widget.itemData['endate'];
      _selectedCountry = widget.itemData['country'] ?? "";
      _selectedState = widget.itemData['region'] ?? "";
      _stillHere = widget.itemData['stillHere'];
      _selectedWorkType = widget.itemData['workType'] ?? "";
    });
  }

  _onImageSelected(var file) {
    setState(() {
      _isImagePicked = true;
      _croppedFile = file;
    });
    // debugPrint("VALUIE::: :: $file");
  }

  _onCountrySelected(String val) {
    setState(() {
      _selectedCountry = val;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0.0,
      color: Colors.grey.shade300,
      child: Form(
        key: _formKey,
        child: Localizations(
          delegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          locale: const Locale('en', ''),
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            shrinkWrap: true,
            children: [
              Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16.0),
                      child: _isImagePicked
                          ? Image.file(
                              File(_controller.croppedPic.value),
                              errorBuilder: (context, error, stackTrace) =>
                                  Image.asset(
                                "assets/images/placeholder.png",
                                width: 128,
                                height: 128,
                                fit: BoxFit.cover,
                              ),
                              width: 128,
                              height: 128,
                              fit: BoxFit.cover,
                            )
                          : Image.network(
                              widget.itemData['companyLogo'],
                              errorBuilder: (context, error, stackTrace) =>
                                  Image.asset(
                                "assets/images/placeholder.png",
                                width: 128,
                                height: 128,
                                fit: BoxFit.cover,
                              ),
                              width: 128,
                              height: 128,
                              fit: BoxFit.cover,
                            ),
                    ),
                    Positioned(
                      bottom: -4,
                      right: -6,
                      child: CircleAvatar(
                        child: IconButton(
                          onPressed: () {
                            showCupertinoDialog(
                              context: context,
                              useRootNavigator: true,
                              builder: (context) => CupertinoAlertDialog(
                                title: TextPoppins(
                                  text: "Image Picker".toUpperCase(),
                                  fontSize: 18,
                                ),
                                content: SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.96,
                                  height: 160,
                                  child: Column(
                                    children: [
                                      const SizedBox(
                                        height: 21,
                                      ),
                                      ImgPicker(
                                        onCropped: _onImageSelected,
                                      ),
                                    ],
                                  ),
                                ),
                                actions: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: TextRoboto(
                                        text: "Close",
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.add_a_photo,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 6.0,
              ),
              const Text(
                "Company's Logo (optional)",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black, fontSize: 15),
              ),
              const SizedBox(
                height: 18.0,
              ),
              CustomTextField(
                hintText: "Company name",
                onChanged: (val) {},
                controller: _companyController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Name of company is required';
                  }

                  return null;
                },
                inputType: TextInputType.text,
                capitalization: TextCapitalization.words,
              ),
              const SizedBox(
                height: 16.0,
              ),
              CustomTextField(
                hintText: "Position(Role)",
                onChanged: (val) {},
                controller: _roleController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Your position/role is required';
                  }
                  return null;
                },
                inputType: TextInputType.text,
                capitalization: TextCapitalization.words,
              ),
              const SizedBox(
                height: 16.0,
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 12.0,
                  ),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(36),
                    ),
                    gapPadding: 4.0,
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(36),
                    ),
                    gapPadding: 4.0,
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(36),
                    ),
                    gapPadding: 4.0,
                  ),
                  filled: false,
                  hintText: _selectedState,
                  labelText: "State",
                  focusColor: Constants.accentColor,
                  hintStyle: const TextStyle(
                    fontFamily: "Inter",
                    color: Colors.black38,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                items: _workTypes
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(e),
                      ),
                    )
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedWorkType = val as String;
                  });
                },
              ),
              const SizedBox(
                height: 16.0,
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 12.0,
                  ),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(36),
                    ),
                    gapPadding: 4.0,
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(36),
                    ),
                    gapPadding: 4.0,
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(36),
                    ),
                    gapPadding: 4.0,
                  ),
                  filled: false,
                  hintText: _selectedState,
                  labelText: "State",
                  focusColor: Constants.accentColor,
                  hintStyle: const TextStyle(
                    fontFamily: "Inter",
                    color: Colors.black38,
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                items: nigerianStates
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(e),
                      ),
                    )
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedState = val as String;
                  });
                },
              ),
              const SizedBox(
                height: 16.0,
              ),
              CustomAutoComplete(
                data: countries,
                onItemSelected: _onCountrySelected,
                hintText: "Country",
              ),
              const SizedBox(
                height: 16.0,
              ),
              CustomDateField(
                hintText: "Start Date",
                onDateSelected: (String raw, String val) {
                  setState(() {
                    _startDateController.text = val;
                  });
                },
                controller: _startDateController,
              ),
              const SizedBox(
                height: 16.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: CustomDateField(
                      isEnabled: !_stillHere,
                      hintText: "Graduation Date",
                      onDateSelected: (String raw, String val) {
                        setState(() {
                          _endDateController.text = val;
                        });
                      },
                      controller: _endDateController,
                    ),
                  ),
                  const SizedBox(
                    width: 16.0,
                  ),
                  Row(
                    children: [
                      const Text("Still working"),
                      CupertinoSwitch(
                        value: _stillHere,
                        activeColor: Constants.primaryColor,
                        onChanged: (val) {
                          setState(() {
                            _stillHere = val;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(
                height: 24.0,
              ),
              RoundedButton(
                bgColor: Constants.primaryColor,
                child: const TextInter(text: "SAVE CHANGES", fontSize: 16),
                borderColor: Colors.transparent,
                foreColor: Colors.white,
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _save(widget.index);
                  }
                },
                variant: "Filled",
              ),
            ],
          ),
        ),
      ),
    );
  }

  _save(index) async {
    _controller.setLoading(true);
    var li = widget.manager.getUser()['experience'];
    var filter = li?.removeAt(index);

    try {
      if (_controller.croppedPic.value.isNotEmpty) {
        //Now upload to Firebase Storage first
        final storageRef = FirebaseStorage.instance.ref();
        final fileRef =
            storageRef.child("experience").child(widget.manager.getUser()['email']);
        final _resp = await fileRef.putFile(File(_controller.croppedPic.value));
        final url = await _resp.ref.getDownloadURL();

        //Now save this url to server
        Map _payload = {
          "experience": [
            ...li,
            {
              "company": _companyController.text.toLowerCase(),
              "role": _roleController.text.toLowerCase(),
              "region": _selectedState.toLowerCase(),
              "workType": _selectedWorkType.toLowerCase(),
              "country": _selectedCountry.toLowerCase(),
              "companyLogo": url,
              "endate": _stillHere ? "" : _endDateController.text,
              "stillHere": _stillHere,
              "startDate": _startDateController.text,
            }
          ]
        };

        // print("DATARIZZED::: $_payload}");

        final resp = await APIService().updateProfile(
          body: _payload,
          accessToken: widget.manager.getAccessToken(),
          email: widget.manager.getUser()['email'],
        );

        _controller.setLoading(false);
        debugPrint("EDU NEW RESPONSE:: ${resp.body}");

        if (resp.statusCode == 200) {
          Map<String, dynamic> _map = jsonDecode(resp.body);
          Constants.toast(_map['message']);
          _controller.croppedPic.value = "";

          //Nw save user's data to preference
          String userData = jsonEncode(_map['data']);
          _controller.userData.value = _map['data'];
          widget.manager.setUserData(userData);

          _controller.shouldExitExpEdu.value = true;
          Future.delayed(const Duration(seconds: 1), () {
            Navigator.pop(context);
          });
          // Navigator.of(context).pop();
        } else {
          Map<String, dynamic> _map = jsonDecode(resp.body);
          Constants.toast(_map['message']);
        }
      } else {
        Map payload = {
          "experience": [
            ...li,
            {
             "company": _companyController.text.toLowerCase(),
              "role": _roleController.text.toLowerCase(),
              "region": _selectedState.toLowerCase(),
              "workType": _selectedWorkType.toLowerCase(),
              "country": _selectedCountry.toLowerCase(),
              "endate": _stillHere ? "" : _endDateController.text,
              "stillHere": _stillHere,
              "startDate": _startDateController.text,
            }
          ]
        };

        debugPrint("DATARIZZED::: $payload}");

        final _resp = await APIService().updateProfile(
          body: payload,
          accessToken: widget.manager.getAccessToken(),
          email: widget.manager.getUser()['email'],
        );

        _controller.setLoading(false);
        debugPrint("EDU NEW RESPONSE:: ${_resp.body}");

        if (_resp.statusCode == 200) {
          Map<String, dynamic> _map = jsonDecode(_resp.body);
          Constants.toast(_map['message']);

          //Nw save user's data to preference
          String userData = jsonEncode(_map['data']);
          _controller.setUserData(_map['data']);
          widget.manager.setUserData(userData);

          // Navigator.pop(context);
          _controller.shouldExitExpEdu.value = true;
          Future.delayed(const Duration(seconds: 1), () {
            Navigator.pop(context);
          });
          // Navigator.of(context).pop();
        } else {
          Map<String, dynamic> _map = jsonDecode(_resp.body);
          Constants.toast(_map['message']);
        }
      }
    } catch (e) {
      _controller.setLoading(false);
      debugPrint(e.toString());
    }
  }
}
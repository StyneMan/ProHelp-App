import 'dart:convert';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:prohelp_app/components/button/roundedbutton.dart';
import 'package:prohelp_app/components/dialog/custom_dialog.dart';
import 'package:prohelp_app/components/inputfield/lineddatefield.dart';
import 'package:prohelp_app/components/inputfield/lineddropdown2.dart';
import 'package:prohelp_app/components/inputfield/llinedtextfield.dart';
import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/helper/constants/constants.dart';
import 'package:prohelp_app/helper/preference/preference_manager.dart';
import 'package:prohelp_app/helper/service/api_service.dart';
import 'package:prohelp_app/helper/state/state_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Personal extends StatefulWidget {
  final PreferenceManager manager;
  const Personal({
    Key? key,
    required this.manager,
  }) : super(key: key);

  @override
  State<Personal> createState() => _PersonalState();
}

class _PersonalState extends State<Personal> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();
  final _addressController = TextEditingController();
  final _ninController = TextEditingController();
  String _selectedGender = "";
  String? _genderLabel;
  bool _shouldEdit = false;

  // final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _controller = Get.find<StateController>();

  onSelected(val) {
    setState(() {
      _selectedGender = val;
      _shouldEdit = true;
    });
  }

  onDateSelected(val) {
    setState(() {
      _ageController.text = val;
      _shouldEdit = true;
    });
  }

  @override
  void initState() {
    super.initState();

    setState(() {
      _nameController.text = _controller.userData.value['bio']['fullname']
              .toString()
              .capitalize ??
          widget.manager.getUser()['bio']['fullname'].toString().capitalize ??
          "Not set";
      _phoneController.text = _controller.userData.value['bio']['phone'] ??
          widget.manager.getUser()['bio']['phone'] ??
          "Not set";
      _addressController.text = _controller.userData.value['bio']['address']
              .toString()
              .capitalize ??
          widget.manager.getUser()['bio']['address'].toString().capitalize ??
          "Not set";
      _emailController.text = _controller.userData.value['email'] ??
          widget.manager.getUser()['email'] ??
          "Not set";
      _ninController.text = _controller.userData.value['bio']['nin'] ??
          widget.manager.getUser()['bio']['nin'] ??
          "0";
      _ageController.text =
          widget.manager.getUser()['bio']['dob'] ?? "dd/mm/yyyy";
      _genderLabel =
          _controller.userData.value['bio']['gender'].toString().capitalize ??
              widget.manager.getUser()['bio']['gender'].toString().capitalize ??
              "Gender";
      _shouldEdit = _controller.croppedPic.value.isNotEmpty;
    });

    // onSelected(
    //     ;
  }

  showStatusDialog() => showDialog(
        context: context,
        builder: (BuildContext context) => SizedBox(
          height: MediaQuery.of(context).size.height * 0.4,
          width: MediaQuery.of(context).size.width * 0.98,
          child: CustomDialog(
            ripple: SvgPicture.asset(
              "assets/images/check_effect.svg",
              width: (Constants.avatarRadius + 20),
              height: (Constants.avatarRadius + 20),
            ),
            avtrBg: Colors.transparent,
            avtrChild: Image.asset(
              "assets/images/checked.png",
            ), //const Icon(CupertinoIcons.check_mark, size: 50,),
            body: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 16.0,
                horizontal: 36.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextPoppins(
                    text: "Profile Update",
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  TextPoppins(
                    text: "Updated successfully",
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                  const SizedBox(
                    height: 21,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.36,
                    child: RoundedButton(
                      bgColor: Constants.primaryColor,
                      child: TextPoppins(
                        text: "CLOSE",
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                      ),
                      borderColor: Colors.transparent,
                      foreColor: Colors.white,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      variant: "Filled",
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  _updateProfile() async {
    _controller.setLoading(true);

    if (_controller.croppedPic.value.isEmpty) {
      Map _payload = {
        "bio": {
          ...widget.manager.getUser()['bio'],
          "fullname": _nameController.text.toLowerCase(),
          "phone": _phoneController.text,
          "address": _addressController.text,
          "dob": _ageController.text,
          "nin": _ninController.text,
        }
      };
      try {
        final _prefs = await SharedPreferences.getInstance();
        var _token = _prefs.getString("accessToken") ?? "";
        final resp = await APIService().updateProfile(
            accessToken: _token,
            body: _payload,
            email: widget.manager.getUser()['email']);

        debugPrint("ABOUT UPDATE:  >> ${resp.body}");
        _controller.setLoading(false);

        if (resp.statusCode == 200) {
          Map<String, dynamic> map = jsonDecode(resp.body);
          Constants.toast(map['message']);

          //Refresh user profile
          String userData = jsonEncode(map['data']);
          widget.manager.setUserData(userData);

          setState(() {
            _nameController.text = map['data']['bio']['fullname'];
            _phoneController.text = map['data']['bio']['phone'];
            _addressController.text = map['data']['bio']['address'];
            _ageController.text = map['data']['bio']['dob'];
            _ninController.text = map['data']['bio']['nin'];
            _shouldEdit = false;
          });

          showStatusDialog();
        } else {
          Map<String, dynamic> map = jsonDecode(resp.body);
          Constants.toast(map['message']);
        }
      } catch (e) {
        _controller.setLoading(false);
        debugPrint(e.toString());
      }
    } else {
      try {
        //Now upload to Firebase Storage first
        final storageRef = FirebaseStorage.instance.ref();
        final fileRef = storageRef
            .child("photos")
            .child("${widget.manager.getUser()['email']}");
        final _resp = await fileRef.putFile(File(_controller.croppedPic.value));
        final url = await _resp.ref.getDownloadURL();

        //Now save this url to server
        Map _payload = {
          "bio": {
            ...widget.manager.getUser()['bio'],
            "fullname": _nameController.text.toLowerCase(),
            "phone": _phoneController.text,
            "address": _addressController.text,
            "dob": _ageController.text,
            "nin": _ninController.text,
            "image": url,
          }
        };
        final _prefs = await SharedPreferences.getInstance();
        var _token = _prefs.getString("accessToken") ?? "";
        final resp = await APIService().updateProfile(
            accessToken: _token,
            body: _payload,
            email: widget.manager.getUser()['email']);

        debugPrint("ABOUT UPDATE:  >> ${resp.body}");
        _controller.setLoading(false);

        if (resp.statusCode == 200) {
          Map<String, dynamic> map = jsonDecode(resp.body);
          Constants.toast(map['message']);

          //Refresh user profile
          String userData = jsonEncode(map['data']);
          widget.manager.setUserData(userData);

          setState(() {
            _nameController.text = map['data']['bio']['fullname'];
            _phoneController.text = map['data']['bio']['phone'];
            _addressController.text = map['data']['bio']['address'];
            _ageController.text = map['data']['bio']['dob'];
            _ninController.text = map['data']['bio']['nin'];
            _shouldEdit = false;
          });

          _controller.croppedPic.value = "";

          showStatusDialog();
        } else {
          Map<String, dynamic> map = jsonDecode(resp.body);
          Constants.toast(map['message']);
        }
      } catch (e) {
        _controller.setLoading(false);
        debugPrint(e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // debugPrint("LKL>> ${_controller.userData.value['nokName']}");
    return Form(
      key: _formKey,
      child: ListView(
        children: [
          LinedTextField(
            label: "Full Name",
            onChanged: (val) {
              setState(() {
                _shouldEdit = true;
              });
            },
            controller: _nameController,
            validator: (value) {
              if (value.toString().isEmpty || value == null) {
                return "Full name is required";
              }
              return null;
            },
            inputType: TextInputType.name,
            capitalization: TextCapitalization.words,
          ),
          const Divider(
            color: Constants.accentColor,
          ),
          const SizedBox(
            height: 10.0,
          ),
          LinedTextField(
            label: "Email",
            isEnabled: false,
            onChanged: (val) {},
            controller: _emailController,
            validator: (value) {
              if (value.toString().isEmpty || value == null) {
                return "Email address is required";
              }
              return null;
            },
            inputType: TextInputType.emailAddress,
            capitalization: TextCapitalization.words,
          ),
          const Divider(
            color: Constants.accentColor,
          ),
          const SizedBox(
            height: 6.0,
          ),
          LinedTextField(
            label: "Phone ",
            onChanged: (val) {
              setState(() {
                _shouldEdit = true;
              });
            },
            controller: _phoneController,
            validator: (value) {
              if (value.toString().isEmpty || value == null) {
                return "Phone number is required";
              }
              return null;
            },
            inputType: TextInputType.number,
            capitalization: TextCapitalization.none,
          ),
          const Divider(
            color: Constants.accentColor,
          ),
          const SizedBox(
            height: 6.0,
          ),
          LinedDateField(
            label: "Age",
            onDateSelected: onDateSelected,
            controller: _ageController,
            inputType: TextInputType.datetime,
          ),
          const Divider(
            color: Constants.accentColor,
          ),
          const SizedBox(
            height: 6.0,
          ),
          LinedDropdown2(
            label: "$_genderLabel",
            title: "Gender",
            onSelected: onSelected,
            items: const ["Male", "Female"],
          ),
          const Divider(
            color: Constants.accentColor,
          ),
          const SizedBox(
            height: 6.0,
          ),
          LinedTextField(
            label: "Address",
            onChanged: (val) {
              setState(() {
                _shouldEdit = true;
              });
            },
            controller: _addressController,
            validator: (value) {
              if (value.toString().isEmpty || value == null) {
                return "Address is required";
              }
              return null;
            },
            inputType: TextInputType.text,
            capitalization: TextCapitalization.words,
          ),
          const Divider(
            color: Constants.accentColor,
          ),
          const SizedBox(
            height: 6.0,
          ),
          LinedTextField(
            label: "NIN",
            onChanged: (val) {
              setState(() {
                _shouldEdit = true;
              });
            },
            controller: _ninController,
            validator: (value) {
              if (value.toString().isEmpty || value == null) {
                return "ID number is required";
              }
              return null;
            },
            inputType: TextInputType.number,
            capitalization: TextCapitalization.none,
          ),
          const Divider(
            color: Constants.accentColor,
          ),
          const SizedBox(
            height: 21.0,
          ),
          Obx(
            () => RoundedButton(
              isLoading: _controller.isLoading.value, 
              bgColor: Constants.primaryColor,
              child: const TextInter(text: "SAVE CHANGES", fontSize: 16),
              borderColor: Colors.transparent,
              foreColor: Colors.white,
              onPressed: !_shouldEdit && _controller.croppedPic.value.isEmpty
                  ? null
                  : () {
                      if (_formKey.currentState!.validate()) {
                        _updateProfile();
                      }
                    },
              variant: "Filled",
            ),
          ),
        ],
      ),
    );
  }
}

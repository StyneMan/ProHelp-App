import 'dart:convert';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:prohelp_app/components/button/roundedbutton.dart';
import 'package:prohelp_app/components/dialog/custom_dialog.dart';
import 'package:prohelp_app/components/inputfield/lineddropdown2.dart';
import 'package:prohelp_app/components/inputfield/llinedtextfield.dart';
import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/data/relationships/relationships.dart';
import 'package:prohelp_app/helper/constants/constants.dart';
import 'package:prohelp_app/helper/preference/preference_manager.dart';
import 'package:prohelp_app/helper/service/api_service.dart';
import 'package:prohelp_app/helper/state/state_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NOK extends StatefulWidget {
  final PreferenceManager manager;
  const NOK({
    Key? key,
    required this.manager,
  }) : super(key: key);

  @override
  State<NOK> createState() => _NOKState();
}

class _NOKState extends State<NOK> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  String _selectedRelationship = "";
  String? _relationshipLabel;

  // final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _shouldEdit = false;
  final _controller = Get.find<StateController>();

  onSelected(val) {
    setState(() {
      _selectedRelationship = val;
    });
  }

  @override
  void initState() {
    super.initState();

    setState(() {
      _nameController.text = _controller.userData.value['guarantor']['name']
              .toString()
              .capitalize ??
          widget.manager.getUser()['guarantor']['name'].toString().capitalize ??
          "Not set";
      _phoneController.text = _controller.userData.value['guarantor']
              ['phone'] ??
          widget.manager.getUser()['guarantor']['phone'] ??
          "Not set";
      _addressController.text = _controller
              .userData.value['guarantor']['address']
              .toString()
              .capitalize ??
          widget.manager
              .getUser()['guarantor']['address']
              .toString()
              .capitalize ??
          "Not set";
      _emailController.text = _controller.userData.value['guarantor']
              ['email'] ??
          widget.manager.getUser()['guarantor']['email'] ??
          "Not set";

      _relationshipLabel = _controller
              .userData.value['guarantor']['relationship']
              .toString()
              .capitalize ??
          widget.manager
              .getUser()['guarantor']['relationship']
              .toString()
              .capitalize ??
          "Select";
    });
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
        "guarantor": {
          ...widget.manager.getUser()['bio'],
          "name": _nameController.text.toLowerCase(),
          "phone": _phoneController.text,
          "address": _addressController.text,
          "email": _emailController.text,
          "relationship": _selectedRelationship.toLowerCase(),
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
            _nameController.text = map['data']['guarantor']['name'];
            _phoneController.text = map['data']['guarantor']['phone'];
            _addressController.text = map['data']['guarantor']['address'];
            _emailController.text = map['data']['guarantor']['email'];
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
            "image": url,
          },
          "guarantor": {
            ...widget.manager.getUser()['bio'],
            "name": _nameController.text.toLowerCase(),
            "phone": _phoneController.text,
            "address": _addressController.text,
            "email": _emailController.text,
            "relationship": _selectedRelationship.toLowerCase(),
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
            _nameController.text = map['data']['guarantor']['name'];
            _phoneController.text = map['data']['guarantor']['phone'];
            _addressController.text = map['data']['guarantor']['address'];
            _emailController.text = map['data']['guarantor']['email'];
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
    // print("LKL>> ${_controller.userData.value['nokName']}");
    return Form(
      key: _formKey,
      child: ListView(
        children: [
          LinedTextField(
            label: "Name",
            onChanged: (val) {},
            controller: _nameController,
            validator: (value) {
              if (value.toString().isEmpty || value == null) {
                return "Guarantor's name is required";
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
            onChanged: (val) {},
            controller: _emailController,
            validator: (value) {
              if (value.toString().isEmpty || value == null) {
                return "Guarantor's email is required";
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
            label: "Phone ",
            onChanged: (val) {},
            controller: _phoneController,
            validator: (value) {
              if (value.toString().isEmpty || value == null) {
                return "Guarantor's phone number is required";
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
            height: 10.0,
          ),
          LinedDropdown2(
            title: "Relationship",
            label: "$_relationshipLabel",
            onSelected: onSelected,
            items: relationships,
          ),
          const Divider(
            color: Constants.accentColor,
          ),
          const SizedBox(
            height: 10.0,
          ),
          LinedTextField(
            label: "Address",
            onChanged: (val) {},
            controller: _addressController,
            validator: (value) {
              if (value.toString().isEmpty || value == null) {
                return "Guarantor's address is required";
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
            height: 21.0,
          ),
          RoundedButton(
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
        ],
      ),
    );
  }
}

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
      _shouldEdit = true;
    });
  }

  @override
  void initState() {
    super.initState();
    print("GURANTOR ::: ${_controller.userData.value}");

    if (_controller.userData.value.isNotEmpty) {
      if (_controller.userData.value['guarantor'] != null) {
        setState(() {
          _nameController.text = _controller.userData.value['guarantor']['name']
                  .toString()
                  .capitalize ??
              widget.manager
                  .getUser()['guarantor']['name']
                  .toString()
                  .capitalize ??
              "Not set";
          _phoneController.text =
              widget.manager.getUser()['guarantor']['phone'] ?? "Not set";
          _addressController.text = widget.manager
                  .getUser()['guarantor']['address']
                  .toString()
                  .capitalize ??
              "Not set";
          _emailController.text =
              widget.manager.getUser()['guarantor']['email'] ?? "Not set";

          _relationshipLabel = widget.manager
                  .getUser()['guarantor']['relationship']
                  .toString()
                  .capitalize ??
              "Select";
        });
      }
    }
  }

  _updateProfile() async {
    _controller.setLoading(true);

    if (_controller.croppedPic.value.isEmpty) {
      Map _payload = {
        "guarantor": {
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
          _controller.setUserData(map['data']);

          setState(() {
            _nameController.text = map['data']['guarantor']['name'];
            _phoneController.text = map['data']['guarantor']['phone'];
            _addressController.text = map['data']['guarantor']['address'];
            _emailController.text = map['data']['guarantor']['email'];
            _shouldEdit = false;
          });

          Constants.showStatusDialog(context: context);
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

          Constants.showStatusDialog(context: context);
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
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipOval(
                      child: Container(
                        height: 128,
                        width: 128,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(64),
                        ),
                        child: Image.network(
                          "${widget.manager.getUser()['bio']}",
                          errorBuilder: (context, error, stackTrace) =>
                              ClipOval(
                            child: SvgPicture.asset(
                              "assets/images/personal.svg",
                              fit: BoxFit.cover,
                            ),
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 6,
                      right: -24,
                      child: Chip(
                        label: TextInter(
                          text: widget.manager.getUser()['isGuarantorVerified']
                              ? "Verified"
                              : "Not verified",
                          fontSize: 12,
                        ),
                        backgroundColor:
                            widget.manager.getUser()['isGuarantorVerified']
                                ? Colors.green
                                : Colors.amber,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10.0,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.60,
                  child: TextPoppins(
                    text:
                        "Provide accurate information about your gurantor in the form below",
                    fontSize: 14,
                    align: TextAlign.center,
                  ),
                )
              ],
            ),
          ),
          const SizedBox(
            height: 18.0,
          ),
          LinedTextField(
            label: "Name",
            onChanged: (val) {
              setState(() {
                _shouldEdit = true;
              });
            },
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
            onChanged: (val) {
              setState(() {
                _shouldEdit = true;
              });
            },
            controller: _emailController,
            validator: (value) {
              if (value.toString().isEmpty || value == null) {
                return "Guarantor's email is required";
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
            height: 10.0,
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
            onChanged: (val) {
              setState(() {
                _shouldEdit = true;
              });
            },
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
            onPressed: !_shouldEdit
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

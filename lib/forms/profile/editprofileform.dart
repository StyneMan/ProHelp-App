import 'dart:io';

// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/instance_manager.dart';
import 'package:prohelp_app/components/button/roundedbutton.dart';
import 'package:prohelp_app/components/text_components.dart';

import '../../helper/constants/constants.dart';
import '../../helper/preference/preference_manager.dart';
import '../../helper/state/state_manager.dart';

class ProfileForm extends StatefulWidget {
  final PreferenceManager manager;
  var croppedFile;
  ProfileForm({
    Key? key,
    required this.manager,
    required this.croppedFile,
  }) : super(key: key);

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  String _countryCode = "+234";
  final _user = FirebaseAuth.instance.currentUser;
  final _formKey = GlobalKey<FormState>();
  final _controller = Get.find<StateController>();
  String? _userID;
  String _number = '';
  bool _isEdited = false;
  // var _user;

  Future<void> updateProfile() async {
    _controller.setLoading(true);

    if (_phoneController.text.startsWith('0')) {
      if (mounted) {
        setState(() {
          _number =
              _phoneController.text.substring(1, _phoneController.text.length);
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _number = _phoneController.text;
        });
      }
    }

    try {
      // if (_user != null) {
      //   await _user?.updateDisplayName(_nameController.text);
      //   // user.updatePhoneNumber(phoneCredential)
      //   // user.updatePhotoURL(cropp)
      //   await FirebaseFirestore.instance
      //       .collection("users")
      //       .doc(_user?.uid)
      //       .set({
      //     "name": _nameController.text,
      //     "phone": "$_countryCode$_number",
      //     "address": _addressController.text,
      //     "age": _ageController.text,
      //   }, SetOptions(merge: true));

      //   if (widget.croppedFile != null) {
      //     final storageRef = FirebaseStorage.instance.ref();
      //     final fileRef = storageRef.child("photos").child("${_user?.uid}");
      //     final resp = await fileRef.putFile(File(widget.croppedFile));

      //     final url = await resp.ref.getDownloadURL();
      //     await FirebaseFirestore.instance
      //         .collection("users")
      //         .doc(_user?.uid)
      //         .set({
      //       "image": url,
      //     }, SetOptions(merge: true));
      //     await _user?.updatePhotoURL(url);
      //   }

      //   await FirebaseFirestore.instance
      //       .collection("users")
      //       .doc(_user?.uid)
      //       .get()
      //       .then((value) => _controller.setUserData(value.data()));

      //   _controller.setLoading(false);
      //   Constants.toast("Profile updated successfully");
      //   Navigator.of(context).pop();
      // }
    } catch (e) {
      _controller.setLoading(false);
    }
  }

  @override
  void initState() {
    super.initState();
    if (mounted) {
      setState(() {
        _nameController.text = _user?.displayName ?? "";
        _emailController.text = _user?.email ?? "";
      });
    }
    _phoneController.text =
        _controller.userData.value['phone']?.substring(4) ?? "";
    _addressController.text = _controller.userData.value['address'] ?? "";
    _ageController.text = _controller.userData.value['age'] ?? "";
  }

  @override
  Widget build(BuildContext context) {
    if (widget.croppedFile != null) {
      if (mounted) {
        setState(() {
          _isEdited = true;
        });
      }
    }
    return Form(
      key: _formKey,
      child: ListView(
        children: [
          TextFormField(
            decoration: const InputDecoration(
              filled: true,
              labelText: 'Name',
              hintText: 'Name',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your full name';
              }
              return null;
            },
            onChanged: (val) {
              setState(() {
                _isEdited = true;
              });
            },
            textCapitalization: TextCapitalization.words,
            keyboardType: TextInputType.name,
            controller: _nameController,
          ),
          const SizedBox(height: 8.0),
          TextFormField(
            decoration: const InputDecoration(
              filled: true,
              labelText: 'Email',
              hintText: 'Email',
            ),
            enabled: false,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp('^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]')
                  .hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
            keyboardType: TextInputType.emailAddress,
            controller: _emailController,
          ),
          const SizedBox(height: 8.0),
          TextFormField(
            decoration: InputDecoration(
              hintText: 'Phone Number',
              filled: true,
              prefixIcon: CountryCodePicker(
                alignLeft: false,
                onChanged: (val) {
                  setState(() {
                    _countryCode = val as String;
                  });
                },
                flagWidth: 24,
                initialSelection: 'NG',
                favorite: ['+234', 'NG'],
                showCountryOnly: false,
                showFlag: false,
                showOnlyCountryWhenClosed: false,
              ),
            ),
            maxLength: 11,
            onChanged: (val) {
              setState(() {
                _isEdited = true;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your phone number';
              }
              if (!RegExp('^(?:[+0]234)?[0-9]{10}').hasMatch(value)) {
                return 'Please enter a valid phone number';
              }
              if (value.length < 10) {
                return 'Phone number not valid';
              }
              return null;
            },
            keyboardType: TextInputType.phone,
            controller: _phoneController,
          ),
          const SizedBox(height: 8.0),
          TextFormField(
            decoration: const InputDecoration(
              filled: true,
              labelText: 'Address',
              hintText: 'Address',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your address';
              }
              return null;
            },
            onChanged: (val) {
              setState(() {
                _isEdited = true;
              });
            },
            textCapitalization: TextCapitalization.words,
            keyboardType: TextInputType.streetAddress,
            controller: _addressController,
          ),
          const SizedBox(height: 8.0),
          TextFormField(
            decoration: const InputDecoration(
              filled: true,
              labelText: 'Age',
              hintText: 'Age',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your age';
              }
              return null;
            },
            onChanged: (val) {
              setState(() {
                _isEdited = true;
              });
            },
            keyboardType: TextInputType.number,
            controller: _ageController,
          ),
          const SizedBox(height: 8.0),
          const SizedBox(
            height: 8.0,
          ),
          const SizedBox(height: 16.0),
          RoundedButton(
            bgColor: Constants.primaryColor,
            child: TextPoppins(text: "SAVE CHANGES", fontSize: 16),
            borderColor: Colors.transparent,
            foreColor: Colors.white,
            onPressed: !_isEdited
                ? null
                : () {
                    if (_formKey.currentState!.validate()) {
                      updateProfile();
                    }
                  },
            variant: "Filled",
          ),
          const SizedBox(height: 24.0),
        ],
      ),
    );
  }
}

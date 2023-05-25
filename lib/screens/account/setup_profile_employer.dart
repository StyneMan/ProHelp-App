import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_overlay_pro/loading_overlay_pro.dart';
import 'package:page_transition/page_transition.dart';
import 'package:prohelp_app/components/button/roundedbutton.dart';
import 'package:prohelp_app/components/inputfield/customdropdown.dart';
import 'package:prohelp_app/components/inputfield/datefield.dart';
import 'package:prohelp_app/components/inputfield/textfield.dart';
import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/helper/constants/constants.dart';
import 'package:prohelp_app/helper/preference/preference_manager.dart';
import 'package:prohelp_app/helper/service/api_service.dart';
import 'package:prohelp_app/helper/socket/socket_manager.dart';
import 'package:prohelp_app/helper/state/state_manager.dart';
import 'package:prohelp_app/screens/auth/account_created/successscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SetupProfileEmployer extends StatefulWidget {
  final PreferenceManager manager;
  final bool isSocial;
  final String email;
  final String? name;
  const SetupProfileEmployer({
    Key? key,
    this.isSocial = false,
    required this.manager,
    required this.email,
    this.name,
  }) : super(key: key);

  @override
  State<SetupProfileEmployer> createState() => _SetupProfileEmployerState();
}

class _SetupProfileEmployerState extends State<SetupProfileEmployer> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _dateController = TextEditingController();

  final _controller = Get.find<StateController>();
  final _formKey = GlobalKey<FormState>();

  String _selectedGender = "Male";
  String _encodedDate = "";

  final socket = SocketManager().socket;

  void _onSelected(String val) {
    _selectedGender = val;
  }

  _init() {
    setState(() {
      _emailController.text = widget.email;
      _nameController.text = "${widget.name}";
    });
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void didChangeDependencies() {
    _init();
    super.didChangeDependencies();
  }

  void _onDateSelected(String raw, String val) {
    _dateController.text = val;
    _encodedDate = raw;
  }

  _saveProfile() async {
    _controller.setLoading(true);
    Map _payload = {
      "accountType": "recruiter",
      "bio": {
        "fullname": _nameController.text.toString().toLowerCase(),
        "phone": _phoneController.text,
        "gender": _selectedGender.toString().toLowerCase(),
        "address": _addressController.text.toString().toLowerCase(),
        "dob": _dateController.text,
      },
      "hasProfile": true,
    };

    try {
      final _prefs = await SharedPreferences.getInstance();
      var _token = _prefs.getString("accessToken") ?? "";
      // widget.manager.setIsLoggedIn(true);
      final response = await APIService().updateProfile(
        accessToken: _token,
        body: _payload,
        email: widget.email,
      );

      debugPrint("PROFILE RESPONSE recruiter >> ${response.body}");
      _controller.setLoading(false);

      if (response.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(response.body);
        Constants.toast(map['message']);

        //Nw save user's data to preference
        String userData = jsonEncode(map['data']);
        widget.manager.setUserData(userData);
        _controller.userData.value = map['data'];
        widget.manager.setIsLoggedIn(true);

        _controller.onInit();

        _controller.clearTempProfile();
        socket.emit('identity', map['data']["_id"]);

        Navigator.of(context).pushReplacement(
          PageTransition(
            type: PageTransitionType.size,
            alignment: Alignment.bottomCenter,
            child: AccountSuccess(
              firstname: "${map["data"]["bio"]["fullname"]}".split(" ")[0],
              accountType: "recruiter",
            ),
          ),
        );
      } else {
        Map<String, dynamic> map = jsonDecode(response.body);
        Constants.toast(map['message']);
      }
    } catch (e) {
      debugPrint(e.toString());
      Constants.toast(e.toString());
      _controller.setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => LoadingOverlayPro(
        isLoading: _controller.isLoading.value,
        backgroundColor: Colors.black54,
        progressIndicator: const CircularProgressIndicator.adaptive(),
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: TextInter(text: "Setup Profile".toUpperCase(), fontSize: 16),
            elevation: 0.0,
            backgroundColor: Colors.white,
            automaticallyImplyLeading: false,
            centerTitle: true,
            foregroundColor: Colors.black,
          ),
          body: SafeArea(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  const SizedBox(
                    height: 16.0,
                  ),
                  CustomTextField(
                    hintText: "Full Name",
                    onChanged: (val) {},
                    controller: _nameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your first and last name';
                      }
                      return null;
                    },
                    inputType: TextInputType.text,
                    capitalization: TextCapitalization.words,
                  ),
                  const SizedBox(
                    height: 21.0,
                  ),
                  CustomTextField(
                    hintText: "Email",
                    isEnabled: false,
                    onChanged: (val) {},
                    controller: _emailController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email or phone';
                      }
                      if (!RegExp('^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]')
                          .hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                    inputType: TextInputType.emailAddress,
                  ),
                  const SizedBox(
                    height: 21.0,
                  ),
                  CustomTextField(
                    hintText: "Phone",
                    onChanged: (val) {},
                    controller: _phoneController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      if (value.toString().length < 11) {
                        return 'Enter a valid phone number';
                      }
                      return null;
                    },
                    inputType: TextInputType.number,
                  ),
                  const SizedBox(
                    height: 16.0,
                  ),
                  CustomTextField(
                    hintText: "Address",
                    onChanged: (val) {},
                    controller: _addressController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your address';
                      }
                      return null;
                    },
                    inputType: TextInputType.text,
                  ),
                  const SizedBox(
                    height: 21.0,
                  ),
                  CustomDropdown(
                    onSelected: _onSelected,
                    hint: "Select gender",
                    items: const ['Male', 'Female'],
                  ),
                  const SizedBox(
                    height: 21.0,
                  ),
                  CustomDateField(
                    hintText: "Date of birth",
                    onDateSelected: _onDateSelected,
                    controller: _dateController,
                  ),
                  const SizedBox(
                    height: 21.0,
                  ),
                  RoundedButton(
                    bgColor: Constants.primaryColor,
                    child: const TextInter(text: "SUBMIT", fontSize: 16),
                    borderColor: Colors.transparent,
                    foreColor: Colors.white,
                    onPressed: () {
                      _saveProfile();
                    },
                    variant: "Filled",
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

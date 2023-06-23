import 'dart:convert';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_overlay_pro/loading_overlay_pro.dart';
import 'package:page_transition/page_transition.dart';
import 'package:prohelp_app/components/button/roundedbutton.dart';
import 'package:prohelp_app/components/dialog/info_dialog.dart';
import 'package:prohelp_app/components/inputfield/city_dropdown.dart';
import 'package:prohelp_app/components/inputfield/customdropdown.dart';
import 'package:prohelp_app/components/inputfield/dob_datefield.dart';
import 'package:prohelp_app/components/inputfield/state_dropdown.dart';
import 'package:prohelp_app/components/inputfield/textfield.dart';
import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/data/state/statesAndCities.dart';
import 'package:prohelp_app/helper/constants/constants.dart';
import 'package:prohelp_app/helper/preference/preference_manager.dart';
import 'package:prohelp_app/helper/service/api_service.dart';
import 'package:prohelp_app/helper/socket/socket_manager.dart';
import 'package:prohelp_app/helper/state/state_manager.dart';
import 'package:prohelp_app/screens/auth/account_created/successscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'components/image_uploader.dart';

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
  final _fnameController = TextEditingController();
  final _mnameController = TextEditingController();
  final _lnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _dateController = TextEditingController();

  final _controller = Get.find<StateController>();
  final _formKey = GlobalKey<FormState>();

  String _selectedGender = "Male";
  String _selectedState = "Abia";
  String _selectedCity = "Select City";
  String _selectedCountry = "Nigeria";
  String _encodedDate = "";

  List<String> _cities = [];

  bool _isImagePicked = false;
  var _croppedFile;

  final socket = SocketManager().socket;

  void _onSelected(String val) {
    _selectedGender = val;
  }

  void _onStateSelected(String val) {
    setState(() {
      _cities = [];
    });
    _onCitySelected("Select city");
    _selectedState = val;
    var selector = stateCities.where((element) => element['state'] == val);
    setState(() {
      _cities = selector.first['cities'] as List<String>;
    });
  }

  void _onCitySelected(String val) {
    setState(() {
      _selectedCity = val;
    });
  }

  void _onCountrySelected(String val) {
    setState(() {
      _selectedCountry = val;
    });
  }

  _init() {
    setState(() {
      _emailController.text = widget.email;
      // _fnameController.text =
      //     "${widget.name?.toLowerCase() == 'null' ? "" : widget.name}";
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

  _uploadPhoto() async {
    _controller.setLoading(true);
    try {
      final storageRef = FirebaseStorage.instance.ref();
      final fileRef =
          storageRef.child("photos").child(_emailController.text.toLowerCase());
      final _resp = await fileRef.putFile(File(_controller.croppedPic.value));
      final url = await _resp.ref.getDownloadURL();

      await _saveProfile(url);

      _controller.croppedPic.value = "";
    } catch (e) {
      debugPrint(e.toString());
      _controller.setLoading(false);
    }
  }

  _saveProfile(url) async {
    _controller.setLoading(true);
    Map _payload = {
      "accountType": "recruiter",
      "bio": {
        "firstname": _fnameController.text.toString().toLowerCase(),
        "middlename": _mnameController.text.toString().toLowerCase(),
        "lastname": _lnameController.text.toString().toLowerCase(),
        "phone": _phoneController.text,
        "gender": _selectedGender.toString().toLowerCase(),
        "dob": _dateController.text,
        "image": url
      },
      "address": {
        "state": _selectedState.toLowerCase(),
        "country": _selectedCountry.toLowerCase(),
        "city": _selectedCity.toLowerCase(),
        "street": _addressController.text.toLowerCase()
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
        socket.emit('identity', map['data']["id"]);

        Navigator.of(context).pushReplacement(
          PageTransition(
            type: PageTransitionType.size,
            alignment: Alignment.bottomCenter,
            child: AccountSuccess(
              firstname: "${map["data"]["bio"]["firstname"]}",
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
                    hintText: "First Name",
                    onChanged: (val) {},
                    controller: _fnameController,
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
                    height: 16.0,
                  ),
                  CustomTextField(
                    hintText: "Middle Name",
                    onChanged: (val) {},
                    controller: _mnameController,
                    validator: (value) {
                      // if (value == null || value.isEmpty) {
                      //   return 'Please enter your first and last name';
                      // }
                      return null;
                    },
                    inputType: TextInputType.text,
                    capitalization: TextCapitalization.words,
                  ),
                  const SizedBox(
                    height: 16.0,
                  ),
                  CustomTextField(
                    hintText: "Last Name",
                    onChanged: (val) {},
                    controller: _lnameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your last name';
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
                    height: 16.0,
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
                  CustomDropdown(
                    onSelected: _onSelected,
                    hint: "Gender",
                    items: const ['Male', 'Female'],
                  ),
                  const SizedBox(
                    height: 16.0,
                  ),
                  CustomDropdown(
                    onSelected: _onCountrySelected,
                    hint: "Country",
                    items: const ['Nigeria'],
                  ),
                  const SizedBox(
                    height: 16.0,
                  ),
                  StateCustomDropdown(
                    onSelected: _onStateSelected,
                    hint: "Select state",
                    items: stateCities,
                  ),
                  const SizedBox(
                    height: 16.0,
                  ),
                  CityCustomDropdown(
                    onSelected: _onCitySelected,
                    hint: _selectedCity,
                    items: _cities,
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
                    height: 16.0,
                  ),
                  CustomDoBDateField(
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
                      // _saveProfile();
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) {
                          return SizedBox(
                            height: 386,
                            width: MediaQuery.of(context).size.width * 0.98,
                            child: InfoDialog(
                              body: Wrap(
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        decoration: const BoxDecoration(
                                          color: Constants.primaryColor,
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(
                                              Constants.padding,
                                            ),
                                            topRight: Radius.circular(
                                              Constants.padding,
                                            ),
                                          ),
                                        ),
                                        padding: const EdgeInsets.all(16.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            const TextInter(
                                              text: "Add Profile Picture",
                                              fontSize: 16,
                                              color: Colors.white,
                                            ),
                                            InkWell(
                                              onTap: () =>
                                                  Navigator.pop(context),
                                              child: const Icon(
                                                Icons.cancel_outlined,
                                                color: Colors.white,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 8.0),
                                      Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          children: [
                                            const ImageUploader(),
                                            const SizedBox(
                                              height: 24.0,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Expanded(
                                                  child: RoundedButton(
                                                    bgColor: Colors.transparent,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: const [
                                                        TextInter(
                                                          text: "Skip",
                                                          fontSize: 15,
                                                          color: Constants
                                                              .primaryColor,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ],
                                                    ),
                                                    borderColor:
                                                        Constants.primaryColor,
                                                    foreColor:
                                                        Constants.primaryColor,
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                      Future.delayed(
                                                        const Duration(
                                                            milliseconds: 500),
                                                        () => _saveProfile(
                                                          "",
                                                        ),
                                                      );
                                                    },
                                                    variant: "Outlined",
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 16.0,
                                                ),
                                                Expanded(
                                                  child: RoundedButton(
                                                    bgColor:
                                                        Constants.primaryColor,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: const [
                                                        TextInter(
                                                          text: "Continue",
                                                          fontSize: 15,
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ],
                                                    ),
                                                    borderColor:
                                                        Colors.transparent,
                                                    foreColor: Colors.white,
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                      if (_controller.croppedPic
                                                          .value.isNotEmpty) {
                                                        _uploadPhoto();
                                                      } else {
                                                        Constants.toast(
                                                            "You must select a picture to continue");
                                                      }
                                                    },
                                                    variant: "Filled",
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
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

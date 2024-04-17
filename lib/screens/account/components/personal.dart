import 'dart:convert';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:prohelp_app/components/button/roundedbutton.dart';
import 'package:prohelp_app/components/dialog/custom_dialog.dart';
import 'package:prohelp_app/components/inputfield/lineddatefield.dart';
import 'package:prohelp_app/components/inputfield/lineddropdown2.dart';
import 'package:prohelp_app/components/inputfield/llinedtextfield.dart';
import 'package:prohelp_app/components/inputfield/state_lineddropdown.dart';
import 'package:prohelp_app/components/picker/img_picker.dart';
import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/data/state/statesAndCities.dart';
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
  final _fnameController = TextEditingController();
  final _mnameController = TextEditingController();
  final _lnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();
  final _addressController = TextEditingController();
  final _zipController = TextEditingController();
  final _ninController = TextEditingController();

  bool _isImagePicked = false;
  var _croppedFile;

  List<String> _cities = [];

  String _selectedGender = "";
  String _selectedCity = "";
  String _selectedState = "";
  String _selectedCountry = "Nigeria";
  String _selectedProfession = "Select profession";

  String? _genderLabel;
  bool _shouldEdit = false;

  // final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _controller = Get.find<StateController>();

  _onSelected(val) {
    setState(() {
      _selectedGender = val;
      _shouldEdit = true;
    });
  }

  _onCitySelected(val) {
    setState(() {
      _selectedCity = val;
      _shouldEdit = true;
    });
  }

  _onStateSelected(val) {
    setState(() {
      _shouldEdit = true;
    });

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

  _onCountrySelected(val) {
    setState(() {
      _selectedCountry = val;
      _shouldEdit = true;
    });
  }

  _onProfessionSelected(val) {
    setState(() {
      _selectedProfession = val;
      _shouldEdit = true;
    });
  }

  _onDateSelected(val) {
    setState(() {
      _ageController.text = val;
      _shouldEdit = true;
    });
  }

  _onImageSelected(var file) {
    setState(() {
      _isImagePicked = true;
      _croppedFile = file;
    });
    debugPrint("VALUIE::: :: $file");
  }

  @override
  void initState() {
    super.initState();

    setState(() {
      _fnameController.text = _controller.userData.value['bio']['firstname']
              .toString()
              .capitalize ??
          widget.manager.getUser()['bio']['firstname'].toString().capitalize ??
          "Not set";
      _mnameController.text = _controller.userData.value['bio']['middlename']
              .toString()
              .capitalize ??
          widget.manager.getUser()['bio']['middlename'].toString().capitalize ??
          "Not set";
      _lnameController.text = _controller.userData.value['bio']['lastname']
              .toString()
              .capitalize ??
          widget.manager.getUser()['bio']['lastname'].toString().capitalize ??
          "Not set";
      _phoneController.text = _controller.userData.value['bio']['phone'] ??
          widget.manager.getUser()['bio']['phone'] ??
          "Not set";
      _addressController.text = _controller.userData.value['address']['street']
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
      _selectedCity = _controller.userData.value['address']['city']
              .toString()
              .capitalize ??
          widget.manager.getUser()['address']['city'].toString().capitalize ??
          "Select city";
      _selectedState = _controller.userData.value['address']['state']
              .toString()
              .capitalize ??
          widget.manager.getUser()['address']['state'].toString().capitalize ??
          "Select state";

      _selectedProfession =
          _controller.userData.value['profession'].toString().capitalize ??
              widget.manager.getUser()['profession'].toString().capitalize ??
              "Select profession";
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
          "firstname": _fnameController.text.toLowerCase(),
          "middlename": _mnameController.text.toLowerCase(),
          "lastname": _lnameController.text.toLowerCase(),
          "phone": _phoneController.text,
          "dob": _ageController.text,
          "nin": _ninController.text,
        },
        "address": {
          "street": _addressController.text.toLowerCase(),
          "state": _selectedState.toLowerCase(),
          "country": _selectedCountry.toLowerCase(),
          "city": _selectedCity.toLowerCase(),
        },
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
            _fnameController.text = map['data']['bio']['firstname'];
            _mnameController.text = map['data']['bio']['middlename'];
            _lnameController.text = map['data']['bio']['lastname'];
            _phoneController.text = map['data']['bio']['phone'];
            _addressController.text = map['data']['address']['street'];
            _ageController.text = map['data']['bio']['dob'];
            _ninController.text = map['data']['bio']['nin'];
            _selectedCity = "${map['data']['address']['city']}".capitalize!;
            _selectedState = "${map['data']['address']['state']}".capitalize!;
            _selectedCountry =
                "${map['data']['address']['country']}".capitalize!;
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
            "firstname": _fnameController.text.toLowerCase(),
            "middlename": _mnameController.text.toLowerCase(),
            "lastname": _lnameController.text.toLowerCase(),
            "phone": _phoneController.text,
            "dob": _ageController.text,
            "nin": _ninController.text,
            "image": url,
          },
          "address": {
            "street": _addressController.text.toLowerCase(),
            "state": _selectedState.toLowerCase(),
            "country": _selectedCountry.toLowerCase(),
            "city": _selectedCity.toLowerCase(),
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
            _fnameController.text = map['data']['bio']['firstname'];
            _mnameController.text = map['data']['bio']['middletname'];
            _lnameController.text = map['data']['bio']['lastname'];
            _phoneController.text = map['data']['bio']['phone'];
            _addressController.text = map['data']['address']['street'];
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
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipOval(
                      child: _isImagePicked
                          ? Container(
                              height: 120,
                              width: 120,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(60),
                              ),
                              child: Image.file(
                                File(_croppedFile),
                                errorBuilder: (context, error, stackTrace) =>
                                    ClipOval(
                                  child: SvgPicture.asset(
                                    "assets/images/personal.svg",
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                fit: BoxFit.cover,
                              ),
                            )
                          : Container(
                              height: 128,
                              width: 128,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(64),
                              ),
                              child: Image.network(
                                "${widget.manager.getUser()['bio']['image']}",
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
                      bottom: 12,
                      right: -3,
                      child: CircleAvatar(
                        backgroundColor: Constants.primaryColor,
                        child: IconButton(
                          onPressed: () {
                            showBarModalBottomSheet(
                              expand: false,
                              context: context,
                              topControl: ClipOval(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(
                                        16,
                                      ),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.close,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              backgroundColor: Colors.white,
                              builder: (context) => SizedBox(
                                height: 175,
                                child: ImgPicker(
                                  onCropped: _onImageSelected,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.add_a_photo_outlined,
                            color: Constants.secondaryColor,
                            size: 24,
                          ),
                        ),
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
                    text: "Fill out the form below to change your password.",
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
            label: "First Name",
            onChanged: (val) {
              setState(() {
                _shouldEdit = true;
              });
            },
            controller: _fnameController,
            validator: (value) {
              if (value.toString().isEmpty || value == null) {
                return "First name is required";
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
            label: "Middle Name",
            onChanged: (val) {
              setState(() {
                _shouldEdit = true;
              });
            },
            controller: _mnameController,
            validator: (value) {
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
            label: "Last Name",
            onChanged: (val) {
              setState(() {
                _shouldEdit = true;
              });
            },
            controller: _lnameController,
            validator: (value) {
              if (value.toString().isEmpty || value == null) {
                return "Last name is required";
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
            onDateSelected: _onDateSelected,
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
            onSelected: _onSelected,
            items: const ["Male", "Female"],
          ),
          const Divider(
            color: Constants.accentColor,
          ),
          const SizedBox(
            height: 6.0,
          ),
          LinedDropdown2(
            isEnabled: false,
            label: _selectedProfession,
            title: "Profession",
            onSelected: _onProfessionSelected,
            items: const ["Programming", "Catering", "Driving", "Baking"],
          ),
          const Divider(
            color: Constants.accentColor,
          ),
          const SizedBox(
            height: 6.0,
          ),
          LinedTextField(
            label: "Street",
            onChanged: (val) {
              setState(() {
                _shouldEdit = true;
              });
            },
            controller: _addressController,
            validator: (value) {
              if (value.toString().isEmpty || value == null) {
                return "Street address is required";
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
          LinedDropdownState(
              label: _selectedState,
              title: "State",
              onSelected: _onStateSelected,
              items: stateCities),
          const Divider(
            color: Constants.accentColor,
          ),
          const SizedBox(
            height: 6.0,
          ),
          LinedDropdown2(
            label: _selectedCity,
            title: "City",
            onSelected: _onCitySelected,
            items: _cities,
          ),
          const Divider(
            color: Constants.accentColor,
          ),
          const SizedBox(
            height: 6.0,
          ),
          LinedDropdown2(
            label: _selectedCountry,
            title: "Country",
            onSelected: _onCountrySelected,
            items: const ["Nigeria"],
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
              // if (value.toString().isEmpty || value == null) {
              //   return "ID number is required";
              // }
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

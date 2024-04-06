import 'dart:convert';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get/instance_manager.dart';
import 'package:loading_overlay_pro/loading_overlay_pro.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:prohelp_app/components/button/roundedbutton.dart';
import 'package:prohelp_app/components/drawer/custom_drawer.dart';
import 'package:prohelp_app/components/inputfield/customdropdown.dart';
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

class VerifyDocs extends StatefulWidget {
  final PreferenceManager manager;
  VerifyDocs({
    Key? key,
    required this.manager,
  }) : super(key: key);

  @override
  State<VerifyDocs> createState() => _VerifyDocsState();
}

class _VerifyDocsState extends State<VerifyDocs> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _controller = Get.find<StateController>();
  bool _isFrontSelected = false, _isFrontErr = false;
  bool _isBackSelected = false, _isBackErr = false;
  String _idType = "";
  bool _shouldEdit = false;

  final _companyController = TextEditingController();
  final _roleController = TextEditingController();
  final _addressController = TextEditingController();
  final _countryController = TextEditingController();
  final _phoneController = TextEditingController();

  String _selectedCity = "";
  String _selectedState = "";
  String _selectedCountry = "Nigeria";

  List<String> _cities = [];

  var _croppedFile1;
  var _croppedFile2;

  String _frontUrl = "", _backUrl = "";

  _onFrontSelected(var file) {
    setState(() {
      _isFrontSelected = true;
      _croppedFile1 = file;
      _isFrontErr = false;
    });
    debugPrint("VALUIE::: :: $file");
  }

  _onBackSelected(var file) {
    setState(() {
      _isBackSelected = true;
      _croppedFile2 = file;
      _isBackErr = false;
    });
    debugPrint("VALUIE::: :: $file");
  }

  _onTypeSelected(var value) {
    setState(() {
      _idType = value;
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

  _uploadFront() async {
    _controller.setLoading(true);
    try {
      final storageRef = FirebaseStorage.instance.ref();
      final fileRef = storageRef
          .child("photos")
          .child("${widget.manager.getUser()['email']}_ID_Front");
      final _resp = await fileRef.putFile(File(_croppedFile1));
      final url = await _resp.ref.getDownloadURL();

      // await _saveProfile(context, url);

      setState(() {
        _frontUrl = url;
      });
      // _controller.croppedPic.value = "";
    } catch (e) {
      debugPrint(e.toString());
      _controller.setLoading(false);
    }
  }

  _uploadBack() async {
    _controller.setLoading(true);
    try {
      final storageRef = FirebaseStorage.instance.ref();
      final fileRef = storageRef
          .child("photos")
          .child("${widget.manager.getUser()['email']}_ID_Back");
      final _resp = await fileRef.putFile(File(_croppedFile2));
      final url = await _resp.ref.getDownloadURL();

      setState(() {
        _backUrl = url;
      });
      _controller.croppedPic.value = "";
    } catch (e) {
      debugPrint(e.toString());
      _controller.setLoading(false);
    }
  }

  _saveChanges() async {
    try {
      await _uploadFront();
      await _uploadBack();
      Map _payload = {
        "bio": {
          ...widget.manager.getUser()['bio'],
          "idcard": {
            "idType": _idType.toLowerCase().replaceAll(" ", "_"),
            "frontview": _frontUrl,
            "backview": _backUrl
          }
        }
      };

      final response = await APIService().updateProfile(
        accessToken: widget.manager.getAccessToken(),
        body: _payload,
        email: widget.manager.getUser()['email'],
      );

      debugPrint("MEANS OF ID RESPONSE >> ${response.body}");
      _controller.setLoading(false);
      if (response.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(response.body);
        Constants.toast("Means of identification added successfully");

        //Nw save user's data to preference
        String userData = jsonEncode(map['data']);
        widget.manager.setUserData(userData);
        widget.manager.setIsLoggedIn(true);
        _controller.userData.value = map['data'];

        //Fetch other data like freelancers, recruiters etc.
        _controller.onInit();
      } else {
        Map<String, dynamic> map = jsonDecode(response.body);
        Constants.toast(map['message']);
      }
    } catch (e) {
      _controller.setLoading(false);
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => LoadingOverlayPro(
        isLoading: _controller.isLoading.value,
        backgroundColor: Colors.black45,
        progressIndicator: const CircularProgressIndicator.adaptive(),
        child: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            elevation: 0.0,
            foregroundColor: Constants.secondaryColor,
            backgroundColor: Constants.primaryColor,
            automaticallyImplyLeading: false,
            leading: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 16.0,
                ),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Icon(
                    CupertinoIcons.arrow_left_circle,
                  ),
                ),
                const SizedBox(
                  width: 4.0,
                ),
              ],
            ),
            title: TextPoppins(
              text: "ID VERIFICATION",
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Constants.secondaryColor,
            ),
            centerTitle: true,
            actions: [
              IconButton(
                onPressed: () {
                  if (!_scaffoldKey.currentState!.isEndDrawerOpen) {
                    _scaffoldKey.currentState!.openEndDrawer();
                  }
                },
                icon: SvgPicture.asset(
                  'assets/images/menu_icon.svg',
                  color: Constants.secondaryColor,
                ),
              ),
            ],
          ),
          endDrawer: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: CustomDrawer(
              manager: widget.manager,
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextPoppins(
                      text: "Means of Identification",
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: TextPoppins(
                        text:
                            "Upload NIN/Voters Card/Driver's Licence/International Passport. Please attach both front and back view of ID.",
                        fontSize: 14,
                        align: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 21.0,
              ),
              CustomDropdown(
                items: const [
                  "National ID",
                  "Voters Card",
                  "Drivers Licence",
                  "International Passport"
                ],
                hint: "Select ID Type",
                onSelected: _onTypeSelected,
              ),
              const SizedBox(
                height: 8.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextPoppins(
                          text: "Front view",
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        SizedBox(
                          height: 175,
                          child: TextButton(
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
                                    onCropped: _onFrontSelected,
                                  ),
                                ),
                              );
                            },
                            child: _isFrontSelected
                                ? Image.file(
                                    File(_croppedFile1),
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Image.asset(
                                      "assets/images/placeholder.png",
                                      fit: BoxFit.cover,
                                    ),
                                    fit: BoxFit.cover,
                                  )
                                : Image.network(
                                    widget.manager.getUser()['bio']['idcard'] ==
                                            null
                                        ? ""
                                        : "${widget.manager.getUser()['bio']['idcard']['frontview']}",
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Image.asset(
                                      "assets/images/placeholder.png",
                                      fit: BoxFit.cover,
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                side: BorderSide(
                                  color: _isFrontErr ? Colors.red : Colors.grey,
                                  width: 1.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        TextPoppins(
                          text: "Back view",
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        SizedBox(
                          height: 175,
                          child: TextButton(
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
                                    onCropped: _onBackSelected,
                                  ),
                                ),
                              );
                            },
                            child: _isBackSelected
                                ? Image.file(
                                    File(_croppedFile2),
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Image.asset(
                                      "assets/images/placeholder.png",
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                    fit: BoxFit.cover,
                                  )
                                : Image.network(
                                    widget.manager.getUser()['bio']['idcard'] ==
                                            null
                                        ? ""
                                        : "${widget.manager.getUser()['bio']['idcard']['backview']}",
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Image.asset(
                                      "assets/images/placeholder.png",
                                      fit: BoxFit.cover,
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                side: BorderSide(
                                  color: _isBackErr ? Colors.red : Colors.grey,
                                  width: 1.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 21.0,
              ),
              RoundedButton(
                bgColor: Constants.primaryColor,
                child: const TextInter(
                  text: "Save Changes",
                  fontSize: 16,
                ),
                borderColor: Colors.transparent,
                foreColor: Colors.white,
                onPressed: () {
                  if (_idType.isEmpty) {
                    Constants.toast("Identity type not selected!");
                    return;
                  } else if (_croppedFile1 == null) {
                    Constants.toast("From view not selected!");
                    setState(() {
                      _isFrontErr = true;
                    });
                    return;
                  } else if (_croppedFile2 == null) {
                    Constants.toast("Rear view not selected!");
                    setState(() {
                      _isBackErr = true;
                    });
                    return;
                  } else {
                    setState(() {
                      _isFrontErr = false;
                      _isBackErr = false;
                    });

                    _saveChanges();
                  }
                },
                variant: "Filled",
              ),
              const SizedBox(height: 12.0),
              const Divider(),
              const SizedBox(
                height: 6.0,
              ),
              TextPoppins(
                text: "Previous Work Information",
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              const SizedBox(
                height: 4.0,
              ),
              LinedTextField(
                label: "Company Name",
                onChanged: (val) {
                  setState(() {
                    _shouldEdit = true;
                  });
                },
                controller: _companyController,
                validator: (value) {
                  if (value.toString().isEmpty || value == null) {
                    return "Company name is required";
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
                height: 6.0,
              ),
              LinedTextField(
                label: "Role",
                onChanged: (val) {
                  setState(() {
                    _shouldEdit = true;
                  });
                },
                controller: _roleController,
                validator: (value) {
                  if (value.toString().isEmpty || value == null) {
                    return "Role is required";
                  }
                  return null;
                },
                inputType: TextInputType.name,
                capitalization: TextCapitalization.words,
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
                label: "Street Address",
                onChanged: (val) {
                  setState(() {
                    _shouldEdit = true;
                  });
                },
                controller: _addressController,
                validator: (value) {
                  // if (value.toString().isEmpty || value == null) {
                  //   return "ID number is required";
                  // }
                  return null;
                },
                inputType: TextInputType.number,
                capitalization: TextCapitalization.none,
              ),
              const SizedBox(height: 10.0),
              RoundedButton(
                bgColor: Constants.primaryColor,
                child: const TextInter(
                  text: "Submit for Review",
                  fontSize: 16,
                ),
                borderColor: Colors.transparent,
                foreColor: Colors.white,
                onPressed: () {},
                variant: 'outlined',
              )
            ],
          ),
        ),
      ),
    );
  }
}

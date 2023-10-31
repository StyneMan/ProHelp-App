import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prohelp_app/components/inputfield/city_dropdown.dart';
import 'package:prohelp_app/components/inputfield/customdropdown.dart';
import 'package:prohelp_app/components/inputfield/dob_datefield.dart';
import 'package:prohelp_app/components/inputfield/profession_dropdown.dart';
import 'package:prohelp_app/components/inputfield/state_dropdown.dart';
import 'package:prohelp_app/components/inputfield/textfield.dart';
import 'package:prohelp_app/data/state/statesAndCities.dart';
import 'package:prohelp_app/helper/state/state_manager.dart';

typedef void InitCallback(Map data);

class SetupStep1 extends StatefulWidget {
  final bool isSocial;
  final String email;
  final String? name;
  final InitCallback onStep1Completed;
  const SetupStep1({
    Key? key,
    this.isSocial = false,
    required this.email,
    this.name,
    required this.onStep1Completed,
  }) : super(key: key);

  @override
  State<SetupStep1> createState() => _SetupStep1State();
}

class _SetupStep1State extends State<SetupStep1> {
  final _fnameController = TextEditingController();
  final _mnameController = TextEditingController();
  final _lnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  // final _maritalStatusController = TextEditingController();
  final _addressController = TextEditingController();
  final _dateController = TextEditingController();
  final _experienceController = TextEditingController();
  // final _professionController = TextEditingController();

  final _controller = Get.find<StateController>();

  String _selectedGender = "Male";
  String _selectedMaritalStatus = "Single";
  String _encodedDate = "";

  String _selectedState = "Abia";
  String _selectedCity = "Aba";
  String _selectedCountry = "Nigeria";
  String _selectedProfession = "";

  List<String> _cities = [];

  _init() {
    setState(() {
      _emailController.text = widget.email;
      // _nameController.text =
      //     "${widget.name?.toLowerCase() == 'null' ? "" : widget.name}";
    });
  }

  void _onSelected(String val) {
    _selectedGender = val;
    widget.onStep1Completed(
      {
        "firstname": _fnameController.text,
        "lastname": _lnameController.text,
        "middlename": _mnameController.text,
        "email": _emailController.text,
        "phone": _phoneController.text.startsWith("0")
            ? "+234${_phoneController.text.substring(1)}"
            : "+234${_phoneController.text}",
        "address": _addressController.text,
        "gender": val,
        "dob": _dateController.text,
        "maritalStatus": _selectedMaritalStatus,
        "state": _selectedState,
        "country": _selectedCountry,
        "experienceYears": _experienceController.text,
        "profession": _selectedProfession,
        "city": _selectedCity.contains("Select") ? "" : _selectedCity,
      },
    );
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

    widget.onStep1Completed(
      {
        "firstname": _fnameController.text,
        "lastname": _lnameController.text,
        "middlename": _mnameController.text,
        "email": _emailController.text,
        "phone": _phoneController.text.startsWith("0")
            ? "+234${_phoneController.text.substring(1)}"
            : "+234${_phoneController.text}",
        "address": _addressController.text,
        "gender": _selectedGender,
        "dob": _dateController.text,
        "state": val,
        "country": _selectedCountry,
        "maritalStatus": _selectedMaritalStatus,
        "experienceYears": _experienceController.text,
        "profession": _selectedProfession,
        "city": _selectedCity.contains("Select") ? "" : _selectedCity,
      },
    );
  }

  void _onCitySelected(String val) {
    setState(() {
      _selectedCity = val;
    });

    widget.onStep1Completed(
      {
        "firstname": _fnameController.text,
        "lastname": _lnameController.text,
        "middlename": _mnameController.text,
        "email": _emailController.text,
        "phone": _phoneController.text.startsWith("0")
            ? "+234${_phoneController.text.substring(1)}"
            : "+234${_phoneController.text}",
        "address": _addressController.text,
        "gender": _selectedGender,
        "dob": _dateController.text,
        "state": _selectedState,
        "country": _selectedCountry,
        "profession": _selectedProfession,
        "city": val,
        "maritalStatus": _selectedMaritalStatus,
        "experienceYears": _experienceController.text,
      },
    );
  }

  void _onMaritalStatusSelected(String val) {
    setState(() {
      _selectedMaritalStatus = val;
    });

    widget.onStep1Completed(
      {
        "firstname": _fnameController.text,
        "lastname": _lnameController.text,
        "middlename": _mnameController.text,
        "email": _emailController.text,
        "phone": _phoneController.text.startsWith("0")
            ? "+234${_phoneController.text.substring(1)}"
            : "+234${_phoneController.text}",
        "address": _addressController.text,
        "gender": _selectedGender,
        "city": _selectedCity,
        "dob": _dateController.text,
        "state": _selectedState,
        "country": _selectedCountry,
        "profession": _selectedProfession,
        "experienceYears": _experienceController.text,
        "maritalStatus": val,
      },
    );
  }

  void _onCountrySelected(String val) {
    setState(() {
      _selectedCountry = val;
    });

    widget.onStep1Completed(
      {
        "firstname": _fnameController.text,
        "lastname": _lnameController.text,
        "middlename": _mnameController.text,
        "email": _emailController.text,
        "phone": _phoneController.text.startsWith("0")
            ? "+234${_phoneController.text.substring(1)}"
            : "+234${_phoneController.text}",
        "address": _addressController.text,
        "gender": _selectedGender,
        "dob": _dateController.text,
        "state": _selectedState,
        "country": val,
        "maritalStatus": _selectedMaritalStatus,
        "profession": _selectedProfession,
        "experienceYears": _experienceController.text,
        "city": _selectedCity.contains("Select") ? "" : _selectedCity,
      },
    );
  }

  void _onProfessionSelected(String val) {
    setState(() {
      _selectedProfession = val;
    });

    widget.onStep1Completed(
      {
        "firstname": _fnameController.text,
        "lastname": _lnameController.text,
        "middlename": _mnameController.text,
        "email": _emailController.text,
        "phone": _phoneController.text.startsWith("0")
            ? "+234${_phoneController.text.substring(1)}"
            : "+234${_phoneController.text}",
        "address": _addressController.text,
        "gender": _selectedGender,
        "dob": _dateController.text,
        "state": _selectedState,
        "country": _selectedCountry,
        "profession": val,
        "maritalStatus": _selectedMaritalStatus,
        "experienceYears": _experienceController.text,
        "city": _selectedCity.contains("Select") ? "" : _selectedCity,
      },
    );
  }

  @override
  void initState() {
    _init();
    _fnameController.text = _controller.firstname.value;
    _mnameController.text = _controller.middlename.value;
    _lnameController.text = _controller.lastname.value;
    _addressController.text = _controller.address.value;
    _dateController.text = _controller.dob.value;
    _experienceController.text = _controller.experience.value;
    _selectedGender = _controller.gender.value;
    _phoneController.text = _controller.phone.value;
    _selectedCity = _controller.city.value;
    _selectedCountry = _controller.country.value;
    _selectedProfession = _controller.profession.value;
    _selectedState = _controller.state.value;
    _selectedMaritalStatus = _controller.maritalStatus.value;

    super.initState();
  }

  @override
  void didChangeDependencies() {
    _init();
    _fnameController.text = _controller.firstname.value;
    _mnameController.text = _controller.middlename.value;
    _lnameController.text = _controller.lastname.value;
    // _emailController.text = _controller.email.value;
    _addressController.text = _controller.address.value;
    _experienceController.text = _controller.experience.value;
    _phoneController.text = _controller.phone.value;
    _dateController.text = _controller.dob.value;
    _selectedGender = _controller.gender.value;
    _selectedCity = _controller.city.value;
    _selectedCountry = _controller.country.value;
    _selectedProfession = _controller.profession.value;
    _selectedState = _controller.state.value;
    _selectedMaritalStatus = _controller.maritalStatus.value;
    super.didChangeDependencies();
  }

  void _onDateSelected(String raw, String val) {
    _dateController.text = val;
    _encodedDate = raw;
    widget.onStep1Completed(
      {
        "firstname": _fnameController.text,
        "lastname": _lnameController.text,
        "middlename": _mnameController.text,
        "email": _emailController.text,
        "phone": _phoneController.text.startsWith("0")
            ? "+234${_phoneController.text.substring(1)}"
            : "+234${_phoneController.text}",
        "address": _addressController.text,
        "gender": _selectedGender,
        "dob": _encodedDate,
        "state": _selectedState,
        "country": _selectedCountry,
        "profession": _selectedProfession,
        "maritalStatus": _selectedMaritalStatus,
        "experienceYears": _experienceController.text,
        "city": _selectedCity.contains("Select") ? "" : _selectedCity,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // _init();
    debugPrint("PROFESSIONS CHECK :: ${_controller.allProfessions.value}");
    return Column(
      children: [
        const SizedBox(
          height: 16.0,
        ),
        CustomTextField(
          hintText: "First name",
          onChanged: (val) {
            _controller.firstname.value = val;
            widget.onStep1Completed(
              {
                "firstname": val,
                "lastname": _lnameController.text,
                "middlename": _mnameController.text,
                "email": _emailController.text,
                "phone": _phoneController.text.startsWith("0")
                    ? "+234${_phoneController.text.substring(1)}"
                    : "+234${_phoneController.text}",
                "address": _addressController.text,
                "gender": _selectedGender,
                "dob": _dateController.text,
                "state": _selectedState,
                "country": _selectedCountry,
                "profession": _selectedProfession,
                "maritalStatus": _selectedMaritalStatus,
                "experienceYears": _experienceController.text,
                "city": _selectedCity.contains("Select") ? "" : _selectedCity,
              },
            );
          },
          controller: _fnameController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your first name';
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
          hintText: "Middle name",
          onChanged: (val) {
            _controller.middlename.value = val;
            widget.onStep1Completed(
              {
                "firstname": _fnameController.text,
                "lastname": _lnameController.text,
                "middlename": val,
                "email": _emailController.text,
                "phone": _phoneController.text.startsWith("0")
                    ? "+234${_phoneController.text.substring(1)}"
                    : "+234${_phoneController.text}",
                "address": _addressController.text,
                "gender": _selectedGender,
                "dob": _dateController.text,
                "state": _selectedState,
                "country": _selectedCountry,
                "profession": _selectedProfession,
                "maritalStatus": _selectedMaritalStatus,
                "experienceYears": _experienceController.text,
                "city": _selectedCity.contains("Select") ? "" : _selectedCity,
              },
            );
          },
          controller: _mnameController,
          validator: (value) {
            // if (value == null || value.isEmpty) {
            //   return 'Please enter your middle name';
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
          hintText: "Last name",
          onChanged: (val) {
            _controller.lastname.value = val;
            widget.onStep1Completed(
              {
                "firstname": _fnameController.text,
                "lastname": val,
                "middlename": _mnameController.text,
                "email": _emailController.text,
                "phone": _phoneController.text.startsWith("0")
                    ? "+234${_phoneController.text.substring(1)}"
                    : "+234${_phoneController.text}",
                "address": _addressController.text,
                "gender": _selectedGender,
                "dob": _dateController.text,
                "state": _selectedState,
                "country": _selectedCountry,
                "profession": _selectedProfession,
                "maritalStatus": _selectedMaritalStatus,
                "experienceYears": _experienceController.text,
                "city": _selectedCity.contains("Select") ? "" : _selectedCity,
              },
            );
          },
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
          onChanged: (val) {
            widget.onStep1Completed(
              {
                "firstname": _fnameController.text,
                "lastname": _lnameController.text,
                "middlename": _mnameController.text,
                "email": _emailController.text,
                "phone": _phoneController.text.startsWith("0")
                    ? "+234${_phoneController.text.substring(1)}"
                    : "+234${_phoneController.text}",
                "address": _addressController.text,
                "gender": _selectedGender,
                "dob": _dateController.text,
                "state": _selectedState,
                "country": _selectedCountry,
                "profession": _selectedProfession,
                "maritalStatus": _selectedMaritalStatus,
                "experienceYears": _experienceController.text,
                "city": _selectedCity.contains("Select") ? "" : _selectedCity,
              },
            );
          },
          controller: _emailController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email address';
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
          onChanged: (val) {
            widget.onStep1Completed(
              {
                "firstname": _fnameController.text,
                "lastname": _lnameController.text,
                "middlename": _mnameController.text,
                "email": _emailController.text,
                "phone": val.startsWith("0")
                    ? "+234${val.substring(1)}"
                    : "+234$val",
                "address": _addressController.text,
                "gender": _selectedGender,
                "dob": _dateController.text,
                "state": _selectedState,
                "country": _selectedCountry,
                "profession": _selectedProfession,
                "maritalStatus": _selectedMaritalStatus,
                "experienceYears": _experienceController.text,
                "city": _selectedCity.contains("Select") ? "" : _selectedCity,
              },
            );
          },
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
          onSelected: _onMaritalStatusSelected,
          hint: "Marital status",
          items: const ['Single', 'Married', "Divorced", "Widowed"],
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
          hint: "State of Origin",
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
          onChanged: (val) {
            widget.onStep1Completed(
              {
                "firstname": _fnameController.text,
                "lastname": _lnameController.text,
                "middlename": _mnameController.text,
                "email": _emailController.text,
                "phone": _phoneController.text.startsWith("0")
                    ? "+234${_phoneController.text.substring(1)}"
                    : "+234${_phoneController.text}",
                "address": val,
                "gender": _selectedGender,
                "dob": _dateController.text,
                "state": _selectedState,
                "country": _selectedCountry,
                "profession": _selectedProfession,
                "maritalStatus": _selectedMaritalStatus,
                "experienceYears": _experienceController.text,
                "city": _selectedCity.contains("Select") ? "" : _selectedCity,
              },
            );
          },
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
        CustomProfessionDropdown(
          onSelected: _onProfessionSelected,
          hint: "Profession",
          items: _controller.allProfessions.value,
        ),
        const SizedBox(
          height: 16.0,
        ),
        CustomTextField(
          hintText: "Years of Experience",
          onChanged: (val) {
            widget.onStep1Completed(
              {
                "firstname": _fnameController.text,
                "middlename": _mnameController.text,
                "lastname": _lnameController.text,
                "email": _emailController.text,
                "phone": _phoneController.text.startsWith("0")
                    ? "+234${_phoneController.text.substring(1)}"
                    : "+234${_phoneController.text}",
                "experienceYears": val,
                'address': _addressController.text,
                "gender": _selectedGender,
                "dob": _dateController.text,
                "state": _selectedState,
                "country": _selectedCountry,
                "profession": _selectedProfession,
                "maritalStatus": _selectedMaritalStatus,
                "city": _selectedCity.contains("Select ") ? "" : _selectedCity
              },
            );
          },
          controller: _experienceController,
          validator: (value) {
            // if (value == null || value.isEmpty) {
            //   return 'Please enter your zip code';
            // }
            return null;
          },
          inputType: TextInputType.number,
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
      ],
    );
  }
}

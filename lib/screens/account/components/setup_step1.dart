import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prohelp_app/components/inputfield/customdropdown.dart';
import 'package:prohelp_app/components/inputfield/datefield.dart';
import 'package:prohelp_app/components/inputfield/textfield.dart';
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
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _dateController = TextEditingController();

  final _controller = Get.find<StateController>();

  String _selectedGender = "Male";
  String _encodedDate = "";

  _init() {
    setState(() {
      _emailController.text = widget.email;
      _nameController.text = "${widget.name}";
    });
  }

  void _onSelected(String val) {
    _selectedGender = val;
    widget.onStep1Completed(
      {
        "fullname": _nameController.text,
        "email": _emailController.text,
        "phone": _phoneController.text.startsWith("0")
            ? "+234${_phoneController.text.substring(1)}"
            : "+234${_phoneController.text}",
        "address": _addressController.text,
        "gender": val,
        "dob": _dateController.text
      },
    );
  }

  @override
  void initState() {
    _init();
    _nameController.text = _controller.name.value;
    _addressController.text = _controller.address.value;
    _dateController.text = _controller.dob.value;
    _selectedGender = _controller.gender.value;
    _phoneController.text = _controller.phone.value;

    super.initState();
  }

  @override
  void didChangeDependencies() {
    _init();
    _nameController.text = _controller.name.value;
    // _emailController.text = _controller.email.value;
    _addressController.text = _controller.address.value;
    _phoneController.text = _controller.phone.value;
    _dateController.text = _controller.dob.value;
    _selectedGender = _controller.gender.value;
    super.didChangeDependencies();
  }

  void _onDateSelected(String raw, String val) {
    _dateController.text = val;
    _encodedDate = raw;
    widget.onStep1Completed(
      {
        "fullname": _nameController.text,
        "email": _emailController.text,
        "phone": _phoneController.text.startsWith("0")
            ? "+234${_phoneController.text.substring(1)}"
            : "+234${_phoneController.text}",
        "address": _addressController.text,
        "gender": _selectedGender,
        "dob": _encodedDate
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // _init();
    return Column(
      children: [
        const SizedBox(
          height: 16.0,
        ),
        CustomTextField(
          hintText: "Full Name",
          onChanged: (val) {
            _controller.name.value = val;
            widget.onStep1Completed(
              {
                "fullname": val,
                "email": _emailController.text,
                "phone": _phoneController.text.startsWith("0")
                    ? "+234${_phoneController.text.substring(1)}"
                    : "+234${_phoneController.text}",
                "address": _addressController.text,
                "gender": _selectedGender,
                "dob": _dateController.text
              },
            );
          },
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
          onChanged: (val) {
            widget.onStep1Completed(
              {
                "fullname": _nameController.text,
                "email": _emailController.text,
                "phone": _phoneController.text.startsWith("0")
                    ? "+234${_phoneController.text.substring(1)}"
                    : "+234${_phoneController.text}",
                "address": _addressController.text,
                "gender": _selectedGender,
                "dob": _dateController.text
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
          height: 21.0,
        ),
        CustomTextField(
          hintText: "Phone",
          onChanged: (val) {
            widget.onStep1Completed(
              {
                "fullname": _nameController.text,
                "email": _emailController.text,
                "phone": val.startsWith("0")
                    ? "+234${val.substring(1)}"
                    : "+234$val",
                "address": _addressController.text,
                "gender": _selectedGender,
                "dob": _dateController.text
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
        CustomTextField(
          hintText: "Address",
          onChanged: (val) {
            widget.onStep1Completed(
              {
                "fullname": _nameController.text,
                "email": _emailController.text,
                "phone": _phoneController.text.startsWith("0")
                    ? "+234${_phoneController.text.substring(1)}"
                    : "+234${_phoneController.text}",
                "address": val,
                "gender": _selectedGender,
                "dob": _dateController.text
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
      ],
    );
  }
}

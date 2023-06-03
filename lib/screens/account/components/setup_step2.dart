import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prohelp_app/components/inputfield/customdropdown.dart';
import 'package:prohelp_app/components/inputfield/textfield.dart';
import 'package:prohelp_app/data/relationships/relationships.dart';
import 'package:prohelp_app/helper/state/state_manager.dart';

typedef MCallback = void Function(Map data);

class SetupStep2 extends StatefulWidget {
  MCallback onStep2Completed;
  SetupStep2({
    Key? key,
    required this.onStep2Completed,
  }) : super(key: key);

  @override
  State<SetupStep2> createState() => _SetupStep2State();
}

class _SetupStep2State extends State<SetupStep2> {
  final _controller = Get.find<StateController>();

  final _nextOfKinNameController = TextEditingController();
  final _nextOfKinEmailController = TextEditingController();
  final _nextOfKinPhoneController = TextEditingController();
  final _nextOfKinAddressController = TextEditingController();

  // final TextEditingController _dateController = TextEditingController();
  String _selectedRelationship = "Sibling";

  String _selectedDate = "";

  void _onSelected(String val) {
    _selectedRelationship = val;
    widget.onStep2Completed(
      {
        "nokName": _nextOfKinNameController.text,
        "nokEmail": _nextOfKinEmailController.text,
        "nokPhone": _nextOfKinPhoneController.text.startsWith("0")
            ? "+234${_nextOfKinPhoneController.text.substring(1)}"
            : "+234${_nextOfKinPhoneController.text}",
        "nokAddress": _nextOfKinAddressController.text,
        "relationship": _selectedRelationship,
      },
    );
  }

  @override
  void initState() {
    _nextOfKinNameController.text = _controller.nokName.value;
    _nextOfKinEmailController.text = _controller.nokEmail.value;
    _nextOfKinAddressController.text = _controller.nokAddress.value;
    _nextOfKinPhoneController.text = _controller.nokPhone.value;
    _selectedRelationship = _controller.nokRelationship.value;

    super.initState();
  }

  @override
  void didChangeDependencies() {
    _nextOfKinNameController.text = _controller.nokName.value;
    _nextOfKinEmailController.text = _controller.nokEmail.value;
    _nextOfKinAddressController.text = _controller.nokAddress.value;
    _nextOfKinPhoneController.text = _controller.nokPhone.value;
    _selectedRelationship = _controller.nokRelationship.value;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextField(
          hintText: "Guarantor Fullname",
          onChanged: (val) {
            widget.onStep2Completed(
              {
                "nokName": val,
                "nokEmail": _nextOfKinEmailController.text,
                "nokPhone": _nextOfKinPhoneController.text.startsWith("0")
                    ? "+234${_nextOfKinPhoneController.text.substring(1)}"
                    : "+234${_nextOfKinPhoneController.text}",
                "nokAddress": _nextOfKinAddressController.text,
                "relationship": _selectedRelationship,
              },
            );
          },
          controller: _nextOfKinNameController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Guarantor\'s name required!';
            }
            return null;
          },
          inputType: TextInputType.name,
          capitalization: TextCapitalization.words,
        ),
        const SizedBox(
          height: 21.0,
        ),
        CustomTextField(
          hintText: "Guarantor Email",
          onChanged: (val) {
            widget.onStep2Completed(
              {
                "nokName": _nextOfKinNameController.text,
                "nokEmail": val,
                "nokPhone": _nextOfKinPhoneController.text.startsWith("0")
                    ? "+234${_nextOfKinPhoneController.text.substring(1)}"
                    : "+234${_nextOfKinPhoneController.text}",
                "nokAddress": _nextOfKinAddressController.text,
                "relationship": _selectedRelationship,
              },
            );
          },
          controller: _nextOfKinEmailController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Guarantor\'s email required!';
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
          hintText: "Guarantor Phone",
          onChanged: (val) {
            widget.onStep2Completed(
              {
                "nokName": _nextOfKinNameController.text,
                "nokEmail": _nextOfKinEmailController.text,
                "nokPhone": val.startsWith("0")
                    ? "+234${val.substring(1)}"
                    : "+234$val",
                "nokAddress": _nextOfKinAddressController.text,
                "relationship": _selectedRelationship,
              },
            );
          },
          controller: _nextOfKinPhoneController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Guarantor\'s phone required!';
            }
            if (value.toString().length < 11) {
              return 'Enter a valid phone number';
            }
            return null;
          },
          inputType: TextInputType.phone,
        ),
        const SizedBox(
          height: 16.0,
        ),
        CustomTextField(
          hintText: "Guarantor Address",
          onChanged: (val) {
            widget.onStep2Completed(
              {
                "nokName": _nextOfKinNameController.text,
                "nokEmail": _nextOfKinEmailController.text,
                "nokPhone": _nextOfKinPhoneController.text.startsWith("0")
                    ? "+234${_nextOfKinPhoneController.text.substring(1)}"
                    : "+234${_nextOfKinPhoneController.text}",
                "nokAddress": val,
                "relationship": _selectedRelationship,
              },
            );
          },
          controller: _nextOfKinAddressController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter guarantor\'s address';
            }
            return null;
          },
          inputType: TextInputType.streetAddress,
        ),
        const SizedBox(
          height: 21.0,
        ),
        CustomDropdown(
          onSelected: _onSelected,
          hint: "Relationship with guarantor",
          items: relationships
        ),
        const SizedBox(
          height: 21.0,
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:prohelp_app/helper/constants/constants.dart';

typedef void InitCallback(String value);

class CustomDropdown extends StatefulWidget {
  final InitCallback onSelected;
  final double borderRadius;
  final String hint;
  final String? label;
  final List<String> items;
  var validator;
  bool isEnabled;
  CustomDropdown({
    Key? key,
    required this.items,
    required this.hint,
    this.borderRadius = 36.0,
    required this.onSelected,
    this.validator,
    this.label,
    this.isEnabled = true,
  }) : super(key: key);

  @override
  State<CustomDropdown> createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  String _hint = "";
  var _gender;

  @override
  void initState() {
    super.initState();
    setState(() {
      _hint = widget.hint;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField(
      hint: Text(
        _hint,
        style: const TextStyle(fontSize: 18, color: Colors.black),
      ),
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24.0,
          vertical: 12.0,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(widget.borderRadius),
          ),
          gapPadding: 4.0,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(widget.borderRadius),
          ),
          gapPadding: 4.0,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(widget.borderRadius),
          ),
          gapPadding: 4.0,
        ),
        filled: false,
        hintText: _hint,
        labelText: widget.label ?? _hint,
        focusColor: Constants.accentColor,
        hintStyle: const TextStyle(
          fontFamily: "Poppins",
          color: Colors.black38,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: const TextStyle(
          fontFamily: "Poppins",
          fontWeight: FontWeight.w500,
          fontSize: 18,
        ),
        // suffixIcon: endIcon,
      ),
      validator: widget.validator,
      items: widget.items.map((e) {
        return DropdownMenuItem(
          value: e,
          child: Text(
            e,
            style: const TextStyle(fontSize: 18, color: Colors.black),
          ),
        );
      }).toList(),
      value: _gender,
      onChanged: !widget.isEnabled
          ? null
          : (newValue) async {
              widget.onSelected(
                newValue as String,
              );
              setState(
                () {
                  _gender = newValue;
                },
              );
            },
      icon: const Icon(Icons.keyboard_arrow_down_rounded),
      iconSize: 30,
      isExpanded: true,
    );
  }
}

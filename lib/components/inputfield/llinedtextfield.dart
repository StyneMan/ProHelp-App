import 'package:flutter/material.dart';
import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/helper/constants/constants.dart';

class LinedTextField extends StatelessWidget {
  final String label;
  final ValueChanged<String> onChanged;
  final TextEditingController controller;
  final TextInputType inputType;
  final TextCapitalization capitalization;
  final bool? isEnabled;
  var validator;
  LinedTextField({
    Key? key,
    required this.label,
    required this.onChanged,
    required this.controller,
    required this.validator,
    required this.inputType,
    required this.capitalization,
    this.isEnabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        TextInter(
          text: label,
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF9CA5C5),
        ),
        Expanded(
          child: TextFormField(
            onChanged: onChanged,
            cursorColor: Constants.primaryColor,
            controller: controller,
            validator: validator,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontFamily: "Inter",
              color: Color(0xFF9CA5C5),
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
            maxLength: label == "Phone" ? 11 : null,
            enabled: isEnabled,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 21.0,
                vertical: 1.0,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: false,
              hintText: label,
              labelText: "",
              focusColor: Constants.accentColor,
              hintStyle: const TextStyle(
                fontFamily: "Inter",
                color: Colors.black38,
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
            keyboardType: inputType,
            textCapitalization: capitalization,
          ),
        ),
      ],
    );
  }
}

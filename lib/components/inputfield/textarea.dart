import 'package:flutter/material.dart';
import 'package:prohelp_app/helper/constants/constants.dart';

class CustomTextArea extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final TextEditingController controller;
  final TextInputType inputType;
  final TextCapitalization capitalization;
  final bool? isEnabled;
  final double borderRadius;
  final int maxLines;
  final int? maxLength;
  var validator;
  final FocusNode? focusNode;
  final bool autoFocus;

  CustomTextArea({
    Key? key,
    required this.hintText,
    this.icon = Icons.person,
    this.isEnabled = true,
    this.capitalization = TextCapitalization.none,
    required this.onChanged,
    required this.controller,
    required this.validator,
    required this.inputType,
    this.borderRadius = 6.0,
    this.maxLines = 10,
    this.maxLength,
    this.focusNode,
    this.autoFocus = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      autofocus: autoFocus,
      focusNode: focusNode,
      onChanged: onChanged,
      cursorColor: Constants.primaryColor,
      controller: controller,
      // validator: validator,
      enabled: isEnabled,
      maxLines: maxLines,
      maxLength: maxLength,
      textAlignVertical: TextAlignVertical.top,
      decoration: InputDecoration(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        alignLabelWithHint: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(borderRadius),
          ),
          gapPadding: 4.0,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(borderRadius),
          ),
          gapPadding: 4.0,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(borderRadius),
          ),
          gapPadding: 4.0,
        ),
        filled: false,
        hintText: hintText,
        labelText: hintText,
        focusColor: Constants.accentColor,
        hintStyle: const TextStyle(
            fontFamily: "Poppins",
            color: Colors.black38,
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 2.8,
            overflow: TextOverflow.clip),
        labelStyle: const TextStyle(
          fontFamily: "Poppins",
          fontWeight: FontWeight.w500,
          fontSize: 18,
        ),
        // border: InputBorder.none,
      ),
      keyboardType: inputType,
      textCapitalization: capitalization,
    );
  }
}

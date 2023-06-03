import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:prohelp_app/helper/constants/constants.dart';

class RoundedInputMoney extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final bool? enabled;
  final ValueChanged<String> onChanged;
  final TextEditingController controller;
  var validator;

  final double borderRadius;

  RoundedInputMoney({
    Key? key,
    required this.hintText,
    this.icon = Icons.money,
    this.enabled,
    required this.onChanged,
    required this.controller,
    required this.validator,
    this.borderRadius = 6.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: onChanged,
      cursorColor: Constants.primaryColor,
      controller: controller,
      validator: validator,
      enabled: enabled,
      inputFormatters: <TextInputFormatter>[
        CurrencyTextInputFormatter(
          locale: 'en',
          decimalDigits: 0,
          symbol: '₦ ',
        ),
      ],
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24.0,
          vertical: 12.0,
        ),
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
        // labelText: hintText,
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
      ),
    );
  }
}

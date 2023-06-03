import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prohelp_app/helper/constants/constants.dart';

typedef void InitCallback(String rawDate, String date);

class CustomDateField extends StatefulWidget {
  final String hintText;
  final IconData icon;
  final InitCallback onDateSelected;
  final TextEditingController controller;
  final TextCapitalization capitalization;
  final bool? isEnabled;

  CustomDateField({
    Key? key,
    required this.hintText,
    this.icon = Icons.person,
    this.isEnabled = true,
    required this.onDateSelected,
    this.capitalization = TextCapitalization.none,
    required this.controller,
  }) : super(key: key);

  @override
  State<CustomDateField> createState() => _CustomDateFieldState();
}

class _CustomDateFieldState extends State<CustomDateField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      cursorColor: Constants.primaryColor,
      controller: widget.controller,
      enabled: widget.isEnabled,
      decoration: InputDecoration(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(36.0),
          ),
          gapPadding: 4.0,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(36.0),
          ),
          gapPadding: 4.0,
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(36.0),
          ),
          gapPadding: 4.0,
        ),
        filled: false,
        hintText: widget.hintText,
        labelText: widget.hintText,
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
        // border: InputBorder.none,
      ),
      readOnly: true, //set it true, so that user will not able to edit text
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(
              1920), //DateTime.now() - not to allow to choose before today.
          lastDate: DateTime(2101),
        );

        if (pickedDate != null) {
          debugPrint(
              "$pickedDate"); //pickedDate output format => 2021-03-10 00:00:00.000
          String formattedDate = DateFormat('dd/MMM/yyyy').format(pickedDate);
          debugPrint(
            formattedDate,
          ); //formatted date output using intl package =>  2021-03-16
          //you can implement different kind of Date Format here according to your requirement
          widget.onDateSelected(pickedDate.toIso8601String(), formattedDate);

          // setState(() {
          //   widget.controller.text =
          //       formattedDate; //set output date to TextField value.
          // });
        } else {
          debugPrint("Date is not selected");
        }
      },
      keyboardType: TextInputType.datetime,
      textCapitalization: widget.capitalization,
    );
  }
}

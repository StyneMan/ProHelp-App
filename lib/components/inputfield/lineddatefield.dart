import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/helper/constants/constants.dart';

typedef void InitCallback(String date);

class LinedDateField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType inputType;
  final TextCapitalization capitalization;
  final bool? isEnabled;
  final InitCallback onDateSelected;

  LinedDateField({
    Key? key,
    required this.label,
    required this.onDateSelected,
    required this.controller,
    required this.inputType,
    this.capitalization = TextCapitalization.none,
    this.isEnabled = true,
  }) : super(key: key);

  @override
  State<LinedDateField> createState() => _LinedDateFieldState();
}

class _LinedDateFieldState extends State<LinedDateField> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        TextInter(
          text: widget.label,
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF9CA5C5),
        ),
        Expanded(
          child: TextField(
            cursorColor: Constants.primaryColor,
            controller: widget.controller,
            enabled: widget.isEnabled,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontFamily: "Inter",
              color: Color(0xFF9CA5C5),
              fontSize: 13,
              fontWeight: FontWeight.w400,
            ),
            maxLength: widget.label == "Phone" ? 11 : null,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 21.0,
                vertical: 1.0,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              filled: false,
              hintText: widget.label,
              labelText: "",
              focusColor: Constants.accentColor,
              hintStyle: const TextStyle(
                fontFamily: "Inter",
                color: Colors.black38,
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
            readOnly: true,
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(1920),
                lastDate: DateTime(2101),
              );

              if (pickedDate != null) {
                debugPrint(
                    "$pickedDate"); //pickedDate output format => 2021-03-10 00:00:00.000
                String formattedDate =
                    DateFormat('dd/MMM/yyyy').format(pickedDate);
                debugPrint(
                  formattedDate,
                ); //formatted date output using intl package =>  2021-03-16

                widget.onDateSelected(formattedDate);
              } else {
                debugPrint("Date is not selected");
              }
            },
            keyboardType: TextInputType.datetime,
            textCapitalization: widget.capitalization,
          ),
        ),
      ],
    );
  }
}

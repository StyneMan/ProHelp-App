import 'package:flutter/material.dart';
import 'package:prohelp_app/helper/constants/constants.dart';
import 'package:substring_highlight/substring_highlight.dart';

typedef void InitCallback(String value);

class CustomAutoComplete extends StatelessWidget {
  List<String> data;
  final InitCallback onItemSelected;
  final String hintText;
  final double borderRadius;
  CustomAutoComplete({
    Key? key,
    required this.data,
    required this.onItemSelected,
    required this.hintText,
    this.borderRadius = 36.0,
  }) : super(key: key);

  final _tcontroller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<String>(
      textEditingController: _tcontroller,
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return const Iterable<String>.empty();
        } else {
          return data.where((word) =>
              word.toLowerCase().contains(textEditingValue.text.toLowerCase()));
        }
      },
      optionsViewBuilder: (context, Function(String) onSelected, options) {
        return Material(
          elevation: 4,
          child: ListView.separated(
            padding: EdgeInsets.zero,
            itemBuilder: (context, index) {
              final String option = options.elementAt(index);
              return ListTile(
                title: SubstringHighlight(
                  text: option.toString(),
                  term: _tcontroller.text,
                  textStyleHighlight:
                      const TextStyle(fontWeight: FontWeight.w700),
                ),
                onTap: () {
                  onItemSelected(option);
                },
              );
            },
            separatorBuilder: (context, index) => const Divider(),
            itemCount: options.length,
          ),
        );
      },
      onSelected: (selectedString) {
        // print(selectedString);
        _tcontroller.text = "";
      },
      focusNode: _focusNode,
      fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
        // _tcontroller = controller;
        return TextField(
          controller: _tcontroller,
          focusNode: focusNode,
          onChanged: (String value) {},
          onEditingComplete: onEditingComplete,
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
            labelText: hintText,
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
      },
    );
  }
}

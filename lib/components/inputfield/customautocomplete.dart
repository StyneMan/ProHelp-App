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

  late TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
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
                // title: Text(option.toString()),
                title: SubstringHighlight(
                  text: option.toString(),
                  term: controller.text,
                  textStyleHighlight: TextStyle(fontWeight: FontWeight.w700),
                ),
                // subtitle: const Text("This is subtitle"),
                onTap: () {
                  onItemSelected(option);
                  // onSelected(option.toString());
                },
              );
            },
            separatorBuilder: (context, index) => Divider(),
            itemCount: options.length,
          ),
        );
      },
      onSelected: (selectedString) {
        print(selectedString);
      },
      fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
        this.controller = controller;
        return TextField(
          controller: controller,
          focusNode: focusNode,
          onChanged: (String value) {},
          onEditingComplete: onEditingComplete,
          decoration:  InputDecoration(
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

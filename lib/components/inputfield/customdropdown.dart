import 'package:flutter/material.dart';

typedef void InitCallback(String value);

class CustomDropdown extends StatefulWidget {
  final InitCallback onSelected;
  final double borderRadius;
  final String hint;
  final List<String> items;
  const CustomDropdown({
    Key? key,
    required this.items,
    required this.hint,
    this.borderRadius = 36.0,
    required this.onSelected,
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 0.0),
        decoration: BoxDecoration(
          border: Border.all(
            width: 1.5,
            color: Colors.black45,
          ),
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
        child: DropdownButton(
          hint: Text(
            _hint,
            style: const TextStyle(fontSize: 18, color: Colors.black),
          ),
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
          onChanged: (newValue) async {
            widget.onSelected(
              newValue as String,
            );
            setState(
              () {
                _gender = newValue;
              },
            );
          },
          onTap: () {
            debugPrint("TAPPED ME >>> ");
          },
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          iconSize: 30,
          isExpanded: true,
          underline: const SizedBox(),
        ),
      ),
    );
  }
}

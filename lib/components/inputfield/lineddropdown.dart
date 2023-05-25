import 'package:flutter/material.dart';
import 'package:prohelp_app/components/text_components.dart';

typedef void InitCallback(String value);

class LinedDropdown extends StatefulWidget {
  final String label;
  final InitCallback onSelected;
  final List<dynamic> items;

  const LinedDropdown({
    Key? key,
    required this.label,
    required this.onSelected,
    required this.items,
  }) : super(key: key);

  @override
  State<LinedDropdown> createState() => _LinedDropdownState();
}

class _LinedDropdownState extends State<LinedDropdown> {
  var selectVal;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TextInter(
            text: widget.label,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF9CA5C5),
          ),
          Expanded(
            child: Container(
              width: 100,
              color: Colors.transparent,
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.56,
            // height: 100,
            child: DropdownButton(
              hint: TextInter(
                text: widget.label,
                align: TextAlign.end,
                color: const Color(0xFF9CA5C5),
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
              alignment: AlignmentDirectional.centerEnd,
              items: widget.items.map((e) {
                return DropdownMenuItem(
                  value: e['code'],
                  alignment: AlignmentDirectional.centerEnd,
                  child: TextInter(
                    text: e['name'],
                    align: TextAlign.end,
                    color: const Color(0xFF9CA5C5),
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                );
              }).toList(),
              value: selectVal,
              onChanged: (newValue) async {
                widget.onSelected(
                  newValue as String,
                );
                setState(
                  () {
                    selectVal = newValue;
                  },
                );
              },
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
              iconSize: 30,
              isExpanded: true,
              underline: const SizedBox(),
            ),
          ),
        ],
      ),
    );
  }
}

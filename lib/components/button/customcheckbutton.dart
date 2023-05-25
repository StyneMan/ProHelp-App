import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/helper/constants/constants.dart';
import 'package:flutter/material.dart';

typedef InitCallback(bool isActive);

class CheckButton extends StatelessWidget {
  final String title;
  bool isActive = false;
  final InitCallback onChanged;
  CheckButton({
    Key? key,
    required this.onChanged,
    required this.title,
    required this.isActive,
  }) : super(key: key);

  bool _isActive = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      width: 100,
      decoration: BoxDecoration(
        border: Border.all(width: 1.0, color: Colors.grey),
        color: (isActive || _isActive)
            ? Colors.blueGrey.withOpacity(0.5)
            : Colors.transparent,
        borderRadius: const BorderRadius.all(
          Radius.circular(8.0),
        ),
      ),
      child: TextButton(
        onPressed: () {
          _isActive = !_isActive;

          onChanged(_isActive);
        },
        child: Center(
          child: TextPoppins(
            text: title,
            fontSize: 12,
            color:
                isActive || _isActive ? Constants.primaryColor : Colors.black54,
          ),
        ),
        style: TextButton.styleFrom(
          foregroundColor: (isActive || _isActive) ? Constants.primaryColor : Colors.black54,
        ),
      ),
    );
  }
}

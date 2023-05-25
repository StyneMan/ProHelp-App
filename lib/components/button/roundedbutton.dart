import 'package:flutter/material.dart';

typedef InitCallback();

class RoundedButton extends StatelessWidget {
  final String variant;
  final Widget child;
  final Color bgColor;
  final Color foreColor;
  final Color borderColor;
  final Function()? onPressed;
  final double paddingX, paddingY;
  final bool isLoading;

  const RoundedButton({
    Key? key,
    required this.bgColor,
    required this.child,
    required this.borderColor,
    required this.foreColor,
    required this.onPressed,
    required this.variant,
    this.paddingX = 12.0,
    this.paddingY = 12.0,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(36.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          border: variant == "Outlined"
              ? Border.all(color: borderColor, width: 1.5)
              : null,
          borderRadius: BorderRadius.circular(36.0),
          color: variant == "Outlined" ? Colors.transparent : bgColor,
        ),
        child: TextButton(
          child: child,
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            padding:
                EdgeInsets.symmetric(vertical: paddingY, horizontal: paddingX),
            foregroundColor: foreColor,
            backgroundColor:
                variant == "Outlined" ? Colors.transparent : bgColor,
          ),
        ),
      ),
    );
  }
}

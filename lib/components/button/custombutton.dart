import 'package:flutter/material.dart';

typedef InitCallback();

class CustomButton extends StatelessWidget {
  final String variant;
  final Widget child;
  final Color bgColor;
  final Color foreColor;
  final Color borderColor;
  final Function()? onPressed;
  final double paddingX, paddingY, borderRadius;

  const CustomButton({
    Key? key,
    required this.bgColor,
    required this.child,
    required this.borderColor,
    required this.foreColor,
    required this.onPressed,
    required this.variant,
    this.borderRadius = 5.0,
    this.paddingX = 10.0,
    this.paddingY = 6.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(3.0),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: paddingX, vertical: paddingY),
        decoration: BoxDecoration(
          border: variant == "Outlined"
              ? Border.all(color: borderColor, width: 1.5)
              : null,
          borderRadius: BorderRadius.circular(borderRadius),
          color: variant == "Outlined" ? Colors.transparent : bgColor,
        ),
        child: InkWell(
          child: Center(child: child),
          onTap: onPressed,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class TextPoppins extends StatelessWidget {
  late final String? text;
  late final double? fontSize;
  late final Color? color;
  late final TextAlign? align;
  late final FontWeight? fontWeight;
  late final bool? softWrap;

  TextPoppins({
    required this.text,
    this.color,
    required this.fontSize,
    this.fontWeight,
    this.align,
    this.softWrap,
  });

  final fontFamily = "Poppins";

  @override
  Widget build(BuildContext context) {
    return Text(
      text!,
      softWrap: softWrap,
      textAlign: align,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontFamily: fontFamily,
        fontWeight: fontWeight,
      ),
    );
  }
}

class TextInter extends StatelessWidget {
  final String? text;
  final double? fontSize;
  final Color? color;
  final TextAlign? align;
  final FontWeight? fontWeight;
  final bool? softWrap;

  const TextInter({
    required this.text,
    this.color,
    required this.fontSize,
    this.fontWeight,
    this.align,
    this.softWrap,
  });

  final fontFamily = "Inter";

  @override
  Widget build(BuildContext context) {
    return Text(
      text!,
      softWrap: softWrap,
      textAlign: align,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontFamily: fontFamily,
        fontWeight: fontWeight,
      ),
    );
  }
}

class TextRoboto extends StatelessWidget {
  late final String? text;
  late final double? fontSize;
  late final Color? color;
  late final FontWeight? fontWeight;
  late final TextAlign? align;

  TextRoboto(
      {required this.text,
      this.color,
      required this.fontSize,
      this.fontWeight,
      this.align});

  final fontFamily = "Roboto";

  @override
  Widget build(BuildContext context) {
    return Text(
      text!,
      textAlign: align,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontFamily: fontFamily,
        fontWeight: fontWeight,
      ),
    );
  }
}

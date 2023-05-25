import 'package:flutter/material.dart';
import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/helper/constants/constants.dart';

class HorzTextDivider extends StatelessWidget {
  final String text;
  const HorzTextDivider({
    Key? key,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.symmetric(vertical: size.height * 0.02),
      width: double.infinity, //size.width * 0.8,
      child: Row(
        children: <Widget>[
          buildDivider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: TextPoppins(
              text: text,
              fontSize: 20,
              color: Constants.primaryColor,
              fontWeight: FontWeight.w400,
            ),
          ),
          buildDivider(),
        ],
      ),
    );
  }

  Expanded buildDivider() {
    return const Expanded(
      child: Divider(
        color: Constants.primaryColor,
        height: 1.2,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:prohelp_app/helper/constants/constants.dart';

class InfoDialog extends StatelessWidget {
  final Widget body;
  // final String title;
  InfoDialog({
    required this.body,
    // required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(36),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }

  dialogContent(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          // padding: const EdgeInsets.only(
          //   left: Constants.padding,
          //   top: Constants.padding,
          //   right: Constants.padding,
          //   bottom: Constants.padding,
          // ),
          // margin: const EdgeInsets.only(top: Constants.avatarRadius),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Colors.white,
            borderRadius: BorderRadius.circular(Constants.padding),
            boxShadow: null,
            // const [
            //   BoxShadow(
            //       color: Colors.black, offset: Offset(0, 10), blurRadius: 10),
            // ],
          ),
          child: body,
        ),
        // Positioned(
        //   left: Constants.padding,
        //   right: Constants.padding,
        //   top: Constants.avatarRadius,
        //   child: ripple,
        // ),
        
      ],
    );
  }
}

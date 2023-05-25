import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import "package:intl/intl.dart";
import 'package:money_formatter/money_formatter.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
// import 'package:logger/logger.dart';

class Constants {
  static const Color primaryColor = Color(0xFF0066F5);
  static const Color accentColor = Color(0xFF8A95BF);
  static const Color secondaryColor = Colors.white;
  static const Color golden = Color(0xFFF1A038);

  static const double padding = 20;
  static const double avatarRadius = 60;

  static const Color shimmerBaseColor = Color.fromARGB(255, 203, 203, 203);
  static const Color shimmerHighlightColor = Colors.white;

  static const baseURL = "https://pro-help-server.vercel.app";
  //"https://pro-help-api.vercel.app"; //"http://192.168.1.103:8080";
  static String pstk = "pk_test_043683268da92cd71e0d30f9d72396396f2dfb1f";

  static String formatMoney(int amt) {
    MoneyFormatter fmf = MoneyFormatter(
      amount: double.parse("${amt}.00"),
      settings: MoneyFormatterSettings(
          symbol: 'NGN',
          thousandSeparator: ',',
          decimalSeparator: '.',
          symbolAndNumberSeparator: ' ',
          fractionDigits: 3,
          compactFormatType: CompactFormatType.short),
    );
    return fmf.output.withoutFractionDigits;
  }

  static String formatMoneyFloat(double amt) {
    MoneyFormatter fmf = MoneyFormatter(
        amount: amt,
        settings: MoneyFormatterSettings(
            symbol: 'NGN',
            thousandSeparator: ',',
            decimalSeparator: '.',
            symbolAndNumberSeparator: ' ',
            fractionDigits: 3,
            compactFormatType: CompactFormatType.short));
    return fmf.output.withoutFractionDigits;
  }

  static nairaSign(context) {
    Locale locale = Localizations.localeOf(context);
    var format =
        NumberFormat.simpleCurrency(locale: Platform.localeName, name: 'NGN');
    return format;
  }

  static toast(String message) {
    Fluttertoast.showToast(
      msg: "" + message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 3,
      backgroundColor: Colors.grey[800],
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

// AnimationController localAnimationController;
  static toastify({
    required context,
    required String message,
    required String type,
    required bool persistent,
  }) {
    showTopSnackBar(
      context,
      type == "info"
          ? CustomSnackBar.info(
              message: message,
            )
          : type == "success"
              ? CustomSnackBar.success(
                  message: message,
                )
              : CustomSnackBar.error(
                  message: message,
                ),
      persistent: persistent,
      // onAnimationControllerInit: (controller) =>
      //     localAnimationController = controller,
    );
  }

  //Account Page
  static final accScaffoldKey = GlobalKey<ScaffoldState>();
  static const riKey2 = const Key('__RIKEY2__');
  static final riKey3 = const Key('__RIKEY3__');

  static final GlobalKey<ScaffoldMessengerState> snackbarKey =
      GlobalKey<ScaffoldMessengerState>();
}

extension HexColor on Color {
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write("ff");
    buffer.write(hexString.replaceFirst("#", ""));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  String toHex({bool loadingHashSign = true}) => "";
}

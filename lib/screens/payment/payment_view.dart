import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentView extends StatelessWidget {
  var webViewController;
  PaymentView({
    Key? key,
    required this.webViewController,
  }) : super(key: key);

  // final _djks = Get.put(PaymentController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: WebViewWidget(controller: webViewController),
      ),
    );
  }
}

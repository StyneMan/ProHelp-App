import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prohelp_app/components/button/roundedbutton.dart';
import 'package:prohelp_app/components/inputfield/rounded_money_input.dart';
import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/helper/constants/constants.dart';
import 'package:prohelp_app/helper/preference/preference_manager.dart';
import 'package:prohelp_app/helper/service/api_service.dart';
import 'package:prohelp_app/helper/state/state_manager.dart';
import 'package:prohelp_app/screens/payment/payment_view.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WalletBody extends StatefulWidget {
  final PreferenceManager manager;
  const WalletBody({
    Key? key,
    required this.manager,
  }) : super(key: key);

  @override
  State<WalletBody> createState() => _WalletBodyState();
}

class _WalletBodyState extends State<WalletBody> {
  final _controller = Get.find<StateController>();
  bool _isClicked = false;
  final _amountController = TextEditingController();
  int _amount = 0, _value = 0;
  var _selectedVal = "";

  final DateTime pageStartTime = DateTime.now();
  late WebViewController webviewController;

  _pluralize(int num) {
    return num > 1 ? "s" : "";
  }

  List coinsList = [
    {"title": '200 Coins', "amount": 500, "value": 200},
    {"title": '500 Coins', "amount": 1000, "value": 500},
    {"title": '800 Coins', "amount": 1500, "value": 800},
    {"title": '1000 Coins', "amount": 1800, "value": 1000},
    {"title": '1500 Coins', "amount": 2000, "value": 1500},
    {"title": '2000 Coins', "amount": 3400, "value": 2000},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          "assets/images/coin_gold.png",
        ),
        const SizedBox(
          height: 8.0,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextPoppins(
                  text: "Balance:",
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                Text(
                  " ${Constants.formatMoney(_controller.userData.value['wallet']['balance'])} coin${_pluralize(widget.manager.getUser()['wallet']['balance'])}",
                ),
              ],
            ),
            const SizedBox(height: 1.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextPoppins(
                  text: "Prev Balance:",
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                Text(
                  " ${Constants.formatMoney(_controller.userData.value['wallet']['prevBalance'])} coin${_pluralize(widget.manager.getUser()['wallet']['prevBalance'])}",
                ),
              ],
            ),
          ],
        ),
        const SizedBox(
          height: 21.0,
        ),
        _isClicked
            ? const SizedBox()
            : SizedBox(
                width: 144,
                child: RoundedButton(
                  bgColor: Constants.primaryColor,
                  child: const TextInter(
                    text: "Top up",
                    fontSize: 16,
                  ),
                  borderColor: Colors.transparent,
                  foreColor: Colors.white,
                  onPressed: () {
                    setState(() {
                      _isClicked = true;
                    });
                  },
                  variant: "Filled",
                ),
              ),
        const SizedBox(height: 16.0),
        _isClicked
            ? Column(
                children: [
                  DropdownButtonFormField(
                    hint: const Text(
                      "Select amount",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                    items: coinsList.map((e) {
                      return DropdownMenuItem(
                        value: e['title'],
                        child: Text(
                          e['title'],
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                      );
                    }).toList(),
                    validator: (val) {},
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 12.0,
                      ),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(36.0),
                        ),
                        gapPadding: 4.0,
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(36.0),
                        ),
                        gapPadding: 4.0,
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(36.0),
                        ),
                        gapPadding: 4.0,
                      ),
                      filled: false,
                      hintText: _selectedVal,
                      labelText: "Select coins amount",
                      focusColor: Constants.accentColor,
                      hintStyle: const TextStyle(
                        fontFamily: "Poppins",
                        color: Colors.black38,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      labelStyle: const TextStyle(
                        fontFamily: "Poppins",
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                      ),
                    ),
                    // value: _gender,
                    onChanged: (newValue) async {
                      debugPrint('NEW VAL $newValue');
                      var ar = coinsList.firstWhere(
                        (element) => element['title'] == newValue,
                      );
                      setState(
                        () {
                          _amountController.text =
                              "${Constants.nairaSign(context).currencySymbol}${Constants.formatMoney(ar['amount'])}";
                          _value = ar['value'];
                        },
                      );
                    },
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                    ),
                    iconSize: 30,
                    isExpanded: true,
                  ),
                  const SizedBox(
                    height: 16.0,
                  ),
                  RoundedInputMoney(
                    hintText: "Amount",
                    borderRadius: 36.0,
                    enabled: false,
                    onChanged: (val) {
                      String? amt = val.replaceAll("₦ ", "");
                      String filteredAmt = amt.replaceAll(",", "");
                      // print("SELCETD NEDWORK:: $_networkValue");
                      // print(
                      //     "SELCETED RATE:: ${_controller.airtimeSwapRate.value}");
                      print("CURRENT AMOUNT TF:: $filteredAmt");
                      setState(() {
                        _amount = int.parse(filteredAmt);
                      });
                    },
                    controller: _amountController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter amount';
                      }
                      return null;
                    },
                  ),
                ],
              )
            : const SizedBox(),
        const SizedBox(
          height: 21.0,
        ),
        !_isClicked
            ? const SizedBox()
            : SizedBox(
                width: 200,
                child: RoundedButton(
                  bgColor: Colors.transparent,
                  child: const TextInter(text: "Continue", fontSize: 16),
                  borderColor: Constants.primaryColor,
                  foreColor: Constants.primaryColor,
                  onPressed: () {
                    String? amt = _amountController.text.replaceAll("₦", "");
                    String filteredAmt = amt.replaceAll(",", "");
                    // print("SELCETD NEDWORK:: $_networkValue");
                    // print(
                    //     "SELCETED RATE:: ${_controller.airtimeSwapRate.value}");
                    print(" AMOUNT TF:: $amt");
                    print("CURRENT AMOUNT TF:: $filteredAmt");
                    setState(() {
                      _amount = int.parse(filteredAmt);
                    });

                    // // Iitialize FlutterWave Payment Here
                    _handlePaymentInitialization();
                  },
                  variant: "Outlined",
                ),
              ),
      ],
    );
  }

  _handlePaymentInitialization() async {
    try {
      _controller.setLoading(true);
      // final Customer customer = Customer(
      //     name:
      //         "${_controller.userData.value['bio']['firstname']} ${_controller.userData.value['bio']['middlename']} ${_controller.userData.value['bio']['lastname']}",
      //     phoneNumber: "${_controller.userData.value['bio']['phone']}",
      //     email: "${_controller.userData.value['email']}");
      // final Flutterwave flutterwave = Flutterwave(
      //   context: context,
      //   publicKey: "FLWPUBK_TEST-3d9167e11cc023e3b2c6164520da7ac8-X",
      //   currency: "NG",
      //   redirectUrl: "https://prohelp.ng",
      //   txRef: const Uuid().v1(),
      //   amount: "$_amount",
      //   customer: customer,
      //   paymentOptions: "ussd, card",
      //   customization: Customization(
      //     title: "Wallet Topup",
      //     description: "This is for wallet topup coins purchase for ProHelp NG",
      //     logo: "${_controller.userData.value['bio']['image']}",
      //   ),
      //   isTestMode: true,
      // );

      // final charge = await flutterwave.charge();
      // print("CHARGE RESPONSE :::: $charge");

      var data = {
        'amount': "$_amount",
        'currency': "NGN",
        "redirect_url": "https://prohelp.ng",
        "customer": {
          'email': "${_controller.userData.value['email']}",
          'phone': "${_controller.userData.value['bio']['phone']}",
          'name':
              "${_controller.userData.value['bio']['firstname']} ${_controller.userData.value['bio']['middlename']} ${_controller.userData.value['bio']['lastname']}",
        },
        'tx_ref': "Prohelp-${DateTime.now().millisecondsSinceEpoch}",
        "customizations": {
          'title': 'Wallet Topup',
          "logo": "https://www.prohelp.ng/favicon.png"
        }
      };

      final _response = await APIService().initPayment(
        accessToken: widget.manager.getAccessToken(),
        email: widget.manager.getUser()['email'],
        transactionType: "fund_wallet",
        payload: data,
      );
      _controller.setLoading(false);
      print("INIT PAYMENT RESPONSE :: ${_response.body}");
      if (_response.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(_response.body);
        String _paymentLink = map['data']['link'];

        print("PAY LINK ;;; $_paymentLink");

        // Now launch webview and open returned payment link here
        _initWebview(paymentLink: _paymentLink);
      }
    } catch (e) {
      _controller.setLoading(false);
      print(e.toString());
    }
  }

  _initWebview({required String paymentLink}) {
    webviewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(NavigationDelegate(
          onPageStarted: (String url) {
            // Set loading here
            _controller.setLoading(true);
          },
          onPageFinished: (String url) {
            Get.back();
            _controller.setLoading(false);
          },
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) async {
            final DateTime pageStartTime = DateTime.now();

            print("REQUEST URL NOW ::: ${request.url}");

            if (request.url
                .startsWith('https://www.prohelp.ng/?status=successful')) {
              // Transaction was successful.
              // Now update user wallet balance.
              Map _payload = {
                "value": _value,
                "userId": widget.manager.getUser()['id'] ??
                    widget.manager.getUser()['_id'],
              };

              final resp = await APIService().topupWallet(
                _payload,
                widget.manager.getAccessToken(),
                widget.manager.getUser()['email'],
              );

              print("TOPUP WALLET RESP :: ${resp.body}");

              // PROFILE
              final _profileResp = await APIService().getProfile(
                widget.manager.getAccessToken(),
                widget.manager.getUser()['email'],
              );
              // print("PROFILE ::: ${_profileResp.body}");
              if (_profileResp.statusCode == 200) {
                Map<String, dynamic> map = jsonDecode(_profileResp.body);

                String userData = jsonEncode(map['data']);
                widget.manager.setUserData(userData);
                _controller.setUserData(map['data']);
              }
            }

            // if (request.url
            //     .startsWith('https://afrikunet.com/mobile/success/buy')) {
            //   // User has paid. Now render his/her service here
            //   final payload = Get.arguments['payload'];
            //   final customerData = Get.arguments['customerData'];

            // https://www.prohelp.ng/?status=successful&tx_ref=Prohelp-1713270237163&transaction_id=5030928

            //   // _initiatePurchase(
            //   //   payload: payload,
            //   //   customerData: customerData,
            //   //   accessToken: Get.arguments['accessToken'],
            //   //   manager: Get.arguments['manager'],
            //   //   selectedDataPlanName: Get.arguments['selectedDataPlanName'],
            //   // );
            // }

            if (request.url.contains('payment/verify')) {
              Constants.toast("VERIFY TRIIGERED!!!");
              // Get.back();
              // Duration durationOnPage =
              //     DateTime.now().difference(pageStartTime);
            }

            return NavigationDecision.navigate;
          }))
      ..loadRequest(
        Uri.parse(paymentLink),
      );

    Future.delayed(const Duration(seconds: 3), () {
      Get.to(
        PaymentView(
          webViewController: webviewController,
        ),
        transition: Transition.cupertino,
      );
    });
  }
}

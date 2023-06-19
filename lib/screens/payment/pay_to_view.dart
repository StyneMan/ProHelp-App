import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:loading_overlay_pro/loading_overlay_pro.dart';
import 'package:prohelp_app/components/button/custombutton.dart';
import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/helper/card/card_utils.dart';
import 'package:prohelp_app/helper/constants/constants.dart';
import 'package:prohelp_app/helper/formatters/card_date_formatter.dart';
import 'package:prohelp_app/helper/formatters/card_number_formatter.dart';
import 'package:prohelp_app/helper/preference/preference_manager.dart';
import 'package:prohelp_app/helper/service/api_service.dart';
import 'package:prohelp_app/helper/state/state_manager.dart';
import 'package:prohelp_app/screens/payment/payment_success.dart';

enum CardType {
  Master,
  Visa,
  Verve,
  Discover,
  AmericanExpress,
  DinersClub,
  Jcb,
  Others,
  Invalid
}

class PayToView extends StatefulWidget {
  var data;
  final PreferenceManager manager;
  final String type;
  PayToView({
    Key? key,
    required this.manager,
    required this.data,
    required this.type,
  }) : super(key: key);

  @override
  State<PayToView> createState() => _PayToViewState();
}

class _PayToViewState extends State<PayToView> {
  TextEditingController cardNumberController = TextEditingController();
  final _cvvController = TextEditingController();
  final _expiryController = TextEditingController();

  final _controller = Get.find<StateController>();

  final plugin = PaystackPlugin();
  CardType cardType = CardType.Invalid;

  final _formKey = GlobalKey<FormState>();

  bool _saveCard = false;
  // int _amountToPay = 5000;

  @override
  void initState() {
    cardNumberController.addListener(
      () {
        getCardTypeFrmNumber();
      },
    );
    plugin.initialize(publicKey: Constants.pstk);
    super.initState();
  }

  void getCardTypeFrmNumber() {
    if (cardNumberController.text.length <= 6) {
      String input = CardUtils.getCleanedNumber(cardNumberController.text);
      CardType type = CardUtils.getCardTypeFrmNumber(input);
      if (type != cardType) {
        setState(() {
          cardType = type;
        });
      }
    }
  }

  @override
  void dispose() {
    cardNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _controller.setLoading(false);

    return Obx(
      () => LoadingOverlayPro(
        isLoading: _controller.isLoading.value,
        backgroundColor: Colors.black45,
        progressIndicator: const CircularProgressIndicator.adaptive(),
        child: Scaffold(
          appBar: AppBar(
            elevation: 0.0,
            foregroundColor: Colors.black,
            backgroundColor: Constants.secondaryColor,
            automaticallyImplyLeading: false,
            leading: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 16.0,
                ),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Icon(
                    CupertinoIcons.arrow_left_circle,
                    size: 28,
                  ),
                ),
                const SizedBox(
                  width: 4.0,
                ),
              ],
            ),
          ),
          body: SafeArea(
            child: ListView(
              children: [
                Container(
                  color: Colors.grey.shade300,
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 12.0,
                      ),
                      ClipOval(
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade400,
                          ),
                          child: const Icon(
                            CupertinoIcons.creditcard_fill,
                            size: 14,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10.0,
                      ),
                      const TextInter(
                        text: "Card",
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 16.0,
                ),
                ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          "assets/images/logo_dark.svg",
                          width: 36,
                          height: 36,
                          color: Colors.grey,
                        ),
                        const SizedBox(
                          width: 16.0,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                const TextInter(text: "NGN", fontSize: 14),
                                const SizedBox(
                                  width: 4.0,
                                ),
                                TextPoppins(
                                  text: "${widget.data['amount']}",
                                  fontSize: 21,
                                  fontWeight: FontWeight.w600,
                                ),
                              ],
                            ),
                            TextInter(
                              text: "${widget.manager.getUser()['email']}",
                              fontSize: 12,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 16.0,
                    ),
                    const Divider(),
                    const SizedBox(
                      height: 16.0,
                    ),
                    const TextInter(
                      text: "Enter your card detail to pay",
                      fontSize: 14,
                      align: TextAlign.center,
                      fontWeight: FontWeight.w500,
                    ),
                    const SizedBox(
                      height: 24.0,
                    ),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: cardNumberController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(19),
                              CardNumberInputFormatter(),
                            ],
                            decoration: InputDecoration(
                              hintText: "Card number",
                              suffix: CardUtils.getCardIcon(cardType),
                            ),
                            validator: (val) {
                              if (val.toString().isEmpty || val == null) {
                                return "Card number is required";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 16.0,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  keyboardType: TextInputType.number,
                                  controller: _cvvController,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    // Limit the input
                                    LengthLimitingTextInputFormatter(4),
                                  ],
                                  decoration: const InputDecoration(
                                    hintText: "CVV",
                                    labelText: "CVV",
                                  ),
                                  validator: (val) {
                                    if (val.toString().isEmpty || val == null) {
                                      return "CVV number is required";
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextFormField(
                                  keyboardType: TextInputType.number,
                                  controller: _expiryController,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(5),
                                    CardMonthInputFormatter(),
                                  ],
                                  decoration: const InputDecoration(
                                    hintText: "MM/YY",
                                    labelText: "Expiry",
                                  ),
                                  validator: (val) {
                                    if (val.toString().isEmpty || val == null) {
                                      return "Expiry date is required";
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 16.0,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Checkbox(
                                value: _saveCard,
                                onChanged: (val) {
                                  setState(() {
                                    _saveCard = val ?? false;
                                  });
                                },
                                checkColor: Constants.golden,
                              ),
                              const TextInter(
                                text: "Remember this card next time",
                                fontSize: 13,
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 16.0,
                          ),
                          CustomButton(
                            paddingY: 16.0,
                            bgColor: Constants.primaryColor,
                            child: Text(
                              "Pay ${Constants.nairaSign(context).currencySymbol}${Constants.formatMoney(widget.data['amount'])}",
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            borderColor: Colors.transparent,
                            foreColor: Colors.black,
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _controller.setLoading(true);
                                _chargeCard();
                              }
                            },
                            variant: "Filled",
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PaymentCard _getCardFromUI() {
    // Using just the must-required parameters.
    var numb = cardNumberController.text.replaceAll(" ", "");
    var cleanedCVV = _cvvController.text.replaceAll(" ", "");
    var expiryArray = _expiryController.text.split("/");
    var expMonth = expiryArray[0];
    var expYear = expiryArray[1];

    return PaymentCard(
      number: numb,
      cvc: cleanedCVV,
      expiryMonth: int.parse(expMonth),
      expiryYear: int.parse(expYear),
    );
  }

  _getAccessCode() {
    return "${widget.manager.getUser()['email']}" +
        DateTime.now().toIso8601String();
  }

  _chargeCard() async {
    var charge = Charge()
      ..card = _getCardFromUI()
      ..amount = widget.data['amount'] * 100
      ..email = "${widget.manager.getUser()['email']}"
      ..reference = _getAccessCode();

    try {
      final response = await plugin.chargeCard(context, charge: charge);
      debugPrint(
          "CHARGE RESPONSE >> ${response.message} , ${response.reference}, ${response.status}");

      // if (response.status) {
      _fundWallet(response.reference, response.status, response.message);
      // } else {
      // _controller.setLoading(false);
      // Constants.toast(response.message);
      // Criminal record 
      // gurantor
      // Means of ID (nin, voter's card, drivers license, international passport)
      // previous work address
      // House address

      // ............
      // Disabilities
      // ............
      // }
    } catch (e) {
      debugPrint("PAYMENT ERROR >> $e");
    }
  }

  _fundWallet(ref, status, summary) async {
    Map _payload = {
      "amount": widget.data['amount'],
      "reference": ref,
      "summary": "Fund wallet: $summary",
      "userId": widget.manager.getUser()['id'],
      "type": "fund_wallet",
      "status": "$status",
    };

    try {
      final res = await APIService().topupWallet(
        _payload,
        widget.manager.getAccessToken(),
        widget.manager.getUser()['email'],
      );

      if (res.statusCode == 200) {
        _controller.onInit();

        Get.to(
          PaymentSuccess(
            data: widget.data,
            manager: widget.manager,
          ),
        );
      }

      _controller.setLoading(false);
    } catch (e) {
      debugPrint(e.toString());
      _controller.setLoading(false);
    }
  }
}

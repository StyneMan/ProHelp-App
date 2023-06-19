import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:loading_overlay_pro/loading_overlay_pro.dart';
import 'package:prohelp_app/components/button/roundedbutton.dart';
import 'package:prohelp_app/components/drawer/custom_drawer.dart';
import 'package:prohelp_app/components/inputfield/rounded_money_input.dart';
import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/helper/constants/constants.dart';
import 'package:prohelp_app/helper/preference/preference_manager.dart';
import 'package:prohelp_app/helper/state/state_manager.dart';
import 'package:prohelp_app/screens/payment/components/transaction_row.dart';
import 'package:prohelp_app/screens/payment/pay_to_view.dart';

class MyWallet extends StatefulWidget {
  final PreferenceManager manager;
  const MyWallet({
    Key? key,
    required this.manager,
  }) : super(key: key);

  @override
  State<MyWallet> createState() => _MyWalletState();
}

class _MyWalletState extends State<MyWallet> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _controller = Get.find<StateController>();
  bool _isClicked = false;
  final _amountController = TextEditingController();
  int _amount = 0;
  var _selectedVal = "";

  List coinsList = [
    {"title": '200 Coins', "amount": 500},
    {"title": '500 Coins', "amount": 1000},
    {"title": '800 Coins', "amount": 1500},
    {"title": '1000 Coins', "amount": 1800},
  ];

  _pluralize(int num) {
    return num > 1 ? "s" : "";
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => LoadingOverlayPro(
        isLoading: _controller.isLoading.value,
        backgroundColor: Colors.black45,
        progressIndicator: const CircularProgressIndicator.adaptive(),
        child: Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            elevation: 0.0,
            foregroundColor: Constants.secondaryColor,
            backgroundColor: Constants.primaryColor,
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
                  ),
                ),
                const SizedBox(
                  width: 4.0,
                ),
              ],
            ),
            title: TextPoppins(
              text: "my wallet".toUpperCase(),
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Constants.secondaryColor,
            ),
            centerTitle: true,
            actions: [
              IconButton(
                onPressed: () {
                  if (!_scaffoldKey.currentState!.isEndDrawerOpen) {
                    _scaffoldKey.currentState!.openEndDrawer();
                  }
                },
                icon: SvgPicture.asset(
                  'assets/images/menu_icon.svg',
                  color: Constants.secondaryColor,
                ),
              ),
            ],
          ),
          endDrawer: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: CustomDrawer(
              manager: widget.manager,
            ),
          ),
          body: Obx(
            () => _controller.userData.value.isEmpty
                ? const SizedBox()
                : ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      const SizedBox(
                        height: 16.0,
                      ),
                      const SizedBox(
                        height: 16.0,
                      ),
                      Column(
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
                            height: 24.0,
                          ),
                          _isClicked
                              ? const SizedBox()
                              : SizedBox(
                                  width: 144,
                                  child: RoundedButton(
                                    bgColor: Constants.primaryColor,
                                    child: const TextInter(
                                        text: "Top up", fontSize: 16),
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
                                      hint: Text(
                                        "Select amount",
                                        style: const TextStyle(
                                            fontSize: 18, color: Colors.black),
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
                                        contentPadding:
                                            const EdgeInsets.symmetric(
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
                                        debugPrint('NEW VAL ${newValue}');
                                        var ar = coinsList.firstWhere(
                                          (element) =>
                                              element['title'] == newValue,
                                        );
                                        debugPrint('NEW VAL ${ar['amount']}');
                                        setState(
                                          () {
                                            // _selectedVal = ar['amount'];
                                            _amountController.text =
                                                "${Constants.nairaSign(context).currencySymbol}${Constants.formatMoney(ar['amount'])}";
                                            // _city = newValue;
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
                                        String filteredAmt =
                                            amt.replaceAll(",", "");
                                        // print("SELCETD NEDWORK:: $_networkValue");
                                        // print(
                                        //     "SELCETED RATE:: ${_controller.airtimeSwapRate.value}");
                                        print(
                                            "CURRENT AMOUNT TF:: $filteredAmt");
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
                                    child: const TextInter(
                                        text: "Continue", fontSize: 16),
                                    borderColor: Constants.primaryColor,
                                    foreColor: Constants.primaryColor,
                                    onPressed: () {
                                      String? amt = _amountController.text
                                          .replaceAll("₦", "");
                                      String filteredAmt =
                                          amt.replaceAll(",", "");
                                      // print("SELCETD NEDWORK:: $_networkValue");
                                      // print(
                                      //     "SELCETED RATE:: ${_controller.airtimeSwapRate.value}");
                                      print(" AMOUNT TF:: $amt");
                                      print("CURRENT AMOUNT TF:: $filteredAmt");
                                      setState(() {
                                        _amount = int.parse(filteredAmt);
                                      });

                                      Future.delayed(
                                          const Duration(milliseconds: 1500),
                                          () {
                                        Navigator.pop(context);
                                        Get.to(
                                          PayToView(
                                            manager: widget.manager,
                                            data: {"amount": _amount},
                                            type: "wallet",
                                          ),
                                          transition: Transition.cupertino,
                                        );
                                      });
                                    },
                                    variant: "Outlined",
                                  ),
                                ),
                        ],
                      ),
                      const SizedBox(height: 21),
                      TextPoppins(
                        text: "Transactions",
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                      const SizedBox(height: 2.0),
                      ListView.separated(
                        shrinkWrap: true,
                        reverse: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) => TransactionRow(
                            data: _controller.userData.value['transactions']
                                    [index] ??
                                widget.manager.getUser()['transactions']
                                    [index]),
                        separatorBuilder: (context, index) => const Divider(),
                        itemCount: _controller
                                .userData.value['transactions'].length ??
                            widget.manager.getUser()['transactions']?.length,
                      )
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

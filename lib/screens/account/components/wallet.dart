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
            () => ListView(
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
                              child:
                                  const TextInter(text: "Top up", fontSize: 16),
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
                        ? RoundedInputMoney(
                            hintText: "Amount",
                            borderRadius: 36.0,
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
                                Navigator.pop(context);
                                Get.to(
                                  PayToView(
                                    manager: widget.manager,
                                    data: {"amount": _amount},
                                    type: "wallet",
                                  ),
                                  transition: Transition.cupertino,
                                );
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
                      data: _controller.userData.value['transactions'][index] ??
                          widget.manager.getUser()['transactions'][index]),
                  separatorBuilder: (context, index) => const Divider(),
                  itemCount:
                      _controller.userData.value['transactions'].length ??
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

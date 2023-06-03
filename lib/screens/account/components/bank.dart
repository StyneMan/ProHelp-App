import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prohelp_app/components/button/roundedbutton.dart';
import 'package:prohelp_app/components/inputfield/lineddropdown.dart';
import 'package:prohelp_app/components/inputfield/llinedtextfield.dart';
import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/data/banks/banks.dart';
import 'package:prohelp_app/helper/constants/constants.dart';
import 'package:prohelp_app/helper/state/state_manager.dart';

class Bank extends StatefulWidget {
  const Bank({Key? key}) : super(key: key);

  @override
  State<Bank> createState() => _BankState();
}

class _BankState extends State<Bank> {
  final _accNameController = TextEditingController();
  final _accNumController = TextEditingController();
  String _selectedBank = "";

  // final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final _controller = Get.find<StateController>();

  onBankSelected(val) {
    setState(() {
      _selectedBank = val;
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _accNameController.text = "Kelechi Adekunle";
      _accNumController.text = "2178005104";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: const SizedBox(),
      // child: ListView(
      //   children: [
      //     LinedTextField(
      //       label: "Account Name",
      //       onChanged: (val) {},
      //       controller: _accNameController,
      //       validator: (value) {
      //         if (value.toString().isEmpty || value == null) {
      //           return "Account name is required";
      //         }
      //         return null;
      //       },
      //       inputType: TextInputType.name,
      //       capitalization: TextCapitalization.words,
      //     ),
      //     const Divider(
      //       color: Constants.accentColor,
      //     ),
      //     const SizedBox(
      //       height: 10.0,
      //     ),
      //     LinedTextField(
      //       label: "Account Number",
      //       onChanged: (val) {},
      //       controller: _accNumController,
      //       validator: (value) {
      //         if (value.toString().isEmpty || value == null) {
      //           return "Account number is required";
      //         }
      //         return null;
      //       },
      //       inputType: TextInputType.number,
      //       capitalization: TextCapitalization.none,
      //     ),
      //     const Divider(
      //       color: Constants.accentColor,
      //     ),
      //     const SizedBox(
      //       height: 10.0,
      //     ),
      //     LinedDropdown(
      //       label: "Bank Name",
      //       onSelected: onBankSelected,
      //       items: banks,
      //     ),
      //     const Divider(
      //       color: Constants.accentColor,
      //     ),
      //     const SizedBox(
      //       height: 21.0,
      //     ),
      //     RoundedButton(
      //       bgColor: Constants.primaryColor,
      //       child: const TextInter(text: "SAVE CHANGES", fontSize: 16),
      //       borderColor: Colors.transparent,
      //       foreColor: Colors.white,
      //       onPressed: () {},
      //       variant: "Filled",
      //     ),
      //   ],
      // ),
    );
  }
}

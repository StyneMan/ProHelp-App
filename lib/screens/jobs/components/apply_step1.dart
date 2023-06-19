import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:get/instance_manager.dart';
import 'package:prohelp_app/components/inputfield/city_dropdown.dart';
import 'package:prohelp_app/components/inputfield/customdropdown.dart';
import 'package:prohelp_app/components/inputfield/state_dropdown.dart';
import 'package:prohelp_app/components/inputfield/textfield.dart';
import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/data/state/statesAndCities.dart';
import 'package:prohelp_app/helper/preference/preference_manager.dart';
import 'package:prohelp_app/helper/state/state_manager.dart';

typedef void InitCallback(Map data);

class ApplyJobStep1 extends StatefulWidget {
  final PreferenceManager manager;
  final InitCallback onStep1Completed;
  var data;
  ApplyJobStep1({
    Key? key,
    required this.data,
    required this.manager,
    required this.onStep1Completed,
  }) : super(key: key);

  @override
  State<ApplyJobStep1> createState() => _ApplyJobStep1State();
}

class _ApplyJobStep1State extends State<ApplyJobStep1> {
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  final _controller = Get.find<StateController>();

  String _selected = "Male";

  void _onSelected(String val) {
    setState(() {
      _selected = val;
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _emailController.text = widget.manager.getUser()['email'];
      _phoneController.text =
          _controller.applicationPhone.value.startsWith("+234")
              ? "0${_controller.applicationPhone.value.toString().substring(4)}"
              : _controller.applicationPhone.value;
      _selected =
          widget.manager.getUser()['bio']['gender'].toString().capitalize!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RichText(
          text: TextSpan(
            text: "You're applying for ",
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              color: Colors.black,
              fontSize: 18,
            ),
            children: [
              TextSpan(
                text: "${widget.data['jobTitle']}. ".capitalize!,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  fontSize: 18,
                ),
              ),
              const TextSpan(
                text: "Provide contact info",
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 21.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipOval(
                  child: Image.network(
                    widget.manager.getUser()['bio']['image'],
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        SvgPicture.asset(
                      "assets/images/personal_icon.svg",
                      width: 64,
                      height: 64,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              width: 8.0,
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TextPoppins(
                        text: "${widget.manager.getUser()['bio']['fullname']}"
                            .capitalize,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      const SizedBox(
                        width: 3.0,
                      ),
                    ],
                  ),
                  TextPoppins(
                    text:
                        "${widget.manager.getUser()['profession']}".capitalize,
                    fontSize: 14,
                  ),
                  Wrap(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          for (var e = 0;
                              e < widget.manager.getUser()['skills']?.length;
                              e++)
                            Container(
                              padding: const EdgeInsets.all(2.0),
                              margin: const EdgeInsets.all(1.5),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              child: TextPoppins(
                                text: widget.manager.getUser()['skills'][e]
                                    ['name'],
                                fontSize: 12,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 36.0,
        ),
        CustomTextField(
          hintText: "Email",
          onChanged: (val) {
            widget.onStep1Completed({
              "email": val,
              "phone": _phoneController.text.startsWith("0")
                  ? "+234${_phoneController.text.substring(1)}"
                  : "+234${_phoneController.text}",
            });
          },
          controller: _emailController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email';
            }
            if (!RegExp('^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]')
                .hasMatch(value)) {
              return 'Please enter a valid email';
            }
            return null;
          },
          inputType: TextInputType.emailAddress,
        ),
        const SizedBox(
          height: 16.0,
        ),
        CustomTextField(
          hintText: "Phone",
          onChanged: (val) {
            widget.onStep1Completed({
              "email": _emailController.text,
              "phone":
                  val.startsWith("0") ? "+234${val.substring(1)}" : "+234$val",
            });
          },
          controller: _phoneController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your phone number';
            }
            if (value.toString().length < 11) {
              return 'Enter a valid phone number';
            }
            return null;
          },
          inputType: TextInputType.number,
        ),
        const SizedBox(
          height: 16.0,
        ),
        CustomDropdown(
          isEnabled: false,
          onSelected: _onSelected,
          hint: _selected,
          label: "Gender",
          items: const ['Male', 'Female'],
          validator: (val) {},
        ),
        const SizedBox(
          height: 16.0,
        ),
      ],
    );
  }
}

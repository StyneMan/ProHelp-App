import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/helper/constants/constants.dart';

class GuestEducationSection extends StatelessWidget {
  final List data;
  const GuestEducationSection({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey,
          width: 0.75,
        ),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextPoppins(
            text: "Education",
            fontSize: 16,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
          const SizedBox(
            height: 10.0,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: data.isEmpty
                ? []
                : [
                    for (var e = 0; e < data.length; e++)
                      Column(
                        children: [
                          data[e]['school'].toString() == 'undefined' ||
                                  data[e]['school'].toString() == 'null'
                              ? const SizedBox()
                              : SizedBox(
                                  height: 90,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      data[e]['schoolLogo'].isEmpty
                                          ? const SizedBox()
                                          : SizedBox(
                                              width: 100,
                                              height: 200,
                                              child: Image.network(
                                                "${data[e]['schoolLogo']}",
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                        stackTrace) =>
                                                    Image.asset(
                                                  "assets/images/logo_dark.png",
                                                  color: Constants.accentColor,
                                                ),
                                              ),
                                            ),
                                      const SizedBox(
                                        width: 10.0,
                                      ),
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            TextPoppins(
                                              text: "${data[e]['school']}"
                                                  .toUpperCase(),
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            TextPoppins(
                                              text:
                                                  "${data[e]['degree']}, ${data[e]['course']}"
                                                      .capitalize,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w400,
                                            ),
                                            TextPoppins(
                                              text: data[e]['stillSchooling']
                                                  ? "Still a student"
                                                  : "Graduated ${data[e]['endate']}",
                                              fontSize: 13,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                          data[e]['school'].toString() == 'undefined' ||
                                  data[e]['school'].toString() == 'null'
                              ? const SizedBox()
                              : const Divider(),
                        ],
                      ),
                  ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prohelp_app/components/text_components.dart';

class GuestExperienceSection extends StatelessWidget {
  final List data;
  const GuestExperienceSection({
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
            text: "Experience",
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
                          SizedBox(
                            height: 90,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 100,
                                  height: 200,
                                  child: Image.network(
                                    data[e]['companyLogo'],
                                    fit: BoxFit.cover,
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
                                        text: data[e]['role'],
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      TextPoppins(
                                        text: data[e]['company'],
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                      ),
                                      TextPoppins(
                                        text:
                                            "${DateFormat('dd/MMM/yyyy').format(DateTime.parse(data[e]['startDate']))} - ${data[e]['stillHere'] ? "Present" : DateFormat('dd/MMM/yyyy').format(DateTime.parse(data[e]['endate']))}",
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                      ),
                                      TextPoppins(
                                        text:
                                            "${data[e]['region']}, ${data[e]['country']}",
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          const Divider(),
                        ],
                      ),
                  ],
          )
        ],
      ),
    );
  }
}

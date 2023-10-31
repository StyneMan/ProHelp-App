import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:page_transition/page_transition.dart';
import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/helper/preference/preference_manager.dart';
import 'package:prohelp_app/screens/user/edits/edit_experience.dart';

class ExperienceSection extends StatelessWidget {
  final List data;
  final PreferenceManager manager;
  const ExperienceSection({
    Key? key,
    required this.data,
    required this.manager,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextPoppins(
                text: "Experience",
                fontSize: 16,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
              InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    PageTransition(
                      type: PageTransitionType.size,
                      alignment: Alignment.bottomCenter,
                      child: ManageExperience(
                        manager: manager,
                        experience: [],
                      ),
                    ),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.all(5.0),
                  child: Icon(
                    Icons.edit,
                    size: 18,
                  ),
                ),
              )
            ],
          ),
          const SizedBox(
            height: 10.0,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: data.isEmpty
                ? []
                : data
                    .map(
                      (e) => Column(
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
                                    "${e['companyLogo']}",
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
                                        text: "${e['role']}".capitalize,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      TextPoppins(
                                        text: "${e['company']}".capitalize,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                      ),
                                      TextPoppins(
                                        text:
                                            "${e['startDate']} - ${e['stillHere'] ? "Present" : e['endate']}",
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                      ),
                                      TextPoppins(
                                        text:
                                            "${DateFormat('dd/MMM/yyyy').format(DateTime.parse(e['startDate']))} - ${e['stillHere'] ? "Present" : DateFormat('dd/MMM/yyyy').format(DateTime.parse(e['endate']))}",
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                      ),
                                      TextPoppins(
                                        text: "${e['region']}, ${e['country']}"
                                            .capitalize,
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
                    )
                    .toList(),
          )
        ],
      ),
    );
  }
}

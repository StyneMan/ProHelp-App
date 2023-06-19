import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:page_transition/page_transition.dart';
import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/helper/constants/constants.dart';
import 'package:prohelp_app/helper/preference/preference_manager.dart';
import 'package:prohelp_app/screens/user/edits/manage_education.dart';

class EducationSection extends StatelessWidget {
  final List data;
  final PreferenceManager manager;
  const EducationSection({
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
                text: "Education",
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
                      child: ManageEducation(
                        manager: manager,
                        education: [],
                      ),
                    ),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.edit,
                    size: 18,
                  ),
                ),
              ),
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
                          e['school'].toString() == 'undefined' ||
                                  e['school'].toString() == 'null'
                              ? const SizedBox()
                              : SizedBox(
                                  height: 90,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 100,
                                        height: 200,
                                        child: Image.network(
                                          e['schoolLogo'],
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
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
                                              text: "${e['school']}".capitalize,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            TextPoppins(
                                              text:
                                                  "${e['degree']} ${e['course']}"
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
                          e['school'].toString() == 'undefined' ||
                                  e['school'].toString() == 'null'
                              ? const SizedBox()
                              : const Divider(),
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

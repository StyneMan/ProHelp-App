import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:prohelp_app/components/drawer/custom_drawer.dart';
import 'package:prohelp_app/components/shimmer/pros_shimmer.dart';
import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/helper/constants/constants.dart';
import 'package:prohelp_app/helper/preference/preference_manager.dart';
import 'package:prohelp_app/helper/service/api_service.dart';
import 'package:prohelp_app/helper/state/state_manager.dart';
import 'package:prohelp_app/screens/jobs/components/applicant_card.dart';

class JobApplications extends StatefulWidget {
  final PreferenceManager manager;
  var data;
  JobApplications({
    Key? key,
    required this.manager,
    required this.data,
  }) : super(key: key);

  @override
  State<JobApplications> createState() => _JobApplicationsState();
}

class _JobApplicationsState extends State<JobApplications> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _controller = Get.find<StateController>();

  @override
  void initState() {
    super.initState();
    debugPrint("JOB ID ${widget.data['id']} ,  ${widget.data['id']}");
  }

  Stream<List<dynamic>> fetchDataStream() {
    final controller = StreamController<List<dynamic>>();
    APIService()
        .getJobApplicationsStreamed(
            accessToken: widget.manager.getAccessToken(),
            email: widget.manager.getUser()['email'],
            jobId: widget.data['id'])
        .then((resp) {
      debugPrint("DEBUG PRINT :: ${resp}");
      return controller.add(resp);
    }).catchError((error) => controller.addError(error));
    return controller.stream;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          text: "Job Applicants".toUpperCase(),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Center(
                child: Wrap(
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextPoppins(
                      text: "Job Applicants for ",
                      fontSize: 16,
                      align: TextAlign.center,
                    ),
                    TextPoppins(
                      text: "${widget.data['jobTitle']}".toUpperCase(),
                      fontSize: 17,
                      softWrap: true,
                      fontWeight: FontWeight.w500,
                      align: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 21.0,
            ),
            Expanded(
              child: StreamBuilder<List<dynamic>>(
                stream: fetchDataStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return ListView.separated(
                      itemBuilder: (context, index) => const ProsShimmer(),
                      separatorBuilder: (context, index) => const Divider(),
                      itemCount: 3,
                    );
                  } else if (!snapshot.hasData) {
                    return SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset('assets/images/empty.png'),
                            const Text(
                              "No applications found",
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return const Center(
                      child: TextInter(
                          text:
                              "An error occured. Check your internet connection",
                          fontSize: 16),
                    );
                  } else {
                    final mdata = snapshot.data!;
                    debugPrint("APPLICAT DATA  $mdata");

                    return ListView.separated(
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        final item = mdata[index];
                        return ApplicantCard(
                          data: item,
                          index: index,
                          manager: widget.manager,
                        );
                      },
                      separatorBuilder: (context, index) => const Divider(),
                      itemCount: mdata.length,
                    );
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

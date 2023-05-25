import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/instance_manager.dart';
import 'package:http/http.dart' as http;
import 'package:prohelp_app/components/drawer/custom_drawer.dart';
import 'package:prohelp_app/components/search/search_delegate.dart';
import 'package:prohelp_app/components/shimmer/banner_shimmer.dart';
import 'package:prohelp_app/components/shimmer/product_shimmer.dart';
import 'package:prohelp_app/components/shimmer/pros_shimmer.dart';
import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/helper/constants/constants.dart';
import 'package:prohelp_app/helper/preference/preference_manager.dart';
import 'package:prohelp_app/helper/service/api_service.dart';
import 'package:prohelp_app/helper/state/state_manager.dart';
import 'package:prohelp_app/screens/pros/components/all_pros.dart';
import 'package:prohelp_app/screens/pros/components/hired_pros.dart';
import 'package:prohelp_app/screens/pros/components/saved_pros.dart';

class Pros extends StatefulWidget {
  final PreferenceManager manager;
  const Pros({
    Key? key,
    required this.manager,
  }) : super(key: key);

  @override
  State<Pros> createState() => _ProsState();
}

class _ProsState extends State<Pros> with SingleTickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _controller = Get.find<StateController>();
  final _user = FirebaseAuth.instance.currentUser;

  late TabController tabController;

  @override
  void initState() {
    tabController = TabController(length: 3, vsync: this);
    super.initState();
    // _controller.setLoading(true);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
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
                showSearch(
                  context: context,
                  // delegate to customize the search bar
                  delegate: CustomSearchDelegate(
                    manager: widget.manager,
                  ),
                );
              },
              child: const Icon(
                CupertinoIcons.search,
                size: 28,
              ),
            ),
            const SizedBox(
              width: 4.0,
            ),
          ],
        ),
        title: TextPoppins(
          text: widget.manager.getUser()['accountType'] != "recruiter"
              ? "Recruiters".toUpperCase()
              : "Professionals".toUpperCase(),
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Constants.secondaryColor,
        ),
        centerTitle: true,
        // bottom: TabBar(
        //   unselectedLabelColor: Colors.grey,
        //   padding: const EdgeInsets.symmetric(horizontal: 10.0),
        //   indicator: const BoxDecoration(
        //     color: Constants.primaryColor,
        //   ), //Change background color from here
        //   tabs: [
        //     Padding(
        //       padding: const EdgeInsets.all(8.0),
        //       child: TextPoppins(
        //         text: "All",
        //         fontSize: 16,
        //         fontWeight: FontWeight.w600,
        //       ),
        //     ),
        //     Padding(
        //       padding: const EdgeInsets.all(8.0),
        //       child: TextPoppins(
        //         text: "Saved",
        //         fontSize: 16,
        //         fontWeight: FontWeight.w600,
        //       ),
        //     ),
        //     Padding(
        //       padding: const EdgeInsets.all(8.0),
        //       child: TextPoppins(
        //         text: "Hired",
        //         fontSize: 16,
        //         fontWeight: FontWeight.w600,
        //       ),
        //     ),
        //   ],
        // ),
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child:
              // FutureBuilder<http.Response>(
              //     future: APIService().getFreelancers(
              //         widget.manager.getAccessToken(),
              //         widget.manager.getUser()['email']),
              //     builder: (context, snapshot) {
              //       // if (snapshot.connectionState == ConnectionState.waiting) {
              //   return ListView(
              //     children: [
              //       Row(
              //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //         crossAxisAlignment: CrossAxisAlignment.center,
              //         children: const [
              //           Expanded(
              //             child: SizedBox(
              //               height: 60,
              //               child: BannerShimmer(),
              //             ),
              //           ),
              //           Expanded(
              //             child: SizedBox(
              //               height: 60,
              //               child: BannerShimmer(),
              //             ),
              //           ),
              //           Expanded(
              //             child: SizedBox(
              //               height: 60,
              //               child: BannerShimmer(),
              //             ),
              //           ),
              //         ],
              //       ),
              //       const SizedBox(height: 21.0,),
              //       ListView.separated(
              //         shrinkWrap: true,
              //         itemCount: 3,
              //         separatorBuilder: (BuildContext context, int index) {
              //           return const SizedBox(height: 32.0);
              //         },
              //         itemBuilder: (BuildContext context, int index) {
              //           return const ProsShimmer();
              //         },
              //       ),
              //     ],
              //   );
              // }
              // if (snapshot.hasError) {
              //   // Future.delayed(const Duration(seconds: 3), () {
              //   //   _controller.setLoading(false);
              //   // });
              //   return const Center(
              //     child: Text(
              //       "An error occured\nCheck your internet connection!",
              //     ),
              //   );
              // }

              // final data = snapshot.data;
              // Map<String, dynamic> map = jsonDecode(data!.body);
              // Future.delayed(const Duration(seconds: 3), () {
              //   // _controller.setLoading(false);
              //   _controller.freelancers.value = map['data'];
              // });

              Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10.0),
              SizedBox(
                // height: 50,
                width: MediaQuery.of(context).size.height,
                child: Column(
                  children: [
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(5),
                      child: TabBar(
                        unselectedLabelColor: Colors.grey,
                        labelColor: Colors.white,
                        indicatorColor: Constants.primaryColor,
                        indicatorWeight: 3,
                        indicator: BoxDecoration(
                          color: Constants.primaryColor,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        controller: tabController,
                        tabs: [
                          Tab(
                            child: TextPoppins(text: "All", fontSize: 16),
                          ),
                          Tab(
                            child: TextPoppins(text: "Saved", fontSize: 16),
                          ),
                          Tab(
                            child: TextPoppins(
                                text: widget.manager.getUser()['accountType'] !=
                                        "recruiter"
                                    ? "Engaged"
                                    : "Hired",
                                fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: tabController,
                  children: [
                    AllProfessionals(
                      manager: widget.manager,
                    ),
                    SavedProfessionals(
                      manager: widget.manager,
                    ),
                    HiredProfessionals(
                      manager: widget.manager,
                    )
                  ],
                ),
              )
            ],
            // );
            // })
            // ,
          ),
        ),
      ),
    );
  }
}

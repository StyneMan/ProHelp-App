import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:prohelp_app/components/drawer/custom_drawer.dart';
import 'package:prohelp_app/components/shimmer/banner_shimmer.dart';
import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/helper/constants/constants.dart';
import 'package:prohelp_app/helper/preference/preference_manager.dart';
import 'package:prohelp_app/helper/state/state_manager.dart';
import 'package:prohelp_app/screens/categories/view_category.dart';

import 'components/home_slider.dart';

class Pros extends StatelessWidget {
  final PreferenceManager manager;
  Pros({
    Key? key,
    required this.manager,
  }) : super(key: key);

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        elevation: 0.0,
        foregroundColor: Constants.secondaryColor,
        backgroundColor: Constants.primaryColor,
        automaticallyImplyLeading: false,
        title: TextPoppins(
          text: "Hello ${manager.getUser()['bio']['firstname']}",
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Constants.secondaryColor,
        ),
        centerTitle: false,
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
          manager: manager,
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            const HomeSlider(),
            const SizedBox(height: 16.0),
            Container(
              padding: const EdgeInsets.all(2.0),
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextPoppins(
                    text: "CATEGORIES",
                    fontSize: 16,
                    color: const Color(0xFF939BAC),
                  ),
                  const SizedBox(width: 12.0),
                  const Expanded(
                    child: Divider(
                      thickness: 2.0,
                      color: Color(0xFF8A95BF),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5.0),
            GetBuilder<StateController>(builder: (controller) {
              if (controller.allProfessions.isEmpty) {
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 6,
                  itemBuilder: (context, index) => const SizedBox(
                    height: 256,
                    child: BannerShimmer(),
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.75,
                  ),
                );
              }
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.allProfessions.length,
                itemBuilder: (context, index) => InkWell(
                  onTap: () {
                    // print("JUST CLICKED HERE RITANOL !!");
                    Get.to(
                      ViewCategory(
                        title:
                            '${controller.allProfessions.value[index]['name']}',
                        data: controller.allProfessions.value[index],
                        manager: manager,
                      ),
                      transition: Transition.cupertino,
                    );
                  },
                  child: Stack(
                    children: <Widget>[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4.0),
                        child: CachedNetworkImage(
                          imageUrl:
                              "${controller.allProfessions.value[index]['image']}",
                          progressIndicatorBuilder: (context, url, prog) =>
                              const Center(
                            child: BannerShimmer(),
                          ),
                          fit: BoxFit.cover,
                          height: 300,
                          width: double.infinity,
                          errorWidget: (context, err, st) => const Center(
                            child: BannerShimmer(),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0.0,
                        left: 0.0,
                        right: 0.0,
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color.fromARGB(200, 0, 0, 0),
                                Color.fromARGB(0, 0, 0, 0)
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 16.0,
                            horizontal: 8.0,
                          ),
                          child: TextPoppins(
                            text:
                                "${controller.allProfessions.value[index]['name']}",
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.75,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

/* 
Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
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
                      padding: const EdgeInsets.all(3),
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
                            child: TextPoppins(text: "All", fontSize: 13),
                          ),
                          Tab(
                            child: TextPoppins(text: "Saved", fontSize: 13),
                          ),
                          Tab(
                            child: TextPoppins(
                                text: widget.manager.getUser()['accountType'] !=
                                        "recruiter"
                                    ? "Connection"
                                    : "Hired",
                                fontSize: 13),
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
          ),
        ),
*/
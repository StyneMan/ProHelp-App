import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:prohelp_app/components/button/roundedbutton.dart';
import 'package:prohelp_app/components/drawer/custom_drawer.dart';
import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/forms/job/add_job_form.dart';
import 'package:prohelp_app/helper/constants/constants.dart';
import 'package:prohelp_app/helper/preference/preference_manager.dart';
import 'package:prohelp_app/helper/state/state_manager.dart';
import 'package:prohelp_app/screens/account/components/wallet.dart';
import 'package:prohelp_app/screens/jobs/components/all_jobs.dart';
import 'package:prohelp_app/screens/jobs/components/job_card.dart';
import 'package:prohelp_app/screens/jobs/components/saved_jobs.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'components/applied_jobs.dart';

class Jobs extends StatefulWidget {
  final PreferenceManager manager;
  var stateController;
  Jobs({
    Key? key,
    required this.manager,
    required this.stateController,
  }) : super(key: key);

  @override
  State<Jobs> createState() => _JobsState();
}

class _JobsState extends State<Jobs> with SingleTickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _controller = Get.find<StateController>();

  late TabController tabController;
  Map<String, dynamic> _userData = {};

  _init() async {
    final _prefs = await SharedPreferences.getInstance();
    var user = _prefs.getString("user") ?? "";
    var _token = _prefs.getString("accessToken") ?? "";
    print("USER ::: $user");
    if (user.isNotEmpty) {
      _userData = jsonDecode(user);
    }
  }

  @override
  void initState() {
    tabController = TabController(length: 3, vsync: this);
    super.initState();
    _init();
    // _controller.setLoading(true);
    // debugPrint("USER TEST :: ${_getUser()}");
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
            ClipOval(
              child: Image.network(
                "${widget.manager.getUser()['bio']['image']}",
                errorBuilder: (context, error, stackTrace) => const Icon(
                    CupertinoIcons.person_alt,
                    size: 21,
                    color: Colors.white),
                width: 36,
                height: 36,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(
              width: 4.0,
            ),
          ],
        ),
        title: TextPoppins(
          text: "jobs".toUpperCase(),
          fontSize: 16,
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
      body: widget.manager.getUser().isEmpty
          ? const SizedBox()
          : widget.manager.getUser()['accountType'] == 'professional'
              ? Padding(
                  padding: const EdgeInsets.all(16.0),
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
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: TabBar(
                                unselectedLabelColor: Colors.grey,
                                labelColor: Colors.white,
                                indicatorColor: Constants.primaryColor,
                                indicatorWeight: 3,
                                indicator: BoxDecoration(
                                  color: Constants.primaryColor,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                labelPadding: const EdgeInsets.all(0.0),
                                controller: tabController,
                                tabs: [
                                  Tab(
                                    child:
                                        TextPoppins(text: "All", fontSize: 13),
                                  ),
                                  Tab(
                                    child: TextPoppins(
                                        text: "Applied", fontSize: 13),
                                  ),
                                  Tab(
                                    child: TextPoppins(
                                      text: "Saved",
                                      fontSize: 13,
                                    ),
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
                            AllJobs(
                              manager: widget.manager,
                            ),
                            AppliedJobs(
                              manager: widget.manager,
                            ),
                            SavedJobs(
                              manager: widget.manager,
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                )
              : _controller.userData.isEmpty
                  ? const SizedBox()
                  : Obx(
                      () => ListView(
                        shrinkWrap: true,
                        padding: const EdgeInsets.all(16.0),
                        children: [
                          const Text(
                            "Post your job here. You have a minimum of 5 free jobs posting slot after which, you'll have to pay to post a job.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(
                            height: 16.0,
                          ),
                          SizedBox(
                            height: 60,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 144,
                                  child: RoundedButton(
                                    bgColor: Constants.primaryColor,
                                    child: const TextInter(
                                      text: "Post new job",
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                    borderColor: Colors.transparent,
                                    foreColor: Colors.white,
                                    onPressed: (_controller.userData
                                                    .value['jobCount'] ??
                                                0) >=
                                            5
                                        ? (_controller.userData.value['wallet']
                                                        ['balance'] ??
                                                    0) >=
                                                200
                                            ? () {
                                                Get.to(
                                                  AddJobForm(
                                                    manager: widget.manager,
                                                    hasPayment: true,
                                                  ),
                                                  transition:
                                                      Transition.cupertino,
                                                );
                                              }
                                            : () {
                                                //Show out of coins alert here
                                                Constants.toast(
                                                    "You are out of coins. Topup to continue posting and connecting!");
                                                Get.to(
                                                  MyWallet(
                                                      manager: widget.manager),
                                                  transition:
                                                      Transition.cupertino,
                                                );
                                              }
                                        : () {
                                            Get.to(
                                              AddJobForm(
                                                manager: widget.manager,
                                              ),
                                              transition: Transition.cupertino,
                                            );
                                          },
                                    variant: "Filled",
                                  ),
                                ),
                                const SizedBox(
                                  width: 6.0,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    const SizedBox(
                                      width: 10.0,
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const Text(
                                          "Count",
                                          style: TextStyle(
                                            color: Constants.primaryColor,
                                          ),
                                        ),
                                        Text(
                                          "${_controller.userData.value['jobCount'] ?? 0}",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 21,
                                            color: Constants.primaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      width: 10.0,
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const Text(
                                          "Jobs",
                                          style: TextStyle(
                                              color: Constants.primaryColor),
                                        ),
                                        Text(
                                          "${_controller.myJobs.value.length}",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 21,
                                            color: Constants.primaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      width: 10.0,
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const Text(
                                          "Active",
                                          style: TextStyle(
                                              color: Constants.primaryColor),
                                        ),
                                        Text(
                                          "${_controller.myJobs.value.where((element) => element['jobStatus'] == "accepting").length}",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 21,
                                            color: Constants.primaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          Row(
                            children: [
                              Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Coins Balance",
                                    style: TextStyle(
                                        color: Constants.primaryColor),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Image.asset("assets/images/coin_gold.png",
                                          width: 40),
                                      Text(
                                        "${Constants.formatMoney(_controller.userData.value['wallet']['balance'] ?? 0)}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 21,
                                          color: Constants.primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(
                                width: 16,
                              ),
                              Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text(
                                    "Prev Balance",
                                    style: TextStyle(
                                        color: Constants.primaryColor),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        "assets/images/coin_blue.png",
                                        width: 40,
                                      ),
                                      Text(
                                        "${Constants.formatMoney(_controller.userData.value['wallet']['prevBalance'] ?? 0)}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 21,
                                          color: Constants.primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Divider(),
                          const SizedBox(
                            height: 10.0,
                          ),
                          TextPoppins(
                            text: "Recently Posted",
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                          const SizedBox(
                            height: 8.0,
                          ),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) => JobCard(
                                data: _controller.myJobs.value[index],
                                index: index,
                                manager: widget.manager),
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 21),
                            itemCount: _controller.myJobs.length,
                          ),
                        ],
                      ),
                    ),
    );
  }
}

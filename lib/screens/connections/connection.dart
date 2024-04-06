import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_overlay_pro/loading_overlay_pro.dart';
import 'package:prohelp_app/components/drawer/custom_drawer.dart';
import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/helper/constants/constants.dart';
import 'package:prohelp_app/helper/preference/preference_manager.dart';
import 'package:prohelp_app/helper/state/state_manager.dart';
import 'package:prohelp_app/screens/connections/manage_connections.dart';
import 'package:prohelp_app/screens/connections/past_connections.dart';

class Connection extends StatefulWidget {
  final PreferenceManager manager;
  final String caller;
  var data;
  Connection({
    Key? key,
    required this.manager,
    required this.caller,
    this.data,
  }) : super(key: key);

  @override
  State<Connection> createState() => _ConnectionState();
}

class _ConnectionState extends State<Connection>
    with SingleTickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _controller = Get.find<StateController>();

  late TabController tabController;

  @override
  void initState() {
    tabController = TabController(length: 2, vsync: this);
    super.initState();
    // _init();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => LoadingOverlayPro(
        isLoading: _controller.isLoading.value,
        backgroundColor: Colors.black38,
        progressIndicator: const CircularProgressIndicator.adaptive(),
        child: Scaffold(
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
              text: "Connections".toUpperCase(),
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Constants.secondaryColor,
            ),
            centerTitle: true,
          ),
          endDrawer: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: CustomDrawer(
              manager: widget.manager,
            ),
          ),
          body: SafeArea(
            child: Padding(
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
                                child: TextPoppins(
                                  text: "Connections",
                                  fontSize: 13,
                                ),
                              ),
                              Tab(
                                child: TextPoppins(
                                  text: "Past Connections",
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
                        ManageConnections(
                          manager: widget.manager,
                          caller: widget.caller,
                          data: widget.data,
                        ),
                        PastConnections(
                          manager: widget.manager,
                          caller: widget.caller,
                          data: widget.data,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get/instance_manager.dart';
import 'package:loading_overlay_pro/loading_overlay_pro.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:prohelp_app/components/drawer/custom_drawer.dart';
import 'package:prohelp_app/components/picker/img_picker.dart';
import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/helper/constants/constants.dart';
import 'package:prohelp_app/helper/preference/preference_manager.dart';
import 'package:prohelp_app/helper/state/state_manager.dart';
import 'package:prohelp_app/screens/account/components/nok.dart';
import 'package:prohelp_app/screens/account/components/personal.dart';


class PersonalInfo extends StatefulWidget {
  final PreferenceManager manager;
  const PersonalInfo({
    Key? key,
    required this.manager,
  }) : super(key: key);

  @override
  State<PersonalInfo> createState() => _PersonalInfoState();
}

class _PersonalInfoState extends State<PersonalInfo>
    with SingleTickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _controller = Get.find<StateController>();

  bool _isImagePicked = false;
  var _croppedFile;

  late TabController tabController;

  @override
  void initState() {
    tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  _onImageSelected(var file) {
    setState(() {
      _isImagePicked = true;
      _croppedFile = file;
    });
    debugPrint("VALUIE::: :: $file");
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => LoadingOverlayPro(
        isLoading: _controller.isLoading.value,
        backgroundColor: Colors.black45,
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
              text: "personal information".toUpperCase(),
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
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          ClipOval(
                            child: _isImagePicked
                                ? Container(
                                    height: 120,
                                    width: 120,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(60),
                                    ),
                                    child: Image.file(
                                      File(_croppedFile),
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              ClipOval(
                                        child: SvgPicture.asset(
                                          "assets/images/personal.svg",
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Container(
                                    height: 128,
                                    width: 128,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(64),
                                    ),
                                    child: Image.network(
                                      "${widget.manager.getUser()['bio']['image']}",
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              ClipOval(
                                        child: SvgPicture.asset(
                                          "assets/images/personal.svg",
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                          ),
                          Positioned(
                            bottom: 12,
                            right: -3,
                            child: CircleAvatar(
                              backgroundColor: Constants.primaryColor,
                              child: IconButton(
                                onPressed: () {
                                  showBarModalBottomSheet(
                                    expand: false,
                                    context: context,
                                    topControl: ClipOval(
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                          child: const Center(
                                            child: Icon(
                                              Icons.close,
                                              size: 24,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    backgroundColor: Colors.white,
                                    builder: (context) => SizedBox(
                                      height: 175,
                                      child: ImgPicker(
                                        onCropped: _onImageSelected,
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.add_a_photo_outlined,
                                  color: Constants.secondaryColor,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.60,
                        child: TextPoppins(
                          text:
                              "Fill out the form below to change your password.",
                          fontSize: 14,
                          align: TextAlign.center,
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 18.0,
                ),
                widget.manager
                            .getUser()['accountType']
                            .toString()
                            .toLowerCase() ==
                        "recruiter"
                    ? const SizedBox()
                    : SizedBox(
                        // height: 50,
                        width: MediaQuery.of(context).size.height,
                        child: Column(
                          children: [
                            Container(
                              color: const Color(0xFFF0F0F4),
                              padding: const EdgeInsets.all(5.0),
                              margin: const EdgeInsets.all(0.5),
                              child: TabBar(
                                unselectedLabelColor: Colors.grey,
                                labelColor: Constants.primaryColor,
                                indicatorColor: Constants.secondaryColor,
                                indicatorWeight: 3,
                                indicator: BoxDecoration(
                                  color: Constants.secondaryColor,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                controller: tabController,
                                tabs: [
                                  Tab(
                                    child: TextPoppins(
                                      text: "Personal",
                                      fontSize: 13,
                                    ),
                                  ),
                                  // Tab(
                                  //   child:
                                  //       TextPoppins(text: "Bank", fontSize: 13),
                                  // ),
                                  Tab(
                                    child: TextPoppins(
                                      text: "Guarantor",
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
                  child: widget.manager
                              .getUser()['accountType']
                              .toString()
                              .toLowerCase() ==
                          "recruiter"
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Personal(manager: widget.manager),
                        )
                      : TabBarView(
                          physics: const NeverScrollableScrollPhysics(),
                          controller: tabController,
                          children: [
                            Personal(
                              manager: widget.manager,
                            ),
                            // const Bank(),
                            NOK(
                              manager: widget.manager,
                            ),
                          ],
                        ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:loading_overlay_pro/loading_overlay_pro.dart';
import 'package:prohelp_app/components/drawer/custom_drawer.dart';
import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/forms/support/support.dart';
import 'package:prohelp_app/helper/constants/constants.dart';
import 'package:prohelp_app/helper/preference/preference_manager.dart';
import 'package:prohelp_app/helper/state/state_manager.dart';

class ContactSupport extends StatelessWidget {
  final PreferenceManager manager;
  ContactSupport({
    Key? key,
    required this.manager,
  }) : super(key: key);

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final _controller = Get.find<StateController>();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => LoadingOverlayPro(
        isLoading: _controller.isLoading.value,
        progressIndicator: const CircularProgressIndicator.adaptive(),
        backgroundColor: Colors.black54,
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
              text: "SUPPORT",
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
              manager: manager,
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              const SizedBox(
                height: 16.0,
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipOval(
                      child: Container(
                        height: 128,
                        width: 128,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(64),
                        ),
                        child: ClipOval(
                          child: SvgPicture.asset(
                            "assets/images/support.svg",
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 16.0,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.6,
                      child: TextPoppins(
                        text:
                            "Contact our support team by filling out the form below.",
                        fontSize: 14,
                        align: TextAlign.center,
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 21.0,
              ),
               SupportForm(manager: manager,),
            ],
          ),
        ),
      ),
    );
  }
}


import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/forms/forgotPassword/passwordform.dart';
import 'package:prohelp_app/helper/constants/constants.dart';
import 'package:prohelp_app/helper/state/state_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_overlay_pro/loading_overlay_pro.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class ForgotPassword extends StatefulWidget {
// final PreferenceManager manager;
  const ForgotPassword({
    Key? key,
  }) : super(key: key);

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _controller = Get.find<StateController>();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => LoadingOverlayPro(
        isLoading: _controller.isLoading.value,
        progressIndicator: const CircularProgressIndicator.adaptive(),
        backgroundColor: Colors.black54,
        child: Scaffold(
          body: Stack(
            clipBehavior: Clip.none,
            children: [
              SlidingUpPanel(
                maxHeight: MediaQuery.of(context).size.height * 0.64,
                minHeight: MediaQuery.of(context).size.height * 0.64,
                parallaxEnabled: true,
                defaultPanelState: PanelState.OPEN,
                renderPanelSheet: true,
                parallaxOffset: .5,
                body: Container(
                  color: Constants.primaryColor,
                  width: double.infinity,
                  height: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.48,
                          child: Image.asset(
                            'assets/images/forgot_pass_img.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 40,
                        left: 8.0,
                        child: IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(
                            CupertinoIcons.arrow_left_circle,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                panelBuilder: (sc) => _panel(sc),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24.0),
                  topRight: Radius.circular(24.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _panel(ScrollController sc) {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(18),
          topRight: Radius.circular(18),
        ),
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                width: double.infinity,
                height: 75,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  image: const DecorationImage(
                      image: AssetImage(
                        "assets/images/bottom_mark.png",
                      ),
                      fit: BoxFit.cover),
                ),
              ),
            ),
            ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: [
                const SizedBox(
                  height: 21,
                ),
                TextPoppins(
                  text: "FORGOT PASSWORD",
                  fontSize: 21,
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
                const SizedBox(
                  height: 18,
                ),
                const Text(
                  "Please enter email linked to your \naccount.",
                  softWrap: true,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black54,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(
                  height: 24.0,
                ),
                const PasswordForm(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

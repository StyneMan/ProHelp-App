import 'dart:io';

import 'package:prohelp_app/components/drawer/custom_drawer.dart';
import 'package:prohelp_app/components/picker/img_picker.dart';
import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/forms/profile/editprofileform.dart';
import 'package:prohelp_app/helper/constants/constants.dart';
import 'package:prohelp_app/helper/preference/preference_manager.dart';
import 'package:prohelp_app/helper/state/state_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/instance_manager.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class EditProfile extends StatefulWidget {
  final PreferenceManager manager;
  const EditProfile({
    Key? key,
    required this.manager,
  }) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _controller = Get.find<StateController>();

  bool _isImagePicked = false;
  var _croppedFile;

  _onImageSelected(var file) {
    setState(() {
      _isImagePicked = true;
      _croppedFile = file;
    });
    print("VALUIE::: :: $file");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        elevation: 0.0,
        foregroundColor: Constants.primaryColor,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: TextPoppins(
          text: "Edit PROFILE".toUpperCase(),
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Constants.secondaryColor,
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(
            CupertinoIcons.arrow_left_circle_fill,
            color: Colors.black,
            size: 28,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              if (!_scaffoldKey.currentState!.isEndDrawerOpen) {
                _scaffoldKey.currentState!.openEndDrawer();
              }
            },
            icon: SvgPicture.asset(
              'assets/images/menu_icon.svg',
              color: Colors.white,
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
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipOval(
                  child: _isImagePicked
                      ? Container(
                          height: 128,
                          width: 129,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(64),
                          ),
                          child: Image.file(
                            File(_croppedFile),
                            errorBuilder: (context, error, stackTrace) =>
                                ClipOval(
                              child: SvgPicture.asset(
                                  "assets/images/user_icon.svg",
                                  fit: BoxFit.cover,),
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
                            "${_controller.userData.value['photo']}",
                            errorBuilder: (context, error, stackTrace) =>
                                ClipOval(
                              child: SvgPicture.asset(
                                "assets/images/user_icon.svg",
                                fit: BoxFit.cover,
                              ),
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
                TextButton(
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
                  child: TextPoppins(
                    text: "Change Picture",
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Constants.primaryColor,
                  ),
                )
              ],
            ),
          ),
          const SizedBox(
            height: 18.0,
          ),
          ProfileForm(
            manager: widget.manager,
            croppedFile: _croppedFile,
          ),
        ],
      ),
    );
  }
}

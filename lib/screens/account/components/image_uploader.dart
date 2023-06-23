import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:prohelp_app/components/picker/img_picker.dart';
import 'package:prohelp_app/helper/constants/constants.dart';
import 'package:prohelp_app/helper/state/state_manager.dart';

class ImageUploader extends StatefulWidget {
  const ImageUploader({Key? key}) : super(key: key);

  @override
  State<ImageUploader> createState() => _ImageUploaderState();
}

class _ImageUploaderState extends State<ImageUploader> {
  final _controller = Get.find<StateController>();
  bool _isImagePicked = false;
  String _croppedFile = "";

  _onImageSelected(var file) {
    setState(() {
      _isImagePicked = true;
      _croppedFile = file;
    });
    debugPrint("VALUIE::: :: $file");
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ClipOval(
          child: _isImagePicked
              ? Obx(
                  () => Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(64),
                    ),
                    child: Image.file(
                      File(_controller.croppedPic.value),
                      errorBuilder: (context, error, stackTrace) => ClipOval(
                        child: SvgPicture.asset(
                          "assets/images/personal.svg",
                          fit: BoxFit.cover,
                        ),
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              : Container(
                  height: 128,
                  width: 128,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(64),
                  ),
                  child: Image.network(
                    "kjj",
                    errorBuilder: (context, error, stackTrace) => ClipOval(
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
    );
  }
}

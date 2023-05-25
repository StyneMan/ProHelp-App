import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/helper/constants/constants.dart';
import 'package:prohelp_app/helper/state/state_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/instance_manager.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

typedef InitCallback(params);

class ImgPicker extends StatefulWidget {
  final InitCallback onCropped;
  const ImgPicker({
    Key? key,
    required this.onCropped,
  }) : super(key: key);

  @override
  State<ImgPicker> createState() => _ImgPickerState();
}

class _ImgPickerState extends State<ImgPicker> {
  // File? _photo;

  final ImagePicker _picker = ImagePicker();
  final _controller = Get.find<StateController>();

  Future imgFromGallery() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

      // setState(() {
      if (pickedFile != null) {
        //Now crop image
        final croppedFile = await ImageCropper().cropImage(
          sourcePath: pickedFile.path,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9
          ],
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Image Cropper',
              toolbarColor: Constants.primaryColor,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false,
            ),
            IOSUiSettings(
              title: 'Image Cropper',
            ),
            WebUiSettings(
              context: context,
            ),
          ],
        );

        // croppedFile.path

        widget.onCropped(croppedFile?.path);
        _controller.croppedPic.value = "${croppedFile?.path}";

        Future.delayed(const Duration(milliseconds: 200), () {
          Navigator.of(context).pop();
        });
      } else {
        debugPrint('No image selected.');
      }
    } catch (e) {
      debugPrint("IMAGE CROP ERR: ${e.toString()}");
    }
    // });
  }

  Future imgFromCamera() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.camera);

      // setState(() {
      if (pickedFile != null) {
        //Now crop image
        final croppedFile = await ImageCropper().cropImage(
          sourcePath: pickedFile.path,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9
          ],
          uiSettings: [
            AndroidUiSettings(
                toolbarTitle: 'Image Cropper',
                toolbarColor: Constants.primaryColor,
                toolbarWidgetColor: Colors.white,
                initAspectRatio: CropAspectRatioPreset.original,
                lockAspectRatio: false),
            IOSUiSettings(
              title: 'Image Cropper',
            ),
            WebUiSettings(
              context: context,
            ),
          ],
        );

        widget.onCropped(croppedFile?.path);
        _controller.croppedPic.value = "${croppedFile?.path}";

        Future.delayed(const Duration(milliseconds: 200), () {
          Navigator.of(context).pop();
        });
      } else {
        debugPrint('No image selected.');
      }
    } catch (e) {
      debugPrint("IMAGE CROP ERR: ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.all(16.0),
      children: [
        ElevatedButton.icon(
          onPressed: () {
            // Navigator.of(context).pop();
            imgFromCamera();
          },
          icon: const Icon(CupertinoIcons.camera),
          label: TextPoppins(text: "Camera", fontSize: 13),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(10.0),
            backgroundColor: Colors.green,
          ),
        ),
        const SizedBox(
          height: 10.0,
        ),
        ElevatedButton.icon(
          onPressed: () {
            imgFromGallery();
          },
          icon: const Icon(CupertinoIcons.folder),
          label: TextPoppins(text: "Gallery", fontSize: 13),
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(10.0)),
        ),
      ],
    );
  }
}

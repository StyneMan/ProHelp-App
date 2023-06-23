import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prohelp_app/components/button/roundedbutton.dart';
import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/helper/constants/constants.dart';
import 'package:prohelp_app/helper/state/state_manager.dart';

typedef void InitCallback(Map data);

class ApplyJobStep2 extends StatefulWidget {
  var data;
  bool isError;
  final InitCallback onStep2Completed;
  ApplyJobStep2({
    Key? key,
    required this.data,
    required this.onStep2Completed,
    required this.isError,
  }) : super(key: key);

  @override
  State<ApplyJobStep2> createState() => _ApplyJobStep2State();
}

class _ApplyJobStep2State extends State<ApplyJobStep2> {
  bool _isUploaded = false;
  final _controller = Get.find<StateController>();
  final List<String> _allowedExtensions = <String>[
    '.png',
    '.docx',
    '.doc',
    '.pdf',
  ];
  double _fileSize = 0;
  var _pickedFile;
  bool _sizeError = false;

  _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      lockParentWindow: true,
      type: FileType.custom,
      dialogTitle: "Select your resume",
      allowedExtensions: ['docx', 'pdf', 'doc', 'png'],
    );

    setState(() {
      _isUploaded = true;
      _pickedFile = result?.files.first;
      _fileSize = (result?.files.first.size ?? 1000.0) /
          1000; //return size in kilobytes
    });

    if (((result?.files.first.size ?? 1000.0) / 1000) > 2048.0) {
      setState(() {
        _sizeError = true;
      });
    } else {
      setState(() {
        _sizeError = false;
      });
    }

    widget.onStep2Completed({
      "pickedFile": result!.files.first,
      "fileSize": (result.files.first.size) / 1000,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextPoppins(
          text: "Let's continue. Attach document ",
          fontSize: 21,
          fontWeight: FontWeight.w500,
          align: TextAlign.center,
        ),
        const SizedBox(
          height: 16.0,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _isUploaded
                ? Row(
                    children: [
                      _pickedFile.extension.toString().endsWith('png')
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(4.0),
                              child: Image.file(
                                File(_pickedFile.path),
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                              ),
                            )
                          : _pickedFile.extension.toString().endsWith('doc') ||
                                  _pickedFile.name.toString().endsWith('docx')
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(4.0),
                                  child: Image.asset(
                                    "assets/images/docs.png",
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : _pickedFile.extension.toString().endsWith('pdf')
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(4.0),
                                      child: Image.asset(
                                        "assets/images/pdf.png",
                                        width: 40,
                                        height: 40,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.document_scanner,
                                    ),
                      const SizedBox(
                        width: 16.0,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.70,
                        child: TextPoppins(
                          text: "${_pickedFile?.name}",
                          fontSize: 14,
                        ),
                      ),
                    ],
                  )
                : const SizedBox(),
            const SizedBox(
              height: 16.0,
            ),
            RoundedButton(
              bgColor: Colors.transparent,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.upload_file,
                    color: widget.isError || _sizeError
                        ? Colors.red
                        : Constants.primaryColor,
                  ),
                  const SizedBox(
                    width: 16.0,
                  ),
                  TextInter(
                    text: "Upload your resume",
                    fontSize: 16,
                    color: widget.isError || _sizeError
                        ? Colors.red
                        : Constants.primaryColor,
                  ),
                ],
              ),
              borderColor: widget.isError || _sizeError
                  ? Colors.red
                  : Constants.primaryColor,
              foreColor: widget.isError || _sizeError
                  ? Colors.red
                  : Constants.primaryColor,
              onPressed: () {
                _pickFile();
              },
              variant: "Outlined",
            ),
            const SizedBox(
              height: 6.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Formats: (.pdf .png .doc .docx)",
                ),
                Text(
                  "Size: ${_fileSize > 1024 ? "${(_fileSize / 1000).toStringAsFixed(2)} MB" : "$_fileSize KB"}",
                ),
              ],
            ),
            const SizedBox(
              height: 2.0,
            ),
            _sizeError
                ? SizedBox(
                    width: double.infinity,
                    child: TextRoboto(
                      text: "File size exceeds 2MB",
                      align: TextAlign.center,
                      color: Colors.red,
                      fontSize: 16,
                    ),
                  )
                : const SizedBox(),
          ],
        ),
        const SizedBox(
          height: 16.0,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextPoppins(
              text: "Requirements",
              fontSize: 21,
              fontWeight: FontWeight.w500,
              align: TextAlign.center,
            ),
            const SizedBox(
              height: 8.0,
            ),
            for (var m = 0; m < widget.data['requirements']?.length; m++)
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${m + 1}."),
                    const SizedBox(
                      width: 8.0,
                    ),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.start,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.80,
                          child: Text(
                            "${widget.data['requirements'][m]}",
                            style: const TextStyle(fontSize: 17),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
          ],
        ),
      ],
    );
  }
}

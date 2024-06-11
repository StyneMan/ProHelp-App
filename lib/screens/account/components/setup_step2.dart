import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prohelp_app/components/button/roundedbutton.dart';
import 'package:prohelp_app/components/inputfield/customdropdown.dart';
import 'package:prohelp_app/components/inputfield/textfield.dart';
import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/data/relationships/relationships.dart';
import 'package:prohelp_app/helper/constants/constants.dart';
import 'package:prohelp_app/helper/state/state_manager.dart';

typedef MCallback = void Function(Map data);

class SetupStep2 extends StatefulWidget {
  MCallback onStep2Completed;
  bool isError;
  SetupStep2({
    Key? key,
    required this.onStep2Completed,
    required this.isError,
  }) : super(key: key);

  @override
  State<SetupStep2> createState() => _SetupStep2State();
}

class _SetupStep2State extends State<SetupStep2> {
  final _controller = Get.find<StateController>();

  final _nextOfKinNameController = TextEditingController();
  final _nextOfKinEmailController = TextEditingController();
  final _nextOfKinPhoneController = TextEditingController();
  final _nextOfKinAddressController = TextEditingController();

  // final TextEditingController _dateController = TextEditingController();
  String _selectedRelationship = "Sibling";
  String _selectedIDMeans = "";

  String _selectedDate = "";
  bool _sizeError = false;
  bool _isUploaded = false;
  final List<String> _allowedExtensions = <String>[
    '.png',
    '.docx',
    '.doc',
    '.pdf',
  ];
  double _fileSize = 0;
  var _pickedFile;

  void _onSelected(String val) {
    _selectedRelationship = val;
    widget.onStep2Completed(
      {
        "nokName": _nextOfKinNameController.text,
        "nokEmail": _nextOfKinEmailController.text,
        "nokPhone": _nextOfKinPhoneController.text.startsWith("0")
            ? "+234${_nextOfKinPhoneController.text.substring(1)}"
            : "+234${_nextOfKinPhoneController.text}",
        "nokAddress": _nextOfKinAddressController.text,
        "relationship": val,
        "idMeans": _selectedIDMeans,
      },
    );

    //  widget.onStep2Completed({
    //   "pickedFile": result!.files.first,
    //   "fileSize": (result.files.first.size) / 1000,
    // });
  }

  void _onMeansSelected(String val) {
    _selectedIDMeans = val;
    widget.onStep2Completed(
      {
        "nokName": _nextOfKinNameController.text,
        "nokEmail": _nextOfKinEmailController.text,
        "nokPhone": _nextOfKinPhoneController.text.startsWith("0")
            ? "+234${_nextOfKinPhoneController.text.substring(1)}"
            : "+234${_nextOfKinPhoneController.text}",
        "nokAddress": _nextOfKinAddressController.text,
        "relationship": _selectedRelationship,
        "idMeans": val,
      },
    );
  }

  @override
  void initState() {
    _nextOfKinNameController.text = _controller.nokName.value;
    _nextOfKinEmailController.text = _controller.nokEmail.value;
    _nextOfKinAddressController.text = _controller.nokAddress.value;
    _nextOfKinPhoneController.text = _controller.nokPhone.value;
    _selectedRelationship = _controller.nokRelationship.value;
    _selectedIDMeans = _controller.nokIdType.value;

    super.initState();
  }

  @override
  void didChangeDependencies() {
    _nextOfKinNameController.text = _controller.nokName.value;
    _nextOfKinEmailController.text = _controller.nokEmail.value;
    _nextOfKinAddressController.text = _controller.nokAddress.value;
    _nextOfKinPhoneController.text = _controller.nokPhone.value;
    _selectedRelationship = _controller.nokRelationship.value;
    super.didChangeDependencies();
  }

  _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      lockParentWindow: true,
      type: FileType.custom,
      dialogTitle: "Select gurantor ID",
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
      "nokName": _nextOfKinNameController.text,
      "nokEmail": _nextOfKinEmailController.text,
      "nokPhone": _nextOfKinPhoneController.text.startsWith("0")
          ? "+234${_nextOfKinPhoneController.text.substring(1)}"
          : "+234${_nextOfKinPhoneController.text}",
      "nokAddress": _nextOfKinAddressController.text,
      "relationship": _selectedRelationship,
      "idMeans": _selectedIDMeans,
      "pickedFile": result!.files.first,
      "fileSize": (result.files.first.size) / 1000,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextField(
          hintText: "Guarantor Fullname",
          onChanged: (val) {
            widget.onStep2Completed(
              {
                "nokName": val,
                "nokEmail": _nextOfKinEmailController.text,
                "nokPhone": _nextOfKinPhoneController.text.startsWith("0")
                    ? "+234${_nextOfKinPhoneController.text.substring(1)}"
                    : "+234${_nextOfKinPhoneController.text}",
                "nokAddress": _nextOfKinAddressController.text,
                "relationship": _selectedRelationship,
                "idMeans": _selectedIDMeans,
              },
            );
          },
          controller: _nextOfKinNameController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Guarantor\'s name required!';
            }
            return null;
          },
          inputType: TextInputType.name,
          capitalization: TextCapitalization.words,
        ),
        const SizedBox(
          height: 21.0,
        ),
        CustomTextField(
          hintText: "Guarantor Email",
          onChanged: (val) {
            widget.onStep2Completed(
              {
                "nokName": _nextOfKinNameController.text,
                "nokEmail": val,
                "nokPhone": _nextOfKinPhoneController.text.startsWith("0")
                    ? "+234${_nextOfKinPhoneController.text.substring(1)}"
                    : "+234${_nextOfKinPhoneController.text}",
                "nokAddress": _nextOfKinAddressController.text,
                "relationship": _selectedRelationship,
                "idMeans": _selectedIDMeans,
              },
            );
          },
          controller: _nextOfKinEmailController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Guarantor\'s email required!';
            }
            if (!RegExp('^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]')
                .hasMatch(value)) {
              return 'Please enter a valid email';
            }
            return null;
          },
          inputType: TextInputType.emailAddress,
        ),
        const SizedBox(
          height: 21.0,
        ),
        CustomTextField(
          hintText: "Guarantor Phone",
          onChanged: (val) {
            widget.onStep2Completed(
              {
                "nokName": _nextOfKinNameController.text,
                "nokEmail": _nextOfKinEmailController.text,
                "nokPhone": val.startsWith("0")
                    ? "+234${val.substring(1)}"
                    : "+234$val",
                "nokAddress": _nextOfKinAddressController.text,
                "relationship": _selectedRelationship,
                "idMeans": _selectedIDMeans,
              },
            );
          },
          controller: _nextOfKinPhoneController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Guarantor\'s phone required!';
            }
            if (value.toString().length < 11) {
              return 'Enter a valid phone number';
            }
            return null;
          },
          inputType: TextInputType.phone,
        ),
        const SizedBox(
          height: 16.0,
        ),
        CustomTextField(
          hintText: "Guarantor Address",
          onChanged: (val) {
            widget.onStep2Completed(
              {
                "nokName": _nextOfKinNameController.text,
                "nokEmail": _nextOfKinEmailController.text,
                "nokPhone": _nextOfKinPhoneController.text.startsWith("0")
                    ? "+234${_nextOfKinPhoneController.text.substring(1)}"
                    : "+234${_nextOfKinPhoneController.text}",
                "nokAddress": val,
                "relationship": _selectedRelationship,
                "idMeans": _selectedIDMeans,
              },
            );
          },
          controller: _nextOfKinAddressController,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter guarantor\'s address';
            }
            return null;
          },
          inputType: TextInputType.streetAddress,
        ),
        const SizedBox(
          height: 21.0,
        ),
        CustomDropdown(
            onSelected: _onSelected,
            hint: "Relationship with guarantor",
            items: relationships),
        const SizedBox(
          height: 21.0,
        ),
        CustomDropdown(
          onSelected: _onMeansSelected,
          hint: "Gurantor Means of ID",
          items: const [
            "voter's-card",
            "driver's-license",
            "national-ID",
            "utility-bill"
          ],
        ),
        const SizedBox(
          height: 8.0,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _isUploaded && _pickedFile != null
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
                    text: "Upload gurantor ID",
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
      ],
    );
  }
}

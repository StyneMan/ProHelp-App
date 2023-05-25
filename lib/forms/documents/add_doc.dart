import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:get/instance_manager.dart';
import 'package:prohelp_app/components/button/roundedbutton.dart';
import 'package:prohelp_app/components/inputfield/textfield.dart';
import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/helper/constants/constants.dart';
import 'package:prohelp_app/helper/preference/preference_manager.dart';
import 'package:prohelp_app/helper/service/api_service.dart';
import 'package:prohelp_app/helper/state/state_manager.dart';

class NewDocumentForm extends StatefulWidget {
  final PreferenceManager manager;

  const NewDocumentForm({
    Key? key,
    required this.manager,
  }) : super(key: key);

  @override
  State<NewDocumentForm> createState() => _NewDocumentFormState();
}

class _NewDocumentFormState extends State<NewDocumentForm> {
  final _controller = Get.find<StateController>();
  final _formKey = GlobalKey<FormState>();

  final _title1Controller = TextEditingController();
  final _title2Controller = TextEditingController();
  final _title3Controller = TextEditingController();
  final _title4Controller = TextEditingController();
  final _title5Controller = TextEditingController();

  List<TextEditingController> _textControllers = [];

  final List<String> _allowedExtensions = <String>[
    '.png',
    '.jpeg',
    '.jpg',
    '.doc',
    '.pdf',
  ];

  bool _uploadComplete = false;

  String dat = "";

  List<String> _downloadURLs = [];
  List _selectedDocuments = [];

  _initDocs() {
    // for (var i = 0; i < widget.manager.getUser()['documents']?.length; i++) {
    setState(() {
      _selectedDocuments = widget.manager.getUser()['documents'];
    });
    // }
  }

  @override
  void initState() {
    super.initState();
    _textControllers = [
      _title1Controller,
      _title2Controller,
      _title3Controller,
      _title4Controller,
      _title5Controller,
    ];
    _initDocs();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Localizations(
        delegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        locale: const Locale('en', ''),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          shrinkWrap: true,
          children: [
            const SizedBox(
              height: 6.0,
            ),
            Text(
              "Upload up to 5 documents. Documents may include (Certifications, Awards and other achievements)\nAllowed extensions: ${[
                ..._allowedExtensions
              ]}",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black, fontSize: 15),
            ),
            const SizedBox(
              height: 24.0,
            ),
            Obx(
              () => ClipRRect(
                borderRadius: BorderRadius.circular(36),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 256),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 1.0),
                    borderRadius: BorderRadius.circular(36),
                    color: Colors.transparent,
                  ),
                  child: TextButton(
                    onPressed: () {
                      _pickFiles();
                    },
                    child: _controller.pickedDocuments.value.isEmpty
                        ? Center(
                            child: Column(
                              children: const [
                                Icon(CupertinoIcons.cloud_upload),
                                TextInter(
                                  text: "Upload Documents",
                                  fontSize: 16,
                                ),
                              ],
                            ),
                          )
                        : Column(
                            children: [
                              ListView.separated(
                                shrinkWrap: true,
                                itemBuilder: (context, index) => Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        _controller.pickedDocuments.value
                                                    .elementAt(index)
                                                    .name
                                                    .toString()
                                                    .endsWith('png') ||
                                                _controller
                                                    .pickedDocuments.value
                                                    .elementAt(index)
                                                    .name
                                                    .toString()
                                                    .endsWith('jpg') ||
                                                _controller
                                                    .pickedDocuments.value
                                                    .elementAt(index)
                                                    .name
                                                    .toString()
                                                    .endsWith('jpeg')
                                            ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(4.0),
                                                child: Image.file(
                                                  File(_controller
                                                      .pickedDocuments.value
                                                      .elementAt(index)
                                                      .path),
                                                  width: 40,
                                                  height: 40,
                                                  fit: BoxFit.cover,
                                                ),
                                              )
                                            : _controller.pickedDocuments.value
                                                    .elementAt(index)
                                                    .name
                                                    .toString()
                                                    .endsWith('doc')
                                                ? ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4.0),
                                                    child: Image.asset(
                                                      "assets/images/docs.png",
                                                      width: 40,
                                                      height: 40,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  )
                                                : _controller
                                                        .pickedDocuments.value
                                                        .elementAt(index)
                                                        .name
                                                        .toString()
                                                        .endsWith('pdf')
                                                    ? ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(4.0),
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
                                      ],
                                    ),
                                    const SizedBox(width: 6.0),
                                    Expanded(
                                      child: CustomTextField(
                                        hintText: "Doc title",
                                        onChanged: (val) {},
                                        controller: index == 0
                                            ? _title1Controller
                                            : index == 1
                                                ? _title2Controller
                                                : index == 3
                                                    ? _title3Controller
                                                    : index == 4
                                                        ? _title4Controller
                                                        : _title5Controller,
                                        validator: (val) {
                                          if (val.toString().isEmpty ||
                                              val == null) {
                                            return "Document title is required";
                                          }
                                          return null;
                                        },
                                        inputType: TextInputType.text,
                                        capitalization:
                                            TextCapitalization.words,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        _remove(index);
                                      },
                                      icon: const Icon(CupertinoIcons.delete),
                                    )
                                  ],
                                ),
                                separatorBuilder: (context, index) =>
                                    const Divider(),
                                itemCount:
                                    _controller.pickedDocuments.value.length,
                              ),
                              const SizedBox(
                                height: 16.0,
                              ),
                              TextButton.icon(
                                onPressed:
                                    _controller.pickedDocuments.value.length >=
                                            5
                                        ? null
                                        : () {
                                            _addMore();
                                          },
                                icon: const Icon(
                                  CupertinoIcons.add_circled_solid,
                                  size: 18,
                                ),
                                label: const TextInter(
                                  text: "Add More",
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                    style: TextButton.styleFrom(
                      padding: _controller.pickedDocuments.value.isEmpty
                          ? const EdgeInsets.all(48)
                          : const EdgeInsets.only(
                              top: 10,
                              bottom: 2.0,
                              left: 10,
                              right: 1.0,
                            ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 24.0,
            ),
            RoundedButton(
              bgColor: Constants.primaryColor,
              child: const TextInter(text: "SAVE CHANGES", fontSize: 16),
              borderColor: Colors.transparent,
              foreColor: Colors.white,
              onPressed: _controller.isLoading.value
                  ? null
                  : () {
                      if (_formKey.currentState!.validate()) {
                        _save();
                      }
                    },
              variant: "Filled",
            ),
          ],
        ),
      ),
    );
  }

  _pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      lockParentWindow: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'pdf', 'doc', 'png'],
    );

    _controller.pickedDocuments.value = result!.files;
  }

  _addMore() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      lockParentWindow: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'pdf', 'doc'],
    );
    // setState(() {
    // _pickedFiles?.add(result!.files.first.name);
    _controller.pickedDocuments.add(result!.files.first);
    // });
  }

  _remove(index) {
    debugPrint("CURR INDEX >> >> $index");
    _controller.pickedDocuments.removeAt(index);
  }

  Future _uploadDocuments() async {
    int count = 0;
    try {
      for (var i = 0; i < _controller.pickedDocuments.length; i++) {
        final file = File(_controller.pickedDocuments.elementAt(i).path);
        final storageRef = FirebaseStorage.instance.ref();

        final uploadTask = storageRef
            .child("docs")
            .child(
                "${widget.manager.getUser()['_id']}_${_textControllers.elementAt(i).text}")
            .putFile(file);

        uploadTask.then((p0) async {
          final url = await p0.ref.getDownloadURL();

          debugPrint(
              "DOWNLOAD URLS AT $i >>>>> ${_controller.pickedDocuments.elementAt(i).path}");

          setState(() {
            count = count + 1;
            _downloadURLs.add(url);
            _selectedDocuments.add({
              "title": _textControllers[i].text,
              "url": url,
              "extension":
                  ".${_controller.pickedDocuments.elementAt(i).path.split('file_picker')[1].toString().split('.')[1]}"
            });
          });
        });
      }
    } on FirebaseException catch (e) {
      _controller.setLoading(true);
      debugPrint(e.toString());
    }
  }

  _save() async {
    _controller.setLoading(true);
    // Navigator.pop(context);

    try {
      await _uploadDocuments();

      Future.delayed(
        const Duration(seconds: 10),
        () async {
          debugPrint("DATA LIST >> >> ${[..._selectedDocuments]}");

          Map _payload = {
            "documents": [
              ...widget.manager.getUser()['documents'],
              ..._selectedDocuments
            ]
          };

          try {
            final resp = await APIService().updateProfile(
              body: _payload,
              accessToken: widget.manager.getAccessToken(),
              email: widget.manager.getUser()['email'],
            );

            _controller.setLoading(false);

            if (resp.statusCode == 200) {
              Map<String, dynamic> _map = jsonDecode(resp.body);
              Constants.toast(_map['message']);

              //Nw save user's data to preference
              String userData = jsonEncode(_map['data']);
              widget.manager.setUserData(userData);
              _controller.userData.value = _map['data'];

              _controller.pickedDocuments.clear();

              // _controller.shouldExitExpEdu.value = true;
              // Future.delayed(const Duration(seconds: 1), () {
              Navigator.pop(context);
              // });
            } else {
              Map<String, dynamic> _map = jsonDecode(resp.body);
              Constants.toast(_map['message']);
            }
          } catch (e) {
            _controller.setLoading(false);
            debugPrint(e.toString());
          }
        },
      );
    } catch (e) {
      _controller.setLoading(false);
      debugPrint(e.toString());
    }
  }
}

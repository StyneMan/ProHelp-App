import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prohelp_app/components/inputfield/customdropdown.dart';
import 'package:prohelp_app/components/inputfield/datefield.dart';
import 'package:prohelp_app/components/inputfield/llinedtextfield.dart';
import 'package:prohelp_app/components/inputfield/textfield.dart';
import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/helper/constants/constants.dart';
import 'package:prohelp_app/helper/state/state_manager.dart';

typedef void InitCallback(Map data);

class SetupStep3 extends StatefulWidget {
  InitCallback onStep3Completed;
  SetupStep3({
    Key? key,
    required this.onStep3Completed,
  }) : super(key: key);

  @override
  State<SetupStep3> createState() => _SetupStep3State();
}

class _SetupStep3State extends State<SetupStep3> {
  final _schoolController = TextEditingController();
  final _fieldStudyController = TextEditingController();
  final _dateGraduatedController = TextEditingController();

  final _title1Controller = TextEditingController();
  final _title2Controller = TextEditingController();
  final _title3Controller = TextEditingController();
  final _title4Controller = TextEditingController();
  final _title5Controller = TextEditingController();

  final _controller = Get.find<StateController>();

  String _selectedDegree = "Bachelor";
  String _encodedDate = "";

  // List<PlatformFile>? _pickedFiles = [];

  @override
  void initState() {
    _schoolController.text = _controller.school.value;
    _selectedDegree = _controller.degree.value;
    _fieldStudyController.text = _controller.fieldStudy.value;
    _dateGraduatedController.text = _controller.dateGraduated.value;

    super.initState();
  }

  @override
  void didChangeDependencies() {
    _schoolController.text = _controller.school.value;
    _selectedDegree = _controller.degree.value;
    _fieldStudyController.text = _controller.fieldStudy.value;
    _dateGraduatedController.text = _controller.dateGraduated.value;

    super.didChangeDependencies();
  }

  void _onDateSelected(String raw, String val) {
    _dateGraduatedController.text = val;
    _encodedDate = raw;
    widget.onStep3Completed(
      {
        "school": _schoolController.text,
        "degree": _selectedDegree,
        "fieldStudy": _fieldStudyController.text,
        "dateGraduated": val
      },
    );
  }

  void _onDegreeSelected(String val) {
    setState(() {
      _selectedDegree = val;
    });

    widget.onStep3Completed(
      {
        "school": _schoolController.text,
        "degree": val,
        "fieldStudy": _fieldStudyController.text,
        "dateGraduated": _dateGraduatedController.text
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomDropdown(
          onSelected: _onDegreeSelected,
          hint: "Degree",
          items: const [
            'None',
            'Elementary',
            "O'level",
            "ND/OND",
            "HND",
            "Bachelor",
            "Masters",
            "PhD"
          ],
        ),
        const SizedBox(
          height: 21.0,
        ),
        CustomTextField(
          hintText: "School",
          isEnabled: _selectedDegree == "None" ? false : true,
          onChanged: (val) {
            widget.onStep3Completed(
              {
                "school": val,
                "degree": _selectedDegree,
                "fieldStudy": _fieldStudyController.text,
                "dateGraduated": _dateGraduatedController.text
              },
            );
          },
          controller: _schoolController,
          validator: (value) {
            if (_selectedDegree != "None") {
              if (value == null || value.isEmpty) {
                return 'School name is required!';
              }
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
          hintText: "Course of study",
          isEnabled: _selectedDegree == "None" ||
                  _selectedDegree == "Elementary" ||
                  _selectedDegree == "O'level"
              ? false
              : true,
          onChanged: (val) {
            widget.onStep3Completed(
              {
                "school": _schoolController.text,
                "degree": _selectedDegree,
                "fieldStudy": val,
                "dateGraduated": _dateGraduatedController.text
              },
            );
          },
          controller: _fieldStudyController,
          validator: (value) {
            if (_selectedDegree != "None" && _selectedDegree != "Elementary") {
              if (value == null || value.isEmpty) {
                return 'Field of study is required!';
              }
            }

            return null;
          },
          inputType: TextInputType.text,
          capitalization: TextCapitalization.words,
        ),
        const SizedBox(
          height: 21.0,
        ),
        CustomDateField(
          isEnabled: _selectedDegree == "None" ? false : true,
          hintText: "Date graduated",
          onDateSelected: _onDateSelected,
          controller: _dateGraduatedController,
        ),
        const SizedBox(
          height: 21.0,
        ),
        // Obx(
        //   () => ClipRRect(
        //     borderRadius: BorderRadius.circular(36),
        //     child: Container(
        //       decoration: BoxDecoration(
        //         border: Border.all(color: Colors.grey, width: 1.0),
        //         borderRadius: BorderRadius.circular(36),
        //         color: Colors.grey.shade200,
        //       ),
        //       child: TextButton(
        //         onPressed: () {
        //           _pickFiles();
        //         },
        //         child: _controller.pickedDocuments.value.isEmpty
        //             ? Center(
        //                 child: Column(
        //                   children: const [
        //                     Icon(CupertinoIcons.cloud_upload),
        //                     TextInter(
        //                       text: "Upload Documents",
        //                       fontSize: 16,
        //                     ),
        //                   ],
        //                 ),
        //               )
        //             : Column(
        //                 children: [
        //                   ListView.separated(
        //                     shrinkWrap: true,
        //                     itemBuilder: (context, index) => Row(
        //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //                       crossAxisAlignment: CrossAxisAlignment.center,
        //                       children: [
        //                         Row(
        //                           mainAxisAlignment: MainAxisAlignment.start,
        //                           crossAxisAlignment: CrossAxisAlignment.center,
        //                           children: [
        //                             TextInter(
        //                               text: _controller.pickedDocuments.value
        //                                   .elementAt(index)
        //                                   .name,
        //                               fontSize: 13,
        //                             ),
        //                             const SizedBox(width: 4.0),
        //                           ],
        //                         ),
        //                         InkWell(
        //                           onTap: () {
        //                             _remove(index);
        //                           },
        //                           child: const Icon(CupertinoIcons.delete),
        //                         )
        //                       ],
        //                     ),
        //                     separatorBuilder: (context, index) =>
        //                         const Divider(),
        //                     itemCount: _controller.pickedDocuments.value.length,
        //                   ),
        //                   const SizedBox(
        //                     height: 16.0,
        //                   ),
        //                   TextButton.icon(
        //                     onPressed: () {
        //                       _addMore();
        //                     },
        //                     icon: const Icon(
        //                       CupertinoIcons.add_circled_solid,
        //                       size: 18,
        //                     ),
        //                     label: const TextInter(
        //                       text: "Add More",
        //                       fontSize: 14,
        //                       fontWeight: FontWeight.w600,
        //                     ),
        //                   ),
        //                 ],
        //               ),
        //         style: TextButton.styleFrom(
        //           padding: _controller.pickedDocuments.value.isEmpty
        //               ? const EdgeInsets.all(48)
        //               : const EdgeInsets.only(
        //                   top: 16,
        //                   bottom: 2.0,
        //                   left: 21,
        //                   right: 21,
        //                 ),
        //         ),
        //       ),
        //     ),
        //   ),
        // ),
        // const SizedBox(
        //   height: 8.0,
        // ),
        // const Padding(
        //   padding: EdgeInsets.symmetric(horizontal: 10.0),
        //   child: TextInter(
        //     text:
        //         "Give your documents names that describes them before uploading (e.g birth_certificate.pdf). Allowed formats: .pdf .png .jpg .doc",
        //     fontSize: 13,
        //     align: TextAlign.center,
        //   ),
        // ),
        const SizedBox(
          height: 16.0,
        ),
      ],
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
    // setState(() {
    //   _pickedFiles = result?.files;
    // });
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
}

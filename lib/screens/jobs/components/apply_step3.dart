import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prohelp_app/components/inputfield/textarea2.dart';
import 'package:prohelp_app/components/text_components.dart';

typedef void InitCallback(Map data);

class ApplyJobStep3 extends StatefulWidget {
  final InitCallback onStep3Completed;
  var data;
  ApplyJobStep3({
    Key? key,
    required this.data,
    required this.onStep3Completed,
  }) : super(key: key);

  @override
  State<ApplyJobStep3> createState() => _ApplyJobStep3State();
}

class _ApplyJobStep3State extends State<ApplyJobStep3> {
  List<TextEditingController> _textControllers = [];

  @override
  void initState() {
    super.initState();
    _textControllers = List.generate(widget.data['screeningQuestions']?.length,
        (index) => TextEditingController());
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextPoppins(
          text: "You're almost done. Now answer questions ",
          fontSize: 21,
          fontWeight: FontWeight.w500,
          align: TextAlign.center,
        ),
        const SizedBox(
          height: 16.0,
        ),
        for (var i = 0; i < widget.data['screeningQuestions']?.length; i++)
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextPoppins(
                text:
                    "${widget.data['screeningQuestions'][i]} ${widget.data['screeningQuestions'][i].toString().endsWith("?") ? "" : "?"}"
                        .capitalizeFirst,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              const SizedBox(
                height: 8.0,
              ),
              CustomTextArea2(
                hintText: "Answer",
                maxLines: 2,
                onChanged: (val) {
                  widget.onStep3Completed({"textController": _textControllers});
                },
                controller: _textControllers.elementAt(i),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please provide an answer';
                  }
                  return null;
                },
                inputType: TextInputType.text,
                capitalization: TextCapitalization.sentences,
              ),
              const SizedBox(
                height: 16.0,
              ),
            ],
          ),
        const SizedBox(
          height: 16.0,
        ),
      ],
    );
  }
}

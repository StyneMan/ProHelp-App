import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prohelp_app/components/text_components.dart';

class GuestMessageBox extends StatefulWidget {
  var data;
  GuestMessageBox({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  State<GuestMessageBox> createState() => _GuestMessageBoxState();
}

class _GuestMessageBoxState extends State<GuestMessageBox> {
  // String originalDateString = "2023-05-19T08:59:54.367Z";
  // DateTime originalDate = DateTime.parse(widget.data['']);

  String _formattedDate = "dd/mm/yyyy";

  @override
  void initState() {
    super.initState();
    ;
    setState(() {
      _formattedDate = DateFormat('dd/MM/yyyy HH:mm')
          .format(DateTime.parse(widget.data['createdAt']));
    });
  }

  // print(formattedDate);
  // Output: 19/05/2023 08:59
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: 75.0,
        maxWidth: MediaQuery.of(context).size.width * 0.6,
      ),
      child: Wrap(
        clipBehavior: Clip.none,
        children: [
          Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextInter(text: widget.data['message'], fontSize: 16),
                  const SizedBox(
                    height: 8.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        _formattedDate,
                        style: const TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                      const SizedBox(
                        width: 8.0,
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

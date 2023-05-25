import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/helper/constants/constants.dart';

class OwnMessageBox extends StatefulWidget {
  var data;
  OwnMessageBox({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  State<OwnMessageBox> createState() => _OwnMessageBoxState();
}

class _OwnMessageBoxState extends State<OwnMessageBox> {
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
        children: [
          Card(
            color: Constants.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextInter(
                    text: widget.data['message'],
                    fontSize: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(
                    height: 2.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        _formattedDate,
                        style: TextStyle(fontSize: 13, color: Colors.white60),
                      ),
                      const SizedBox(
                        width: 8.0,
                      ),
                      Icon(
                        Icons.done_all,
                        color: widget.data['isRead'] ? Colors.green : Colors.grey,
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

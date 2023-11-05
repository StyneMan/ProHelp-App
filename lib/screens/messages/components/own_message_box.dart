import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/helper/constants/constants.dart';

class OwnMessageBox extends StatefulWidget {
  var data;
  // final bool isRead;
  OwnMessageBox({
    Key? key,
    required this.data,
    // required this.isRead,
  }) : super(key: key);

  @override
  State<OwnMessageBox> createState() => _OwnMessageBoxState();
}

class _OwnMessageBoxState extends State<OwnMessageBox> {
  // String originalDateString = "2023-05-19T08:59:54.367Z";
  // DateTime originalDate = DateTime.parse(widget.data['']);

  String _formattedDate = "dd/mm/yyyy";
  Offset _tapPosition = Offset.zero;

  void _getTapPosition(TapDownDetails details) {
    final RenderBox referenceBox = context.findRenderObject() as RenderBox;
    setState(() {
      _tapPosition = referenceBox.globalToLocal(details.globalPosition);
    });
  }

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
    final RenderObject? overlay =
        Overlay.of(context).context.findRenderObject();

    return SizedBox(
      child: InkWell(
        // onTapDown: (details) => _getTapPosition(details),
        // onLongPress: () {
        //   showMenu(
        //     context: context,
        //     position: RelativeRect.fromRect(
        //       Rect.fromLTWH(_tapPosition.dx, _tapPosition.dy, overlay!.paintBounds.size.height, 30),
        //       Rect.fromLTWH(
        //         0,
        //         100,
        //         overlay.paintBounds.size.width,
        //         overlay.paintBounds.size.height,
        //       ),
        //     ),
        //     items: [
        //       PopupMenuItem(
        //         value: 0,
        //         child: const Text('Delete Message'),
        //         onTap: () {
        //           debugPrint("JUST CLIEKED ME !!!");
        //         },
        //       ),
        //     ],
        //   );
        // },
        child: ConstrainedBox(
          constraints: BoxConstraints(
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
                        text: widget.data['content'],
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
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white60,
                            ),
                          ),
                          const SizedBox(
                            width: 8.0,
                          ),
                          // Icon(
                          //   Icons.done_all,
                          //   color: widget.data['isRead']
                          //       ? Colors.blue.shade200
                          //       : Colors.grey,
                          // ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

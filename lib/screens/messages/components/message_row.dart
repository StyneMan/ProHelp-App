import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/helper/constants/constants.dart';
import 'package:prohelp_app/helper/preference/preference_manager.dart';
import 'package:prohelp_app/helper/socket/socket_manager.dart';
import 'package:prohelp_app/helper/state/state_manager.dart';
import 'package:prohelp_app/screens/messages/chat_page.dart';

class MessageRow extends StatefulWidget {
  final PreferenceManager manager;
  var data;
  MessageRow({
    Key? key,
    required this.data,
    required this.manager,
  }) : super(key: key);

  @override
  State<MessageRow> createState() => _MessageRowState();
}

class _MessageRowState extends State<MessageRow> {
  final _controller = Get.find<StateController>();
  var socket;
  var guestData;

  @override
  void initState() {
    super.initState();

    print("DATA INSPECTION :::  ${jsonEncode(widget.data)}");
    // if (widget.data) {
    widget.data['users']?.forEach((element) => {
          if (element['_id'] != widget.manager.getUser()['id'])
            {setState(() => guestData = element)}
        });
    // }

    socket = SocketManager().socket;
    if (socket.disconnected) {
      //   socket.connect();
      //   socket.emit(
      //     "subscribe",
      //     {"room": widget.data['_id'], "otherUser": _getOtherUserId()},
      //   );
      // } else {
      //   socket.emit(
      //     "subscribe",
      //     {"room": widget.data['_id'], "otherUser": _getOtherUserId()},
      //   );
      // }
    }
  }

  @override
  build(BuildContext context) {
    return InkWell(
      onTap: () {
        // debugPrint("CHAT ID >> ${widget.data['id']}");

        _controller.selectedConversation.value = widget.data;

        Get.to(
          ChatPage(
            manager: widget.manager,
            caller: "messages",
            data: widget.data,
          ),
        );
      },
      child: guestData?.isEmpty
          ? SizedBox()
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipOval(
                      child: Image.network(
                        guestData['bio']['image'],
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            SvgPicture.asset(
                          "assets/images/personal.svg",
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 16.0,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextPoppins(
                          text:
                              "${guestData['bio']['firstname']} ${guestData['bio']['lastname']}"
                                  .capitalize,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                        widget.data['latestMessage'] == null
                            ? const SizedBox()
                            : SizedBox(
                                width: MediaQuery.of(context).size.width * 0.6,
                                child: Text(
                                  "${widget.data['latestMessage']['content'].length > 24 ? "${widget.data['latestMessage']['content']?.toString().substring(0, 24)}..." : widget.data['latestMessage']['content']}",
                                  style: const TextStyle(
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                      ],
                    )
                  ],
                ),
                const SizedBox(
                  width: 10.0,
                ),
              ],
            ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/helper/constants/constants.dart';
import 'package:prohelp_app/helper/preference/preference_manager.dart';
import 'package:prohelp_app/helper/socket/socket_manager.dart';
import 'package:prohelp_app/helper/state/state_manager.dart';
import 'package:prohelp_app/screens/messages/chat_page.dart';

class MessageRow extends StatelessWidget {
  final PreferenceManager manager;
  var data;
  MessageRow({
    Key? key,
    required this.data,
    required this.manager,
  }) : super(key: key);

  final _controller = Get.find<StateController>();
  

  _getOtherUserName() {
    return manager.getUser()['_id'] == data['initiator']['id']
        ? data['receiver']['name']
        : data['initiator']['name'];
  }

  _getOtherUserPhoto() {
    return manager.getUser()['_id'] == data['initiator']['id']
        ? data['receiver']['photo']
        : data['initiator']['photo'];
  }

  _getOtherUserId() {
    return manager.getUser()['_id'] == data['initiator']['id']
        ? data['receiver']['id']
        : data['initiator']['id'];
  }

  _getOtherUserEmail() {
    return manager.getUser()['_id'] == data['initiator']['id']
        ? data['receiver']['email']
        : data['initiator']['email'];
  }

  @override
  build(BuildContext context) {
    return InkWell(
      onTap: () {
        final socket = SocketManager().socket;

        debugPrint("CHAT ID >> ${data['_id']}");
        socket.emit("subscribe",
            ({"room": data['_id'], "otherUser": _getOtherUserId()}));

        Get.to(
          ChatPage(
            manager: manager,
            caller: "messages",
            data: data,
          ),
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipOval(
                child: Image.network(
                  _getOtherUserPhoto(),
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      SvgPicture.asset(
                    "assets/images/personal.svg",
                    width: 56,
                    height: 56,
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
                    text: _getOtherUserName().toString().capitalize,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: Text(
                      "${data['recentMessage']}",
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
          1 > 0
              ? ClipOval(
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Constants.primaryColor,
                    ),
                    child: Center(
                      child: Text(
                        "${1}",
                        style:
                            const TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ),
                  ),
                )
              : const SizedBox(),
        ],
      ),
    );
  }
}

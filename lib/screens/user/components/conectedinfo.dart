import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prohelp_app/components/button/roundedbutton.dart';
import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/helper/constants/constants.dart';
import 'package:prohelp_app/helper/preference/preference_manager.dart';
import 'package:prohelp_app/helper/service/api_service.dart';
import 'package:prohelp_app/helper/socket/socket_manager.dart';
import 'package:prohelp_app/helper/state/state_manager.dart';
import 'package:prohelp_app/screens/messages/chat_page.dart';
import 'package:url_launcher/url_launcher.dart';

class ConnectedInfoContent extends StatefulWidget {
  var guestData;
  final PreferenceManager manager;
  ConnectedInfoContent({
    Key? key,
    required this.guestData,
    required this.manager,
  }) : super(key: key);

  @override
  State<ConnectedInfoContent> createState() => _ConnectedInfoContentState();
}

class _ConnectedInfoContentState extends State<ConnectedInfoContent> {
  // bool _hasCallSupport = false;
  final _controller = Get.find<StateController>();

  Future<void>? _launched;
  var emailLaunchUri;

  _makePhoneCall(String phoneNumber) {
    // Use `Uri` to ensure that `phoneNumber` is properly URL-encoded.
    // Just using 'tel:$phoneNumber' would create invalid URLs in some cases,
    // such as spaces in the input, which would cause `launch` to fail on some
    // platforms.
    canLaunch('tel:123').then((bool result) async {
      final Uri launchUri = Uri(
        scheme: 'tel',
        path: phoneNumber,
      );
      await launch(launchUri.toString());
    });
  }

  String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  @override
  void initState() {
    super.initState();
    emailLaunchUri = Uri(
      scheme: 'mailto',
      path: '${widget.guestData['email']}',
      query: encodeQueryParameters(<String, String>{
        'subject': 'Example Subject & Symbols are allowed!'
      }),
    );
  }

//
  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Constants.primaryColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(
                    Constants.padding,
                  ),
                  topRight: Radius.circular(
                    Constants.padding,
                  ),
                ),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const TextInter(
                    text: "Contact Information",
                    fontSize: 16,
                    color: Colors.white,
                  ),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.cancel_outlined,
                      color: Colors.white,
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 21.0,
                  ),
                  TextButton.icon(
                    onPressed: () {
                      _makePhoneCall("${widget.guestData['bio']['phone']}");
                    },
                    icon: const Icon(CupertinoIcons.phone_circle_fill),
                    label: TextInter(
                      text: "${widget.guestData['bio']['phone']}",
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(
                    height: 2.0,
                  ),
                  const Divider(),
                  const SizedBox(
                    height: 2.0,
                  ),
                  TextButton.icon(
                    onPressed: () {
                      launch(emailLaunchUri.toString());
                    },
                    icon: const Icon(CupertinoIcons.mail_solid),
                    label: TextInter(
                      text: "${widget.guestData['email']}",
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(
                    height: 16.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16.0,
                      horizontal: 24.0,
                    ),
                    child: RoundedButton(
                      bgColor: Colors.transparent,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            CupertinoIcons.chat_bubble_2_fill,
                          ),
                          SizedBox(
                            width: 10.0,
                          ),
                          TextInter(
                            text: "Start Chat",
                            fontSize: 15,
                            color: Constants.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ],
                      ),
                      borderColor: Constants.primaryColor,
                      foreColor: Constants.primaryColor,
                      onPressed: () {
                        Navigator.pop(context);
                        _initiateChat();
                        // Navigator.of(context).push(
                        //   PageTransition(
                        //     type: PageTransitionType.size,
                        //     alignment: Alignment.bottomCenter,
                        //     child: ChatPage(
                        //       manager: widget.manager,
                        //     ),
                        //   ),
                        // );
                      },
                      variant: "Outlined",
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  _initiateChat() async {
    final socket = SocketManager().socket;

    _controller.setLoading(true);
    Map _data = {
      "userId": widget.guestData['id'] ?? widget.guestData['_id'],
    };

    print("PAYLOAD :: $_data");

    try {
      final resp = await APIService().initChat(
        accessToken: widget.manager.getAccessToken(),
        email: widget.manager.getUser()['email'],
        payload: _data,
      );
      _controller.setLoading(false);
      debugPrint("CHAT INITIATE RESPOSNE >> ${resp.body}");

      if (resp.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(resp.body);
        _controller.selectedConversation.value = map;

        final _allChatsResponse = await APIService().getUsersChats(
          accessToken: widget.manager.getAccessToken(),
          email: widget.manager.getUser()['email'],
        );

        if (_allChatsResponse.statusCode == 200) {
          debugPrint("ALL CHATS RESPONSE >> ${_allChatsResponse.body}");
          Map<String, dynamic> _mapper = jsonDecode(_allChatsResponse.body);
          // Now update GetX state
          _controller.myChats.value = _mapper['data'];
        }

        // socket.emit(
        //   "subscribe",
        //   ({
        //     "room": map['data']['chatId'],
        //     "otherUser": widget.guestData['id']
        //   }),
        // );

        Get.to(
          ChatPage(
            manager: widget.manager,
            data: map,
            caller: "profile",
          ),
        );
      } else {
        Constants.toast("An error occurred!");
      }
    } catch (e) {
      debugPrint(e.toString());
      _controller.setLoading(false);
    }
  }
}

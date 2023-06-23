import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prohelp_app/components/inputfield/chatfield.dart';
import 'package:prohelp_app/components/shimmer/banner_shimmer.dart';
import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/helper/constants/constants.dart';
import 'package:prohelp_app/helper/preference/preference_manager.dart';
import 'package:prohelp_app/helper/service/api_service.dart';
import 'package:prohelp_app/helper/socket/socket_manager.dart';
import 'package:prohelp_app/helper/state/state_manager.dart';
import 'package:prohelp_app/screens/user/profile2.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;

import 'components/guest_message_box.dart';
import 'components/own_message_box.dart';

class ChatPage extends StatefulWidget {
  final PreferenceManager manager;
  final String caller;
  var data;
  ChatPage({
    Key? key,
    required this.manager,
    required this.data,
    required this.caller,
  }) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _controller = Get.find<StateController>();
  // final _searchController = TextEditingController();
  final _inputController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();

  bool isTyping = false;
  String _myId = "", senderId = "";
  String user1Id = "", user2Id = "";
  // String _guestName = "", _guestId = "", _guestPhoto = "";

  _init() async {
    try {
      final res = await APIService().getConversationsByChatId(
        accessToken: widget.manager.getAccessToken(),
        email: widget.manager.getUser()['email'],
        chatId: widget.caller == "profile"
            ? widget.data['chatId']
            : widget.data['_id'],
      );

      _controller.isConversationLoading.value = false;

      setState(() {
        _myId = widget.manager.getUser()['id'];
      });
      if (res.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(res.body);
        // debugPrint("SENDER ID >> ${map['conversation'][0]['sender']['id']}");
        // debugPrint(
        //     "RECEIVER ID >> ${map['conversation'][0]['receiver']['id']}");
        // debugPrint("MY USERID >> ${widget.manager.getUser()['_id']}");

        _controller.currentConversation.value = map['conversation'];

        setState(() {
          // _guestName = map['conversation'][0]['receiver']['name'];
          // _guestPhoto = map['conversation'][0]['receiver']['photo'];
          // senderId  = map['conversation'][0]['sender']['photo'];
          // _guestId = map['conversation'][0]['receiver']['id'];
          user1Id = map['users'][0]['id'];
          user2Id = map['users'][1]['id'];
        });
      }
    } catch (e) {
      _controller.isConversationLoading.value = false;
    }
  }

  _getOtherUserName() {
    return widget.manager.getUser()['id'] == widget.data['initiator']['id']
        ? widget.data['receiver']['name']
        : widget.data['initiator']['name'];
  }

  _getOtherUserPhoto() {
    return widget.manager.getUser()['id'] == widget.data['initiator']['id']
        ? widget.data['receiver']['photo']
        : widget.data['initiator']['photo'];
  }

  _getOtherUserId() {
    return widget.manager.getUser()['id'] == widget.data['initiator']['id']
        ? widget.data['receiver']['id']
        : widget.data['initiator']['id'];
  }

  _getOtherUserEmail() {
    return widget.manager.getUser()['id'] == widget.data['initiator']['id']
        ? widget.data['receiver']['email']
        : widget.data['initiator']['email'];
  }

  _markAsRead() {
    final socket = SocketManager().socket;
    if (socket.disconnected) {
      socket.connect();
      socket.emit('isRead', {
        'reader': widget.manager.getUser()['id'],
        'readerName':
            "${widget.manager.getUser()['bio']['firstname']} ${widget.manager.getUser()['bio']['middlename']} ${widget.manager.getUser()['bio']['lastname']}",
        'otherUser': _getOtherUserId(),
        'chatId': widget.caller == "profile"
            ? widget.data['chatId']
            : widget.data['_id'],
      });
    } else {
      socket.emit('isRead', {
        'reader': widget.manager.getUser()['id'],
        'readerName':
            "${widget.manager.getUser()['bio']['firstname']} ${widget.manager.getUser()['bio']['middlename']} ${widget.manager.getUser()['bio']['lastname']}",
        'otherUser': _getOtherUserId(),
        'chatId': widget.caller == "profile"
            ? widget.data['chatId']
            : widget.data['_id'],
      });
    }

    //Already on the chat page
    socket.on('new-message', (data) {
      if (data['senderId'] != widget.manager.getUser()['id']) {
        socket.emit('isRead', {
          'reader': widget.manager.getUser()['id'],
          'readerName':
              "${widget.manager.getUser()['bio']['firstname']} ${widget.manager.getUser()['bio']['middlename']} ${widget.manager.getUser()['bio']['lastname']}",
          'otherUser': _getOtherUserId(),
          'chatId': widget.caller == "profile"
              ? widget.data['chatId']
              : widget.data['_id'],
        });
      }
    });

    socket.on('message-read', (data) {
      debugPrint("IS READ NOTICE ===>>>, $data");
    });
  }

  @override
  void initState() {
    super.initState();
    _init();
    _focusNode.addListener(_scrollToBottom);

    _markAsRead();

    Future.delayed(const Duration(seconds: 3), () {
      debugPrint(
          "CHAT PAGE ROUTE NAME >> ${ModalRoute.of(context)?.settings.name}");
    });
  }

  void _scrollToBottom() {
    if (_focusNode.hasFocus) {
      // final position = _scrollController.position.maxScrollExtent;
      // _scrollController.jumpTo(position);
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_scrollToBottom);
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _markAsRead();
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        elevation: 0.0,
        foregroundColor: Constants.secondaryColor,
        backgroundColor: Constants.primaryColor,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: const Icon(
                CupertinoIcons.arrow_left_circle,
              ),
            ),
            const SizedBox(
              width: 16.0,
            ),
            TextButton(
              onPressed: () {
                Get.to(
                  UserProfile2(
                    manager: widget.manager,
                    name: _getOtherUserName(),
                    image: _getOtherUserPhoto(),
                    userId: _getOtherUserId(),
                    email: _getOtherUserEmail(),
                  ),
                );
              },
              child: Row(
                children: [
                  ClipOval(
                    child: _getOtherUserPhoto().isEmpty
                        ? const SizedBox()
                        : Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.white,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(
                              child: Image.network(
                                _getOtherUserPhoto() ?? "",
                                errorBuilder: (context, error, stackTrace) =>
                                    const SizedBox(),
                                width: 24,
                                height: 24,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(
                    width: 5.0,
                  ),
                  TextPoppins(
                    text: "${_getOtherUserName()}".capitalize,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Constants.secondaryColor,
                  ),
                ],
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.all(0.5),
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton(
            icon: const Icon(
              CupertinoIcons.ellipsis_vertical,
            ),
            onSelected: (result) {
              if (result == 0) {
                Get.to(
                  UserProfile2(
                    manager: widget.manager,
                    name: _getOtherUserName(),
                    image: _getOtherUserPhoto(),
                    userId: _getOtherUserId(),
                    email: _getOtherUserEmail(),
                  ),
                );
              } else {
                showCupertinoDialog(
                  context: context,
                  builder: (context) => CupertinoAlertDialog(
                    title: TextPoppins(
                      text: "Clear Chat",
                      fontSize: 18,
                    ),
                    content: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.96,
                      height: 100,
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 24,
                          ),
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              text: "I ",
                              style: const TextStyle(
                                color: Colors.black45,
                              ),
                              children: [
                                TextSpan(
                                  text:
                                      "${widget.manager.getUser()['bio']['fullname']}",
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const TextSpan(
                                  text: " confirm that I to clear this chat ",
                                  style: TextStyle(
                                    color: Colors.black45,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: TextRoboto(
                            text: "Cancel",
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _clearChat();
                          },
                          child: TextRoboto(
                            text: "Proceed",
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
            itemBuilder: (BuildContext bc) {
              return widget.data['initiator']['id'] ==
                      widget.manager.getUser()['id']
                  ? [
                      const PopupMenuItem(
                        child: Text("User profile"),
                        value: 0,
                      ),
                      const PopupMenuItem(
                        child: Text("Clear conversation"),
                        value: 1,
                      ),
                    ]
                  : [
                      const PopupMenuItem(
                        child: Text("User profile"),
                        value: 0,
                      ),
                    ];
            },
          ),
        ],
      ),
      body: Obx(
        () => Stack(
          children: [
            _controller.isConversationLoading.value
                ? ListView.separated(
                    itemBuilder: (context, index) => index % 2 == 0
                        ? Align(
                            alignment: Alignment.centerRight,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.6,
                                  height: 40,
                                  child: const BannerShimmer(),
                                )
                              ],
                            ),
                          )
                        : Align(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.6,
                                  height: 50,
                                  child: const BannerShimmer(),
                                )
                              ],
                            ),
                          ),
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 21.0),
                    itemCount: 5,
                  )
                : _controller.currentConversation.value.isEmpty
                    ? const Center(
                        child: TextInter(
                          text: "No conversation found",
                          fontSize: 16,
                        ),
                      )
                    : Column(
                        children: [
                          Expanded(
                            child: ListView.separated(
                              padding: const EdgeInsets.all(10.0),
                              shrinkWrap: true,
                              controller: _scrollController,
                              itemBuilder: (context, index) {
                                return _controller.currentConversation
                                            .value[index]['sender']['id'] ==
                                        widget.manager.getUser()['id']
                                    ? Align(
                                        alignment: Alignment.centerRight,
                                        child: OwnMessageBox(
                                          data: _controller
                                              .currentConversation.value[index],
                                        ),
                                      )
                                    : _controller.currentConversation
                                                    .value[index]['receiver']
                                                ['id'] ==
                                            widget.manager.getUser()['id']
                                        ? Align(
                                            alignment: Alignment.centerLeft,
                                            child: GuestMessageBox(
                                              data: _controller
                                                  .currentConversation
                                                  .value[index],
                                            ),
                                          )
                                        : const SizedBox();
                              },
                              separatorBuilder: (context, index) =>
                                  const SizedBox(
                                height: 21,
                              ),
                              itemCount:
                                  _controller.currentConversation.value.length,
                            ),
                          ),
                          const SizedBox(height: 75),
                        ],
                      ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Form(
                key: _formKey,
                child: Container(
                  padding: const EdgeInsets.all(12.0),
                  width: MediaQuery.of(context).size.width * 0.94,
                  color: Colors.white,
                  child: ChatInputField(
                    hintText: '',
                    focusNode: _focusNode,
                    placeholder: "Your message",
                    onChanged: (val) {
                      if (val.length > 1) {
                        setState(() {
                          isTyping = true;
                        });
                      } else {
                        setState(() {
                          isTyping = false;
                        });
                      }
                    },
                    controller: _inputController,
                    validator: (value) {},
                    inputType: TextInputType.text,
                    endIcon: IconButton(
                      onPressed: !isTyping
                          ? null
                          : () {
                              _postMessage();
                            },
                      icon: Icon(
                        Icons.send,
                        color: !isTyping
                            ? Colors.grey.withOpacity(0.5)
                            : Constants.primaryColor,
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  _refreshChatList() async {
    try {
      final _prefs = await SharedPreferences.getInstance();
      final _token = _prefs.getString("accessToken") ?? "";
      final _user = _prefs.getString("user") ?? "";
      Map<String, dynamic> userMap = jsonDecode(_user);

      final chatResp = await APIService().getUsersChats(
        accessToken: _token,
        email: userMap['email'],
        userId: userMap['id'],
      );
      debugPrint("MY CHATS RESPONSE >> ${chatResp.body}");
      if (chatResp.statusCode == 200) {
        Map<String, dynamic> chatMap = jsonDecode(chatResp.body);
        _controller.myChats.value = chatMap['data'];
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  _postMessage() async {
    Map _body = {
      "message": _inputController.text,
      "chatId": widget.data['chatId'],
      "receiver": {
        "id": user1Id == widget.manager.getUser()['id'] ? user2Id : user1Id,
        "name": _getOtherUserName(),
        "photo": _getOtherUserPhoto(),
      },
      "sender": {
        "id": widget.manager.getUser()['id'],
        "name":
            "${widget.manager.getUser()['bio']['firstname']} ${widget.manager.getUser()['bio']['middlename']} ${widget.manager.getUser()['bio']['lastname']}",
        "photo": widget.manager.getUser()['bio']['image'],
      }
    };

    Map _body2 = {
      "message": _inputController.text,
      "chatId": widget.data['_id'],
      "receiver": {
        "id": user1Id == widget.manager.getUser()['id'] ? user2Id : user1Id,
        "name": _getOtherUserName(),
        "photo": _getOtherUserPhoto(),
      },
      "sender": {
        "id": widget.manager.getUser()['id'],
        "name": "${widget.manager.getUser()['bio']['firstname']} ${widget.manager.getUser()['bio']['middlename']} ${widget.manager.getUser()['bio']['lastname']}",
        "photo": widget.manager.getUser()['bio']['image'],
      }
    };

    try {
      final res = await APIService().postMessage(
          accessToken: widget.manager.getAccessToken(),
          email: widget.manager.getUser()['email'],
          payload: widget.caller == "profile" ? _body : _body2);

      if (res.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(res.body);
        _controller.currentConversation.add(map['post']);
        _refreshChatList();

        setState(() {
          _inputController.text = "";
          isTyping = false;
        });
      }

      debugPrint("DATA >> <<>> ${res.body}");
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  _clearChat() {}
}

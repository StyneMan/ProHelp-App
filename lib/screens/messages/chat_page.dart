// import 'dart:convert';

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
// import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart';
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
  var _guestData, _selectedConversationCompare;
  bool _refresh = false;

  bool isTyping = false,
      typing = false,
      loading = true,
      socketConnected = false;
  var messages;
  late Socket socket;

  _init() async {
    socket = SocketManager().socket;
    socket.emit("setup", widget.manager.getUser());
    socket.on("userConnected", (va) {
      setState(() => socketConnected = true);
    });
    socket.on("typing", (val) => setState(() => isTyping = true));
    socket.on("stop typing", (val) => setState(() => isTyping = false));

    for (var element in widget.data['users']) {
      if (element['_id'] != widget.manager.getUser()['id']) {
        setState(() {
          _guestData = element;
        });
      }
    }
  }

  _fetchMessage() async {
    if (_controller.selectedConversation.value.isNotEmpty) {
      try {
        setState(() {
          loading = true;
        });

        final response = await APIService().getConversationsByChatId(
            accessToken: widget.manager.getAccessToken(),
            chatId: _controller.selectedConversation.value['id'],
            email: widget.manager.getUser()['email']);

        debugPrint("THE RESPONSE ::>>:: ${response.body}");
        if (response.statusCode == 200) {
          debugPrint("REACHED HERE LIKE THIS >>> ");
          //  jsonData = json.decode(response.body);
          // dataController.data.value = jsonData;
          // final List<Map<String, dynamic>> map = json.decode(response.body);
          debugPrint("THE RESPONSE MAPPED ::>>:: ");

          setState(() {
            loading = false;
            messages = response.body;
          });

          _controller.currentMessages.value = response.body as List;
        }

        socket.emit("join chat", _controller.selectedConversation.value['id']);
      } catch (e) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _init();
    _fetchMessage();
    _focusNode.addListener(_scrollToBottom);

    _selectedConversationCompare = _controller.selectedConversation.value;

    socket.on("message recieved", (newMessageRecieved) {
      // debugPrint("LOGGING RECEIVED MSG :: $newMessageRecieved");
      // debugPrint("LOGGING 2 :: ${messages}");
      // debugPrint("LOGGING 3 :: ${jsonEncode(newMessageRecieved)}");

      // debugPrint(
      //     "LOGGING RECEIVED MSG ENC :: ${jsonDecode(newMessageRecieved)}");

      // if ( _controller.selectedConversation.value['id']  || // if chat is not selected or doesn't match current chat
      //     _controller.selectedConversation.value['id'] !=
      //         newMessageRecieved['chat']['id']) {
      //   // if (!notification.includes(newMessageRecieved)) {
      //   //   setNotification([newMessageRecieved, ...notification]);
      //   // //   setFetchAgain(!fetchAgain);
      //   // }
      // } else {
      var rawfied = [...jsonDecode(messages), (newMessageRecieved)];

      setState(() {
        messages = jsonEncode(rawfied);
        _refresh = true;
      });

      // }
    });
  }

  @override
  void didUpdateWidget(covariant ChatPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_selectedConversationCompare !=
        _controller.selectedConversation.value) {
      // Fetch messages when the selectedConversation changes
      _fetchMessage();
      _selectedConversationCompare = _controller.selectedConversation.value;
    }
  }

  void _scrollToBottom() {
    print("CUUR POSITION ::: ${_scrollController.position.maxScrollExtent}");
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  _postMessage() async {
    _scrollController.animateTo(
      _scrollController.position.minScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    if (_inputController.text.isNotEmpty) {
      socket.emit("stop typing", _controller.selectedConversation.value['id']);
      final Map _payload = {
        "content": _inputController.text,
        "chatId": _controller.selectedConversation.value['id'],
      };

      try {
        _inputController.clear();
        final response = await APIService().postMessage(
          accessToken: widget.manager.getAccessToken(),
          email: widget.manager.getUser()['email'],
          payload: _payload,
        );
        debugPrint("THE RESPONSE ::: ${response.body}");

        socket.emit("new message", jsonDecode(response.body));
        var rawfied = [...jsonDecode(messages), jsonDecode(response.body)];

        setState(() {
          messages = jsonEncode(rawfied);
        });

        // _controller.currentMessages.value = jsonEncode(rawfied) as List;

        _scrollToBottom();
        // setMessages([...messages, resp.data]);
      } catch (e) {
        debugPrint(e.toString());
      }
    }
  }

  _typingHandler(var val) {
    if (!socketConnected) return;

    if (!typing) {
      setState(() {
        typing = true;
      });

      socket.emit("typing", _controller.selectedConversation.value['id']);

      var lastTypingTime = DateTime.now().millisecondsSinceEpoch;
      var timerLength = 2000;

      Future.delayed(Duration(milliseconds: timerLength), () {
        var timeNow = DateTime.now().millisecondsSinceEpoch;
        var timeDiff = timeNow - lastTypingTime;

        if (timeDiff >= timerLength && typing) {
          socket.emit(
              "stop typing", _controller.selectedConversation.value['id']);
          setState(() {
            typing = false;
          });
        }
      });
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
    print("REFRESH :: $_refresh");

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
            _guestData != null
                ? TextButton(
                    onPressed: () {
                      // Get.to(
                      //   UserProfile2(
                      //     manager: widget.manager,
                      //     name: _getOtherUserName(),
                      //     image: _getOtherUserPhoto(),
                      //     userId: _getOtherUserId(),
                      //     email: _getOtherUserEmail(),
                      //   ),
                      // );
                    },
                    child: Row(
                      children: [
                        ClipOval(
                          child: Container(
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
                                _guestData['bio']['image'] ?? "",
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
                          text:
                              "${_guestData['bio']['firstname']} ${_guestData['bio']['lastname']}"
                                  .capitalize,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Constants.secondaryColor,
                        ),
                      ],
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.all(0.5),
                    ),
                  )
                : const SizedBox(),
          ],
        ),
        centerTitle: true,
        actions: [
          isTyping
              ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: null,
                      child: Text(
                        "Typing...",
                        style: TextStyle(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                )
              : const SizedBox(),
        ],
      ),
      body: Stack(
        children: [
          loading
              ? ListView.separated(
                  itemBuilder: (context, index) => SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: index % 2 == 0
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.6,
                                height: 40,
                                child: const BannerShimmer(),
                              )
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.6,
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
              : messages == null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset('assets/images/empty.png'),
                          const TextInter(
                            text: "No messages found",
                            fontSize: 16,
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            reverse: true,
                            controller: _scrollController,
                            child: ListView.separated(
                              padding: const EdgeInsets.all(10.0),
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (context, index) {
                                final item = jsonDecode(messages)[index];
                                final sender = item['sender'];
                                // final chat = item['chat'];
                                return sender['id'] ==
                                        widget.manager.getUser()['id']
                                    ? Align(
                                        alignment: Alignment.centerRight,
                                        child: OwnMessageBox(
                                          data: item,
                                        ),
                                      )
                                    : Align(
                                        alignment: Alignment.centerLeft,
                                        child: GuestMessageBox(
                                          data: item,
                                        ),
                                      );
                              },
                              separatorBuilder: (context, index) =>
                                  const SizedBox(
                                height: 21,
                              ),
                              itemCount: jsonDecode(messages)?.length,
                            ),
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
                  hintText: 'Your message',
                  focusNode: _focusNode,
                  placeholder: "Your message",
                  onChanged: (val) {
                    _scrollController.animateTo(
                      _scrollController.position.minScrollExtent,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                    _typingHandler(val);
                  },
                  controller: _inputController,
                  validator: (value) {},
                  inputType: TextInputType.text,
                  endIcon: _inputController.text.isEmpty
                      ? const SizedBox()
                      : IconButton(
                          onPressed: () {
                            _postMessage();
                          },
                          icon: const Icon(
                            Icons.telegram,
                          ),
                        ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  // _refreshChatList() async {
  //   try {
  //     final _prefs = await SharedPreferences.getInstance();
  //     final _token = _prefs.getString("accessToken") ?? "";
  //     final _user = _prefs.getString("user") ?? "";
  //     Map<String, dynamic> userMap = jsonDecode(_user);

  //     final chatResp = await APIService().getUsersChats(
  //       accessToken: _token,
  //       email: userMap['email'],
  //     );
  //     debugPrint("MY CHATS RESPONSE >> ${chatResp.body}");
  //     if (chatResp.statusCode == 200) {
  //       Map<String, dynamic> chatMap = jsonDecode(chatResp.body);
  //       _controller.myChats.value = chatMap['data'];
  //     }
  //   } catch (e) {
  //     debugPrint(e.toString());
  //   }
  // }

  _clearChat() {}
}

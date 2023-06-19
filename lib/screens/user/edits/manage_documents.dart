import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'package:loading_overlay_pro/loading_overlay_pro.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:path_provider/path_provider.dart';
import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/forms/documents/add_doc.dart';
import 'package:prohelp_app/helper/constants/constants.dart';
import 'package:prohelp_app/helper/preference/preference_manager.dart';
import 'package:prohelp_app/helper/service/api_service.dart';
import 'package:prohelp_app/helper/state/state_manager.dart';

import 'package:http/http.dart' as http;

class ManageDocuments extends StatefulWidget {
  final List documents;
  final PreferenceManager manager;
  const ManageDocuments({
    Key? key,
    required this.documents,
    required this.manager,
  }) : super(key: key);

  @override
  State<ManageDocuments> createState() => _ManageDocumentsState();
}

class _ManageDocumentsState extends State<ManageDocuments> {
  // final _scaffoldKey = GlobalKey<ScaffoldState>();

  final _controller = Get.find<StateController>();

  Widget get $thisWidget => build(context);

  /// Try setting it to true and see that the default transition from
  /// MaterialPageRoute is combined with [CupertinoFullscreenDialogTransition]
  /// By default material pages use [FadeUpwardsPageTransitionsBuilder]
  bool inheritRouteTransition = false;

  // For production the correct value should be between 400 milliseconds and 1 second
  Duration transitionDuration = const Duration(seconds: 1);

  ReceivePort _port = ReceivePort();

  /// Uses the nearest route to build a transition to [child]
  Widget buildRouteTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    /// Using [this.context] instead of the provided [context]
    /// allows us to make sure we use the route that [this.widget] is being
    /// displayed in instead of the route that our modal will be displayed in
    final route = ModalRoute.of(this.context);

    return route!.buildTransitions(
      context,
      animation,
      secondaryAnimation,
      child,
    );
  }

  @override
  void initState() {
    super.initState();

    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = DownloadTaskStatus(data[1]);
      int progress = data[2];
      setState(() {});
    });

    FlutterDownloader.registerCallback(downloadCallback);
  }

  @pragma('vm:entry-point')
  static void downloadCallback(String id, int status, int progress) {
    final SendPort? send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    debugPrint("STATUS: $id");
    // if (status == 3) {
    //   Constants.toast("File downloaded successfully");
    // }
    send?.send([id, status, progress]);
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  // bool _isClicked = false;
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => LoadingOverlayPro(
        isLoading: _controller.isLoading.value,
        backgroundColor: Colors.black38,
        progressIndicator: const CircularProgressIndicator.adaptive(),
        child: Scaffold(
          appBar: AppBar(
            elevation: 0.0,
            foregroundColor: Constants.secondaryColor,
            backgroundColor: Constants.primaryColor,
            automaticallyImplyLeading: false,
            leading: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 16.0,
                ),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Icon(
                    CupertinoIcons.arrow_left_circle,
                  ),
                ),
                const SizedBox(
                  width: 4.0,
                ),
              ],
            ),
            title: TextPoppins(
              text: "My Documents".toUpperCase(),
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Constants.secondaryColor,
            ),
            centerTitle: true,
            actions: [
              IconButton(
                onPressed: _controller.isLoading.value
                    ? null
                    : () {
                        showBarModalBottomSheet(
                          expand: false,
                          context: context,
                          useRootNavigator: true,
                          backgroundColor: Colors.white,
                          topControl: ClipOval(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(
                                    16,
                                  ),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.close,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          builder: (context) => SizedBox(
                            height: MediaQuery.of(context).size.height * 0.75,
                            child: NewDocumentForm(
                              manager: widget.manager,
                            ),
                          ),
                        );
                      },
                icon: const Icon(CupertinoIcons.add),
              ),
            ],
          ),
          body: widget.manager.getUser()['documents'].isEmpty
              ? Container(
                  width: double.infinity,
                  height: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset('assets/images/empty.png'),
                        const TextInter(
                          text: "No relevant documents attached",
                          fontSize: 16,
                          align: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListView.separated(
                      padding: const EdgeInsets.all(16.0),
                      shrinkWrap: true,
                      itemBuilder: (context, index) => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              widget.manager
                                          .getUser()['documents'][index]
                                              ['extension']
                                          .toString()
                                          .endsWith('png') ||
                                      widget.manager
                                          .getUser()['documents'][index]
                                              ['extension']
                                          .toString()
                                          .endsWith('jpg') ||
                                      widget.manager
                                          .getUser()['documents'][index]
                                              ['extension']
                                          .toString()
                                          .endsWith('jpeg')
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(4.0),
                                      child: Image.network(
                                        "${widget.manager.getUser()['documents'][index]['url']}",
                                        width: 38,
                                        height: 38,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : widget.manager
                                          .getUser()['documents'][index]
                                              ['extension']
                                          .toString()
                                          .endsWith('doc')
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(4.0),
                                          child: Image.asset(
                                            "assets/images/docs.png",
                                            width: 40,
                                            height: 40,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : widget.manager
                                              .getUser()['documents'][index]
                                                  ['extension']
                                              .toString()
                                              .endsWith('pdf')
                                          ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(4.0),
                                              child: Image.asset(
                                                "assets/images/pdf.png",
                                                width: 40,
                                                height: 40,
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          : const Icon(
                                              Icons.document_scanner,
                                            ),
                            ],
                          ),
                          const SizedBox(width: 8.0),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  children: [
                                    TextPoppins(
                                      text:
                                          "${widget.manager.getUser()['documents'][index]['title']}",
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(
                                height: 4.0,
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.download,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  _downloadFile(
                                      "${widget.manager.getUser()['documents'][index]['url']}");
                                },
                              ),
                              IconButton(
                                onPressed: () {
                                  showCupertinoDialog(
                                    context: context,
                                    builder: (context) => CupertinoAlertDialog(
                                      title: TextPoppins(
                                        text: "DELETE DOCUMENT",
                                        fontSize: 18,
                                      ),
                                      content: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.96,
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
                                                        "${widget.manager.getUser()['bio']['fullname']}"
                                                            .split(' ')[0],
                                                    style: const TextStyle(
                                                      color: Colors.green,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  const TextSpan(
                                                    text:
                                                        " confirm that I want to delete this item. Action cannot not be undone. ",
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

                                              _deleteItem(index);
                                            },
                                            child: TextRoboto(
                                              text: "Continue",
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  CupertinoIcons.delete_simple,
                                  size: 18,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 24.0),
                      itemCount: widget.manager.getUser()['documents']?.length,
                    ),
                    const SizedBox(
                      height: 24.0,
                    ),
                    // RoundedButton(bgColor: Constants.primaryColor, child: TextPoppins(text: "SAVE CHANGES", fontSize: fontSize), borderColor: borderColor, foreColor: foreColor, onPressed: onPressed, variant: variant)
                  ],
                ),
        ),
      ),
    );
  }

  Future<void> _downloadFile(String url) async {
    try {
      Directory? directory = Platform.isAndroid
          ? await getExternalStorageDirectory()
          : await getTemporaryDirectory();

      final taskId = await FlutterDownloader.enqueue(
        url: url,
        saveInPublicStorage: true,
        savedDir: "${directory?.path}",
        showNotification: true,
        openFileFromNotification: true,
      );

      FlutterDownloader.loadTasks();
      FlutterDownloader.open(taskId: "$taskId");
    } catch (e) {
      print('DOWNLOAD ERROR >>: $e');
    }
  }

  _deleteItem(index) async {
    _controller.setLoading(true);

    var li = widget.manager.getUser()['documents'];
    var filter = li?.removeAt(index);

    Map _body = {"documents": li};

    try {
      final _resp = await APIService().updateProfile(
        body: _body,
        accessToken: widget.manager.getAccessToken(),
        email: widget.manager.getUser()['email'],
      );

      _controller.setLoading(false);
      debugPrint("DDELETE DOC RESPONSE:: ${_resp.body}");

      if (_resp.statusCode == 200) {
        Map<String, dynamic> _map = jsonDecode(_resp.body);
        Constants.toast(_map['message']);

        //Nw save user's data to preference
        String userData = jsonEncode(_map['data']);
        widget.manager.setUserData(userData);

        // Navigator.of(context).pop();
      } else {
        Map<String, dynamic> _map = jsonDecode(_resp.body);
        Constants.toast(_map['message']);
      }
    } catch (e) {
      debugPrint(e.toString());
      _controller.setLoading(false);
    }
  }
}

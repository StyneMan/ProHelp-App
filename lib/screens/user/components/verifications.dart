import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:prohelp_app/components/button/roundedbutton.dart';
import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/helper/constants/constants.dart';

class VerificationsContent extends StatefulWidget {
  var documents;
  VerificationsContent({
    Key? key,
    required this.documents,
  }) : super(key: key);

  @override
  State<VerificationsContent> createState() => _VerificationsContentState();
}

class _VerificationsContentState extends State<VerificationsContent> {
  ReceivePort _port = ReceivePort();

  int _progress = 0, currIndex = 0;
  bool _isComplete = true; 
  List<Map> rowMaps = [];
  List<Map> downloadsListMaps = [];

  Future task() async {
    List<DownloadTask>? getTasks = await FlutterDownloader.loadTasks();
    getTasks?.forEach((_task) {
      Map _map = Map();
      _map['status'] = _task.status;
      _map['progress'] = _task.progress;
      _map['id'] = _task.taskId;
      _map['filename'] = _task.filename;
      _map['savedDirectory'] = _task.savedDir;
      downloadsListMaps.add(_map);
    });
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = DownloadTaskStatus(data[1]);
      _progress = data[2];
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

  Future<void> _downloadFile(String url, int index) async {
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

      // FlutterDownloader.loadTasks();
      List<DownloadTask>? getTasks = await FlutterDownloader.loadTasks();
      getTasks?.forEach((_task) {
        Map _map = Map();
        _map['index'] = index;
        _map['status'] = _task.status;
        _map['progress'] = _task.progress;
        _map['id'] = _task.taskId;
        _map['filename'] = _task.filename;
        _map['savedDirectory'] = _task.savedDir;
        setState(() {
          _progress = _task.progress;
          downloadsListMaps.add(_map);
        });
      });

      // FlutterDownloader.open(taskId: "$taskId");
    } catch (e) {
      debugPrint('DOWNLOAD ERROR >>: $e');
    }
  }

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
                    text: "Verifications",
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
            widget.documents.isEmpty
                ? const SizedBox(
                    height: 200,
                    child: Center(
                      child:
                          TextInter(text: "No documents found", fontSize: 14),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 16.0,
                        ),
                        ListView.separated(
                          shrinkWrap: true,
                          itemBuilder: (context, index) => Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      widget.documents
                                                  .elementAt(index)['extension']
                                                  .toString()
                                                  .endsWith('png') ||
                                              widget.documents
                                                  .elementAt(index)['extension']
                                                  .toString()
                                                  .endsWith('jpg') ||
                                              widget.documents
                                                  .elementAt(index)['extension']
                                                  .toString()
                                                  .endsWith('jpeg')
                                          ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(4.0),
                                              child: Image.network(
                                                "${widget.documents.elementAt(index)['url']}",
                                                width: 38,
                                                height: 38,
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          : widget.documents
                                                  .elementAt(index)['extension']
                                                  .toString()
                                                  .endsWith('doc')
                                              ? ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          4.0),
                                                  child: Image.asset(
                                                    "assets/images/docs.png",
                                                    width: 40,
                                                    height: 40,
                                                    fit: BoxFit.cover,
                                                  ),
                                                )
                                              : widget.documents
                                                      .elementAt(
                                                          index)['extension']
                                                      .toString()
                                                      .endsWith('pdf')
                                                  ? ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4.0),
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
                                      const SizedBox(
                                        width: 6.0,
                                      ),
                                      TextInter(
                                        text: widget.documents
                                            .elementAt(index)['title'],
                                        fontSize: 16,
                                      ),
                                    ],
                                  ),
                                  InkWell(
                                    child: const Padding(
                                      padding: EdgeInsets.all(4.0),
                                      child: Icon(
                                        Icons.download,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    onTap: () {
                                      setState(() {
                                        currIndex = index;
                                      });
                                      _downloadFile(
                                          "${widget.documents.elementAt(index)['url']}",
                                          index);
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4.0),
                              downloadsListMaps.isNotEmpty
                                  ? index != currIndex
                                      ? const SizedBox()
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Expanded(
                                              child: LinearProgressIndicator(
                                                value: _progress
                                                    .toDouble(), //downloadsListMaps.firstWhere((element) => element['index'] == index)['progress']/100,
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 4.0,
                                            ),
                                            TextInter(
                                              text: "$_progress%",
                                              fontSize: 14,
                                            )
                                          ],
                                        )
                                  : const SizedBox(),
                              const SizedBox(height: 4.0),
                            ],
                          ),
                          separatorBuilder: (context, index) => const Divider(),
                          itemCount: widget.documents.length,
                        ),
                        const SizedBox(
                          height: 24.0,
                        ),
                        // _isComplete
                        // ? const SizedBox()
                        // : Center(
                        //     child: CircularProgressIndicator.adaptive(
                        //       value: _progress.toDouble(),
                        //     ),
                        //   ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 16.0,
                            horizontal: 24.0,
                          ),
                          child: RoundedButton(
                            bgColor: Colors.transparent,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: const [
                                // Icon(
                                //   Icons.edit_document,
                                // ),
                                SizedBox(
                                  width: 10.0,
                                ),
                                TextInter(
                                  text: "Close",
                                  fontSize: 16,
                                  color: Constants.primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ],
                            ),
                            borderColor: Constants.primaryColor,
                            foreColor: Constants.primaryColor,
                            onPressed: !_isComplete
                                ? null
                                : () {
                                    Navigator.pop(context);
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
}

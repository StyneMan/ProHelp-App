import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_overlay_pro/loading_overlay_pro.dart';
import 'package:path_provider/path_provider.dart';
import 'package:prohelp_app/components/drawer/custom_drawer.dart';
import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/helper/constants/constants.dart';
import 'package:prohelp_app/helper/preference/preference_manager.dart';
import 'package:prohelp_app/helper/state/state_manager.dart';
import 'package:timeago/timeago.dart' as timeago;

class ViewApplication extends StatefulWidget {
  final PreferenceManager manager;
  var data;
  ViewApplication({
    Key? key,
    required this.manager,
    required this.data,
  }) : super(key: key);

  @override
  State<ViewApplication> createState() => _ViewApplicationState();
}

class _ViewApplicationState extends State<ViewApplication> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _controller = Get.find<StateController>();
  ReceivePort _port = ReceivePort();
  bool _isDownloading = false;

  int _progress = 0, currIndex = 0;
  // bool _isComplete = true;
  List<Map> rowMaps = [];
  List<Map> downloadsListMaps = [];
  String _extension = "";

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

    try {
      final ex =
          widget.data['resume'].toString().split("resumes")[1].split("?alt")[0];
      setState(() {
        _extension = ex;
      });
    } catch (e) {
      debugPrint(e.toString());
    }

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

      // FlutterDownloader.loadTasks();
      List<DownloadTask>? getTasks = await FlutterDownloader.loadTasks();
      getTasks?.forEach((_task) {
        Map _map = Map();
        _map['status'] = _task.status;
        _map['progress'] = _task.progress;
        _map['id'] = _task.taskId;
        _map['filename'] = _task.filename;
        _map['savedDirectory'] = _task.savedDir;
        setState(() {
          _progress = _task.progress;
          downloadsListMaps.add(_map);
          _isDownloading = false;
        });
      });

      // FlutterDownloader.open(taskId: "$taskId");
    } catch (e) {
      debugPrint('DOWNLOAD ERROR >>: $e');
    }
  }

  String timeUntil(DateTime date) {
    return timeago.format(date, locale: "en", allowFromNow: true);
  }

  // Future<void> _downloadFile(String url) async {
  //   try {
  //     setState(() {
  //       _isDownloading = true;
  //     });
  //     Directory? directory = Platform.isAndroid
  //         ? await getExternalStorageDirectory()
  //         : await getTemporaryDirectory();

  //     final taskId = await FlutterDownloader.enqueue(
  //       url: url,
  //       saveInPublicStorage: true,
  //       savedDir: "${directory?.path}",
  //       showNotification: true,
  //       openFileFromNotification: true,
  //     );

  //     FlutterDownloader.loadTasks();
  //     // FlutterDownloader.open(taskId: "$taskId");
  //     setState(() {
  //       _isDownloading = false;
  //     });
  //   } catch (e) {
  //     print('DOWNLOAD ERROR >>: $e');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    // print("RESUME >> ${widget.data['resume']}");
    return Obx(
      () => LoadingOverlayPro(
        isLoading: _controller.isLoading.value,
        backgroundColor: Colors.black45,
        progressIndicator: const CircularProgressIndicator.adaptive(),
        child: Scaffold(
          key: _scaffoldKey,
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
              text: "Application info".toUpperCase(),
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Constants.secondaryColor,
            ),
            centerTitle: true,
            actions: [
              IconButton(
                onPressed: () {
                  if (!_scaffoldKey.currentState!.isEndDrawerOpen) {
                    _scaffoldKey.currentState!.openEndDrawer();
                  }
                },
                icon: SvgPicture.asset(
                  'assets/images/menu_icon.svg',
                  color: Constants.secondaryColor,
                ),
              ),
            ],
          ),
          endDrawer: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: CustomDrawer(
              manager: widget.manager,
            ),
          ),
          body: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(16.0),
            children: [
              const SizedBox(height: 10.0),
              TextPoppins(
                text: "${widget.data['job']['jobTitle']}".toUpperCase(),
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Image.network(
                      widget.data['applicant']['bio']['image'],
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          SvgPicture.asset(
                        "assets/images/personal_icon.svg",
                        width: 56,
                        height: 56,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextPoppins(
                        text:
                            "${widget.data['applicant']['bio']['firstname']} ${widget.data['applicant']['bio']['lastname']}"
                                .capitalize,
                        fontSize: 13,
                      ),
                      TextPoppins(
                        text: "${widget.data['applicant']['email']}",
                        fontSize: 12,
                      ),
                      TextPoppins(
                        text: "${widget.data['applicant']['bio']['phone']}",
                        fontSize: 12,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              TextPoppins(
                text:
                    "Applied on ${DateFormat('dd/MM/yyyy').format(DateTime.parse(widget.data['createdAt']))} (${timeUntil(DateTime.parse("${widget.data['createdAt']}"))})"
                        .replaceAll("about", "")
                        .replaceAll("minute", "min"),
                fontSize: 14,
              ),
              const SizedBox(height: 21.0),
              TextPoppins(
                text: "Job Information",
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    CupertinoIcons.bag_fill,
                    color: Colors.black54,
                    size: 28,
                  ),
                  const SizedBox(
                    width: 16.0,
                  ),
                  TextPoppins(
                    text: "${widget.data['job']['jobType']}".capitalize,
                    fontSize: 16,
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.track_changes_rounded,
                    color: Colors.black54,
                    size: 28,
                  ),
                  const SizedBox(
                    width: 16.0,
                  ),
                  TextPoppins(
                    text: "${widget.data['job']['jobStatus']}".capitalize,
                    fontSize: 16,
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              TextPoppins(
                text: "Description",
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
              Text(
                "${widget.data['job']['description']}".capitalizeFirst!,
              ),
              const SizedBox(height: 21.0),
              TextPoppins(
                text: "Minimun qualification",
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
              Text(
                "${widget.data['job']['minimumQualification']}"
                    .capitalizeFirst!,
              ),
              const SizedBox(height: 21.0),
              TextPoppins(
                text: "Applicant's Resume",
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
              Row(
                children: [
                  _extension.endsWith('png')
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(4.0),
                          child: Image.asset(
                            "assets/images/placeholder.png",
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          ),
                        )
                      : _extension.endsWith('doc') ||
                              _extension.endsWith('docx')
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(4.0),
                              child: Image.asset(
                                "assets/images/docs.png",
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                              ),
                            )
                          : _extension.endsWith('pdf')
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(4.0),
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
                    width: 16.0,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.70,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TextPoppins(
                          text:
                              "${widget.data['applicant']['bio']['firstname']}'s Resume"
                                  .capitalize,
                          fontSize: 14,
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() => _isDownloading = true);
                            _downloadFile("${widget.data['resume']}");
                          },
                          icon: const Icon(Icons.download_rounded),
                        ),
                        _isDownloading
                            ? CircularProgressIndicator.adaptive(
                                value: _progress.toDouble(),
                              )
                            : const SizedBox()
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 21.0),
              TextPoppins(
                text: "Screening Answers",
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
              Column(
                children: [
                  for (var k = 0; k < widget.data['answers']?.length; k++)
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "${k + 1}.",
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.80,
                                  child: Text(
                                    "${widget.data['answers'][k]['question']}",
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.80,
                                  child: Text(
                                    "${widget.data['answers'][k]['answer']}",
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                ],
              ),
              const SizedBox(height: 21.0),
            ],
          ),
        ),
      ),
    );
  }
}

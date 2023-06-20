import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_overlay_pro/loading_overlay_pro.dart';
import 'package:prohelp_app/components/dialog/info_dialog.dart';
import 'package:prohelp_app/components/shimmer/pros_shimmer.dart';
import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/helper/constants/constants.dart';
import 'package:prohelp_app/helper/preference/preference_manager.dart';
import 'package:prohelp_app/helper/service/api_service.dart';
import 'package:prohelp_app/helper/state/state_manager.dart';

import 'components/reviews_row.dart';
import 'components/write_review.dart';

class ViewReviews extends StatefulWidget {
  var data;
  final PreferenceManager manager;
  ViewReviews({
    Key? key,
    required this.data,
    required this.manager,
  }) : super(key: key);

  @override
  State<ViewReviews> createState() => _ViewReviewsState();
}

class _ViewReviewsState extends State<ViewReviews> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _controller = Get.find<StateController>();
  bool _isReviewed = false;

  Stream<List<dynamic>> fetchDataStream() {
    final controller = StreamController<List<dynamic>>();
    APIService()
        .getReviewsByUserIdStreamed(
            accessToken: widget.manager.getAccessToken(),
            email: widget.manager.getUser()['email'],
            userId: widget.data['id'])
        .then((resp) => controller.add(resp))
        .catchError((error) => controller.addError(error));
    return controller.stream;
  }

  _checkReviewed() {
    for (var i = 0; i < widget.data['reviews']?.length; i++) {
      if (widget.data['reviews'][i]['reviewer'] ==
          widget.manager.getUser()['id']) {
        setState(() {
          _isReviewed = true;
        });
      } else {
        setState(() {
          _isReviewed = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _checkReviewed();
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
              text: "Reviews".toUpperCase(),
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Constants.secondaryColor,
            ),
            centerTitle:
                (widget.manager.getUser()['id'] == widget.data['id'] ||
                        _isReviewed)
                    ? true
                    : false,
            actions: [
              (widget.manager.getUser()['id'] == widget.data['id'] ||
                      _isReviewed)
                  ? const SizedBox()
                  : TextButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return SizedBox(
                              // height: 300,
                              width: MediaQuery.of(context).size.width * 0.98,
                              child: InfoDialog(
                                body: WriteReview(
                                  data: widget.data,
                                  manager: widget.manager,
                                ),
                              ),
                            );
                          },
                        );
                      },
                      icon: const Icon(Icons.edit_document),
                      label: const Text("Add"),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                      ),
                    )
            ],
          ),
          body: StreamBuilder<List<dynamic>>(
            stream: fetchDataStream(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                // Data is available, use it to build the UI
                final mdata = snapshot.data!;
                debugPrint("REVIEWS DATA  $mdata");
                return ListView.separated(
                  itemCount: mdata.length,
                  padding: const EdgeInsets.all(10.0),
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final item = mdata[index];
                    return ReviewRow(
                      manager: widget.manager,
                      data: item,
                      userData: widget.data,
                    );
                  },
                );
              } else if (snapshot.hasError) {
                // Error occurred while fetching data
                return Text('Error: ${snapshot.error}');
              } else if (!snapshot.hasData) {
                // No data found
                return Container(
                  width: double.infinity,
                  height: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                         Image.asset('assets/images/empty.png'),
                        const TextInter(text: "No reviews found", fontSize: 16),
                        widget.manager.getUser()['id'] == widget.data['id']
                            ? const SizedBox()
                            : TextButton.icon(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return SizedBox(
                                        // height: 300,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.98,
                                        child: InfoDialog(
                                          body: WriteReview(
                                            data: widget.data,
                                            manager: widget.manager,
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                                icon: const Icon(
                                  Icons.edit_document,
                                  size: 16,
                                ),
                                label: const Text("Write review"),
                              ),
                      ],
                    ),
                  ),
                );
              } else {
                // Data is still loading
                return ListView.separated(
                  itemBuilder: (context, index) => const ProsShimmer(),
                  separatorBuilder: (context, index) => const Divider(),
                  itemCount: 3,
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

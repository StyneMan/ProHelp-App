import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:page_transition/page_transition.dart';
import 'package:prohelp_app/components/button/custombutton.dart';
import 'package:prohelp_app/components/drawer/custom_drawer.dart';
import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/helper/constants/constants.dart';
import 'package:prohelp_app/helper/preference/preference_manager.dart';
import 'package:prohelp_app/helper/service/api_service.dart';
import 'package:prohelp_app/screens/account/about.dart';
import 'package:prohelp_app/screens/connections/connection.dart';
import 'package:prohelp_app/screens/reviews/reviews.dart';
import 'package:prohelp_app/screens/user/components/education_section.dart';
import 'package:prohelp_app/screens/user/components/experience_section.dart';
import 'package:prohelp_app/helper/state/state_manager.dart';
import 'package:prohelp_app/screens/user/edits/manage_skills.dart';

import '../connections/manage_connections.dart';
import 'edits/manage_documents.dart';

class MyProfile extends StatefulWidget {
  final PreferenceManager manager;
  const MyProfile({
    Key? key,
    required this.manager,
  }) : super(key: key);

  @override
  State<MyProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<MyProfile> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _controller = Get.find<StateController>();
  var currentProfession;
  bool _isConnectionRequestReceived = false;
  var _connectionCount = 0;
  String _professionBanner = "";

  _init() {
    print("PROFESSIONS ::: ${_controller.allProfessions.value}");
    if (_controller.allProfessions.value.isNotEmpty &&
        widget.manager.getUser()['profession'].isNotEmpty) {
      final result = _controller.allProfessions.value.where((p0) =>
          p0?['name']?.toLowerCase() ==
          widget.manager.getUser()['profession']?.toLowerCase());

      if (mounted) {
        // setState(() {
        currentProfession = result.first;
        // });
      }
    }
  }

  _checkConnection() {
    for (var element in widget.manager.getUser()['pendingReceivedConnect']) {
      if (element == widget.manager.getUser()['id']) {
        setState(() {
          _isConnectionRequestReceived = true;
        });
      }
    }
  }

  _setBanner() {
    if (_controller.allProfessions.value.isNotEmpty &&
        widget.manager.getUser()['accountType'] != "recruiter") {
      var pro = _controller.allProfessions.value.where((item) =>
          item['name'].toLowerCase() ==
          widget.manager.getUser()['profession']?.toLowerCase());
      try {
        if (mounted) {
          setState(() {
            _professionBanner = "${pro.first['image']}";
          });
        }
      } catch (e) {
        print("$e");
      }
    }
  }

  @override
  void initState() {
    _init();
    _setBanner();
    _checkConnection();
    super.initState();

    APIService()
        .getUserConnectionsStreamed(
      accessToken: widget.manager.getAccessToken(),
      email: widget.manager.getUser()['email'],
    )
        .listen((event) {
      Map<String, dynamic> map = jsonDecode(event.body);
      print("CONNECTIONS STREAM LISTENER ::: ${jsonEncode(map)}");
      setState(() {
        _connectionCount = 0;
      });
      if (mounted) {
        setState(() {
          _connectionCount = map['totalDocs'] ?? 0;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      endDrawer: CustomDrawer(
        manager: widget.manager,
      ),
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          ListView(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.25,
                    child:
                        widget.manager.getUser()['accountType'] == "recruiter"
                            ? Image.asset(
                                "assets/images/recruiter_prohelp.webp",
                                fit: BoxFit.cover,
                              )
                            : Image.network(
                                "$_professionBanner",
                                fit: BoxFit.cover,
                              ),
                  ),
                  Positioned(
                    bottom: 0.0,
                    left: 0.0,
                    right: 0.0,
                    top: 8.0,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color.fromARGB(200, 0, 0, 0),
                            Color.fromARGB(0, 0, 0, 0)
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 56.0,
                        horizontal: 20.0,
                      ),
                      child: const SizedBox(
                        height: 48.0,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    bottom: -Constants.avatarRadius,
                    child: CircleAvatar(
                      backgroundColor: Constants.secondaryColor,
                      radius: Constants.avatarRadius,
                      child: ClipOval(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(Constants.avatarRadius),
                            ),
                            border: Border.all(
                              color: Colors.white,
                              width: 1.0,
                            ),
                          ),
                          child: Image.network(
                            widget.manager.getUser()['bio']['image'],
                            fit: BoxFit.cover,
                            width: Constants.avatarRadius + 48,
                            height: Constants.avatarRadius + 48,
                            errorBuilder: (context, url, error) =>
                                SvgPicture.asset(
                              "assets/images/personal.svg",
                              fit: BoxFit.cover,
                              width: Constants.avatarRadius + 40,
                              height: Constants.avatarRadius + 40,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -Constants.avatarRadius + 24,
                    left: (Constants.avatarRadius * 2) - 6,
                    child: ClipOval(
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                        ),
                        child: Center(
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(9),
                              color: !widget.manager.getUser()['isVerified']
                                  ? Constants.golden
                                  : Colors.green,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: (Constants.avatarRadius * 2) + 12,
                    ),
                    Expanded(
                      flex: 2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              !widget.manager.getUser()['isVerified']
                                  ? TextPoppins(
                                      text: "Not verified",
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Constants.golden,
                                    )
                                  : TextPoppins(
                                      text: "Verified",
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.green,
                                    ),
                              const SizedBox(
                                width: 4.0,
                              ),
                              const IconButton(
                                onPressed: null,
                                icon: Padding(
                                  padding: EdgeInsets.all(1.2),
                                  child: SizedBox(),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 8.0,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 1.0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextPoppins(
                      text:
                          "${widget.manager.getUser()['bio']['firstname']} ${widget.manager.getUser()['bio']['middlename']} ${widget.manager.getUser()['bio']['lastname']}"
                              .capitalize,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                    TextPoppins(
                      text: "${widget.manager.getUser()['profession']}"
                          .capitalize,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        RatingBar.builder(
                          initialRating: "${widget.manager.getUser()['rating']}"
                                  .contains(".")
                              ? widget.manager.getUser()['rating']
                              : (widget.manager.getUser()['rating'] ?? 0)
                                      .toDouble() ??
                                  0.0,
                          // ['rating'] ?? 0.0,
                          minRating: 1,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          ignoreGestures: true,
                          itemCount: 5,
                          itemSize: 21,
                          itemPadding:
                              const EdgeInsets.symmetric(horizontal: 0.0),
                          itemBuilder: (context, _) => const Icon(
                            Icons.star,
                            size: 18,
                            color: Colors.amber,
                          ),
                          onRatingUpdate: (rating) {
                            debugPrint("$rating");
                          },
                        ),
                        const SizedBox(
                          width: 4.0,
                        ),
                        TextPoppins(
                          text:
                              "(${widget.manager.getUser()['reviews']?.length} reviews)",
                          fontSize: 12,
                        ),
                      ],
                    ),
                    widget.manager.getUser()['accountType'] == "recruiter"
                        ? const SizedBox()
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 5.0,
                              ),
                              SizedBox(
                                child: TextPoppins(
                                  text:
                                      "${widget.manager.getUser()['address']['city']} ${widget.manager.getUser()['address']['state']}, ${widget.manager.getUser()['address']['country']}"
                                          .capitalize,
                                  fontSize: 13,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(
                                width: 5.0,
                              ),
                              const Icon(
                                Icons.circle,
                                size: 6,
                                color: Colors.black87,
                              ),
                              const SizedBox(
                                width: 5.0,
                              ),
                              TextPoppins(
                                text:
                                    "$_connectionCount ${_connectionCount > 1 ? "Connections " : "Connection"}",
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Constants.primaryColor,
                              ),
                            ],
                          ),
                    widget.manager.getUser()['accountType'] == "recruiter"
                        ? const SizedBox()
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Wrap(
                                spacing: 0,
                                runSpacing: -8,
                                alignment: WrapAlignment.start,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children:
                                    widget.manager.getUser()['skills']?.isEmpty
                                        ? const [
                                            Center(
                                              child: TextInter(
                                                text:
                                                    "You have not added any skill",
                                                fontSize: 12,
                                              ),
                                            )
                                          ]
                                        : [
                                            for (var m = 0;
                                                m <
                                                    _controller
                                                        .userData
                                                        .value['skills']
                                                        ?.length;
                                                m++)
                                              Chip(
                                                label: TextPoppins(
                                                  text:
                                                      "${_controller.userData.value['skills'][m]['name']}"
                                                          .capitalize,
                                                  fontSize: 12,
                                                ),
                                              ),
                                          ],
                              ),
                              TextButton.icon(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    PageTransition(
                                      type: PageTransitionType.size,
                                      alignment: Alignment.bottomCenter,
                                      child: ManageSkills(
                                        manager: widget.manager,
                                        skills: _controller
                                            .userData.value['skills'],
                                        profession: currentProfession,
                                      ),
                                    ),
                                  );
                                },
                                icon: Icon(
                                  (_controller.userData.value['skills'] ??
                                                  widget.manager
                                                      .getUser()['skill'])
                                              ?.length ==
                                          5
                                      ? CupertinoIcons.pen
                                      : CupertinoIcons.add,
                                  size: 13,
                                ),
                                label: TextInter(
                                  text: widget.manager
                                              .getUser()['skill']
                                              ?.length ==
                                          5
                                      ? ""
                                      : widget.manager.getUser()[
                                                      'accountType'] !=
                                                  "recruiter" &&
                                              widget.manager
                                                  .getUser()['skills']
                                                  .isEmpty
                                          ? "Add skill"
                                          : "More",
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                    const SizedBox(
                      height: 8.0,
                    ),
                    SizedBox(
                      height: 36,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: CustomButton(
                              borderRadius: 36.0,
                              paddingY: 1.0,
                              bgColor: Constants.primaryColor,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    widget.manager.getUser()['accountType'] ==
                                            "recruiter"
                                        ? !_isConnectionRequestReceived
                                            ? Icons.visibility
                                            : Icons.pending_actions
                                        : _isConnectionRequestReceived
                                            ? Icons.pending_actions
                                            : CupertinoIcons.person_3,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(
                                    width: 2.0,
                                  ),
                                  TextPoppins(
                                    text: _isConnectionRequestReceived
                                        ? "Accept"
                                        : "Connections",
                                    fontSize: 11,
                                    color: Colors.white,
                                  )
                                ],
                              ),
                              borderColor: Colors.transparent,
                              foreColor: Colors.white,
                              onPressed: _isConnectionRequestReceived
                                  ? () {
                                      // Accept Request here
                                    }
                                  : () {
                                      Navigator.of(context).push(
                                        PageTransition(
                                          type: PageTransitionType.size,
                                          alignment: Alignment.bottomCenter,
                                          child: Connection(
                                            manager: widget.manager,
                                            caller: "me",
                                          ),
                                        ),
                                      );
                                    },
                              variant: "Filled",
                            ),
                          ),
                          const SizedBox(
                            width: 3.0,
                          ),
                          widget.manager
                                      .getUser()['accountType']
                                      .toString()
                                      .toLowerCase() ==
                                  "recruiter"
                              ? const SizedBox()
                              : Expanded(
                                  child: CustomButton(
                                    borderRadius: 36.0,
                                    paddingY: 1.0,
                                    bgColor: Colors.grey.shade400,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.rate_review_sharp,
                                          size: 14,
                                        ),
                                        const SizedBox(
                                          width: 5.0,
                                        ),
                                        TextPoppins(
                                          text: "Reviews",
                                          fontSize: 13,
                                        )
                                      ],
                                    ),
                                    borderColor: Colors.transparent,
                                    foreColor: Colors.black,
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        PageTransition(
                                          type: PageTransitionType.size,
                                          alignment: Alignment.bottomCenter,
                                          child: ViewReviews(
                                            manager: widget.manager,
                                            data: widget.manager.getUser(),
                                          ),
                                        ),
                                      );
                                    },
                                    variant: "Filled",
                                  ),
                                ),
                          const SizedBox(
                            width: 3.0,
                          ),
                          Expanded(
                            child: CustomButton(
                              borderRadius: 36.0,
                              paddingY: 1.0,
                              bgColor: const Color(0xFF07B4B4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    widget.manager.getUser()['accountType'] ==
                                            "recruiter"
                                        ? Icons.reviews
                                        : Icons.edit_document,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                  const SizedBox(
                                    width: 5.0,
                                  ),
                                  TextPoppins(
                                    text: widget.manager
                                                .getUser()['accountType'] ==
                                            "recruiter"
                                        ? "Reviews"
                                        : "Documents",
                                    fontSize: 11,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                              borderColor: Colors.transparent,
                              foreColor: Colors.white,
                              onPressed: () {
                                Get.to(
                                  widget.manager.getUser()['accountType'] ==
                                          "recruiter"
                                      ? ViewReviews(
                                          manager: widget.manager,
                                          data: widget.manager.getUser(),
                                        )
                                      : ManageDocuments(
                                          documents: _controller
                                              .userData.value['documents'],
                                          manager: widget.manager,
                                        ),
                                );
                              },
                              variant: "Filled",
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 16.0,
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey,
                          width: 0.75,
                        ),
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              TextPoppins(
                                text: "About",
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).push(
                                    PageTransition(
                                      type: PageTransitionType.size,
                                      alignment: Alignment.bottomCenter,
                                      child: AboutMe(
                                        manager: widget.manager,
                                      ),
                                    ),
                                  );
                                },
                                child: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Icon(
                                    Icons.edit,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 4.0,
                          ),
                          Text(
                            "${widget.manager.getUser()['bio']['about'] ?? ""}",
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    widget.manager.getUser()['accountType'] == "recruiter"
                        ? const SizedBox()
                        : const SizedBox(
                            height: 16.0,
                          ),
                    widget.manager.getUser()['accountType'] == "recruiter"
                        ? const SizedBox()
                        : ExperienceSection(
                            data: widget.manager.getUser()['experience'],
                            manager: widget.manager,
                          ),
                    const SizedBox(
                      height: 16.0,
                    ),
                    widget.manager.getUser()['accountType'] == "recruiter"
                        ? const SizedBox()
                        : EducationSection(
                            data: widget.manager.getUser()['education'],
                            manager: widget.manager,
                          ),
                    const SizedBox(
                      height: 36.0,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 36,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(
                    CupertinoIcons.arrow_left_circle,
                    color: Colors.white,
                  ),
                ),
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
          )
        ],
      ),
    );
  }
}

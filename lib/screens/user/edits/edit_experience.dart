import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_overlay_pro/loading_overlay_pro.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/forms/education/add_edu_form.dart';
import 'package:prohelp_app/forms/education/edit_edu_form.dart';
import 'package:prohelp_app/forms/experience/add_experience_form.dart';
import 'package:prohelp_app/forms/experience/edit_experience_form.dart';
import 'package:prohelp_app/helper/constants/constants.dart';
import 'package:prohelp_app/helper/preference/preference_manager.dart';
import 'package:prohelp_app/helper/service/api_service.dart';
import 'package:prohelp_app/helper/state/state_manager.dart';

import '../components/dialog_body.dart';

class ManageExperience extends StatefulWidget {
  final List experience;
  final PreferenceManager manager;
  ManageExperience({
    Key? key,
    required this.experience,
    required this.manager,
  }) : super(key: key);

  @override
  State<ManageExperience> createState() => _ManageExperienceState();
}

class _ManageExperienceState extends State<ManageExperience> {
  // final _scaffoldKey = GlobalKey<ScaffoldState>();

  final _controller = Get.find<StateController>();

  Widget get $thisWidget => build(context);

  /// Try setting it to true and see that the default transition from
  /// MaterialPageRoute is combined with [CupertinoFullscreenDialogTransition]
  /// By default material pages use [FadeUpwardsPageTransitionsBuilder]
  bool inheritRouteTransition = false;

  // For production the correct value should be between 400 milliseconds and 1 second
  Duration transitionDuration = const Duration(seconds: 1);

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
    _controller.shouldExitExpEdu.value = false;
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
              text: "Work Experience".toUpperCase(),
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Constants.secondaryColor,
            ),
            centerTitle: true,
            actions: [
              IconButton(
                onPressed: () {
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
                      height: MediaQuery.of(context).size.height * 0.90,
                      child: NewExperienceForm(
                        manager: widget.manager,
                      ),
                    ),
                  );
                },
                icon: const Icon(CupertinoIcons.add),
              ),
            ],
          ),
          body: widget.manager.getUser()['experience'].isEmpty
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
                          text: "No work experience found",
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
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16.0),
                            child: Image.network(
                              widget.manager.getUser()['experience'][index]
                                  ['companyLogo'],
                              errorBuilder: (context, error, stackTrace) =>
                                  Image.asset(
                                "assets/images/placeholder.png",
                                width: 75,
                                height: 75,
                                fit: BoxFit.cover,
                              ),
                              width: 75,
                              height: 75,
                              fit: BoxFit.cover,
                            ),
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
                                          "${widget.manager.getUser()['experience'][index]['role']}",
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ],
                                ),
                                TextInter(
                                  text:
                                      "${widget.manager.getUser()['experience'][index]['company']} . ${widget.manager.getUser()['experience'][index]['workType']}",
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    TextInter(
                                      text:
                                          "${widget.manager.getUser()['experience'][index]['startDate']}",
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    const SizedBox(
                                      width: 10.0,
                                    ),
                                    TextInter(
                                      text: widget.manager
                                                  .getUser()['experience']
                                              [index]['stillSchooling']
                                          ? "Still a student"
                                          : "${widget.manager.getUser()['experience'][index]['endate']}",
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ],
                                ),
                                TextInter(
                                  text:
                                      "${widget.manager.getUser()['experience'][index]['region']} . ${widget.manager.getUser()['experience'][index]['country']}",
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ],
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              IconButton(
                                onPressed: () {
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
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.90,
                                      child: EditExperienceForm(
                                        index: index,
                                        manager: widget.manager,
                                        itemData: widget.manager
                                            .getUser()['experience'][index],
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.edit, size: 18),
                              ),
                              const SizedBox(
                                height: 4.0,
                              ),
                              IconButton(
                                onPressed: () {
                                  showCupertinoDialog(
                                    context: context,
                                    builder: (context) => CupertinoAlertDialog(
                                      title: TextPoppins(
                                        text: "DELETE EXPERIENCE",
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
                      itemCount: widget.manager.getUser()['experience']?.length,
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

  _deleteItem(index) async {
    _controller.setLoading(true);

    var li = widget.manager.getUser()['experience'];
    var filter = li?.removeAt(index);

    Map _body = {"experience": li};

    try {
      final _resp = await APIService().updateProfile(
        body: _body,
        accessToken: widget.manager.getAccessToken(),
        email: widget.manager.getUser()['email'],
      );

      _controller.setLoading(false);
      debugPrint("EXP NEW RESPONSE:: ${_resp.body}");

      if (_resp.statusCode == 200) {
        Map<String, dynamic> _map = jsonDecode(_resp.body);
        Constants.toast(_map['message']);

        //Nw save user's data to preference
        String userData = jsonEncode(_map['data']);
        widget.manager.setUserData(userData);

        Navigator.of(context).pop();
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

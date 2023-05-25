// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:prohelp_app/components/drawer/custom_drawer.dart';
import 'package:prohelp_app/components/inputfield/searchfield.dart';
import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/helper/constants/constants.dart';
import 'package:prohelp_app/helper/preference/preference_manager.dart';
import 'package:prohelp_app/helper/state/state_manager.dart';
import 'package:prohelp_app/screens/messages/components/message_row.dart';

class Messages extends StatelessWidget {
  final PreferenceManager manager;
  Messages({
    Key? key,
    required this.manager,
  }) : super(key: key);

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _controller = Get.find<StateController>();
  final _searchController = TextEditingController();

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    manager.getUser()['bio']['image'] ?? "",
                    errorBuilder: (context, error, stackTrace) => const Icon(
                        CupertinoIcons.person_alt,
                        size: 21,
                        color: Colors.white),
                    width: 24,
                    height: 24,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: 4.0,
            ),
          ],
        ),
        title: TextPoppins(
          text: "Messages".toUpperCase(),
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
          manager: manager,
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: _controller.myChats.isEmpty || _controller.myChats.value.isEmpty
            ? Center(
                child: TextInter(
                  text:
                      "Not chats found. Connect with ${manager.getUser()['accountType'] == "recruiter" ? "professionals" : "job recruiters"} and start chatting!",
                  fontSize: 16,
                  align: TextAlign.center,
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 10.0,
                  ),
                  SearchField(
                    hintText: "Search",
                    onChanged: (val) {},
                    controller: _searchController,
                    validator: (val) {},
                    inputType: TextInputType.text,
                  ),
                  const SizedBox(
                    height: 21.0,
                  ),
                  Expanded(
                    child: Obx(
                      () => ListView.separated(
                        shrinkWrap: true,
                        itemBuilder: (context, index) => MessageRow(
                          manager: manager,
                          data: _controller.myChats.value.elementAt(index),
                        ),
                        separatorBuilder: (context, index) => const SizedBox(
                          height: 16.0,
                        ),
                        itemCount: _controller.myChats.value.length,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

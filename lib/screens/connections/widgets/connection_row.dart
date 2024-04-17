import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:prohelp_app/components/button/roundedbutton.dart';
import 'package:prohelp_app/components/dialog/info_dialog.dart';
import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/helper/constants/constants.dart';
import 'package:prohelp_app/helper/preference/preference_manager.dart';
import 'package:prohelp_app/helper/service/api_service.dart';
import 'package:prohelp_app/helper/state/state_manager.dart';

class ConnectionRow extends StatefulWidget {
  var data;
  final PreferenceManager manager;
  ConnectionRow({
    Key? key,
    required this.data,
    required this.manager,
  }) : super(key: key);

  @override
  State<ConnectionRow> createState() => _ConnectionRowState();
}

class _ConnectionRowState extends State<ConnectionRow> {
  final _controller = Get.find<StateController>();

  Widget _confirmationContent(
          {required String title, required String message}) =>
      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16.0),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextPoppins(text: message, fontSize: 13),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Get.back();
                    },
                    child: TextPoppins(
                      text: "Close",
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 10.0,
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (title.contains('Decline')) {
                        _declineRequest();
                      } else {
                        _acceptRequest();
                      }
                    },
                    child: TextPoppins(
                      text: "Yes, Proceed",
                      fontSize: 13,
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      );

  _confirmDecline() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.4,
          width: MediaQuery.of(context).size.width * 0.98,
          child: InfoDialog(
            body: Wrap(
              children: [
                _confirmationContent(
                  title: 'Decline Connection Request',
                  message:
                      "Are you sure you want to decline this connection request from ${widget.data['user']['bio']['firstname']} ${widget.data['user']['bio']['lastname']}? ",
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  _confirmAccept() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.4,
          width: MediaQuery.of(context).size.width * 0.98,
          child: InfoDialog(
            body: Wrap(
              children: [
                _confirmationContent(
                  title: 'Accept Connection Request',
                  message:
                      "Are you sure you want to accept this connection request from ${widget.data['user']['bio']['firstname']} ${widget.data['user']['bio']['lastname']}? ",
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  _declineRequest() async {
    _controller.setLoading(true);
    Get.back();
    try {
      print("PAYJKD :: ${widget.data['guest']}");
      Map _payload = {
        'accepterId': widget.data['guest']['_id'],
        'userId': widget.data['user']['_id'],
      };

      final resp = await APIService().declineConnectionRequest(
        accessToken: widget.manager.getAccessToken(),
        email: widget.manager.getUser()['email'],
        payload: _payload,
        connectionId: widget.data['id'],
      );
      print("DELINE CONNEC :::  ${resp.body}");

      _controller.setLoading(false);
    } catch (e) {
      print("$e");
      _controller.setLoading(false);
    }
  }

  _acceptRequest() async {
    _controller.setLoading(true);
    Get.back();
    try {
      Map _payload = {
        'accepterId': widget.data['guest']['_id'],
        'userId': widget.data['user']['_id'],
      };
      final resp = await APIService().acceptConnectionRequest(
        accessToken: widget.manager.getAccessToken(),
        email: widget.manager.getUser()['email'],
        payload: _payload,
        connectionId: widget.data['id'],
      );
      print("ACCEPT CONNEC :::  ${resp.body}");
      _controller.setLoading(false);
    } catch (e) {
      _controller.setLoading(false);
      print("$e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipOval(
                      child: Image.network(
                        "${widget.data['user']['bio']['image']}",
                        width: 40,
                        height: 40,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            SvgPicture.asset(
                          "assets/images/personal_icon.svg",
                          width: 40,
                          height: 40,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  width: 8.0,
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: TextPoppins(
                              text:
                                  "${widget.data['user']['bio']['firstname'].toString().capitalize!} ${widget.data['user']['bio']['lastname'].toString().capitalize!} sent you a connection request",
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(
                            width: 3.0,
                          ),
                        ],
                      ),
                      TextPoppins(
                        text: Constants.timeUntil(
                            DateTime.parse("${widget.data['createdAt']}")),
                        fontSize: 12,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: RoundedButton(
                    bgColor: Colors.transparent,
                    child: TextPoppins(text: "Decline", fontSize: 13),
                    borderColor: Constants.primaryColor,
                    foreColor: Constants.primaryColor,
                    paddingY: 10,
                    onPressed: () {
                      _confirmDecline();
                    },
                    variant: 'Outlined',
                  ),
                ),
                const SizedBox(
                  width: 10.0,
                ),
                Expanded(
                  child: RoundedButton(
                    bgColor: Constants.primaryColor,
                    child: TextPoppins(text: "Accept", fontSize: 13),
                    borderColor: Constants.accentColor,
                    foreColor: Colors.white,
                    onPressed: () {
                      _confirmAccept();
                    },
                    variant: 'filled',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

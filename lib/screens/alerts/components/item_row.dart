import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

class AlertItemRow extends StatelessWidget {
  var alert;
  AlertItemRow({
    Key? key,
    required this.alert,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipOval(
              child: Container(
                width: 48,
                height: 48,
                color: alert['type'] == "auth" || alert['type'] == "profile"
                    ? Colors.red.shade50
                    : alert['type'] == "wallet"
                        ? Colors.blue.shade50
                        : alert['type'] == "job"
                            ? Colors.purple.shade50
                            : Colors.green.shade50,
                child: Center(
                  child: Icon(
                    alert['type'] == "auth"
                        ? CupertinoIcons.lock_shield
                        : alert['type'] == "wallet"
                            ? CupertinoIcons.creditcard
                            : alert['type'] == "job"
                                ? CupertinoIcons.tag_circle
                                : alert['type'] == "connection"
                                    ? CupertinoIcons
                                        .arrow_right_arrow_left_circle
                                    : CupertinoIcons
                                        .person_crop_circle_badge_checkmark,
                    color: alert['type'] == "auth" || alert['type'] == "profile"
                        ? Colors.red
                        : alert['type'] == "wallet"
                            ? Colors.blue
                            : alert['type'] == "job"
                                ? Colors.purple
                                : Colors.green,
                    size: 28,
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: 16.0,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.60,
                  child: Text(
                    "${alert['message']}",
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'Poppins',
                    ),
                    softWrap: true,
                  ),
                ),
                const SizedBox(
                  height: 2.0,
                ),
                Text(
                  "${DateFormat('E d MMM, yyyy hh:mm a').format(DateTime.parse(alert['createdAt']))} (${timeUntil(DateTime.parse(alert['createdAt']))})",
                  style: const TextStyle(
                    fontSize: 11,
                    fontFamily: 'Poppins',
                  ),
                  softWrap: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String timeUntil(DateTime date) {
    return timeago
        .format(date, locale: "en", allowFromNow: true)
        .replaceAll("minute", "min")
        .replaceAll("second", "sec")
        .replaceAll("hour", "hr")
        .replaceAll("about", "");
  }
}

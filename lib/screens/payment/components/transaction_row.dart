import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/helper/constants/constants.dart';

class TransactionRow extends StatefulWidget {
  var data;
  TransactionRow({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  State<TransactionRow> createState() => _TransactionRowState();
}

class _TransactionRowState extends State<TransactionRow> {
  String timeUntil(DateTime date) {
    return timeago.format(date, locale: "en", allowFromNow: true);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipOval(
          child: Container(
            width: 48,
            height: 48,
            padding: const EdgeInsets.all(2.0),
            decoration: BoxDecoration(
              color: Constants.primaryColor.withOpacity(0.3),
            ),
            child: widget.data['type'] == "connection"
                ? const Icon(
                    CupertinoIcons.person_3_fill,
                    color: Constants.primaryColor,
                  )
                : widget.data['type'] == "job_posting"
                    ? const Icon(
                        Icons.wallet_travel_rounded,
                        color: Constants.primaryColor,
                      )
                    : const Icon(
                        CupertinoIcons.creditcard,
                        color: Constants.primaryColor,
                      ),
          ),
        ),
        const SizedBox(
          width: 10.0,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextPoppins(
              text:
                  "${widget.data['type']} @ ${Constants.formatMoney(widget.data['amount'])} coins"
                      .replaceAll("_", " ")
                      .capitalize,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            Wrap(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.72,
                  child: Text(
                    "${widget.data['summary']}",
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
            TextPoppins(
              text:
                  "Initiated on ${DateFormat('dd/MM/yyyy').format(DateTime.parse(widget.data['createdAt']))} (${timeUntil(DateTime.parse("${widget.data['createdAt']}"))})"
                      .replaceAll("about", "")
                      .replaceAll("minute", "min"),
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ],
        )
      ],
    );
  }
}

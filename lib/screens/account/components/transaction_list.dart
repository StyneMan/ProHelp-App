import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:prohelp_app/components/shimmer/cart_shimmer.dart';
import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/helper/preference/preference_manager.dart';
import 'package:prohelp_app/helper/service/api_service.dart';
import 'package:prohelp_app/screens/payment/components/transaction_row.dart';

class TransactionList extends StatelessWidget {
  final PreferenceManager manager;
  const TransactionList({
    Key? key,
    required this.manager,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<http.Response>(
      stream: APIService().getTransactionsStreamed(
        email: manager.getUser()['email'],
        accessToken: manager.getAccessToken(),
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.all(8.0),
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) => const CartShimmer(),
            itemCount: 5,
          );
        } else if (!snapshot.hasData || snapshot.hasError) {
          return Center(
            child: TextPoppins(
              text: "An error ocurred. ",
              fontSize: 13,
            ),
          );
        }

        final data = snapshot.data;
        Map<String, dynamic> map = jsonDecode(data!.body);
        debugPrint("TRANSACTIONS RESPONSE >>> ${data.body}");

        if (map['docs']?.length < 1) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset('assets/images/empty.png'),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 48.0),
                  child: TextInter(
                    text: "No transactions found",
                    fontSize: 16,
                    align: TextAlign.center,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          padding: const EdgeInsets.all(8.0),
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return TransactionRow(data: map['docs'][index]);
          },
          separatorBuilder: (context, index) {
            return const Column(
              children: [
                SizedBox(height: 4.0),
                Divider(),
                SizedBox(height: 4.0),
              ],
            );
          },
          itemCount: map['docs']?.length,
        );
      },
    );
  }
}

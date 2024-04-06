import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:prohelp_app/components/shimmer/pros_shimmer.dart';
import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/helper/preference/preference_manager.dart';
import 'package:prohelp_app/helper/service/api_service.dart';
import 'package:prohelp_app/screens/pros/components/professional_card.dart';

import 'package:http/http.dart' as http;

class ViewCategory extends StatefulWidget {
  final String title;
  var data;
  final PreferenceManager manager;
  ViewCategory({
    Key? key,
    required this.title,
    required this.data,
    required this.manager,
  }) : super(key: key);

  @override
  State<ViewCategory> createState() => _ViewCategoryState();
}

class _ViewCategoryState extends State<ViewCategory> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor: Colors.grey,
            pinned: true,
            floating: true,
            expandedHeight: 210.0,
            flexibleSpace: FlexibleSpaceBar(
              title: TextPoppins(
                text: widget.title,
                fontSize: 14,
              ),
              background: Image.network(
                "${widget.data['image']}",
                fit: BoxFit.cover,
              ),
            ),
            // actions: [
            //   IconButton(
            //     onPressed: () {},
            //     icon: const Icon(Icons.filter),
            //   )
            // ],
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 100,
              width: MediaQuery.of(context).size.width * 0.6,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 22.0, vertical: 8.0),
                child: Center(
                  child: TextPoppins(
                    text: "${widget.data['description']}",
                    fontSize: 14,
                    align: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
          SliverFillViewport(
            delegate: SliverChildListDelegate(
              [
                StreamBuilder<http.Response>(
                  stream: APIService().getProfessionalsByCategoryStreamed(
                    category: "${widget.data['name']}",
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return ListView.separated(
                        shrinkWrap: true,
                        itemCount: 3,
                        separatorBuilder: (BuildContext context, int index) {
                          return const SizedBox(height: 32.0);
                        },
                        itemBuilder: (BuildContext context, int index) {
                          return const ProsShimmer();
                        },
                      );
                    }

                    if (snapshot.hasError) {
                      return const Center(
                        child: Text(
                          "An error occurred. Check your internet and try again.",
                        ),
                      );
                    }

                    if (!snapshot.hasData) {
                      return SizedBox(
                        width: double.infinity,
                        height: double.infinity,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset('assets/images/empty.png'),
                              const Text(
                                "No professionals found",
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final data = snapshot.data;
                    Map<String, dynamic> map = jsonDecode(data!.body);
                    debugPrint("SAVED PROS RESPONSE >>> ${data.body}");

                    if (map['docs']?.isEmpty) {
                      return SizedBox(
                        width: double.infinity,
                        height: 256,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(
                              height: 100,
                            ),
                            Image.asset('assets/images/empty.png'),
                            const Text(
                              "No professionals found",
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      itemBuilder: (context, i) => ProfessionalsCard(
                        data: map['docs'][i],
                        manager: widget.manager,
                        index: i,
                      ),
                      separatorBuilder: (context, i) => const SizedBox(
                        height: 16.0,
                      ),
                      itemCount: map['docs']?.length,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

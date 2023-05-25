import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SummaryShimmer extends StatelessWidget {
  const SummaryShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (context, index) => const Divider(),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Shimmer.fromColors(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                height: 48,
              ),
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
            ),
            Shimmer.fromColors(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.18,
                height: 48,
              ),
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
            )
          ],
        );
      },
    );
  }
}

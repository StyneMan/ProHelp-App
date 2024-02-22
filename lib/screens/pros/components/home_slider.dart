import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prohelp_app/components/shimmer/banner_shimmer.dart';
import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/helper/state/state_manager.dart';

class HomeSlider extends StatefulWidget {
  const HomeSlider({Key? key}) : super(key: key);

  @override
  State<HomeSlider> createState() => _HomeSliderState();
}

class _HomeSliderState extends State<HomeSlider> {
  int _current = 0;
  bool _hasLoaded = false;
  final _controller = Get.find<StateController>();

  // @override
  // void initState() {
  //   super.initState();
  //   Future.delayed(
  //     const Duration(seconds: 3),
  //     () {
  //       setState(() {
  //         _hasLoaded = true;
  //       });
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<StateController>(builder: (controller) {
      if (controller.homeBanners.isEmpty) {
        return const SizedBox(
          height: 200,
          child: BannerShimmer(),
        );
      }

      // var list = controller.banners.where((p0) => p0['page'] == "home");

      return Column(
        children: [
          CarouselSlider(
            options: CarouselOptions(
              height: 210,
              viewportFraction: 1,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 10),
              enlargeStrategy: CenterPageEnlargeStrategy.scale,
              enlargeCenterPage: true,
              aspectRatio: 2.0,
              onPageChanged: (int page, _) {
                setState(() {
                  _current = page;
                });
                // _selectedSlider.value = page;
              },
            ),
            items: controller.homeBanners.map((sliderData) {
              return Builder(
                builder: (BuildContext context) {
                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    padding: const EdgeInsets.all(14.0),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(sliderData['featuredImage']),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextPoppins(
                          text: sliderData['title'],
                          color: Colors.white,
                          fontSize: 16,
                        )
                      ],
                    ),
                  );
                },
              );
            }).toList(),
          ),
          const SizedBox(
            height: 8,
          ),
        ],
      );
    });
  }
}

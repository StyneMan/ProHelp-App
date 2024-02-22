class HomeSlide {
  String title;
  String bgImage;

  HomeSlide({
    required this.title,
    required this.bgImage,
  });
}

final List<HomeSlide> homeSlideList = [
  HomeSlide(
    title: "Buy and Redeem Vouchers with ease",
    bgImage: "assets/images/homeslide3.jpg",
  ),
  HomeSlide(
    title: "Topup your phone with ease",
    bgImage: "assets/images/homeslide2.jpg",
  ),
  HomeSlide(
    title: "What a lovely world!!",
    bgImage: "assets/images/homeslide3.jpg",
  ),
  HomeSlide(
    title: "Utilty bill payment at it's best",
    bgImage: "assets/images/homeslide2.jpg",
  ),
];

class Slides {
  late String title;
  late String desc;
  late String author;
  late String image;

  Slides({
    required this.title,
    required this.desc,
    required this.author,
    required this.image,
  });
}

List<Slides> onboardingSlides = [
  Slides(
    image: "assets/images/onboarding.png",
    title: "Coming Soon",
    desc:
        "When nutrition is wrong, medicine is of no use. When nutrition is correct medicine is of no need.",
    author: "",
  ),
  Slides(
    image: "assets/images/onboarding.png",
    title: "Coming Soon",
    desc:
        "Health is much more dependent on our habits and nutrition than on medicine",
    author: "",
  ),
  Slides(
    image: "assets/images/onboarding.png",
    title: "Coming Soon",
    desc:
        "Medicine is not health care, food is health care. Medicine is sick care",
    author: "",
  ),
];

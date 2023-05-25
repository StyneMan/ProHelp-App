class Goal {
  String title;
  String image;

  Goal({
    required this.image,
    required this.title,
  });
}

List<Goal> goals = [
  Goal(image: "assets/images/eat_healthy.png", title: "Eat healthy"),
  Goal(image: "assets/images/weight_loss.png", title: "Weight loss"),
  Goal(image: "assets/images/health_related.png", title: "Health related"),
  Goal(image: "assets/images/weight_gain.png", title: "Weight gain"),
];

List<String> personalizeList = [
  "Gluten",
  "Dairy",
  "Egg",
  "Peanut",
  "Soy",
  "Fish",
  "Shellfish",
  "Other"
];

List<String> months = [
  "January",
  "February",
  "March",
  "April",
  "May",
  "June",
  "July",
  "August",
  "September",
  "October",
  "November",
  "December"
];

List<String> weekDays = [
  "Monday",
  "Tuesday",
  "Wednesday",
  "Thursday",
  "Friday",
  "Saturday",
  "Sunday"
];

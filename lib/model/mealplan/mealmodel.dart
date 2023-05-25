class MealMode {
  late String day;
  late int quantity;

  MealMode({required this.day, required this.quantity});

  MealMode.fromJson(Map<String, dynamic> parsedJson) {
    day = parsedJson['day'];
    quantity = parsedJson['quantity'];
  }

  Map<String, dynamic> toJson() => {
        'day': day,
        'quantity': quantity,
      };
}

class Plan {
  List<MealMode>? meals;
  late int selectedPlan;
  late List<String> selectedDays;
  late String totalMeals;

  Plan({
    required this.meals,
    required this.selectedDays,
    required this.selectedPlan,
    required this.totalMeals,
  });

  Plan.fromJson(Map<dynamic, dynamic> parsedJson) {
    if (parsedJson['meals'] != null) {
      meals = [];
      parsedJson['meals'].forEach((v) {
        meals!.add(MealMode.fromJson(v));
      });
    }
    selectedPlan = parsedJson['selectedPlan'];
    totalMeals = parsedJson['totalMeals'];
    if (parsedJson['selectedDays'] != null) {
      selectedDays = [];
      parsedJson['selectedDays'].forEach((v) {
        selectedDays.add((v));
      });
    }
  }
}

import 'dart:convert';

class Product {
  late String id;
  late String name;
  late String image;
  late String menu;
  late String description;
  late int price;
  late List<String> ingredients;
  late String calories;
  late String proteins;
  late String carbs;
  late String fat;

  Product({
    required this.id,
    required this.fat,
    required this.name,
    required this.menu,
    required this.image,
    required this.price,
    required this.carbs,
    required this.calories,
    required this.proteins,
    required this.ingredients,
    required this.description,
  });

  Product.fromJson(Map<String, dynamic> parsedJson) {
    id = parsedJson['id'];
    name = parsedJson['name'];
    image = parsedJson['image'] ?? "";
    price = parsedJson['price'];
    menu = parsedJson['menu'];
    fat = (parsedJson['fat']);
    description = parsedJson['description'];
    calories = parsedJson['calories'];
    carbs = parsedJson['carbs'];
    proteins = parsedJson['proteins'];
    if (parsedJson['ingredients'] != null) {
      ingredients = [];
      parsedJson['ingredients'].forEach((v) {
        ingredients.add(v);
      });
    }
  }

  Map<String, dynamic> toJson(Product option) => {
        'image': image,
        'name': name,
        'id': id,
        'price': price,
        'menu': menu,
        'fat': fat,
        'description': description,
        'carbs': carbs,
        'calories': calories,
        'proteins': proteins,
        'ingredients': jsonEncode(ingredients.map((e) => e).toList()),
      };
}

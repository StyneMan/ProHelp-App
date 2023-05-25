import 'package:flutter/material.dart';

class MenuModel {
  late String title;
  late String description;
  late String image;
  Color color;

  MenuModel({
    required this.title,
    required this.image,
    required this.color,
    required this.description,
  });
}

List<MenuModel> menuList = [
  MenuModel(
    title: "ALL MEALS",
    image: "assets/images/menu1.png",
    color: Colors.amber,
    description: "",
  ),
  MenuModel(
    title: "BREAKFAST",
    image: "assets/images/menu2.png",
    color: Colors.cyan,
    description: "",
  ),
  MenuModel(
    title: "LUNCH",
    image: "assets/images/menu3.png",
    color: Colors.redAccent,
    description: "",
  ),
  MenuModel(
    title: "DINNER",
    image: "assets/images/menu1.png",
    color: Colors.purple,
    description: "",
  ),
  MenuModel(
    title: "KETO",
    image: "assets/images/menu2.png",
    color: Colors.green,
    description: "low glycemic index",
  ),
  MenuModel(
    title: "Gluten Free",
    image: "assets/images/menu3.png",
    color: Colors.brown,
    description: "polycystic ovary ",
  ),
];

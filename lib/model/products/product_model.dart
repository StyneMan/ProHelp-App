class ProductMenu {
  late int id;
  late String name;
  late String image;

  ProductMenu({
    required this.id,
    required this.image,
    required this.name,
  });

  ProductMenu.fromJson(Map<String, dynamic> parsedJson) {
    id = parsedJson['id'];
    name = parsedJson['name'];
    image = parsedJson['image'] ?? "";
  }

  Map<String, dynamic> toJson(ProductMenu option) => {
        'image': image,
        'name': name,
        'id': id,
      };
}

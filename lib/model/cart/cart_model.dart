class CartModel {
  String? id;
  String? name;
  String? image;
  late int price;
  late int addedOn;
  String? productId;
  String? menu;
  late int quantity;
  int? cost;

  CartModel({
    required this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.productId,
    required this.quantity,
    required this.cost,
    required this.addedOn,
    required this.menu,
  });

  CartModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    image = json['image'];
    price = json['price'] ?? 0;
    productId = json['productId'];
    quantity = json['quantity'] ?? 1;
    cost = json['cost'];
    menu = json['menu'];
    addedOn = json['addedOn'];
  }

  Map toJson() => {
        'id': id,
        'name': name,
        'image': image,
        'price': price,
        'cost': price * quantity,
        'quantity': quantity,
        'productId': productId,
        'menu': menu,
        'addedOn': addedOn,
      };
}

// List<CartModel> cartList = [
//   CartModel(
//     id: "121",
//     name: "Sweet corn & beef protein",
//     image: "assets/images/dsc4.png",
//     price: 5000,
//     productId: "productId",
//     quantity: 2,
//     cost: 7000,
//     addedOn: 11,
//     category: "category",
//   ),
//   CartModel(
//     id: "121",
//     name: "Sweet corn & beef protein",
//     image: "assets/images/dsc2.png",
//     price: 5000,
//     productId: "productId",
//     quantity: 2,
//     cost: 7000,
//     addedOn: 11,
//     category: "category",
//   ),
//   CartModel(
//     id: "122",
//     name: "Sweet corn & beef protein",
//     image: "assets/images/dsc1.png",
//     price: 5000,
//     productId: "productId",
//     quantity: 2,
//     cost: 10000,
//     addedOn: 11,
//     category: "category",
//   ),
// ];

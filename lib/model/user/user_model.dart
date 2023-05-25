import '../cart/cart_model.dart';
import '../order/order_model.dart';

class UserModel {
  String? name;
  String? phone;
  String? email;
  String? address;
  String? image;
  String? landmark;
  String? height;
  bool? isActive;
  String? id;
  List<CartModel>? cart;
  List<dynamic>? monMeals;
  List<dynamic>? tueMeals;
  List<dynamic>? wedMeals;
  List<dynamic>? thuMeals;
  List<dynamic>? friMeals;
  List<dynamic>? satMeals;
  List<dynamic>? sunMeals;
  List<OrderModel>? orders;

  UserModel({
    required this.height,
    required this.address,
    required this.email,
    required this.name,
    required this.image,
    required this.id,
    required this.landmark,
    required this.monMeals,
    required this.tueMeals,
    required this.wedMeals,
    required this.thuMeals,
    required this.friMeals,
    required this.satMeals,
    required this.sunMeals,
    this.phone,
    this.cart,
    this.orders,
    this.isActive,
  });

  UserModel.fromJson(Map<String, dynamic> parsedJson) {
    isActive = parsedJson['isActive'];
    height = parsedJson['height'];
    email = parsedJson['email'];
    name = parsedJson['name'];
    address = parsedJson['address'];
    id = parsedJson['id'];
    landmark = parsedJson['landmark'];
    image = parsedJson['image'];
    phone = parsedJson['phone'];
    if (parsedJson['cart'] != null) {
      cart = [];
      parsedJson['cart'].forEach((v) {
        cart!.add(CartModel.fromJson(v));
      });
    }
    if (parsedJson['orders'] != null) {
      orders = [];
      parsedJson['orders'].forEach((v) {
        orders!.add(OrderModel.fromJson(v));
      });
    }
  }

  // factory UserProfile.fromMap(Map data) {
  //   return UserProfile(
  //     password: data['password'],
  //     osPlatform: data['osPlatform'],
  //     email: data['email'],
  //     name: data['name'],
  //     gender: data['gender'],
  //     id: data['id'],
  //     isEmailVerified: data['isEmailVerified'],
  //     isPhoneVerified: data['isPhoneVerified'],
  //     phone: data['phone'],
  //     isActive: data['isActive'],
  //   );
  // }

  Map<String, dynamic> toJson() => {
        'isActive': isActive,
        'landmark': landmark,
        'height': height,
        'email': email,
        'name': name,
        'image': image,
        'id': id,
        'address': address,
        'phone': phone,
      };
}

class OrderModel {
  String? orderNo;
  String? image;
  String? name;
  String? productId;
  String? category;
  late int price;
  late int cost;
  late int quantity;
  String? paidAt;
  late int deliveryFee;
  String? paymentMethod;
  // DeliveryModel? deliveryInfo;

  OrderModel({
    required this.orderNo,
    required this.productId,
    required this.category,
    required this.paidAt,
    required this.quantity,
    required this.deliveryFee,
    required this.price,
    required this.image,
    required this.name,
    required this.cost,
    // required this.deliveryInfo,
    required this.paymentMethod,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      productId: json['productId'],
      name: json['name'],
      image: json['image'],
      category: json['category'],
      price: json['price'],
      paidAt: json['paidAt'],
      cost: json['cost'],
      deliveryFee: json['deliveryFee'],
      // deliveryInfo:
      //     DeliveryModel.fromJson(jsonDecode(json['deliveryInfo'] ?? "")),
      quantity: json['quantity'],
      orderNo: json['orderNo'],
      paymentMethod: json['paymentMethod'],
    );
  }

  factory OrderModel.fromMap(Map data) {
    return OrderModel(
      productId: data['productId'],
      image: data['image'],
      name: data['name'],
      category: data['category'],
      quantity: data['quantity'],
      price: data['price'],
      paidAt: data['paidAt'],
      deliveryFee: data['deliveryFee'],
      // deliveryInfo: DeliveryModel.fromJson(jsonDecode(data['deliveryInfo'])),
      cost: data['cost'],
      orderNo: data['orderNo'],
      paymentMethod: data['paymentMethod'],
    );
  }

  Map<String, dynamic> toJson() => {
        'image': image,
        'name': name,
        'productId': productId,
        'price': price,
        'category': category,
        'cost': cost,
        'paidAt': paidAt,
        'deliveryFee': deliveryFee,
        // 'deliveryInfo': DeliveryModel.toJson(jsonEncode(deliveryInfo)),
        'quantity': quantity,
        'orderNo': orderNo,
        'paymentMethod': paymentMethod,
      };
}

class OrdersModel {
  String? productId;
  String? image;
  String? orderNo;
  String? createdAt;
  String? name;
  String? customerId;
  String? customerName;
  String? menu;
  late int price;
  late int cost;
  late int quantity;
  late int deliveryFee;
  late String deliveryInfo;
  late String paymentMethod;
  late String status;

  OrdersModel({
    required this.productId,
    required this.name,
    required this.status,
    required this.orderNo,
    required this.menu,
    required this.customerId,
    required this.customerName,
    required this.deliveryFee,
    required this.deliveryInfo,
    required this.paymentMethod,
    required this.createdAt,
    required this.cost,
    required this.image,
    required this.price,
    required this.quantity,
  });

  OrdersModel.fromJson(Map<String, dynamic> json) {
    productId = json['productId'];
    name = json['name'];
    status = json['status'];
    menu = json['menu'];
    orderNo = json['orderNo'];
    createdAt = json['createdAt'];
    customerId = json['customerId'];
    deliveryFee = json['deliveryFee'];
    customerName = json['customerName'];
    deliveryInfo = json['deliveryInfo'];
    paymentMethod = json['paymentMethod'];
  }

  Map toJson() => {
        'productId': productId,
        'name': name,
        'image': image,
        'cost': cost,
        'price': price,
        'quantity': quantity,
        'status': status,
        'menu': menu,
        'orderNo': orderNo,
        'createdAt': createdAt,
        'customerId': customerId,
        'deliveryFee': deliveryFee,
        'customerName': customerName,
        'deliveryInfo': deliveryInfo,
        'paymentMethod': paymentMethod,
      };
}

class DeliveryModel {
  String? phone;
  String? address;

  DeliveryModel({
    required this.address,
    required this.phone, //3042132740
  });

  factory DeliveryModel.fromJson(Map<String, dynamic> json) {
    return DeliveryModel(address: json['address'], phone: json['phone']);
  }

  Map<String, dynamic> toJson() => {
        "address": address,
        "phone": phone,
      };
}


// List<OrdersModel> ordersList = [
//   OrdersModel(
//     createdAt: "10 NOV, 2022",
//     orderNo: "14SD346",
//     product: productList[0],
//   ),
//   OrdersModel(
//     createdAt: "10 NOV, 2022",
//     orderNo: "14SD346",
//     product: productList[2],
//   ),
//   OrdersModel(
//     createdAt: "10 NOV, 2022",
//     orderNo: "14SD346",
//     product: productList[1],
//   ),
//   OrdersModel(
//     createdAt: "10 NOV, 2022",
//     orderNo: "14SD346",
//     product: productList[2],
//   ),
//   OrdersModel(
//     createdAt: "10 NOV, 2022",
//     orderNo: "14SD346",
//     product: productList[1],
//   ),
// ];

// To parse this JSON data, do
//
//     final cartResponseModel = cartResponseModelFromJson(jsonString);

import 'dart:convert';

import 'package:viteezy/core/models/product_response_model.dart';

CartResponseModel cartResponseModelFromJson(String str) => CartResponseModel.fromJson(json.decode(str));

String cartResponseModelToJson(CartResponseModel data) => json.encode(data.toJson());

class CartResponseModel {
  bool? success;
  String? message;
  CartData? data;

  CartResponseModel({this.success, this.message, this.data});

  factory CartResponseModel.fromJson(Map<String, dynamic> json) => CartResponseModel(
    success: json["success"],
    message: json["message"],
    data: json["data"] == null ? null : CartData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {"success": success, "message": message, "data": data?.toJson()};
}

class CartData {
  Cart? cart;
  List<Product>? suggestedProducts;

  CartData({this.cart, this.suggestedProducts});

  factory CartData.fromJson(Map<String, dynamic> json) => CartData(
    cart: json["cart"] == null ? null : Cart.fromJson(json["cart"]),
    // paymentDetails: json["paymentDetails"] == null ? null : PaymentDetails.fromJson(json["paymentDetails"]),
    suggestedProducts: json["suggestedProducts"] == null
        ? []
        : List<Product>.from(json["suggestedProducts"]!.map((x) => Product.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "cart": cart?.toJson(),
    "suggestedProducts": suggestedProducts == null ? [] : List<dynamic>.from(suggestedProducts!.map((x) => x.toJson())),
  };
}

class Cart {
  String? id;
  String? userId;
  String? variantType;
  List<CartItem>? items;
  double? subtotal;
  double? tax;
  double? shipping;
  double? discount;
  double? total;
  String? currency;
  dynamic couponCode;
  double? couponDiscountAmount;
  bool? isDeleted;
  DateTime? expiresAt;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  Cart({
    this.id,
    this.userId,
    this.items,
    this.subtotal,
    this.tax,
    this.shipping,
    this.discount,
    this.total,
    this.isDeleted,
    this.expiresAt,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.variantType,
    this.currency,
    this.couponCode,
    this.couponDiscountAmount,
  });

  factory Cart.fromJson(Map<String, dynamic> json) => Cart(
    id: json["_id"],
    userId: json["userId"],
    variantType: json["variantType"],
    items: json["items"] == null ? [] : List<CartItem>.from(json["items"]!.map((x) => CartItem.fromJson(x))),
    subtotal: json["subtotal"]?.toDouble(),
    tax: json["tax"]?.toDouble(),
    shipping: json["shipping"]?.toDouble(),
    discount: json["discount"]?.toDouble(),
    total: json["total"]?.toDouble(),
    currency: json["currency"],
    couponCode: json["couponCode"],
    couponDiscountAmount: json["couponDiscountAmount"]?.toDouble(),
    isDeleted: json["isDeleted"],
    expiresAt: json["expiresAt"] == null ? null : DateTime.parse(json["expiresAt"]),
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "userId": userId,
    "variantType": variantType,
    "items": items == null ? [] : List<dynamic>.from(items!.map((x) => x.toJson())),
    "subtotal": subtotal,
    "tax": tax,
    "shipping": shipping,
    "discount": discount,
    "total": total,
    "currency": currency,
    "couponCode": couponCode,
    "couponDiscountAmount": couponDiscountAmount,
    "isDeleted": isDeleted,
    "expiresAt": expiresAt?.toIso8601String(),
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
  };
}

class CartItem {
  String? productId;
  Price? price;
  DateTime? addedAt;
  String? id;
  String? variantType;
  Product? product;
  double? membershipDiscount;
  int? quantity;
  int? planDays;

  CartItem({
    this.productId,
    this.price,
    this.addedAt,
    this.id,
    this.product,
    this.membershipDiscount,
    this.quantity,
    this.variantType,
    this.planDays,
  });

  int get effectiveQuantity => quantity ?? 1;

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    productId: json["productId"],
    price: json["price"] == null ? null : Price.fromJson(json["price"]),
    addedAt: json["addedAt"] == null ? null : DateTime.parse(json["addedAt"]),
    id: json["_id"],
    variantType: json['variantType'],
    product: json["product"] == null ? null : Product.fromJson(json["product"]),
    planDays: json['planDays'] ?? 0,
    membershipDiscount: json["membershipDiscount"]?.toDouble(),
    quantity: json["quantity"] is int
        ? json["quantity"] as int
        : (json["quantity"] != null ? int.tryParse(json["quantity"].toString()) : null),
  );

  Map<String, dynamic> toJson() => {
    "productId": productId,
    "price": price?.toJson(),
    "addedAt": addedAt?.toIso8601String(),
    "_id": id,
    "product": product?.toJson(),
    if (quantity != null) "quantity": quantity,
  };
}

class PaymentDetails {
  Price? subtotal;
  Price? discount;
  Price? shipping;
  Price? tax;
  Price? grandTotal;
  dynamic couponCode;

  PaymentDetails({this.subtotal, this.discount, this.shipping, this.tax, this.grandTotal, this.couponCode});

  factory PaymentDetails.fromJson(Map<String, dynamic> json) => PaymentDetails(
    subtotal: json["subtotal"] == null ? null : Price.fromJson(json["subtotal"]),
    discount: json["discount"] == null ? null : Price.fromJson(json["discount"]),
    shipping: json["shipping"] == null ? null : Price.fromJson(json["shipping"]),
    tax: json["tax"] == null ? null : Price.fromJson(json["tax"]),
    grandTotal: json["grandTotal"] == null ? null : Price.fromJson(json["grandTotal"]),
    couponCode: json["couponCode"],
  );

  Map<String, dynamic> toJson() => {
    "subtotal": subtotal?.toJson(),
    "discount": discount?.toJson(),
    "shipping": shipping?.toJson(),
    "tax": tax?.toJson(),
    "grandTotal": grandTotal?.toJson(),
    "couponCode": couponCode,
  };
}

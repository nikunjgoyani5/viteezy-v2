import 'dart:convert';

import 'api_response.dart';
import 'checkout_summary_model.dart';

OrderHistoryModel orderHistoryModelFromJson(String str) =>
    OrderHistoryModel.fromJson(json.decode(str));

String orderHistoryModelToJson(OrderHistoryModel data) =>
    json.encode(data.toJson());

class OrderHistoryModel {
  bool? success;
  String? message;
  List<OrderData>? data;
  Pagination? pagination;

  OrderHistoryModel({this.success, this.message, this.data, this.pagination});

  factory OrderHistoryModel.fromJson(Map<String, dynamic> json) =>
      OrderHistoryModel(
        success: json["success"],
        message: json["message"],
        data: json["data"] == null
            ? []
            : List<OrderData>.from(
                json["data"]!.map((x) => OrderData.fromJson(x)),
              ),
        pagination: json["pagination"] == null
            ? null
            : Pagination.fromJson(json["pagination"]),
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data == null
        ? []
        : List<dynamic>.from(data!.map((x) => x.toJson())),
    "pagination": pagination?.toJson(),
  };
}

class OrderData {
  String? id;
  String? orderNumber;
  String? planType;
  bool? isOneTime;
  String? variantType;
  String? status;
  String? paymentStatus;
  List<Item>? items;
  Pricing? pricing;
  ShippingAddressId? shippingAddressId;
  dynamic billingAddressId;
  String? paymentMethod;
  Payment? payment;
  String? couponCode;
  dynamic notes;
  Metadata? metadata;
  dynamic trackingNumber;
  dynamic shippedAt;
  dynamic deliveredAt;
  DateTime? createdAt;
  DateTime? updatedAt;
  CouponMetadata? couponMetadata;

  OrderData({
    this.id,
    this.orderNumber,
    this.planType,
    this.isOneTime,
    this.variantType,
    this.status,
    this.paymentStatus,
    this.items,
    this.pricing,
    this.couponCode,
    this.metadata,
    this.paymentMethod,
    this.trackingNumber,
    this.shippedAt,
    this.deliveredAt,
    this.createdAt,
    this.couponMetadata,
    this.billingAddressId,
    this.notes,
    this.payment,
    this.shippingAddressId,
    this.updatedAt,
  });

  factory OrderData.fromJson(Map<String, dynamic> json) => OrderData(
    id: json["id"],
    orderNumber: json["orderNumber"],
    planType: json["planType"],
    isOneTime: json["isOneTime"],
    variantType: json["variantType"],
    status: json["status"],
    paymentStatus: json["paymentStatus"],
    items: json["items"] == null
        ? []
        : List<Item>.from(json["items"]!.map((x) => Item.fromJson(x))),
    pricing: json["pricing"] == null ? null : Pricing.fromJson(json["pricing"]),
    shippingAddressId: json["shippingAddressId"] == null
        ? null
        : ShippingAddressId.fromJson(json["shippingAddressId"]),
    billingAddressId: json["billingAddressId"],
    paymentMethod: json["paymentMethod"],
    payment: json["payment"] == null ? null : Payment.fromJson(json["payment"]),
    couponCode: json["couponCode"],
    notes: json["notes"],
    metadata: json["metadata"] == null
        ? null
        : Metadata.fromJson(json["metadata"]),
    trackingNumber: json["trackingNumber"],
    shippedAt: json["shippedAt"],
    deliveredAt: json["deliveredAt"],
    createdAt: json["createdAt"] == null
        ? null
        : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null
        ? null
        : DateTime.parse(json["updatedAt"]),
    couponMetadata: json["couponMetadata"] == null
        ? null
        : CouponMetadata.fromJson(json["couponMetadata"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "orderNumber": orderNumber,
    "planType": planType,
    "isOneTime": isOneTime,
    "variantType": variantType,
    "status": status,
    "paymentStatus": paymentStatus,
    "items": items == null
        ? []
        : List<dynamic>.from(items!.map((x) => x.toJson())),
    "pricing": pricing?.toJson(),
    "couponCode": couponCode,
    "metadata": metadata?.toJson(),
    "paymentMethod": paymentMethod,
    "trackingNumber": trackingNumber,
    "shippedAt": shippedAt,
    "deliveredAt": deliveredAt,
    "createdAt": createdAt?.toIso8601String(),
    "couponMetadata": couponMetadata?.toJson(),
  };
}

class CouponMetadata {
  String? type;
  int? value;
  int? minOrderAmount;
  Name? name;

  CouponMetadata({this.type, this.value, this.minOrderAmount, this.name});

  factory CouponMetadata.fromJson(Map<String, dynamic> json) => CouponMetadata(
    type: json["type"],
    value: json["value"],
    minOrderAmount: json["minOrderAmount"],
    name: json["name"] == null ? null : Name.fromJson(json["name"]),
  );

  Map<String, dynamic> toJson() => {
    "type": type,
    "value": value,
    "minOrderAmount": minOrderAmount,
    "name": name?.toJson(),
  };
}

class Name {
  String? en;
  String? nl;

  Name({this.en, this.nl});

  factory Name.fromJson(Map<String, dynamic> json) =>
      Name(en: json["en"], nl: json["nl"]);

  Map<String, dynamic> toJson() => {"en": en, "nl": nl};
}

class Item {
  ProductId? productId;
  String? name;
  double? amount;
  double? discountedPrice;
  int? taxRate;
  double? totalAmount;
  int? durationDays;
  int? capsuleCount;
  int? quantity;
  double? savingsPercentage;
  List<String>? features;

  Item({
    this.productId,
    this.name,
    this.amount,
    this.discountedPrice,
    this.taxRate,
    this.totalAmount,
    this.durationDays,
    this.capsuleCount,
    this.quantity,
    this.savingsPercentage,
    this.features,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    productId: json["productId"] == null
        ? null
        : ProductId.fromJson(json["productId"]),
    name: json["name"],
    amount: json["amount"]?.toDouble(),
    discountedPrice: json["discountedPrice"]?.toDouble(),
    taxRate: json["taxRate"],
    totalAmount: json["totalAmount"]?.toDouble(),
    durationDays: json["durationDays"],
    capsuleCount: json["capsuleCount"],
    quantity: json["quantity"],
    savingsPercentage: json["savingsPercentage"]?.toDouble(),
    features: json["features"] == null
        ? []
        : List<String>.from(json["features"]!.map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "productId": productId?.toJson(),
    "name": name,
    "amount": amount,
    "discountedPrice": discountedPrice,
    "taxRate": taxRate,
    "totalAmount": totalAmount,
    "durationDays": durationDays,
    "capsuleCount": capsuleCount,
    "savingsPercentage": savingsPercentage,
    "features": features == null
        ? []
        : List<dynamic>.from(features!.map((x) => x)),
  };
}

class ProductId {
  String? id;
  String? title;
  String? slug;
  String? description;
  String? productImage;
  List<String>? categories;
  List<String>? galleryImages;
  bool? status;

  ProductId({
    this.id,
    this.title,
    this.slug,
    this.description,
    this.productImage,
    this.categories,
    this.galleryImages,
    this.status,
  });

  factory ProductId.fromJson(Map<String, dynamic> json) => ProductId(
    id: json["_id"],
    title: json["title"],
    slug: json["slug"],
    description: json["description"],
    productImage: json["productImage"],
    categories: json["categories"] == null
        ? []
        : List<String>.from(json["categories"]!.map((x) => x)),
    galleryImages: json["galleryImages"] == null
        ? []
        : List<String>.from(json["galleryImages"]!.map((x) => x)),
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "title": title,
    "slug": slug,
    "description": description,
    "productImage": productImage,
    "categories": categories == null
        ? []
        : List<dynamic>.from(categories!.map((x) => x)),
    "galleryImages": galleryImages == null
        ? []
        : List<dynamic>.from(galleryImages!.map((x) => x)),
    "status": status,
  };
}

class Metadata {
  PlanDetails? planDetails;
  String? paymentSessionId;
  DateTime? orderConfirmationEmailSentAt;

  Metadata({
    this.planDetails,
    this.paymentSessionId,
    this.orderConfirmationEmailSentAt,
  });

  factory Metadata.fromJson(Map<String, dynamic> json) => Metadata(
    planDetails: json["planDetails"] == null
        ? null
        : PlanDetails.fromJson(json["planDetails"]),
    paymentSessionId: json["paymentSessionId"],
    orderConfirmationEmailSentAt: json["orderConfirmationEmailSentAt"] == null
        ? null
        : DateTime.parse(json["orderConfirmationEmailSentAt"]),
  );

  Map<String, dynamic> toJson() => {
    "planDetails": planDetails?.toJson(),
    "paymentSessionId": paymentSessionId,
    "orderConfirmationEmailSentAt": orderConfirmationEmailSentAt
        ?.toIso8601String(),
  };
}

class PlanDetails {
  int? planDurationDays;
  bool? isOneTime;
  String? variantType;
  String? interval;
  int? cycleDays;
  int? capsuleCount;

  PlanDetails({
    this.planDurationDays,
    this.isOneTime,
    this.variantType,
    this.interval,
    this.cycleDays,
    this.capsuleCount,
  });

  factory PlanDetails.fromJson(Map<String, dynamic> json) => PlanDetails(
    planDurationDays: json["planDurationDays"],
    isOneTime: json["isOneTime"],
    variantType: json["variantType"],
    interval: json["interval"],
    cycleDays: json["cycleDays"],
    capsuleCount: json["capsuleCount"],
  );

  Map<String, dynamic> toJson() => {
    "planDurationDays": planDurationDays,
    "isOneTime": isOneTime,
    "variantType": variantType,
    "interval": interval,
    "cycleDays": cycleDays,
    "capsuleCount": capsuleCount,
  };
}

class ShippingAddressId {
  String? id;
  String? firstName;
  String? lastName;
  String? streetName;
  String? houseNumber;
  String? houseNumberAddition;
  String? postalCode;
  String? address;
  String? phone;
  String? country;
  String? city;
  String? note;

  ShippingAddressId({
    this.id,
    this.firstName,
    this.lastName,
    this.streetName,
    this.houseNumber,
    this.houseNumberAddition,
    this.postalCode,
    this.address,
    this.phone,
    this.country,
    this.city,
    this.note,
  });

  factory ShippingAddressId.fromJson(Map<String, dynamic> json) =>
      ShippingAddressId(
        id: json["_id"],
        firstName: json["firstName"],
        lastName: json["lastName"],
        streetName: json["streetName"],
        houseNumber: json["houseNumber"],
        houseNumberAddition: json["houseNumberAddition"],
        postalCode: json["postalCode"],
        address: json["address"],
        phone: json["phone"],
        country: json["country"],
        city: json["city"],
        note: json["note"],
      );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "firstName": firstName,
    "lastName": lastName,
    "streetName": streetName,
    "houseNumber": houseNumber,
    "houseNumberAddition": houseNumberAddition,
    "postalCode": postalCode,
    "address": address,
    "phone": phone,
    "country": country,
    "city": city,
    "note": note,
  };
}

class Payment {
  String? id;
  String? paymentMethod;
  String? status;
  Amount? amount;
  String? currency;
  dynamic transactionId;
  String? gatewayTransactionId;
  dynamic failureReason;
  dynamic refundAmount;
  dynamic refundReason;
  dynamic refundedAt;
  DateTime? processedAt;
  DateTime? createdAt;

  Payment({
    this.id,
    this.paymentMethod,
    this.status,
    this.amount,
    this.currency,
    this.transactionId,
    this.gatewayTransactionId,
    this.failureReason,
    this.refundAmount,
    this.refundReason,
    this.refundedAt,
    this.processedAt,
    this.createdAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
    id: json["id"],
    paymentMethod: json["paymentMethod"],
    status: json["status"],
    amount: json["amount"] == null ? null : Amount.fromJson(json["amount"]),
    currency: json["currency"],
    transactionId: json["transactionId"],
    gatewayTransactionId: json["gatewayTransactionId"],
    failureReason: json["failureReason"],
    refundAmount: json["refundAmount"],
    refundReason: json["refundReason"],
    refundedAt: json["refundedAt"],
    processedAt: json["processedAt"] == null
        ? null
        : DateTime.parse(json["processedAt"]),
    createdAt: json["createdAt"] == null
        ? null
        : DateTime.parse(json["createdAt"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "paymentMethod": paymentMethod,
    "status": status,
    "amount": amount?.toJson(),
    "currency": currency,
    "transactionId": transactionId,
    "gatewayTransactionId": gatewayTransactionId,
    "failureReason": failureReason,
    "refundAmount": refundAmount,
    "refundReason": refundReason,
    "refundedAt": refundedAt,
    "processedAt": processedAt?.toIso8601String(),
    "createdAt": createdAt?.toIso8601String(),
  };
}

class Amount {
  String? currency;
  double? amount;
  double? taxRate;

  Amount({this.currency, this.amount, this.taxRate});

  factory Amount.fromJson(Map<String, dynamic> json) => Amount(
    currency: json["currency"],
    amount: json["amount"]?.toDouble(),
    taxRate: json["taxRate"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "currency": currency,
    "amount": amount,
    "taxRate": taxRate,
  };
}

// To parse this JSON data, do
//
//     final subscriptionModel = subscriptionModelFromJson(jsonString);

import 'dart:convert';

import 'api_response.dart';

SubscriptionModel subscriptionModelFromJson(String str) => SubscriptionModel.fromJson(json.decode(str));

String subscriptionModelToJson(SubscriptionModel data) => json.encode(data.toJson());

class SubscriptionModel {
  bool? success;
  String? message;
  List<SubscriptionData>? data;

  SubscriptionModel({this.success, this.message, this.data});

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) => SubscriptionModel(
    success: json["success"],
    message: json["message"],
    data: json["data"] == null
        ? []
        : List<SubscriptionData>.from(json["data"]!.map((x) => SubscriptionData.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class SubscriptionData {
  String? id;
  String? subscriptionNumber;
  OrderId? orderId;
  String? status;
  String? planType;
  int? cycleDays;
  DateTime? subscriptionStartDate;
  DateTime? subscriptionEndDate;
  List<Item>? items;
  DateTime? initialDeliveryDate;
  DateTime? nextDeliveryDate;
  DateTime? nextBillingDate;
  DateTime? lastBilledDate;
  dynamic lastDeliveredDate;
  int? daysUntilNextDelivery;
  int? daysUntilNextBilling;
  dynamic cancelledAt;
  dynamic pausedAt;
  DateTime? createdAt;
  DateTime? updatedAt;

  SubscriptionData({
    this.id,
    this.subscriptionNumber,
    this.orderId,
    this.status,
    this.planType,
    this.cycleDays,
    this.subscriptionStartDate,
    this.subscriptionEndDate,
    this.items,
    this.initialDeliveryDate,
    this.nextDeliveryDate,
    this.nextBillingDate,
    this.lastBilledDate,
    this.lastDeliveredDate,
    this.daysUntilNextDelivery,
    this.daysUntilNextBilling,
    this.cancelledAt,
    this.pausedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory SubscriptionData.fromJson(Map<String, dynamic> json) => SubscriptionData(
    id: json["id"],
    subscriptionNumber: json["subscriptionNumber"],
    orderId: json["orderId"] == null ? null : OrderId.fromJson(json["orderId"]),
    status: json["status"],
    planType: json["planType"],
    cycleDays: json["cycleDays"],
    subscriptionStartDate: json["subscriptionStartDate"] == null ? null : DateTime.parse(json["subscriptionStartDate"]),
    subscriptionEndDate: json["subscriptionEndDate"] == null ? null : DateTime.parse(json["subscriptionEndDate"]),
    items: json["items"] == null ? [] : List<Item>.from(json["items"]!.map((x) => Item.fromJson(x))),
    initialDeliveryDate: json["initialDeliveryDate"] == null ? null : DateTime.parse(json["initialDeliveryDate"]),
    nextDeliveryDate: json["nextDeliveryDate"] == null ? null : DateTime.parse(json["nextDeliveryDate"]),
    nextBillingDate: json["nextBillingDate"] == null ? null : DateTime.parse(json["nextBillingDate"]),
    lastBilledDate: json["lastBilledDate"] == null ? null : DateTime.parse(json["lastBilledDate"]),
    lastDeliveredDate: json["lastDeliveredDate"],
    daysUntilNextDelivery: json["daysUntilNextDelivery"],
    daysUntilNextBilling: json["daysUntilNextBilling"],
    cancelledAt: json["cancelledAt"],
    pausedAt: json["pausedAt"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "subscriptionNumber": subscriptionNumber,
    "orderId": orderId?.toJson(),
    "status": status,
    "planType": planType,
    "cycleDays": cycleDays,
    "subscriptionStartDate": subscriptionStartDate?.toIso8601String(),
    "subscriptionEndDate": subscriptionEndDate?.toIso8601String(),
    "items": items == null ? [] : List<dynamic>.from(items!.map((x) => x.toJson())),
    "initialDeliveryDate": initialDeliveryDate?.toIso8601String(),
    "nextDeliveryDate": nextDeliveryDate?.toIso8601String(),
    "nextBillingDate": nextBillingDate?.toIso8601String(),
    "lastBilledDate": lastBilledDate?.toIso8601String(),
    "lastDeliveredDate": lastDeliveredDate,
    "daysUntilNextDelivery": daysUntilNextDelivery,
    "daysUntilNextBilling": daysUntilNextBilling,
    "cancelledAt": cancelledAt,
    "pausedAt": pausedAt,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
  };
}

class Item {
  String? productId;
  String? name;
  int? planDays;
  int? capsuleCount;
  double? amount;
  double? discountedPrice;
  int? taxRate;
  double? totalAmount;
  int? durationDays;
  double? savingsPercentage;
  List<String>? features;
  String? id;

  Item({
    this.productId,
    this.name,
    this.planDays,
    this.capsuleCount,
    this.amount,
    this.discountedPrice,
    this.taxRate,
    this.totalAmount,
    this.durationDays,
    this.savingsPercentage,
    this.features,
    this.id,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    productId: json["product_id"],
    name: json["name"],
    planDays: json["planDays"],
    capsuleCount: json["capsuleCount"],
    amount: json["amount"]?.toDouble(),
    discountedPrice: json["discountedPrice"]?.toDouble(),
    taxRate: json["taxRate"],
    totalAmount: json["totalAmount"]?.toDouble(),
    durationDays: json["durationDays"],
    savingsPercentage: json["savingsPercentage"]?.toDouble(),
    features: json["features"] == null ? [] : List<String>.from(json["features"]!.map((x) => x)),
    id: json["_id"],
  );

  Map<String, dynamic> toJson() => {
    "productId": productId,
    "name": name,
    "planDays": planDays,
    "capsuleCount": capsuleCount,
    "amount": amount,
    "discountedPrice": discountedPrice,
    "taxRate": taxRate,
    "totalAmount": totalAmount,
    "durationDays": durationDays,
    "savingsPercentage": savingsPercentage,
    "features": features == null ? [] : List<dynamic>.from(features!.map((x) => x)),
    "_id": id,
  };
}

class OrderId {
  String? id;
  String? orderNumber;
  String? status;

  OrderId({this.id, this.orderNumber, this.status});

  factory OrderId.fromJson(Map<String, dynamic> json) =>
      OrderId(id: json["_id"], orderNumber: json["orderNumber"], status: json["status"]);

  Map<String, dynamic> toJson() => {"_id": id, "orderNumber": orderNumber, "status": status};
}

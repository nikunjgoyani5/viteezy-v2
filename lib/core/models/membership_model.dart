// To parse this JSON data, do
//
//     final membershipsModel = membershipsModelFromJson(jsonString);

import 'dart:convert';
import 'dart:ffi';

MembershipsModel membershipsModelFromJson(String str) => MembershipsModel.fromJson(json.decode(str));

String membershipsModelToJson(MembershipsModel data) => json.encode(data.toJson());

class MembershipsModel {
  bool? success;
  String? message;
  PlanData? data;

  MembershipsModel({this.success, this.message, this.data});

  factory MembershipsModel.fromJson(Map<String, dynamic> json) => MembershipsModel(
    success: json["success"],
    message: json["message"],
    data: json["data"] == null ? null : PlanData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {"success": success, "message": message, "data": data?.toJson()};
}

class PlanData {
  List<Plan>? plans;

  PlanData({this.plans});

  factory PlanData.fromJson(Map<String, dynamic> json) =>
      PlanData(plans: json["plans"] == null ? [] : List<Plan>.from(json["plans"]!.map((x) => Plan.fromJson(x))));

  Map<String, dynamic> toJson() => {"plans": plans == null ? [] : List<dynamic>.from(plans!.map((x) => x.toJson()))};
}

class Plan {
  String? id;
  String? name;
  String? slug;
  String? shortDescription;
  String? description;
  Price? price;
  String? interval;
  int? durationDays;
  List<String>? benefits;
  bool? isAutoRenew;

  Plan({
    this.id,
    this.name,
    this.slug,
    this.shortDescription,
    this.description,
    this.price,
    this.interval,
    this.durationDays,
    this.benefits,
    this.isAutoRenew,
  });

  factory Plan.fromJson(Map<String, dynamic> json) => Plan(
    id: json["id"],
    name: json["name"],
    slug: json["slug"],
    shortDescription: json["shortDescription"],
    description: json["description"],
    price: json["price"] == null ? null : Price.fromJson(json["price"]),
    interval: json["interval"],
    durationDays: json["durationDays"],
    benefits: json["benefits"] == null ? [] : List<String>.from(json["benefits"]!.map((x) => x)),
    isAutoRenew: json["isAutoRenew"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "slug": slug,
    "shortDescription": shortDescription,
    "description": description,
    "price": price?.toJson(),
    "interval": interval,
    "durationDays": durationDays,
    "benefits": benefits == null ? [] : List<dynamic>.from(benefits!.map((x) => x)),
    "isAutoRenew": isAutoRenew,
  };
}

class Price {
  String? currency;
  num? amount;
  num? taxRate;

  Price({this.currency, this.amount, this.taxRate});

  factory Price.fromJson(Map<String, dynamic> json) =>
      Price(currency: json["currency"], amount: json["amount"] ?? 0.0, taxRate: json["taxRate"] ?? 0.0);

  Map<String, dynamic> toJson() => {"currency": currency, "amount": amount, "taxRate": taxRate};
}

// Membership List Model
class MembershipListItem {
  final String id;
  final String status;
  final String planLabel;
  final PlanDetail? planId;
  final PlanSnapshot? planSnapshot;
  final String amountDisplay;
  final dynamic pauseDate;
  final dynamic daysUntilExpiry;
  final dynamic daysUntilNextBilling;
  final dynamic pauseReason;
  final bool isAutoRenew;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  MembershipListItem({
    required this.id,
    required this.status,
    required this.planLabel,
    this.planId,
    this.planSnapshot,
    required this.amountDisplay,
    this.pauseDate,
    this.daysUntilExpiry,
    this.daysUntilNextBilling,
    this.pauseReason,
    required this.isAutoRenew,
    this.createdAt,
    this.updatedAt,
  });

  factory MembershipListItem.fromJson(Map<String, dynamic> json) {
    return MembershipListItem(
      id: json['id'] ?? '',
      status: json['status'] ?? '',
      planLabel: json['planLabel'] ?? '',
      planId: json['planId'] != null ? PlanDetail.fromJson(json['planId']) : null,
      planSnapshot: json['planSnapshot'] != null ? PlanSnapshot.fromJson(json['planSnapshot']) : null,
      amountDisplay: json['amountDisplay'] ?? '',
      pauseDate: json['pauseDate'],
      daysUntilExpiry: json['daysUntilExpiry'],
      daysUntilNextBilling: json['daysUntilNextBilling'],
      pauseReason: json['pauseReason'],
      isAutoRenew: json['isAutoRenew'] ?? false,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'planLabel': planLabel,
      'planId': planId?.toJson(),
      'planSnapshot': planSnapshot?.toJson(),
      'amountDisplay': amountDisplay,
      'pauseDate': pauseDate,
      'daysUntilExpiry': daysUntilExpiry,
      'daysUntilNextBilling': daysUntilNextBilling,
      'pauseReason': pauseReason,
      'isAutoRenew': isAutoRenew,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class PlanDetail {
  final String id;
  final String name;
  final String slug;
  final PriceDetail? price;
  final String interval;
  final int durationDays;
  final List<String> benefits;

  PlanDetail({
    required this.id,
    required this.name,
    required this.slug,
    this.price,
    required this.interval,
    required this.durationDays,
    required this.benefits,
  });

  factory PlanDetail.fromJson(Map<String, dynamic> json) {
    return PlanDetail(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      price: json['price'] != null ? PriceDetail.fromJson(json['price']) : null,
      interval: json['interval'] ?? '',
      durationDays: json['durationDays'] ?? 0,
      benefits: List<String>.from(json['benefits'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'slug': slug,
      'price': price?.toJson(),
      'interval': interval,
      'durationDays': durationDays,
      'benefits': benefits,
    };
  }
}

class PriceDetail {
  final String currency;
  final num amount;
  final num taxRate;

  PriceDetail({
    required this.currency,
    required this.amount,
    required this.taxRate,
  });

  factory PriceDetail.fromJson(Map<String, dynamic> json) {
    return PriceDetail(
      currency: json['currency'] ?? '',
      amount: json['amount'] ?? 0,
      taxRate: json['taxRate'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currency': currency,
      'amount': amount,
      'taxRate': taxRate,
    };
  }
}

class PlanSnapshot {
  final String planId;
  final String name;
  final String slug;
  final String interval;
  final int durationDays;
  final PriceDetail? price;
  final List<String> benefits;

  PlanSnapshot({
    required this.planId,
    required this.name,
    required this.slug,
    required this.interval,
    required this.durationDays,
    this.price,
    required this.benefits,
  });

  factory PlanSnapshot.fromJson(Map<String, dynamic> json) {
    return PlanSnapshot(
      planId: json['planId'] ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      interval: json['interval'] ?? '',
      durationDays: json['durationDays'] ?? 0,
      price: json['price'] != null ? PriceDetail.fromJson(json['price']) : null,
      benefits: List<String>.from(json['benefits'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'planId': planId,
      'name': name,
      'slug': slug,
      'interval': interval,
      'durationDays': durationDays,
      'price': price?.toJson(),
      'benefits': benefits,
    };
  }
}

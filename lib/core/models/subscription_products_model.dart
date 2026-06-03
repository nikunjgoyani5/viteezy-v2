// Model for GET subscriptions/:id/products response

import 'package:viteezy/core/models/product_response_model.dart';

class SubscriptionProductsData {
  final String? subscriptionId;
  final List<SubscriptionProductItem> items;

  SubscriptionProductsData({
    this.subscriptionId,
    required this.items,
  });

  factory SubscriptionProductsData.fromJson(Map<String, dynamic> json) {
    List<SubscriptionProductItem> itemList = [];
    if (json['items'] != null && json['items'] is List) {
      for (var e in json['items'] as List) {
        if (e is Map<String, dynamic>) {
          itemList.add(SubscriptionProductItem.fromJson(e));
        }
      }
    }
    return SubscriptionProductsData(
      subscriptionId: json['subscriptionId']?.toString(),
      items: itemList,
    );
  }

  Map<String, dynamic> toJson() => {
        'subscriptionId': subscriptionId,
        'items': items.map((e) => e.toJson()).toList(),
      };
}

class SubscriptionProductItem {
  final String? productId;
  final String? name;
  final int? planDays;
  final int? capsuleCount;
  final double? amount;
  final double? discountedPrice;
  final int? taxRate;
  final double? totalAmount;
  final int? durationDays;
  final double? savingsPercentage;
  final List<String>? features;
  final Product? product;

  SubscriptionProductItem({
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
    this.product,
  });

  factory SubscriptionProductItem.fromJson(Map<String, dynamic> json) {
    List<String> featuresList = [];
    if (json['features'] != null && json['features'] is List) {
      for (var e in json['features'] as List) {
        if (e != null) featuresList.add(e.toString());
      }
    }
    return SubscriptionProductItem(
      productId: json['productId']?.toString(),
      name: json['name']?.toString(),
      planDays: json['planDays'] is int ? json['planDays'] as int : (json['planDays'] is num ? (json['planDays'] as num).toInt() : null),
      capsuleCount: json['capsuleCount'] is int ? json['capsuleCount'] as int : (json['capsuleCount'] is num ? (json['capsuleCount'] as num).toInt() : null),
      amount: (json['amount'] is num) ? (json['amount'] as num).toDouble() : null,
      discountedPrice: (json['discountedPrice'] is num) ? (json['discountedPrice'] as num).toDouble() : null,
      taxRate: json['taxRate'] is int ? json['taxRate'] as int : (json['taxRate'] is num ? (json['taxRate'] as num).toInt() : null),
      totalAmount: (json['totalAmount'] is num) ? (json['totalAmount'] as num).toDouble() : null,
      durationDays: json['durationDays'] is int ? json['durationDays'] as int : (json['durationDays'] is num ? (json['durationDays'] as num).toInt() : null),
      savingsPercentage: (json['savingsPercentage'] is num) ? (json['savingsPercentage'] as num).toDouble() : null,
      features: featuresList.isNotEmpty ? featuresList : null,
      product: json['product'] != null && json['product'] is Map<String, dynamic>
          ? Product.fromJson(json['product'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'name': name,
        'planDays': planDays,
        'capsuleCount': capsuleCount,
        'amount': amount,
        'discountedPrice': discountedPrice,
        'taxRate': taxRate,
        'totalAmount': totalAmount,
        'durationDays': durationDays,
        'savingsPercentage': savingsPercentage,
        'features': features,
        'product': product?.toJson(),
      };
}

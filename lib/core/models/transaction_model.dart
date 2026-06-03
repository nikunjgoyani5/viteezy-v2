class TransactionModel {
  final String id;
  final String paymentMethod;
  final String status;
  final String transactionId;
  final num amount;
  final String currency;
  final num taxRate;
  final DateTime? processedAt;
  final String? orderId;
  final String? membershipId;
  final String? subscriptionId;
  final DateTime? createdAt;
  final SubscriptionModel? subscription;

  TransactionModel({
    required this.id,
    required this.paymentMethod,
    required this.status,
    required this.transactionId,
    required this.amount,
    required this.currency,
    required this.taxRate,
    this.processedAt,
    this.orderId,
    this.membershipId,
    this.subscriptionId,
    this.createdAt,
    this.subscription,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] ?? '',
      paymentMethod: json['paymentMethod'] ?? '',
      status: json['status'] ?? '',
      transactionId: json['transactionId'] ?? '',
      amount: json['amount'] ?? 0,
      currency: json['currency'] ?? '',
      taxRate: json['taxRate'] ?? 0,
      processedAt: json['processedAt'] != null ? DateTime.tryParse(json['processedAt']) : null,
      orderId: json['orderId'],
      membershipId: json['membershipId'],
      subscriptionId: json['subscriptionId'],
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      subscription: json['subscription'] != null ? SubscriptionModel.fromJson(json['subscription']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'paymentMethod': paymentMethod,
      'status': status,
      'transactionId': transactionId,
      'amount': amount,
      'currency': currency,
      'taxRate': taxRate,
      'processedAt': processedAt?.toIso8601String(),
      'orderId': orderId,
      'membershipId': membershipId,
      'subscriptionId': subscriptionId,
      'createdAt': createdAt?.toIso8601String(),
      'subscription': subscription?.toJson(),
    };
  }
}

class SubscriptionModel {
  final String id;
  final String subscriptionNumber;
  final String status;
  final String planType;
  final int cycleDays;
  final DateTime? subscriptionStartDate;
  final DateTime? subscriptionEndDate;
  final DateTime? nextDeliveryDate;
  final DateTime? nextBillingDate;
  final DateTime? lastBilledDate;
  final bool isAutoRenew;
  final int renewalCount;
  final List<SubscriptionItem> items;

  SubscriptionModel({
    required this.id,
    required this.subscriptionNumber,
    required this.status,
    required this.planType,
    required this.cycleDays,
    this.subscriptionStartDate,
    this.subscriptionEndDate,
    this.nextDeliveryDate,
    this.nextBillingDate,
    this.lastBilledDate,
    required this.isAutoRenew,
    required this.renewalCount,
    required this.items,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['id'] ?? '',
      subscriptionNumber: json['subscriptionNumber'] ?? '',
      status: json['status'] ?? '',
      planType: json['planType'] ?? '',
      cycleDays: json['cycleDays'] ?? 0,
      subscriptionStartDate: json['subscriptionStartDate'] != null ? DateTime.tryParse(json['subscriptionStartDate']) : null,
      subscriptionEndDate: json['subscriptionEndDate'] != null ? DateTime.tryParse(json['subscriptionEndDate']) : null,
      nextDeliveryDate: json['nextDeliveryDate'] != null ? DateTime.tryParse(json['nextDeliveryDate']) : null,
      nextBillingDate: json['nextBillingDate'] != null ? DateTime.tryParse(json['nextBillingDate']) : null,
      lastBilledDate: json['lastBilledDate'] != null ? DateTime.tryParse(json['lastBilledDate']) : null,
      isAutoRenew: json['isAutoRenew'] ?? false,
      renewalCount: json['renewalCount'] ?? 0,
      items: (json['items'] as List?)?.map((item) => SubscriptionItem.fromJson(item)).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subscriptionNumber': subscriptionNumber,
      'status': status,
      'planType': planType,
      'cycleDays': cycleDays,
      'subscriptionStartDate': subscriptionStartDate?.toIso8601String(),
      'subscriptionEndDate': subscriptionEndDate?.toIso8601String(),
      'nextDeliveryDate': nextDeliveryDate?.toIso8601String(),
      'nextBillingDate': nextBillingDate?.toIso8601String(),
      'lastBilledDate': lastBilledDate?.toIso8601String(),
      'isAutoRenew': isAutoRenew,
      'renewalCount': renewalCount,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

class SubscriptionItem {
  final String productId;
  final String name;
  final int planDays;
  final int capsuleCount;
  final num amount;
  final num discountedPrice;
  final num taxRate;
  final num totalAmount;
  final int durationDays;
  final num savingsPercentage;
  final List<String> features;

  SubscriptionItem({
    required this.productId,
    required this.name,
    required this.planDays,
    required this.capsuleCount,
    required this.amount,
    required this.discountedPrice,
    required this.taxRate,
    required this.totalAmount,
    required this.durationDays,
    required this.savingsPercentage,
    required this.features,
  });

  factory SubscriptionItem.fromJson(Map<String, dynamic> json) {
    return SubscriptionItem(
      productId: json['productId'] ?? '',
      name: json['name'] ?? '',
      planDays: json['planDays'] ?? 0,
      capsuleCount: json['capsuleCount'] ?? 0,
      amount: json['amount'] ?? 0,
      discountedPrice: json['discountedPrice'] ?? 0,
      taxRate: json['taxRate'] ?? 0,
      totalAmount: json['totalAmount'] ?? 0,
      durationDays: json['durationDays'] ?? 0,
      savingsPercentage: json['savingsPercentage'] ?? 0,
      features: List<String>.from(json['features'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
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
    };
  }
}
class Membership {
  String? id;
  String? planName;
  String? status;
  DateTime? startedAt;
  DateTime? expiresAt;
  int? planPrice;
  String? currency;
  String? interval;

  Membership({
    this.id,
    this.planName,
    this.status,
    this.startedAt,
    this.expiresAt,
    this.planPrice,
    this.currency,
    this.interval,
  });

  factory Membership.fromJson(Map<String, dynamic> json) => Membership(
    id: json["id"],
    planName: json["planName"],
    status: json["status"],
    startedAt: json["startedAt"] == null ? null : DateTime.parse(json["startedAt"]),
    expiresAt: json["expiresAt"] == null ? null : DateTime.parse(json["expiresAt"]),
    planPrice: json["planPrice"],
    currency: json["currency"],
    interval: json["interval"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "planName": planName,
    "status": status,
    "startedAt": startedAt?.toIso8601String(),
    "expiresAt": expiresAt?.toIso8601String(),
    "planPrice": planPrice,
    "currency": currency,
    "interval": interval,
  };
}
// Model for GET subscriptions/:id/activity response.
// Current API shape returns a single object under data.subscription.

class SubscriptionActivityItem {
  final String? id;
  final String? subscriptionNumber;
  final SubscriptionActivityOrder? order;
  final String? status;
  final String? planType;
  final int? cycleDays;
  final String? subscriptionStartDate;
  final String? subscriptionEndDate;
  final List<SubscriptionActivityPlanItem> items;
  final String? initialDeliveryDate;
  final String? nextDeliveryDate;
  final String? nextBillingDate;
  final String? lastBilledDate;
  final String? lastDeliveredDate;
  final int? daysUntilNextDelivery;
  final int? daysUntilNextBilling;
  final String? cancelledAt;
  final String? cancellationReason;
  final String? pausedAt;
  final String? pausedUntil;
  final String? createdAt;
  final String? updatedAt;

  const SubscriptionActivityItem({
    this.id,
    this.subscriptionNumber,
    this.order,
    this.status,
    this.planType,
    this.cycleDays,
    this.subscriptionStartDate,
    this.subscriptionEndDate,
    this.items = const [],
    this.initialDeliveryDate,
    this.nextDeliveryDate,
    this.nextBillingDate,
    this.lastBilledDate,
    this.lastDeliveredDate,
    this.daysUntilNextDelivery,
    this.daysUntilNextBilling,
    this.cancelledAt,
    this.cancellationReason,
    this.pausedAt,
    this.pausedUntil,
    this.createdAt,
    this.updatedAt,
  });

  factory SubscriptionActivityItem.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final parsedItems = rawItems is List
        ? rawItems
              .map((e) => e is Map<String, dynamic> ? SubscriptionActivityPlanItem.fromJson(e) : null)
              .whereType<SubscriptionActivityPlanItem>()
              .toList()
        : <SubscriptionActivityPlanItem>[];

    return SubscriptionActivityItem(
      id: json['_id']?.toString() ?? json['id']?.toString(),
      subscriptionNumber: json['subscriptionNumber']?.toString(),
      order: json['orderId'] is Map<String, dynamic> ? SubscriptionActivityOrder.fromJson(json['orderId']) : null,
      status: json['status']?.toString(),
      planType: json['planType']?.toString(),
      cycleDays: _toInt(json['cycleDays']),
      subscriptionStartDate: json['subscriptionStartDate']?.toString(),
      subscriptionEndDate: json['subscriptionEndDate']?.toString(),
      items: parsedItems,
      initialDeliveryDate: json['initialDeliveryDate']?.toString(),
      nextDeliveryDate: json['nextDeliveryDate']?.toString(),
      nextBillingDate: json['nextBillingDate']?.toString(),
      lastBilledDate: json['lastBilledDate']?.toString(),
      lastDeliveredDate: json['lastDeliveredDate']?.toString(),
      daysUntilNextDelivery: _toInt(json['daysUntilNextDelivery']),
      daysUntilNextBilling: _toInt(json['daysUntilNextBilling']),
      cancelledAt: json['cancelledAt']?.toString(),
      cancellationReason: json['cancellationReason']?.toString(),
      pausedAt: json['pausedAt']?.toString(),
      pausedUntil: json['pausedUntil']?.toString(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  // Backward-compatible helpers used by existing UI
  String? get toStatus => status;
  int? get planCycleDays => cycleDays;
  double? get planPriceTotal {
    if (items.isEmpty) return null;
    return items.fold<double>(0.0, (sum, item) => sum + (item.totalAmount ?? 0.0));
  }

  String? get planCurrency => items.firstWhere((e) => e.currency != null, orElse: () => const SubscriptionActivityPlanItem()).currency;
  String? get reason => cancellationReason;

  static int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return null;
  }
}

class SubscriptionActivityOrder {
  final String? id;
  final String? orderNumber;
  final String? status;

  const SubscriptionActivityOrder({this.id, this.orderNumber, this.status});

  factory SubscriptionActivityOrder.fromJson(Map<String, dynamic> json) => SubscriptionActivityOrder(
    id: json['_id']?.toString() ?? json['id']?.toString(),
    orderNumber: json['orderNumber']?.toString(),
    status: json['status']?.toString(),
  );
}

class SubscriptionActivityPlanItem {
  final String? id;
  final String? productId;
  final String? name;
  final int? planDays;
  final int? capsuleCount;
  final double? amount;
  final double? discountedPrice;
  final double? taxRate;
  final double? totalAmount;
  final int? durationDays;
  final double? savingsPercentage;
  final String? currency;

  const SubscriptionActivityPlanItem({
    this.id,
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
    this.currency,
  });

  factory SubscriptionActivityPlanItem.fromJson(Map<String, dynamic> json) {
    String? currency;
    final rawProduct = json['productId'];
    if (rawProduct is Map<String, dynamic>) {
      final price = rawProduct['price'];
      if (price is Map<String, dynamic>) {
        currency = price['currency']?.toString();
      }
    }

    return SubscriptionActivityPlanItem(
      id: json['_id']?.toString() ?? json['id']?.toString(),
      productId: json['product_id']?.toString(),
      name: json['name']?.toString(),
      planDays: SubscriptionActivityItem._toInt(json['planDays']),
      capsuleCount: SubscriptionActivityItem._toInt(json['capsuleCount']),
      amount: json['amount'] is num ? (json['amount'] as num).toDouble() : null,
      discountedPrice: json['discountedPrice'] is num ? (json['discountedPrice'] as num).toDouble() : null,
      taxRate: json['taxRate'] is num ? (json['taxRate'] as num).toDouble() : null,
      totalAmount: json['totalAmount'] is num ? (json['totalAmount'] as num).toDouble() : null,
      durationDays: SubscriptionActivityItem._toInt(json['durationDays']),
      savingsPercentage: json['savingsPercentage'] is num ? (json['savingsPercentage'] as num).toDouble() : null,
      currency: currency,
    );
  }
}

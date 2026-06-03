// To parse this JSON data, do
//
//     final checkoutSummaryModel = checkoutSummaryModelFromJson(jsonString);

import 'dart:convert';

CheckoutSummaryData checkoutSummaryModelFromJson(String str) => CheckoutSummaryData.fromJson(json.decode(str));

String checkoutSummaryModelToJson(CheckoutSummaryData data) => json.encode(data.toJson());

class CheckoutSummaryData {
  Cart? cart;
  List<SubscriptionPlan>? sachetsPlans;
  Map<String, List<SubscriptionPlan>>? standUpPouchPlans;
  Pricing? pricing;
  dynamic shippingAddressId;
  dynamic billingAddressId;
  List<SuggestedProduct>? suggestedProducts;

  CheckoutSummaryData({
    this.cart,
    this.pricing,
    this.shippingAddressId,
    this.billingAddressId,
    this.suggestedProducts,
    this.sachetsPlans,
    this.standUpPouchPlans,
  });

  factory CheckoutSummaryData.fromJson(Map<String, dynamic> json) => CheckoutSummaryData(
    cart: json["cart"] == null ? null : Cart.fromJson(json["cart"]),
    pricing: json["pricing"] == null ? null : Pricing.fromJson(json["pricing"]),
    shippingAddressId: json["shippingAddressId"],
    billingAddressId: json["billingAddressId"],
    suggestedProducts: json["suggestedProducts"] == null
        ? []
        : List<SuggestedProduct>.from(json["suggestedProducts"]!.map((x) => SuggestedProduct.fromJson(x))),
    sachetsPlans: json["sachetsPlans"] == null
        ? []
        : List<SubscriptionPlan>.from(json["sachetsPlans"]!.map((x) => SubscriptionPlan.fromJson(x))),
    standUpPouchPlans: json["standUpPouchPlans"] == null
        ? null
        : Map.from(json["standUpPouchPlans"]!).map(
            (k, v) => MapEntry<String, List<SubscriptionPlan>>(
              k.toString(),
              List<SubscriptionPlan>.from((v as List).map((x) => SubscriptionPlan.fromJson(x as Map<String, dynamic>))),
            ),
          ),
  );

  Map<String, dynamic> toJson() => {
    "cart": cart?.toJson(),
    "pricing": pricing?.toJson(),
    "shippingAddressId": shippingAddressId,
    "billingAddressId": billingAddressId,
    "suggestedProducts": suggestedProducts == null ? [] : List<dynamic>.from(suggestedProducts!.map((x) => x.toJson())),
    "sachetsPlans": sachetsPlans == null ? [] : List<dynamic>.from(sachetsPlans!.map((x) => x.toJson())),
    "standUpPouchPlans": standUpPouchPlans?.map((k, v) => MapEntry(k, v.map((x) => x.toJson()).toList())),
  };
}

class Cart {
  List<Item>? items;
  String? cartId;

  Cart({this.items, this.cartId});

  factory Cart.fromJson(Map<String, dynamic> json) => Cart(
    items: json["items"] == null ? [] : List<Item>.from(json["items"]!.map((x) => Item.fromJson(x))),
    cartId: json['cartId'],
  );

  Map<String, dynamic> toJson() => {"items": items == null ? [] : List<dynamic>.from(items!.map((x) => x.toJson()))};
}

class Item {
  String? productId;
  String? title;
  String? image;
  String? variant;
  int? quantity;
  BasePlanPrice? basePlanPrice;
  double? membershipDiscount;
  int? taxRate;

  Item({
    this.productId,
    this.title,
    this.image,
    this.variant,
    this.quantity,
    this.basePlanPrice,
    this.membershipDiscount,
    this.taxRate,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    productId: json["productId"],
    title: json["title"],
    image: json["image"],
    variant: json["variant"],
    quantity: json["quantity"],
    basePlanPrice: json["basePlanPrice"] == null ? null : BasePlanPrice.fromJson(json["basePlanPrice"]),
    membershipDiscount: json["membershipDiscount"] != null
        ? (json["membershipDiscount"] is int
              ? (json["membershipDiscount"] as int).toDouble()
              : (json["membershipDiscount"] as num).toDouble())
        : 0.0,
    taxRate: json["taxRate"],
  );

  Map<String, dynamic> toJson() => {
    "productId": productId,
    "title": title,
    "image": image,
    "variant": variant,
    "quantity": quantity,
    "basePlanPrice": basePlanPrice?.toJson(),
    "membershipDiscount": membershipDiscount,
    "taxRate": taxRate,
  };
}

class BasePlanPrice {
  String? currency;
  double? amount;
  double? discountedPrice;
  double? totalAmount;
  String? planType;
  int? taxRate;

  BasePlanPrice({this.currency, this.amount, this.discountedPrice, this.totalAmount, this.planType, this.taxRate});

  factory BasePlanPrice.fromJson(Map<String, dynamic> json) => BasePlanPrice(
    currency: json["currency"],
    amount: json["amount"]?.toDouble(),
    discountedPrice: json["discountedPrice"]?.toDouble(),
    totalAmount: json["totalAmount"]?.toDouble(),
    planType: json["planType"],
    taxRate: json["taxRate"],
  );

  Map<String, dynamic> toJson() => {
    "currency": currency,
    "amount": amount,
    "discountedPrice": discountedPrice,
    "totalAmount": totalAmount,
    "planType": planType,
    "taxRate": taxRate,
  };
}

class Pricing {
  SachetsPrice? sachets;
  StandUpPouchPrice? standUpPouch;
  Overall? overall;

  Pricing({this.sachets, this.standUpPouch, this.overall});

  factory Pricing.fromJson(Map<String, dynamic> json) => Pricing(
    sachets: json["sachets"] == null ? null : SachetsPrice.fromJson(json["sachets"]),
    standUpPouch: json["standUpPouch"] == null ? null : StandUpPouchPrice.fromJson(json["standUpPouch"]),
    overall: json["overall"] == null ? null : Overall.fromJson(json["overall"]),
  );

  Map<String, dynamic> toJson() => {
    "sachets": sachets?.toJson(),
    "standUpPouch": standUpPouch?.toJson(),
    "overall": overall?.toJson(),
  };
}

class StandUpPouchPrice {
  double? subTotal;
  double? discountedPrice;
  int? membershipDiscountAmount;

  int? taxAmount;

  // double? grandTotal;
  String? currency;
  double? total;

  StandUpPouchPrice({
    this.subTotal,
    this.discountedPrice,
    this.membershipDiscountAmount,

    this.taxAmount,
    // this.grandTotal,
    this.currency,
    this.total,
  });

  factory StandUpPouchPrice.fromJson(Map<String, dynamic> json) => StandUpPouchPrice(
    subTotal: json["subTotal"]?.toDouble(),
    discountedPrice: json["discountedPrice"]?.toDouble(),
    membershipDiscountAmount: json["membershipDiscountAmount"],
    taxAmount: json["taxAmount"],
    currency: json["currency"],
    total: json["total"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "subTotal": subTotal,
    "discountedPrice": discountedPrice,
    "membershipDiscountAmount": membershipDiscountAmount,
    "taxAmount": taxAmount,
    "currency": currency,
    "total": total,
  };
}

class SachetsPrice {
  double? subTotal;
  double? discountedPrice;
  double? membershipDiscountAmount;
  double? subscriptionPlanDiscountAmount;
  int? taxAmount;

  // double? grandTotal;
  String? currency;
  double? total;

  SachetsPrice({
    this.subTotal,
    this.discountedPrice,
    this.membershipDiscountAmount,
    this.subscriptionPlanDiscountAmount,
    this.taxAmount,
    // this.grandTotal,
    this.currency,
    this.total,
  });

  factory SachetsPrice.fromJson(Map<String, dynamic> json) => SachetsPrice(
    subTotal: json["subTotal"]?.toDouble(),
    discountedPrice: json["discountedPrice"]?.toDouble(),
    membershipDiscountAmount: json["membershipDiscountAmount"]?.toDouble(),
    subscriptionPlanDiscountAmount: json["subscriptionPlanDiscountAmount"]?.toDouble(),
    taxAmount: json["taxAmount"],
    currency: json["currency"],
    total: json["total"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "subTotal": subTotal,
    "discountedPrice": discountedPrice,
    "membershipDiscountAmount": membershipDiscountAmount,
    "subscriptionPlanDiscountAmount": subscriptionPlanDiscountAmount,
    "taxAmount": taxAmount,
    "currency": currency,
    "total": total,
  };
}

class Overall {
  double? subTotal;
  double? discountedPrice;
  double? couponDiscountAmount;
  double? membershipDiscountAmount;
  double? subscriptionPlanDiscountAmount;
  double? taxAmount;
  double? grandTotal;
  String? currency;

  // double? total;

  Overall({
    this.subTotal,
    this.discountedPrice,
    this.couponDiscountAmount,
    this.membershipDiscountAmount,
    this.subscriptionPlanDiscountAmount,
    this.taxAmount,
    this.grandTotal,
    this.currency,
    // this.total,
  });

  factory Overall.fromJson(Map<String, dynamic> json) => Overall(
    subTotal: json["subTotal"]?.toDouble(),
    discountedPrice: json["discountedPrice"]?.toDouble(),
    couponDiscountAmount: json["couponDiscountAmount"]?.toDouble(),
    membershipDiscountAmount: json["membershipDiscountAmount"]?.toDouble(),
    subscriptionPlanDiscountAmount: json["subscriptionPlanDiscountAmount"]?.toDouble(),
    taxAmount: json["taxAmount"]?.toDouble(),
    grandTotal: json["grandTotal"]?.toDouble(),
    currency: json["currency"],
    // total: json["total"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "subTotal": subTotal,
    "discountedPrice": discountedPrice,
    "couponDiscountAmount": couponDiscountAmount,
    "membershipDiscountAmount": membershipDiscountAmount,
    "subscriptionPlanDiscountAmount": subscriptionPlanDiscountAmount,
    "taxAmount": taxAmount,
    "grandTotal": grandTotal,
    "currency": currency,
    // "total": total,
  };
}

class SubscriptionPlan {
  String? planKey;
  String? label;
  int? durationDays;
  int? capsuleCount;
  double? totalAmount;
  double? amount;
  double? discountedPrice;
  double? savePercentage;
  int? supplementsCount;
  double? perMonthAmount;
  double? perDeliveryAmount;
  List<String>? features;
  bool? isRecommended;
  bool? isSelected;
  bool? isSubscription;

  SubscriptionPlan({
    this.planKey,
    this.label,
    this.durationDays,
    this.capsuleCount,
    this.totalAmount,
    this.discountedPrice,
    this.savePercentage,
    this.supplementsCount,
    this.perMonthAmount,
    this.perDeliveryAmount,
    this.features,
    this.isRecommended,
    this.isSelected,
    this.isSubscription,
    this.amount,
  });

  factory SubscriptionPlan.fromJson(Map<String, dynamic> json) => SubscriptionPlan(
    planKey: json["planKey"],
    label: json["label"],
    durationDays: json["durationDays"],
    capsuleCount: json["capsuleCount"],
    totalAmount: json["totalAmount"]?.toDouble(),
    discountedPrice: json["discountedPrice"]?.toDouble(),
    savePercentage: json["savePercentage"]?.toDouble(),
    supplementsCount: json["supplementsCount"],
    perMonthAmount: json["perMonthAmount"]?.toDouble(),
    perDeliveryAmount: json["perDeliveryAmount"]?.toDouble(),
    features: json["features"] == null ? [] : List<String>.from(json["features"]!.map((x) => x)),
    isRecommended: json["isRecommended"],
    isSelected: json["isSelected"],
    isSubscription: json["isSubscription"],
    amount: json['amount']?.toDouble() ?? 0.0,
  );

  Map<String, dynamic> toJson() => {
    "planKey": planKey,
    "label": label,
    "durationDays": durationDays,
    "capsuleCount": capsuleCount,
    "totalAmount": totalAmount,
    "discountedPrice": discountedPrice,
    "savePercentage": savePercentage,
    "supplementsCount": supplementsCount,
    "perMonthAmount": perMonthAmount,
    "perDeliveryAmount": perDeliveryAmount,
    "features": features == null ? [] : List<dynamic>.from(features!.map((x) => x)),
    "isRecommended": isRecommended,
    "isSelected": isSelected,
    "isSubscription": isSubscription,
  };
}

class SuggestedProduct {
  String? productId;
  String? title;
  String? image;
  double? price;
  String? variant;

  SuggestedProduct({this.productId, this.title, this.image, this.price, this.variant});

  factory SuggestedProduct.fromJson(Map<String, dynamic> json) => SuggestedProduct(
    productId: json["productId"],
    title: json["title"],
    image: json["image"],
    price: json["price"]?.toDouble(),
    variant: json["variant"],
  );

  Map<String, dynamic> toJson() => {
    "productId": productId,
    "title": title,
    "image": image,
    "price": price,
    "variant": variant,
  };
}

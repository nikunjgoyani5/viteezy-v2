// To parse this JSON data, do
//
//     final productModel = productModelFromJson(jsonString);

import 'dart:convert';

import 'api_response.dart';
import 'categories_response_model.dart';
import '../l10n/locale_service.dart';

ProductResponseModel productModelFromJson(String str) => ProductResponseModel.fromJson(json.decode(str));

String productModelToJson(ProductResponseModel data) => json.encode(data.toJson());

class ProductResponseModel {
  bool? success;
  String? message;
  List<Product>? data;
  Pagination? pagination;

  ProductResponseModel({this.success, this.message, this.data, this.pagination});

  factory ProductResponseModel.fromJson(Map<String, dynamic> json) => ProductResponseModel(
    success: json["success"],
    message: json["message"],
    data: json["data"] == null ? [] : List<Product>.from(json["data"]!.map((x) => Product.fromJson(x))),
    pagination: json["pagination"] == null ? null : Pagination.fromJson(json["pagination"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    "pagination": pagination?.toJson(),
  };
}

class Product {
  String? id;
  String? title;
  String? slug;
  String? description;
  String? shortDescription;
  String? productImage;
  List<String>? benefits;
  List<Ingredient>? ingredients;
  /// Localized ingredient copy from product detail API; prefer over [ingredients] when present.
  List<Ingredient>? productIngredientDetails;
  List<Category>? categories;
  List<String>? healthGoals;
  String? nutritionInfo;
  List<String>? galleryImages;
  String? howToUse;
  bool? status;
  Price? price;
  String? variant;
  bool? hasStandupPouch;
  SachetPrices? sachetPrices;
  StandupPouchPrice? standupPouchPrice;
  List<String>? standupPouchImages;
  ComparisonSection? comparisonSection;
  Specification? specification;
  bool? isFeatured;
  bool? isDeleted;
  dynamic deletedAt;
  String? createdBy;
  dynamic updatedBy;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;
  int? averageRating;
  int? ratingCount;
  List<dynamic>? variants;
  bool? isMember;
  bool? isLiked;
  bool? isInSubscription ;
  bool? isInCart;

  Product({
    this.id,
    this.title,
    this.slug,
    this.description,
    this.shortDescription,
    this.productImage,
    this.benefits,
    this.ingredients,
    this.productIngredientDetails,
    this.categories,
    this.healthGoals,
    this.nutritionInfo,
    this.galleryImages,
    this.howToUse,
    this.status,
    this.price,
    this.variant,
    this.hasStandupPouch,
    this.sachetPrices,
    this.standupPouchPrice,
    this.standupPouchImages,
    this.comparisonSection,
    this.specification,
    this.isFeatured,
    this.isDeleted,
    this.deletedAt,
    this.createdBy,
    this.updatedBy,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.averageRating,
    this.ratingCount,
    this.variants,
    this.isMember,
    this.isLiked,
    this.isInCart,
    this.isInSubscription,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json["_id"],
    title: json["title"],
    slug: json["slug"],
    description: json["description"],
    shortDescription: json["shortDescription"],
    productImage: json["productImage"],
    benefits: json["benefits"] == null ? [] : List<String>.from(json["benefits"]!.map((x) => x)),
    ingredients: json["ingredients"] == null
        ? []
        : List<Ingredient>.from(json["ingredients"]!.map((x) => Ingredient.fromJson(x as Map<String, dynamic>))),
    productIngredientDetails: json["productIngredientDetails"] == null
        ? []
        : List<Ingredient>.from(
            json["productIngredientDetails"]!.map((x) => Ingredient.fromJson(x as Map<String, dynamic>)),
          ),
    categories: json["categories"] == null
        ? []
        : List<Category>.from(json["categories"]!.map((x) => Category.fromJson(x))),
    healthGoals: json["healthGoals"] == null ? [] : List<String>.from(json["healthGoals"]!.map((x) => x)),
    nutritionInfo: json["nutritionInfo"],
    galleryImages: json["galleryImages"] == null ? [] : List<String>.from(json["galleryImages"]!.map((x) => x)),
    howToUse: json["howToUse"],
    status: json["status"],
    price: json["price"] == null ? null : Price.fromJson(json["price"]),
    variant: json["variant"],
    hasStandupPouch: json["hasStandupPouch"],
    sachetPrices: json["sachetPrices"] == null ? null : SachetPrices.fromJson(json["sachetPrices"]),
    standupPouchPrice: json["standupPouchPrice"] == null ? null : StandupPouchPrice.fromJson(json["standupPouchPrice"]),
    standupPouchImages: json["standupPouchImages"] == null
        ? []
        : List<String>.from(json["standupPouchImages"]!.map((x) => x)),
    comparisonSection: json["comparisonSection"] == null ? null : ComparisonSection.fromJson(json["comparisonSection"]),
    specification: json["specification"] == null ? null : Specification.fromJson(json["specification"]),
    isFeatured: json["isFeatured"],
    isDeleted: json["isDeleted"],
    deletedAt: json["deletedAt"],
    createdBy: json["createdBy"],
    updatedBy: json["updatedBy"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    v: json["__v"],
    averageRating: json["averageRating"],
    ratingCount: json["ratingCount"],
    variants: json["variants"] == null ? [] : List<dynamic>.from(json["variants"]!.map((x) => x)),
    isMember: json["isMember"],
    isLiked: json["is_liked"],
    isInCart: json['isInCart'],
    isInSubscription : json['isInSubscription'],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "title": title,
    "slug": slug,
    "description": description,
    "shortDescription": shortDescription,
    "productImage": productImage,
    "benefits": benefits == null ? [] : List<dynamic>.from(benefits!.map((x) => x)),
    "ingredients": ingredients == null ? [] : List<dynamic>.from(ingredients!.map((x) => x.toJson())),
    "productIngredientDetails": productIngredientDetails == null
        ? []
        : List<dynamic>.from(productIngredientDetails!.map((x) => x.toJson())),
    "categories": categories == null ? [] : List<dynamic>.from(categories!.map((x) => x.toJson())),
    "healthGoals": healthGoals == null ? [] : List<dynamic>.from(healthGoals!.map((x) => x)),
    "nutritionInfo": nutritionInfo,
    "galleryImages": galleryImages == null ? [] : List<dynamic>.from(galleryImages!.map((x) => x)),
    "howToUse": howToUse,
    "status": status,
    "price": price?.toJson(),
    "variant": variant,
    "hasStandupPouch": hasStandupPouch,
    "sachetPrices": sachetPrices?.toJson(),
    "standupPouchPrice": standupPouchPrice?.toJson(),
    "standupPouchImages": standupPouchImages == null ? [] : List<dynamic>.from(standupPouchImages!.map((x) => x)),
    "comparisonSection": comparisonSection?.toJson(),
    "specification": specification?.toJson(),
    "isFeatured": isFeatured,
    "isDeleted": isDeleted,
    "deletedAt": deletedAt,
    "createdBy": createdBy,
    "updatedBy": updatedBy,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
    "averageRating": averageRating,
    "ratingCount": ratingCount,
    "variants": variants == null ? [] : List<dynamic>.from(variants!.map((x) => x)),
    "isMember": isMember,
    "is_liked": isLiked,
  };

  /// Detail API may send richer localized data in [productIngredientDetails]; listings use [ingredients].
  List<Ingredient> get ingredientsForDisplay {
    final details = productIngredientDetails;
    if (details != null && details.isNotEmpty) return details;
    return ingredients ?? [];
  }
}

class ComparisonSection {
  String? title;
  List<String>? columns;
  List<Roww>? rows;

  ComparisonSection({this.title, this.columns, this.rows});

  factory ComparisonSection.fromJson(Map<String, dynamic> json) => ComparisonSection(
    title: json["title"],
    columns: json["columns"] == null ? [] : List<String>.from(json["columns"]!.map((x) => x)),
    rows: json["rows"] == null ? [] : List<Roww>.from(json["rows"]!.map((x) => Roww.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "title": title,
    "columns": columns == null ? [] : List<dynamic>.from(columns!.map((x) => x)),
    "rows": rows == null ? [] : List<dynamic>.from(rows!.map((x) => x.toJson())),
  };
}

class Roww {
  String? label;
  List<bool>? values;

  Roww({this.label, this.values});

  factory Roww.fromJson(Map<String, dynamic> json) =>
      Roww(label: json["label"], values: json["values"] == null ? [] : List<bool>.from(json["values"]!.map((x) => x)));

  Map<String, dynamic> toJson() => {
    "label": label,
    "values": values == null ? [] : List<dynamic>.from(values!.map((x) => x)),
  };
}

class Ingredient {
  String? id;
  final dynamic _name;
  final dynamic _description;
  dynamic image;

  /// Resolved for current app locale (see [LocaleService.localeCode]).
  String? get name => _localizedOrString(_name);

  String? get description => _localizedOrString(_description);

  Ingredient({this.id, dynamic name, dynamic description, this.image}) : _name = name, _description = description;

  /// API may return a plain string or a map of locale code → string (en, nl, de, fr, es).
  static String? _localizedOrString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is Map) {
      final map = value.map((k, v) => MapEntry(k.toString(), v));
      final code = LocaleService.localeCode;
      final preferred = map[code];
      if (preferred != null && preferred.toString().trim().isNotEmpty) {
        return preferred.toString();
      }
      final en = map['en'];
      if (en != null && en.toString().trim().isNotEmpty) {
        return en.toString();
      }
      for (final v in map.values) {
        if (v != null && v.toString().trim().isNotEmpty) return v.toString();
      }
    }
    return value.toString();
  }

  factory Ingredient.fromJson(Map<String, dynamic> json) => Ingredient(
        id: json["_id"]?.toString(),
        name: json["name"],
        description: json["description"],
        image: json["image"],
      );

  Map<String, dynamic> toJson() => {"_id": id, "name": _name, "description": _description, "image": image};
}

class Price {
  String? currency;
  double? amount;
  int? taxRate;
  double? totalAmount;
  int? totalTaxRate;


  Price({this.currency, this.amount, this.taxRate, this.totalAmount, this.totalTaxRate});

  factory Price.fromJson(Map<String, dynamic> json) =>
      Price(currency: json["currency"]!, amount: json["amount"]?.toDouble(), taxRate: json["taxRate"], totalAmount: json["totalAmount"]?.toDouble(), totalTaxRate: json["totalTaxRate"]);

  Map<String, dynamic> toJson() => {"currency": currency, "amount": amount, "taxRate": taxRate, "totalAmount": totalAmount, "totalTaxRate": totalTaxRate};
}

class SachetPrices {
  NinetyDays? thirtyDays;
  NinetyDays? sixtyDays;
  NinetyDays? ninetyDays;
  NinetyDays? oneEightyDays;
  OneTime? oneTime;

  SachetPrices({this.thirtyDays, this.sixtyDays, this.ninetyDays, this.oneEightyDays, this.oneTime});

  factory SachetPrices.fromJson(Map<String, dynamic> json) => SachetPrices(
    thirtyDays: json["thirtyDays"] == null ? null : NinetyDays.fromJson(json["thirtyDays"]),
    sixtyDays: json["sixtyDays"] == null ? null : NinetyDays.fromJson(json["sixtyDays"]),
    ninetyDays: json["ninetyDays"] == null ? null : NinetyDays.fromJson(json["ninetyDays"]),
    oneEightyDays: json["oneEightyDays"] == null ? null : NinetyDays.fromJson(json["oneEightyDays"]),
    oneTime: json["oneTime"] == null ? null : OneTime.fromJson(json["oneTime"]),
  );

  Map<String, dynamic> toJson() => {
    "thirtyDays": thirtyDays?.toJson(),
    "sixtyDays": sixtyDays?.toJson(),
    "ninetyDays": ninetyDays?.toJson(),
    "oneEightyDays": oneEightyDays?.toJson(),
    "oneTime": oneTime?.toJson(),
  };
}

class NinetyDays {
  String? currency;
  double? amount;
  double? discountedPrice;
  int? taxRate;
  double? totalAmount;
  int? durationDays;
  int? capsuleCount;
  double? savingsPercentage;
  List<String>? features;

  NinetyDays({
    this.currency,
    this.amount,
    this.discountedPrice,
    this.taxRate,
    this.totalAmount,
    this.durationDays,
    this.capsuleCount,
    this.savingsPercentage,
    this.features,
  });

  factory NinetyDays.fromJson(Map<String, dynamic> json) => NinetyDays(
    currency: json["currency"],
    amount: json["amount"]?.toDouble(),
    discountedPrice: json["discountedPrice"]?.toDouble(),
    taxRate: json["taxRate"],
    totalAmount: json["totalAmount"]?.toDouble(),
    durationDays: json["durationDays"],
    capsuleCount: json["capsuleCount"],
    savingsPercentage: json["savingsPercentage"]?.toDouble(),
    features: json["features"] == null
        ? []
        : List<String>.from(
      json["features"].map(
            (x) {
          // If feature is already string
          if (x is String) return x;

          // If feature is localized object
          if (x is Map<String, dynamic>) {
            return x[LocaleService.localeCode] ??
                x['en'] ??
                '';
          }

          return '';
        },
      ),
    ),
  );

  Map<String, dynamic> toJson() => {
    "currency": currency,
    "amount": amount,
    "discountedPrice": discountedPrice,
    "taxRate": taxRate,
    "totalAmount": totalAmount,
    "durationDays": durationDays,
    "capsuleCount": capsuleCount,
    "savingsPercentage": savingsPercentage,
    "features": features == null ? [] : List<dynamic>.from(features!.map((x) => x)),
  };
}

class OneTime {
  Count? count30;
  Count? count60;

  OneTime({this.count30, this.count60});

  factory OneTime.fromJson(Map<String, dynamic> json) => OneTime(
    count30: json["count30"] == null ? null : Count.fromJson(json["count30"]),
    count60: json["count60"] == null ? null : Count.fromJson(json["count60"]),
  );

  Map<String, dynamic> toJson() => {"count30": count30?.toJson(), "count60": count60?.toJson()};
}

class Count {
  String? currency;
  double? amount;
  double? discountedPrice;
  int? taxRate;
  int? capsuleCount;

  Count({this.currency, this.amount, this.discountedPrice, this.taxRate, this.capsuleCount});

  factory Count.fromJson(Map<String, dynamic> json) => Count(
    currency: json["currency"],
    amount: json["amount"]?.toDouble(),
    discountedPrice: json["discountedPrice"]?.toDouble(),
    taxRate: json["taxRate"],
    capsuleCount: json["capsuleCount"],
  );

  Map<String, dynamic> toJson() => {
    "currency": currency,
    "amount": amount,
    "discountedPrice": discountedPrice,
    "taxRate": taxRate,
    "capsuleCount": capsuleCount,
  };
}

class Specification {
  String? mainTitle;
  String? bgImage;
  List<Item>? items;

  Specification({this.mainTitle, this.bgImage, this.items});

  factory Specification.fromJson(Map<String, dynamic> json) => Specification(
    mainTitle: json["main_title"],
    bgImage: json["bg_image"],
    items: json["items"] == null ? [] : List<Item>.from(json["items"]!.map((x) => Item.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "main_title": mainTitle,
    "bg_image": bgImage,
    "items": items == null ? [] : List<dynamic>.from(items!.map((x) => x.toJson())),
  };
}

class Item {
  String? title;
  String? descr;
  String? image;
  String? imageMobile;

  Item({this.title, this.descr, this.image, this.imageMobile});

  factory Item.fromJson(Map<String, dynamic> json) =>
      Item(title: json["title"], descr: json["descr"], image: json["image"], imageMobile: json["imageMobile"]);

  Map<String, dynamic> toJson() => {"title": title, "descr": descr, "image": image, "imageMobile": imageMobile};
}

class StandupPouchPrice {
  NinetyDays? count60;
  NinetyDays? count120;

  StandupPouchPrice({this.count60, this.count120});

  factory StandupPouchPrice.fromJson(Map<String, dynamic> json) => StandupPouchPrice(
    count60: json["count_0"] == null ? null : NinetyDays.fromJson(json["count_0"]),
    count120: json["count_1"] == null ? null : NinetyDays.fromJson(json["count_1"]),
  );

  Map<String, dynamic> toJson() => {"count_0": count60?.toJson(), "count_1": count120?.toJson()};
}

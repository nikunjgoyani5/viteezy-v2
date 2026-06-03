// To parse this JSON data, do
//
//     final filtersResponseModel = filtersResponseModelFromJson(jsonString);

import 'dart:convert';

FiltersResponseModel filtersResponseModelFromJson(String str) => FiltersResponseModel.fromJson(json.decode(str));

String filtersResponseModelToJson(FiltersResponseModel data) => json.encode(data.toJson());

class FiltersResponseModel {
  bool? success;
  String? message;
  FiltersData? data;

  FiltersResponseModel({this.success, this.message, this.data});

  factory FiltersResponseModel.fromJson(Map<String, dynamic> json) => FiltersResponseModel(
    success: json["success"],
    message: json["message"],
    data: json["data"] == null ? null : FiltersData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {"success": success, "message": message, "data": data?.toJson()};
}

class FiltersData {
  List<Category>? categories;
  List<String>? healthGoals;
  List<Ingredient>? ingredients;
  List<String>? variants;
  List<bool>? hasStandupPouch;
  List<bool>? status;
  List<SortBy>? sortBy;

  FiltersData({
    this.categories,
    this.healthGoals,
    this.ingredients,
    this.variants,
    this.hasStandupPouch,
    this.status,
    this.sortBy,
  });

  factory FiltersData.fromJson(Map<String, dynamic> json) => FiltersData(
    categories: json["categories"] == null
        ? []
        : List<Category>.from(json["categories"]!.map((x) => Category.fromJson(x))),
    healthGoals: json["healthGoals"] == null ? [] : List<String>.from(json["healthGoals"]!.map((x) => x)),
    ingredients: json["ingredients"] == null
        ? []
        : List<Ingredient>.from(json["ingredients"]!.map((x) => Ingredient.fromJson(x))),
    variants: json["variants"] == null ? [] : List<String>.from(json["variants"]!.map((x) => x)),
    hasStandupPouch: json["hasStandupPouch"] == null ? [] : List<bool>.from(json["hasStandupPouch"]!.map((x) => x)),
    status: json["status"] == null ? [] : List<bool>.from(json["status"]!.map((x) => x)),
    sortBy: json["sortBy"] == null ? [] : List<SortBy>.from(json["sortBy"]!.map((x) => SortBy.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "categories": categories == null ? [] : List<dynamic>.from(categories!.map((x) => x.toJson())),
    "healthGoals": healthGoals == null ? [] : List<dynamic>.from(healthGoals!.map((x) => x)),
    "ingredients": ingredients == null ? [] : List<dynamic>.from(ingredients!.map((x) => x.toJson())),
    "variants": variants == null ? [] : List<dynamic>.from(variants!.map((x) => x)),
    "hasStandupPouch": hasStandupPouch == null ? [] : List<dynamic>.from(hasStandupPouch!.map((x) => x)),
    "status": status == null ? [] : List<dynamic>.from(status!.map((x) => x)),
    "sortBy": sortBy == null ? [] : List<dynamic>.from(sortBy!.map((x) => x)),
  };
}

class SortBy {
  String? label;
  String? value;

  SortBy({this.label, this.value});

  factory SortBy.fromJson(Map<String, dynamic> json) => SortBy(label: json["label"], value: json["value"]);

  Map<String, dynamic> toJson() => {"label": label, "value": value};
}

class Category {
  String? id;
  String? slug;
  String? name;
  String? icon;

  Category({this.id, this.slug, this.name, this.icon});

  factory Category.fromJson(Map<String, dynamic> json) =>
      Category(id: json["_id"], slug: json["slug"], name: json["name"], icon: json["icon"]);

  Map<String, dynamic> toJson() => {"_id": id, "slug": slug, "name": name, "icon": icon};
}

class Ingredient {
  String? id;
  String? name;

  Ingredient({this.id, this.name});

  factory Ingredient.fromJson(Map<String, dynamic> json) => Ingredient(id: json["_id"], name: json["name"]);

  Map<String, dynamic> toJson() => {"_id": id, "name": name};
}

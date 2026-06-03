// To parse this JSON data, do
//
//     final productReviewModel = productReviewModelFromJson(jsonString);

import 'dart:convert';

import 'package:viteezy/core/models/product_response_model.dart';

import 'api_response.dart';

ProductReviewModel productReviewModelFromJson(String str) => ProductReviewModel.fromJson(json.decode(str));

String productReviewModelToJson(ProductReviewModel data) => json.encode(data.toJson());

class ProductReviewModel {
  bool? success;
  String? message;
  List<ProductReview>? data;
  Pagination? pagination;

  ProductReviewModel({this.success, this.message, this.data, this.pagination});

  factory ProductReviewModel.fromJson(Map<String, dynamic> json) => ProductReviewModel(
    success: json["success"],
    message: json["message"],
    data: json["data"] == null ? [] : List<ProductReview>.from(json["data"]!.map((x) => ProductReview.fromJson(x))),
    pagination: json["pagination"] == null ? null : Pagination.fromJson(json["pagination"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    "pagination": pagination?.toJson(),
  };
}

class ProductReview {
  String? id;
  String? videoUrl;
  String? videoThumbnail;
  List<Product>? products;
  bool? isVisibleOnHomepage;
  bool? isFeatured;
  bool? isVisibleInLp;
  bool? isActive;
  int? displayOrder;
  bool? isDeleted;
  String? createdBy;
  String? updatedBy;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  ProductReview({
    this.id,
    this.videoUrl,
    this.videoThumbnail,
    this.products,
    this.isVisibleOnHomepage,
    this.isFeatured,
    this.isVisibleInLp,
    this.isActive,
    this.displayOrder,
    this.isDeleted,
    this.createdBy,
    this.updatedBy,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory ProductReview.fromJson(Map<String, dynamic> json) => ProductReview(
    id: json["_id"],
    videoUrl: json["videoUrl"],
    videoThumbnail: json["videoThumbnail"],
    products: json["products"] == null ? [] : List<Product>.from(json["products"]!.map((x) => Product.fromJson(x))),
    isVisibleOnHomepage: json["isVisibleOnHomepage"],
    isFeatured: json["isFeatured"],
    isVisibleInLp: json["isVisibleInLP"],
    isActive: json["isActive"],
    displayOrder: json["displayOrder"],
    isDeleted: json["isDeleted"],
    createdBy: json["createdBy"],
    updatedBy: json["updatedBy"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "videoUrl": videoUrl,
    "videoThumbnail": videoThumbnail,
    "products": products == null ? [] : List<dynamic>.from(products!.map((x) => x.toJson())),
    "isVisibleOnHomepage": isVisibleOnHomepage,
    "isFeatured": isFeatured,
    "isVisibleInLP": isVisibleInLp,
    "isActive": isActive,
    "displayOrder": displayOrder,
    "isDeleted": isDeleted,
    "createdBy": createdBy,
    "updatedBy": updatedBy,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
  };
}

class ProductDetails {
  String? id;
  String? title;
  String? slug;
  String? productImage;
  SachetPrices? sachetPrices;

  ProductDetails({this.id, this.title, this.slug, this.productImage, this.sachetPrices});

  factory ProductDetails.fromJson(Map<String, dynamic> json) => ProductDetails(
    id: json["_id"],
    title: json["title"],
    slug: json["slug"],
    productImage: json["productImage"],
    sachetPrices: json["sachetPrices"] == null ? null : SachetPrices.fromJson(json["sachetPrices"]),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "title": title,
    "slug": slug,
    "productImage": productImage,
    "sachetPrices": sachetPrices?.toJson(),
  };
}

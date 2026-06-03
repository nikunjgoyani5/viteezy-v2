// To parse this JSON data, do
//
//     final wishlistModel = wishlistModelFromJson(jsonString);

import 'dart:convert';

import 'package:viteezy/core/models/api_response.dart';
import 'package:viteezy/core/models/product_response_model.dart';

WishlistModel wishlistModelFromJson(String str) => WishlistModel.fromJson(json.decode(str));

String wishlistModelToJson(WishlistModel data) => json.encode(data.toJson());

class WishlistModel {
  bool? success;
  String? message;
  List<Product>? data;
  Pagination? pagination;

  WishlistModel({this.success, this.message, this.data, this.pagination});

  factory WishlistModel.fromJson(Map<String, dynamic> json) => WishlistModel(
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

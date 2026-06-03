// To parse this JSON data, do
//
//     final aiChatLogin = aiChatLoginFromJson(jsonString);

import 'dart:convert';

import 'ai_chat_response_model.dart';

AiChatLogin aiChatLoginFromJson(String str) => AiChatLogin.fromJson(json.decode(str));

String aiChatLoginToJson(AiChatLogin data) => json.encode(data.toJson());

class AiChatLogin {
  bool? success;
  String? message;
  LoinData? data;

  AiChatLogin({this.success, this.message, this.data});

  factory AiChatLogin.fromJson(Map<String, dynamic> json) => AiChatLogin(
    success: json["success"],
    message: json["message"],
    data: json["data"] == null ? null : LoinData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {"success": success, "message": message, "data": data?.toJson()};
}

class LoinData {
  bool? isLogin;
  bool? showRecommendation;
  String? message;
  DateTime? timestamp;
  List<ProductRecommended>? products;

  LoinData({this.isLogin, this.showRecommendation, this.message, this.timestamp, this.products});

  factory LoinData.fromJson(Map<String, dynamic> json) => LoinData(
    isLogin: json["isLogin"],
    showRecommendation: json["showRecommendation"],
    message: json["message"],
    timestamp: json["timestamp"] == null ? null : DateTime.parse(json["timestamp"]),
    products: json["products"] == null
        ? []
        : List<ProductRecommended>.from(json["products"]!.map((x) => ProductRecommended.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "isLogin": isLogin,
    "showRecommendation": showRecommendation,
    "message": message,
    "timestamp": timestamp?.toIso8601String(),
  };
}

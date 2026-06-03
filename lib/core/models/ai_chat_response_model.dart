// To parse this JSON data, do
//
//     final aiChatResponse = aiChatResponseFromJson(jsonString);

import 'dart:convert';

AiChatResponse aiChatResponseFromJson(String str) => AiChatResponse.fromJson(json.decode(str));

String aiChatResponseToJson(AiChatResponse data) => json.encode(data.toJson());

class AiChatResponse {
  bool? success;
  String? message;
  ChatData? data;

  AiChatResponse({this.success, this.message, this.data});

  factory AiChatResponse.fromJson(Map<String, dynamic> json) => AiChatResponse(
    success: json["success"],
    message: json["message"],
    data: json["data"] == null ? null : ChatData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {"success": success, "message": message, "data": data?.toJson()};
}

class ChatData {
  String? sessionId;
  Reply? reply;
  List<Option>? options;
  List<ProductRecommended>? products;
  dynamic questionType;
  dynamic redirectUrl;
  bool? isRegistered;
  DateTime? timestamp;
  bool? showLoginButton;
  bool? isError;

  ChatData({
    this.sessionId,
    this.reply,
    this.options,
    this.questionType,
    this.redirectUrl,
    this.isRegistered,
    this.timestamp,
    this.showLoginButton = true,
    this.products,
    this.isError,
  });

  factory ChatData.fromJson(Map<String, dynamic> json) => ChatData(
    sessionId: json["session_id"],
    reply: json["reply"] == null ? null : Reply.fromJson(json["reply"]),
    options: json["options"] == null ? [] : List<Option>.from(json["options"]!.map((x) => Option.fromJson(x))),
    questionType: json["question_type"],
    products: json["products"] == null
        ? []
        : List<ProductRecommended>.from(json["products"]!.map((x) => ProductRecommended.fromJson(x))),

    redirectUrl: json["redirect_url"],
    isRegistered: json["isRegistered"],
    timestamp: json["timestamp"] == null ? null : DateTime.parse(json["timestamp"]),
    showLoginButton: json["showLoginButton"],
    isError: json["isError"],
  );

  Map<String, dynamic> toJson() => {
    "session_id": sessionId,
    "reply": reply?.toJson(),
    "options": options,
    "question_type": questionType,
    "redirect_url": redirectUrl,
    "isRegistered": isRegistered,
    "timestamp": timestamp?.toIso8601String(),
    "showLoginButton": showLoginButton,
    "isError": isError,
  };
}

class ProductRecommended {
  String? title;
  String? id;
  String? shortDescription;
  String? productImage;

  ProductRecommended({this.title, this.shortDescription, this.productImage, this.id});

  factory ProductRecommended.fromJson(Map<String, dynamic> json) => ProductRecommended(
    id: json["id"],
    title: json["title"],
    shortDescription: json["shortDescription"],
    productImage: json["productImage"],
  );

  Map<String, dynamic> toJson() => {"title": title, "shortDescription": shortDescription, "productImage": productImage};
}

class Option {
  String? value;
  String? label;

  Option({this.value, this.label});

  factory Option.fromJson(Map<String, dynamic> json) => Option(value: json["value"], label: json["label"]);

  Map<String, dynamic> toJson() => {"value": value, "label": label};
}

class Reply {
  String? role;
  String? content;
  DateTime? createdAt;

  Reply({this.role, this.content, this.createdAt});

  factory Reply.fromJson(Map<String, dynamic> json) => Reply(
    role: json["role"],
    content: json["content"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
  );

  Map<String, dynamic> toJson() => {"role": role, "content": content, "created_at": createdAt?.toIso8601String()};
}

// To parse this JSON data, do
//
//     final notificationListModel = notificationListModelFromJson(jsonString);

import 'dart:convert';

import 'api_response.dart';

NotificationListModel notificationListModelFromJson(String str) => NotificationListModel.fromJson(json.decode(str));

String notificationListModelToJson(NotificationListModel data) => json.encode(data.toJson());

class NotificationListModel {
  bool? success;
  String? message;
  List<NotificationData>? data;
  Pagination? pagination;

  NotificationListModel({this.success, this.message, this.data, this.pagination});

  factory NotificationListModel.fromJson(Map<String, dynamic> json) => NotificationListModel(
    success: json["success"],
    message: json["message"],
    data: json["data"] == null
        ? []
        : List<NotificationData>.from(json["data"]!.map((x) => NotificationData.fromJson(x))),
    pagination: json["pagination"] == null ? null : Pagination.fromJson(json["pagination"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    "pagination": pagination?.toJson(),
  };
}

class NotificationData {
  String? id;
  String? userId;
  String? category;
  String? type;
  String? title;
  String? message;
  String? appRoute;
  Query? query;
  bool? isRead;
  bool? pushSent;
  bool? isDeleted;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;
  DateTime? pushSentAt;

  NotificationData({
    this.id,
    this.userId,
    this.category,
    this.type,
    this.title,
    this.message,
    this.appRoute,
    this.query,
    this.isRead,
    this.pushSent,
    this.isDeleted,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.pushSentAt,
  });

  factory NotificationData.fromJson(Map<String, dynamic> json) => NotificationData(
    id: json["_id"],
    userId: json["userId"],
    category: json["category"],
    type: json["type"],
    title: json["title"],
    message: json["message"],
    appRoute: json["appRoute"],
    query: json["query"] == null ? null : Query.fromJson(json["query"]),
    isRead: json["isRead"],
    pushSent: json["pushSent"],
    isDeleted: json["isDeleted"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    v: json["__v"],
    pushSentAt: json["pushSentAt"] == null ? null : DateTime.parse(json["pushSentAt"]),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "userId": userId,
    "category": category,
    "type": type,
    "title": title,
    "message": message,
    "appRoute": appRoute,
    "query": query?.toJson(),
    "isRead": isRead,
    "pushSent": pushSent,
    "isDeleted": isDeleted,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
    "pushSentAt": pushSentAt?.toIso8601String(),
  };
}

class Query {
  String? subscriptionId;
  String? orderId;
  String? productId;
  String? membershipId;
  String? ticketId;
  String? quizSessionId;
  String? expertId;

  Query({
    this.subscriptionId,
    this.orderId,
    this.productId,
    this.membershipId,
    this.ticketId,
    this.quizSessionId,
    this.expertId,
  });

  factory Query.fromJson(Map<String, dynamic> json) => Query(
    subscriptionId: json["subscriptionId"],
    orderId: json["orderId"],
    productId: json["productId"] ?? json["product_id"],
    membershipId: json["membershipId"],
    ticketId: json["ticketId"],
    quizSessionId: json["quizSessionId"],
    expertId: json["expertId"],
  );

  Map<String, dynamic> toJson() => {
    "subscriptionId": subscriptionId,
    "orderId": orderId,
    "productId": productId,
    "membershipId": membershipId,
    "ticketId": ticketId,
    "quizSessionId": quizSessionId,
    "expertId": expertId,
  };
}

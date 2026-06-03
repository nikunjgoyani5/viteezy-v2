// To parse this JSON data, do
//
//     final sessionHistoryModel = sessionHistoryModelFromJson(jsonString);

import 'dart:convert';

import 'package:viteezy/core/models/api_response.dart';

SessionHistoryModel sessionHistoryModelFromJson(String str) => SessionHistoryModel.fromJson(json.decode(str));

String sessionHistoryModelToJson(SessionHistoryModel data) => json.encode(data.toJson());

class SessionHistoryModel {
  bool? success;
  String? message;
  List<SessionHistory>? data;
  Pagination? pagination;

  SessionHistoryModel({this.success, this.message, this.data, this.pagination});

  factory SessionHistoryModel.fromJson(Map<String, dynamic> json) => SessionHistoryModel(
    success: json["success"],
    message: json["message"],
    data: json["data"] == null ? [] : List<SessionHistory>.from(json["data"]!.map((x) => SessionHistory.fromJson(x))),
    pagination: json["pagination"] == null ? null : Pagination.fromJson(json["pagination"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class SessionHistory {
  String? sessionId;
  String? sessionName;
  DateTime? createdAt;
  DateTime? updatedAt;

  SessionHistory({this.sessionId, this.sessionName, this.createdAt, this.updatedAt});

  factory SessionHistory.fromJson(Map<String, dynamic> json) => SessionHistory(
    sessionId: json["session_id"],
    sessionName: json["session_name"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "session_id": sessionId,
    "session_name": sessionName,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}

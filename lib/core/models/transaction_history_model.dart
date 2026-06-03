// Model for GET users/me/transactions?subscriptionId=xxx response

import 'package:viteezy/core/utils/exports.dart';

class TransactionHistoryResponse {
  final bool success;
  final String? message;
  final List<TransactionHistoryItem> data;
  final Pagination? pagination;

  TransactionHistoryResponse({
    required this.success,
    this.message,
    required this.data,
    this.pagination,
  });

  factory TransactionHistoryResponse.fromJson(Map<String, dynamic> json) {
    List<TransactionHistoryItem> list = [];
    if (json['data'] != null && json['data'] is List) {
      for (var e in json['data'] as List) {
        if (e is Map<String, dynamic>) {
          list.add(TransactionHistoryItem.fromJson(e));
        }
      }
    }
    return TransactionHistoryResponse(
      success: json['success'] == true,
      message: json['message']?.toString(),
      data: list,
      pagination: json['pagination'] != null
          ? Pagination.fromJson(json['pagination'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
        'data': data.map((e) => e.toJson()).toList(),
        'pagination': pagination?.toJson(),
      };
}

class TransactionHistoryItem {
  final String? id;
  final String? paymentMethod;
  final String? status;
  final String? transactionId;
  final double? amount;
  final String? currency;
  final double? taxRate;
  final String? processedAt;
  final String? orderId;
  final String? membershipId;
  final String? subscriptionId;
  final String? createdAt;

  TransactionHistoryItem({
    this.id,
    this.paymentMethod,
    this.status,
    this.transactionId,
    this.amount,
    this.currency,
    this.taxRate,
    this.processedAt,
    this.orderId,
    this.membershipId,
    this.subscriptionId,
    this.createdAt,
  });

  factory TransactionHistoryItem.fromJson(Map<String, dynamic> json) =>
      TransactionHistoryItem(
        id: json['id']?.toString(),
        paymentMethod: json['paymentMethod']?.toString(),
        status: json['status']?.toString(),
        transactionId: json['transactionId']?.toString(),
        amount: (json['amount'] is num) ? (json['amount'] as num).toDouble() : null,
        currency: json['currency']?.toString(),
        taxRate: (json['taxRate'] is num) ? (json['taxRate'] as num).toDouble() : null,
        processedAt: json['processedAt']?.toString(),
        orderId: json['orderId']?.toString(),
        membershipId: json['membershipId']?.toString(),
        subscriptionId: json['subscriptionId']?.toString(),
        createdAt: json['createdAt']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'paymentMethod': paymentMethod,
        'status': status,
        'transactionId': transactionId,
        'amount': amount,
        'currency': currency,
        'taxRate': taxRate,
        'processedAt': processedAt,
        'orderId': orderId,
        'membershipId': membershipId,
        'subscriptionId': subscriptionId,
        'createdAt': createdAt,
      };
}

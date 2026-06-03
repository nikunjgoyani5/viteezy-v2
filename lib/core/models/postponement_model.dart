class PostponementItem {
  final String? id;
  final String? orderId;
  final String? userId;
  final String? subscriptionId;
  final DateTime? originalDeliveryDate;
  final DateTime? requestedDeliveryDate;
  final String? reason;
  final String? status;
  final bool? isDeleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PostponementItem({
    this.id,
    this.orderId,
    this.userId,
    this.subscriptionId,
    this.originalDeliveryDate,
    this.requestedDeliveryDate,
    this.reason,
    this.status,
    this.isDeleted,
    this.createdAt,
    this.updatedAt,
  });

  factory PostponementItem.fromJson(Map<String, dynamic> json) => PostponementItem(
        id: json['_id']?.toString() ?? json['id']?.toString(),
        orderId: json['orderId']?.toString(),
        userId: json['userId']?.toString(),
        subscriptionId: json['subscriptionId']?.toString(),
        originalDeliveryDate: json['originalDeliveryDate'] != null
            ? DateTime.tryParse(json['originalDeliveryDate'].toString())
            : null,
        requestedDeliveryDate: json['requestedDeliveryDate'] != null
            ? DateTime.tryParse(json['requestedDeliveryDate'].toString())
            : null,
        reason: json['reason']?.toString(),
        status: json['status']?.toString(),
        isDeleted: json['isDeleted'] == true,
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'].toString())
            : null,
        updatedAt: json['updatedAt'] != null
            ? DateTime.tryParse(json['updatedAt'].toString())
            : null,
      );

  Map<String, dynamic> toJson() => {
        '_id': id,
        'orderId': orderId,
        'userId': userId,
        'subscriptionId': subscriptionId,
        'originalDeliveryDate': originalDeliveryDate?.toIso8601String(),
        'requestedDeliveryDate': requestedDeliveryDate?.toIso8601String(),
        'reason': reason,
        'status': status,
        'isDeleted': isDeleted,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };
}

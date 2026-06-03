/// Single row from `GET /reminders/history`.
class ReminderHistoryItem {
  final String reminderId;
  final String eventType;
  final String message;
  final DateTime? createdAt;
  final String? triggeredBy;
  final Map<String, dynamic>? oldValue;
  final Map<String, dynamic>? newValue;

  ReminderHistoryItem({
    required this.reminderId,
    required this.eventType,
    required this.message,
    this.createdAt,
    this.triggeredBy,
    this.oldValue,
    this.newValue,
  });

  factory ReminderHistoryItem.fromJson(Map<String, dynamic> json) {
    return ReminderHistoryItem(
      reminderId: json['reminderId']?.toString() ?? '',
      eventType: json['eventType']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      triggeredBy: json['triggeredBy']?.toString(),
      oldValue: json['oldValue'] is Map<String, dynamic> ? Map<String, dynamic>.from(json['oldValue'] as Map) : null,
      newValue: json['newValue'] is Map<String, dynamic> ? Map<String, dynamic>.from(json['newValue'] as Map) : null,
    );
  }
}

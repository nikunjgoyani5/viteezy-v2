import 'package:intl/intl.dart';

class ReminderModel {
   String id;
   String reminderSetBy;
   String time;
   String note;
   bool isActive;
   DateTime? createdAt;
   DateTime? updatedAt;
   int? version;

  ReminderModel({
    required this.id,
    required this.reminderSetBy,
    required this.time,
    required this.note,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
    this.version,
  });

  DateTime? get dateTime {
    try {
      DateTime? dt = DateTime.tryParse(time);

      if (dt == null) {
        // Handle format: Mon May 11 2026 11:07:15 GMT+0000 (Coordinated Universal Time)
        if (time.contains('GMT')) {

          String part = time.split('GMT')[0].trim();
          try {
            dt = DateFormat("EEE MMM dd yyyy HH:mm:ss").parse(part);
          } catch (_) {}
        }
      }
      return dt?.toLocal();
    } catch (e) {
      return null;
    }
  }

   String get formattedTime {
     final dt = dateTime;

     if (dt != null) {
       return DateFormat('hh:mm a').format(dt.toLocal());
     }

     return time;
   }

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      id: json['_id'] ?? json['id'] ?? '',
      reminderSetBy: json['reminderSetBy'] ?? '',
      time: json['time'] ?? '',
      note: json['note'] ?? '',
      isActive: json['isActive'] ?? false,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
      version: json['__v'] is int ? json['__v'] as int : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'reminderSetBy': reminderSetBy,
      'time': time,
      'note': note,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      '__v': version,
    };
  }
}

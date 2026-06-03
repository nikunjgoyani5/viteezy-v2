import 'package:viteezy/core/exceptions/app_exception.dart';
import 'package:viteezy/core/models/api_response.dart';
import 'package:viteezy/core/models/reminder_history_item.dart';
import 'package:viteezy/core/models/reminder_model.dart';
import 'package:viteezy/core/repositories/base_repository.dart';
import 'package:viteezy/core/services/api_endpoints.dart';

import '../services/api_service.dart';

class ReminderRepository extends BaseRepository {
  ReminderRepository({super.apiClient});

  Future<void> getReminders({
    Function(List<ReminderModel> reminders)? onSuccess,
    Function(AppException error)? onError,
  }) async {
    await apiClient.request(
      url: getFullUrl(ApiEndpoints.reminders),
      type: RequestType.get,
      onSuccess: (data) {
        final list = <ReminderModel>[];
        if (data.data != null && data.data['reminders'] != null) {
          final raw = data.data['reminders'];
          if (raw is List) {
            for (final item in raw) {
              if (item is Map<String, dynamic>) {
                list.add(ReminderModel.fromJson(item));
              }
            }
          }
        }
        onSuccess?.call(list);
      },
      onError: onError,
    );
  }

  Future<void> getReminderHistory({
    int page = 1,
    int limit = 10,
    Function(List<ReminderHistoryItem> items, Pagination? pagination)? onSuccess,
    Function(AppException error)? onError,
  }) async {
    await apiClient.request(
      url: getFullUrl(ApiEndpoints.remindersHistory(page, limit)),
      type: RequestType.get,
      onSuccess: (data) {
        final list = <ReminderHistoryItem>[];
        if (data.data != null && data.data is List) {
          for (final item in data.data as List) {
            if (item is Map<String, dynamic>) {
              list.add(ReminderHistoryItem.fromJson(item));
            }
          }
        }
        onSuccess?.call(list, data.pagination);
      },
      onError: onError,
    );
  }

  Future<void> toggleReminder({
    required String reminderId,
    required bool isActive,
    Function(ReminderModel? reminder)? onSuccess,
    Function(AppException error)? onError,
  }) async {
    final body = {'isActive': isActive};
    await apiClient.request(
      url: getFullUrl(ApiEndpoints.reminderToggle(reminderId)),
      type: RequestType.patch,
      body: body,
      onSuccess: (data) {
        ReminderModel? reminder;
        if (data.data != null && data.data is Map<String, dynamic>) {
          reminder = ReminderModel.fromJson(data.data as Map<String, dynamic>);
        }
        onSuccess?.call(reminder);
      },
      onError: onError,
    );
  }

  Future<void> createReminder({
    required String time,
    required String note,
    Function(ReminderModel? reminder)? onSuccess,
    Function(AppException error)? onError,
  }) async {
    final body = {
      'time': time,
      'note': note,
    };
    await apiClient.request(
      url: getFullUrl(ApiEndpoints.reminders),
      type: RequestType.post,
      body: body,
      onSuccess: (data) {
        ReminderModel? reminder;
        if (data.data != null && data.data is Map<String, dynamic>) {
          reminder = ReminderModel.fromJson(data.data as Map<String, dynamic>);
        }
        onSuccess?.call(reminder);
      },
      onError: onError,
    );
  }

  Future<void> updateReminder({
    required String reminderId,
    required String time,
    required String note,
    Function(ReminderModel? reminder)? onSuccess,
    Function(AppException error)? onError,
  }) async {
    final body = {
      'time': time,
      'note': note,
    };
    await apiClient.request(
      url: getFullUrl('${ApiEndpoints.reminders}/$reminderId'),
      type: RequestType.patch,
      body: body,
      onSuccess: (data) {
        ReminderModel? reminder;
        if (data.data != null && data.data is Map<String, dynamic>) {
          reminder = ReminderModel.fromJson(data.data as Map<String, dynamic>);
        }
        onSuccess?.call(reminder);
      },
      onError: onError,
    );
  }

  Future<void> deleteReminder({
    required String reminderId,
    Function()? onSuccess,
    Function(AppException error)? onError,
  }) async {
    await apiClient.request(
      url: getFullUrl('${ApiEndpoints.reminders}/$reminderId'),
      type: RequestType.delete,
      onSuccess: (data) {
        onSuccess?.call();
      },
      onError: onError,
    );
  }
}

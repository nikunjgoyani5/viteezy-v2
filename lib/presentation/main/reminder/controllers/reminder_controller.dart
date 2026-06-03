import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:viteezy/core/models/api_response.dart';
import 'package:viteezy/core/models/reminder_history_item.dart';
import 'package:viteezy/core/models/reminder_model.dart';
import 'package:viteezy/core/repositories/reminder_repository.dart';

import '../../../../core/utils/app_functions.dart';

class ReminderController extends GetxController {
  final ReminderRepository _repo = ReminderRepository();

  /// Reminder list state
  RxList<ReminderModel> reminders = <ReminderModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxMap<String, bool> toggleLoading = <String, bool>{}.obs;

  /// Reminder history (`/reminders/history`)
  final RxList<ReminderHistoryItem> reminderHistory = <ReminderHistoryItem>[].obs;
  final RxBool isHistoryLoading = false.obs;
  final RxBool isHistoryLoadingMore = false.obs;
  Pagination? historyPagination;
  int _historyPage = 1;
  static const int _historyLimit = 10;

  /// Add reminder sheet state
  final Rx<DateTime> selectedTime = DateTime.now().obs;
  final TextEditingController noteController = TextEditingController();
  final RxBool isSaving = false.obs;
  final RxBool isUpdate = false.obs;
  final Rx<ReminderModel?> editingReminder = Rx<ReminderModel?>(null);

  Future<void> loadReminders({bool force = false}) async {
    if (!force && reminders.isNotEmpty) return;

    isLoading.value = true;
    await _repo.getReminders(
      onSuccess: (list) {
        if (_needsUpdate(list)) {
          reminders.assignAll(list);
        }
        isLoading.value = false;
      },
      onError: (error) {
        if (Get.context != null) {
          AppFunctions.showCustomToast(Get.context!, message: error.message, isSuccess: false);
          isLoading.value = false;
        }
      },
    );
  }

  bool _needsUpdate(List<ReminderModel> newList) {
    if (newList.length != reminders.length) return true;
    final currentIds = reminders.map((e) => e.id).toSet();
    final newIds = newList.map((e) => e.id).toSet();
    if (!setEquals(currentIds, newIds)) return true;

    // If updatedAt differs, treat as changed.
    final updatedMap = {for (var r in reminders) r.id: r.updatedAt};
    for (final item in newList) {
      if (item.updatedAt != null && updatedMap[item.id] != item.updatedAt) {
        return true;
      }
    }

    return false;
  }

  bool get _hasMoreHistory {
    final p = historyPagination;
    if (p == null) return false;
    if (p.hasNext == true) return true;
    if (p.hasNext == false) return false;
    final cur = p.page;
    final totalPages = p.pages;
    if (cur != null && totalPages != null && totalPages > 0 && cur < totalPages) {
      return true;
    }
    return false;
  }

  /// Exposed for the history list scroll logic (under-filled viewport, etc.).
  bool get hasMoreReminderHistory => _hasMoreHistory;

  Future<void> loadReminderHistory({bool refresh = false}) async {
    if (isHistoryLoading.value) return;

    if (refresh) {
      _historyPage = 1;
      reminderHistory.clear();
      historyPagination = null;
    }

    isHistoryLoading.value = true;

    await _repo.getReminderHistory(
      page: _historyPage,
      limit: _historyLimit,
      onSuccess: (items, pagination) {
        reminderHistory.assignAll(items);
        historyPagination = pagination;
        isHistoryLoading.value = false;
      },
      onError: (error) {
        isHistoryLoading.value = false;
        if (Get.context != null) {
          AppFunctions.showCustomToast(Get.context!, message: error.message, isSuccess: false);
        }
      },
    );
  }

  Future<void> loadMoreReminderHistory() async {
    if (isHistoryLoadingMore.value || isHistoryLoading.value) return;
    if (!_hasMoreHistory) return;

    isHistoryLoadingMore.value = true;
    final nextPage = _historyPage + 1;

    await _repo.getReminderHistory(
      page: nextPage,
      limit: _historyLimit,
      onSuccess: (items, pagination) {
        reminderHistory.addAll(items);
        _historyPage = nextPage;
        historyPagination = pagination;
        isHistoryLoadingMore.value = false;
      },
      onError: (error) {
        isHistoryLoadingMore.value = false;
        if (Get.context != null) {
          AppFunctions.showCustomToast(Get.context!, message: error.message, isSuccess: false);
        }
      },
    );
  }

  Future<void> toggleReminder(String id, bool isActive, BuildContext context) async {
    if (toggleLoading[id] == true) return;

    toggleLoading[id] = true;

    final index = reminders.indexWhere((r) => r.id == id);
    if (index == -1) return;

    final oldValue = reminders[index].isActive;

    reminders[index].isActive = isActive;
    reminders.refresh();

    await _repo.toggleReminder(
      reminderId: id,
      isActive: isActive,

      onSuccess: (updated) {},

      onError: (error) async {
        await Future.delayed(const Duration(milliseconds: 500));
        reminders[index].isActive = oldValue;
        reminders.refresh();

        if (Get.context != null) {
          AppFunctions.showCustomToast(Get.context!, message: error.message, isSuccess: false);
        }
      },
    );

    toggleLoading[id] = false;
  }

  Future<void> createReminder(BuildContext context) async {
    if (isSaving.value) return;

    final note = noteController.text.trim();
    if (note.isEmpty) {
      AppFunctions.showCustomToast(context, message: 'Please enter a note.!', isSuccess: false);
      return;
    }

    isSaving.value = true;

    // Use the existing date if updating, otherwise use today.
    // This ensures we only change the time part as requested.
    final baseDate = (isUpdate.value && editingReminder.value != null)
        ? (editingReminder.value!.dateTime ?? DateTime.now())
        : DateTime.now();

    final localDateTime = DateTime(
      baseDate.year,
      baseDate.month,
      baseDate.day,
      selectedTime.value.hour + 5,
      selectedTime.value.minute + 30,
    );

    // Convert to UTC and format exactly as requested by the server (ending with .000Z)
    final timeIso = AppFunctions.formatToIso8601(localDateTime);

    if (isUpdate.value && editingReminder.value != null) {
      await _repo.updateReminder(
        reminderId: editingReminder.value!.id,
        time: timeIso,
        note: note,
        onSuccess: (updated) {
          if (updated != null) {
            final index = reminders.indexWhere((r) => r.id == updated.id);
            if (index != -1) {
              reminders[index] = updated;
            }
          }
          Get.back();
          AppFunctions.showCustomToast(context, message: 'Reminder updated successfully', isSuccess: true);
          resetForm();
          loadReminders(force: true);
        },
        onError: (error) {
          AppFunctions.showCustomToast(context, message: error.message, isSuccess: false);
        },
      );
    } else {
      await _repo.createReminder(
        time: timeIso,
        note: note,

        onSuccess: (created) {
          Get.back();
          AppFunctions.showCustomToast(context, message: 'Reminder created successfully', isSuccess: true);

          resetForm();
          loadReminders(force: true);
        },
        onError: (error) {
          AppFunctions.showCustomToast(context, message: error.message, isSuccess: false);
        },
      );
    }

    isSaving.value = false;
  }

  void resetForm() {
    noteController.clear();
    selectedTime.value = DateTime.now();
    isUpdate.value = false;
    editingReminder.value = null;
  }

  Future<void> deleteReminder(String id, BuildContext context) async {
    await _repo.deleteReminder(
      reminderId: id,
      onSuccess: () {
        reminders.removeWhere((r) => r.id == id);
        AppFunctions.showCustomToast(context, message: 'Reminder deleted successfully', isSuccess: true);
      },
      onError: (error) {
        AppFunctions.showCustomToast(context, message: error.message, isSuccess: false);
      },
    );
  }

  @override
  void onClose() {
    noteController.dispose();
    super.onClose();
  }
}

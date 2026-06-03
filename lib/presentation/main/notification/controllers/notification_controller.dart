import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:viteezy/core/exceptions/app_exception.dart';
import 'package:viteezy/core/models/api_response.dart';
import 'package:viteezy/core/models/notification_list_response_model.dart';
import 'package:viteezy/core/repositories/notification_repository.dart';
import 'package:viteezy/core/utils/notification_route_helper.dart';

/// Notification Controller
class NotificationController extends GetxController {
  final TextEditingController searchController = TextEditingController();
  final RxBool isSearchMode = false.obs;
  final RxString searchQuery = ''.obs;

  final NotificationRepository _notificationRepository =
      NotificationRepository();

  final RxBool isLoading = true.obs;
  final RxList<NotificationData> notifications = <NotificationData>[].obs;
  Pagination? pagination;

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(_onSearchChanged);
    fetchNotifications();
  }

  Future<void> fetchNotifications({int page = 1, int limit = 10, bool isRefresh = false}) async {
    if (isRefresh) {
      notifications.clear();
    }
    isLoading.value = true;

    await _notificationRepository.getNotifications(
      page: page,
      limit: limit,
      onSuccess: (ApiResponse response) {
        final list = response.data;
        if (list != null && list is List) {
          final parsed = list
              .map((e) {
                try {
                  return NotificationData.fromJson(e as Map<String, dynamic>);
                } catch (_) {
                  return null;
                }
              })
              .whereType<NotificationData>()
              .toList();
          if (isRefresh) {
            notifications.assignAll(parsed);
          } else {
            notifications.addAll(parsed);
          }
        }
        pagination = response.pagination;
        isLoading.value = false;
      },
      onError: (AppException error) {
        isLoading.value = false;
        debugPrint('Error loading notifications: ${error.message}');
      },
    );
  }

  void _onSearchChanged() {
    searchQuery.value = searchController.text.trim();
  }

  void enterSearchMode() {
    isSearchMode.value = true;
    searchController.clear();
    searchQuery.value = '';
  }

  void exitSearchMode() {
    isSearchMode.value = false;
    searchController.clear();
    searchQuery.value = '';
  }

  List<NotificationData> get filteredNotifications {
    if (searchQuery.value.isEmpty) {
      return notifications;
    }
    final q = searchQuery.value.toLowerCase();
    return notifications
        .where((n) {
      final title = (n.title ?? '').toLowerCase();
      final message = (n.message ?? '').toLowerCase();
      return title.contains(q) || message.contains(q);
    })
        .toList();
  }

  /// Call when user taps a notification: mark as read via API, update list locally on success, then navigate.
  void onNotificationPressed(NotificationData item) {
    final id = item.id;
    if (id != null && id.isNotEmpty && (item.isRead != true)) {
      _notificationRepository.markNotificationAsRead(
        notificationId: id,
        onSuccess: (_) {
          final index = notifications.indexWhere((n) => n.id == id);
          if (index != -1) {
            notifications[index].isRead = true;
            notifications.refresh();
          }
        },
        onError: (_) {},
      );
    }
    NotificationRouteHelper.onNotificationTap(item);
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}

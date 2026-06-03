import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:viteezy/core/utils/app_prefrence.dart';

/// Service to manage pending actions that require login
class PendingActionService extends GetxService {
  static PendingActionService get to => Get.find<PendingActionService>();

  // Pending action type
  String? _pendingActionType;
  Map<String, dynamic>? _pendingActionData;
  VoidCallback? _pendingCallback;

  /// Store a pending action
  void setPendingAction({
    required String actionType,
    Map<String, dynamic>? data,
    VoidCallback? callback,
  }) {
    _pendingActionType = actionType;
    _pendingActionData = data;
    _pendingCallback = callback;
  }

  /// Check if there's a pending action
  bool get hasPendingAction => _pendingActionType != null;

  /// Get pending action type
  String? get pendingActionType => _pendingActionType;

  /// Execute pending action if user is logged in
  void executePendingActionIfLoggedIn() {
    final isLoggedIn = PrefService.getBool(PrefKeys.isLogin) &&
        PrefService.getString(PrefKeys.accessToken).isNotEmpty;

    if (isLoggedIn && hasPendingAction) {
      _executePendingAction();
    }
  }

  /// Execute the pending action
  void _executePendingAction() {
    if (_pendingActionType == null) return;

    // Execute callback if available
    _pendingCallback?.call();

    // Clear pending action
    clearPendingAction();
  }

  /// Clear pending action
  void clearPendingAction() {
    _pendingActionType = null;
    _pendingActionData = null;
    _pendingCallback = null;
  }

  /// Get pending action data
  Map<String, dynamic>? get pendingActionData => _pendingActionData;
}

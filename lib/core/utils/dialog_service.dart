import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../theme/text_styles.dart';
import '../widgets/discount_dialog.dart';
import '../services/pending_action_service.dart';

/// Dialog service for showing common dialogs throughout the app
class DialogService {
  /// Show error dialog with user-friendly message
  static void showErrorDialog({required String message, String? title, VoidCallback? onOk}) {
    // Delay dialog to avoid showing during build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.dialog(
        Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Error Icon
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.errorColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.error_outline,
                    color: AppColors.errorColor,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                if (title != null) ...[
                  Text(
                    title,
                    style: TextStyles.semiBold(20.sp),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                ],

                // Message
                Text(
                  message,
                  style: TextStyles.regular(
                    14.sp,
                    fontColor: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // OK Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      onOk?.call();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: AppColors.textOnPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('OK', style: TextStyles.semiBold(16.sp)),
                  ),
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );
    });
  }

  /// Show success dialog
  static void showSuccessDialog({required String message, String? title, VoidCallback? onOk}) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success Icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(color: AppColors.successColor.withValues(alpha: 0.1), shape: BoxShape.circle),
                child: const Icon(Icons.check_circle_outline, color: AppColors.successColor, size: 36),
              ),
              const SizedBox(height: 20),

              // Title
              if (title != null) ...[
                Text(title, style: TextStyles.semiBold(20.sp), textAlign: TextAlign.center),
                const SizedBox(height: 12),
              ],

              // Message
              Text(
                message,
                style: TextStyles.regular(14.sp, fontColor: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // OK Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    onOk?.call();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: AppColors.textOnPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text('OK', style: TextStyles.semiBold(16.sp)),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// Show error snackbar
  static void showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.errorColor,
      colorText: AppColors.textOnPrimary,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.error_outline, color: AppColors.textOnPrimary),
    );
  }

  /// Show success snackbar
  static void showSuccessSnackbar(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.successColor,
      colorText: AppColors.textOnPrimary,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.check_circle_outline, color: AppColors.textOnPrimary),
    );
  }

  /// Show info snackbar
  static void showInfoSnackbar(String message) {
    Get.snackbar(
      'Info',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primaryColor,
      colorText: AppColors.textOnPrimary,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      icon: const Icon(Icons.info_outline, color: AppColors.textOnPrimary),
    );
  }

  /// Show discount dialog
  static void showDiscountDialog({
    Function(String email)? onClaimDiscount,
    VoidCallback? onClose,
  }) {
    Get.dialog(
      DiscountDialog(
        onClaimDiscount: onClaimDiscount,
        onClose: onClose,
      ),
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.5),
    );
  }

  /// Show progress dialog with message
  static void showProgressDialog({required String message}) {
    Get.dialog(
      PopScope(
        canPop: false, // Prevent closing by back button
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Loading indicator
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                ),
                const SizedBox(height: 20),
                // Message
                Text(
                  message,
                  style: TextStyles.regular(14.sp, fontColor: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// Hide progress dialog
  static void hideProgressDialog() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }

  /// Show login required dialog
  static void showLoginRequiredDialog({
    String? message,
    VoidCallback? onLogin,
    String? pendingActionType,
    Map<String, dynamic>? pendingActionData,
    VoidCallback? pendingCallback,
  }) {
    // Store pending action if provided
    if (pendingActionType != null && Get.isRegistered<PendingActionService>()) {
      PendingActionService.to.setPendingAction(
        actionType: pendingActionType,
        data: pendingActionData,
        callback: pendingCallback,
      );
    }

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Lock Icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock_outline,
                  color: AppColors.primaryColor,
                  size: 36,
                ),
              ),
              SizedBox(height: 20.h),
              
              // Title
              Text(
                'Login Required',
                style: TextStyles.semiBold(20.sp),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12.h),
              
              // Message
              Text(
                message ?? 'Please login to access this feature.',
                style: TextStyles.regular(14.sp, fontColor: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        // Clear pending action on cancel
                        if (Get.isRegistered<PendingActionService>()) {
                          PendingActionService.to.clearPendingAction();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.white,
                        foregroundColor: AppColors.black1414141,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: AppColors.yellowF0EFE4),
                        ),
                      ),
                      child: Text('Cancel', style: TextStyles.medium(16.sp)),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        if (onLogin != null) {
                          onLogin();
                        } else {
                          // Default: navigate to login
                          Get.toNamed('/login');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        foregroundColor: AppColors.textOnPrimary,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('Login', style: TextStyles.semiBold(16.sp)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }
}

import 'package:viteezy/gen/assets.gen.dart';
import '../utils/exports.dart';

/// A reusable toast widget that slides up from the bottom
class CustomToast {
  /// Show a toast notification with optional action button
  static void show({
    required String message,
    IconData? icon,
    Color? iconColor,
    String? actionText,
    VoidCallback? onActionPressed,
    Duration duration = const Duration(seconds: 3),
    required BuildContext context,
  }) {
    // Dismiss any existing toast first
    if (Get.isSnackbarOpen) {
      Get.closeAllSnackbars();
    }

    Get.snackbar(
      '',
      '',
      messageText: _buildToastContent(
        message: message,
        iconColor: iconColor ?? AppColors.successColor,
        actionText: actionText,
        onActionPressed: onActionPressed,
        context: context,
      ),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.transparent,
      margin: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 35.h),
      duration: duration,
      animationDuration: const Duration(milliseconds: 300),
      forwardAnimationCurve: Curves.easeOut,
      reverseAnimationCurve: Curves.easeIn,
      isDismissible: true,
      dismissDirection: DismissDirection.down,
      borderRadius: 0,
      padding: EdgeInsets.zero,
      barBlur: 0,
      overlayBlur: 0,
    );
  }

  /// Build the toast content widget
  static Widget _buildToastContent({
    required String message,
    required Color iconColor,
    String? actionText,
    VoidCallback? onActionPressed,
    required BuildContext context,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.blackColor.withValues(alpha: 0.15),
            offset: const Offset(0, 11),
            blurRadius: 15.4,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Assets.icons.icDoubleCheckIcon.svg(),
          SizedBox(width: 12.w),
          // Message
          Expanded(
            child: Text(message, style: TextStyles.medium(14.sp, fontColor: AppColors.textPrimary)),
          ),
          // Action Button (if provided)
          if (actionText != null && onActionPressed != null) ...[
            SizedBox(width: 12.w),
            ElevatedButton(
              onPressed: onActionPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.textPrimary,
                foregroundColor: AppColors.textOnPrimary,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                minimumSize: Size(0, 32.h),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                elevation: 0,
                shadowColor: Colors.transparent,
                side: BorderSide.none,
                surfaceTintColor: Colors.transparent,
              ),
              child: Text(actionText, style: TextStyles.semiBold(12.sp, fontColor: AppColors.white)),
            ),
          ],
        ],
      ),
    );
  }

  /// Show success toast for item added to cart
  static void showItemAddedToCart({
    VoidCallback? onGoToCart,
    required BuildContext context,
    String? message,
  }) {
    show(
      context: context,
      message: message ?? 'Item added to cart',
      icon: Icons.check_circle,
      iconColor: AppColors.successColor,
      actionText: 'Go To Cart',
      onActionPressed:
          onGoToCart ??
          () {
            Get.closeAllSnackbars();
            // TODO: Navigate to cart screen
            // Example: Get.toNamed(AppRoutes.cart) or switch to cart tab in dashboard
          },
      duration: const Duration(seconds: 3),
    );
  }
}

import 'package:get/get.dart';
import 'package:viteezy/core/services/cart_count_service.dart';
import 'package:viteezy/core/services/onesignal_notification_service.dart';
import 'package:viteezy/core/services/pending_action_service.dart';
import 'package:viteezy/core/utils/app_prefrence.dart';
import 'package:viteezy/presentation/main/cart/controllers/cart_controller.dart';
import 'package:viteezy/presentation/main/profile/controllers/profile_controller.dart';
import 'package:viteezy/presentation/main/wishlist/controllers/wishlist_controller.dart';

/// Helper class to refresh all data after login
class LoginRefreshHelper {
  /// Refresh all user-specific data after successful login
  static Future<void> refreshAllDataAfterLogin() async {
    // Refresh cart count
    if (Get.isRegistered<CartCountService>()) {
      CartCountService.to.initializeCartCount();
    }

    // Refresh cart data
    if (Get.isRegistered<CartController>()) {
      final cartController = Get.find<CartController>();
      cartController.refreshCartSilently();
    }

    // Refresh profile data
    if (Get.isRegistered<ProfileController>()) {
      final profileController = Get.find<ProfileController>();
      profileController.getUserProfile();
    }

    // Refresh wishlist data
    if (Get.isRegistered<WishlistController>()) {
      final wishlistController = Get.find<WishlistController>();
      wishlistController.pageNumber = 1;
      wishlistController.wishlistProductList.clear();
      wishlistController.getProductWishlist();
    }
  }

  /// Execute pending action and refresh data after login
  static Future<void> handlePostLoginActions() async {
    // Link OneSignal to user for targeted notifications
    final userId = PrefService.getString(PrefKeys.userId);
    await OneSignalNotificationService.setExternalUserId(userId.isNotEmpty ? userId : null);

    // Re-register device token with backend so this user is linked to the current player ID (only if subscribed to push)
    OneSignalNotificationService.registerDeviceTokenWithBackendIfLoggedIn();

    // Refresh all data
    await refreshAllDataAfterLogin();

    // Execute pending action if exists
    if (Get.isRegistered<PendingActionService>()) {
      PendingActionService.to.executePendingActionIfLoggedIn();
    }
  }
}

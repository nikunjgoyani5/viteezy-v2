import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:viteezy/core/models/user_model.dart';
import 'package:viteezy/core/routes/app_routes.dart';
import 'package:viteezy/core/services/cart_count_service.dart';
import 'package:viteezy/core/services/onesignal_notification_service.dart';
import 'package:viteezy/core/utils/app_prefrence.dart';
import 'package:viteezy/core/utils/dialog_service.dart';
import 'package:viteezy/presentation/main/browse/controllers/browse_controller.dart';
import 'package:viteezy/presentation/main/cart/controllers/cart_controller.dart';
import 'package:viteezy/presentation/main/profile/controllers/profile_controller.dart';
import 'package:viteezy/presentation/main/shop_all_view/controller/shop_all_controller.dart';
import 'package:viteezy/presentation/main/home/controllers/home_controller.dart';
import 'package:viteezy/presentation/main/wishlist/controllers/wishlist_controller.dart';

import '../../reminder/controllers/reminder_controller.dart';

/// Dashboard Controller
class DashboardController extends GetxController {
  final RxInt selectedBottomNav = 0.obs; // Bottom navigation index (0=Home, 1=Browse, 2=Cart, 3=Wishlist, 4=Account)

  // Get cart count from global CartCountService
  int get cartItemCount => CartCountService.to.cartItemCount.value;

  @override
  void onInit() {
    super.onInit();

    // Defer API calls until after build phase to avoid setState during build
    Future.microtask(() {
      if (Get.isRegistered<ShopAllController>()) {
        final shopAllController = Get.find<ShopAllController>();
        // Reset all browse state to initial values
        shopAllController.getProductCategories();
      }

      // Initialize cart count if not already initialized (only if user is logged in)
      final isLoggedIn =
          PrefService.getBool(PrefKeys.isLogin) && PrefService.getString(PrefKeys.accessToken).isNotEmpty;
      if (isLoggedIn && Get.isRegistered<CartCountService>()) {
        final cartCountService = CartCountService.to;
        // If cart count is not initialized (null), fetch from API
        if (!cartCountService.isInitialized) {
          cartCountService.initializeCartCount();
        }
      }
    });
  }

  @override
  void onReady() {
    super.onReady();
    // Handle deep link from notification (e.g. open dashboard on Cart tab)
    final tab = Get.arguments?['tab'];
    if (tab is int && tab >= 0 && tab <= 4) {
      WidgetsBinding.instance.addPostFrameCallback((_) => changeBottomNav(tab));
    }
    // When app launched from killed state via notification: Splash → Dashboard → target screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      OneSignalNotificationService.handlePendingNotificationIfAny();
    });
  }

  void changeBottomNav(int index) {
    if (selectedBottomNav.value == index) {
      return;
    }

    // Check login for protected tabs (Browse, Cart, and Wishlist)
    // Home (index 0) and Account (index 4) don't require login
    if (index == 1 || index == 2 || index == 3) {
      final isLoggedIn =
          PrefService.getBool(PrefKeys.isLogin) && PrefService.getString(PrefKeys.accessToken).isNotEmpty;
      if (!isLoggedIn) {
        // Show login dialog with appropriate message
        String message;
        switch (index) {
          case 1:
            message = 'browse_login_required'.tr;
            break;
          case 2:
            message = 'product_detail_login_cart'.tr;
            break;
          case 3:
            message = 'wishlist_login_required'.tr;
            break;
          default:
            message = 'auth_login_required_message'.tr;
        }

        // Store pending navigation action
        final pendingActionType = 'navigate_to_tab_$index';
        DialogService.showLoginRequiredDialog(
          message: message,
          pendingActionType: pendingActionType,
          pendingCallback: () {
            // Execute navigation after login
            selectedBottomNav.value = index;
            if (index == 1) {
              if (Get.isRegistered<BrowseController>()) {
                final browseController = Get.find<BrowseController>();
                browseController.resetBrowseState();
                browseController.getFeaturedProduct();
              }
            } else if (index == 2) {
              if (Get.isRegistered<CartController>()) {
                final cartController = Get.find<CartController>();
                cartController.cartData.value = null;
                cartController.isLoading.value = true;
                cartController.initializeCartItems();
              }
            } else if (index == 3) {
              Get.find<WishlistController>().pageNumber = 1;
              Get.find<WishlistController>().wishlistProductList.clear();
              Get.find<WishlistController>().getProductWishlist();
            }
          },
          onLogin: () {
            Get.toNamed(AppRoutes.login);
          },
        );
        return; // Don't change tab if not logged in
      }
    }

    // Pause home video when switching away from home tab
    if (selectedBottomNav.value == 0 && index != 0 && Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().pauseVideoWhenLeavingHome();
    }

    selectedBottomNav.value = index;
    if (index == 1) {
      // Browse tab selected - reset state and fetch products
      if (Get.isRegistered<BrowseController>()) {
        final browseController = Get.find<BrowseController>();
        // Reset all browse state to initial values
        browseController.resetBrowseState();
        // Fetch initial products (login check already done above)
        browseController.getFeaturedProduct();
      }
    } else if (index == 2) {
      // Cart tab selected - show shimmer (login check already done above)
      if (Get.isRegistered<CartController>()) {
        final cartController = Get.find<CartController>();
        cartController.cartData.value = null;
        cartController.isLoading.value = true;
        cartController.initializeCartItems();
      }
    } else if (index == 3) {
      // Wishlist tab - login check already done above
      // Register Reminder Controller (IMPORTANT)
      if (!Get.isRegistered<ReminderController>()) {
        Get.put(ReminderController()).loadReminders();
      }
      Get.find<ReminderController>().loadReminders();
    } else if (index == 4) {
      // Account tab - fetch profile data only if logged in, otherwise clear data
      final isLoggedIn =
          PrefService.getBool(PrefKeys.isLogin) && PrefService.getString(PrefKeys.accessToken).isNotEmpty;
      if (Get.isRegistered<ProfileController>()) {
        final profileController = Get.find<ProfileController>();
        if (isLoggedIn) {
          profileController.getUserProfile();
        } else {
          // Clear user data and update UI when not logged in
          profileController.userData = UserData();
          profileController.fNameController.clear();
          profileController.lNameController.clear();
          profileController.emailController.clear();
          profileController.update(); // Force UI update to show guest user UI
        }
      }
    }
  }
}

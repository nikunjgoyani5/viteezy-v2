import 'package:get/get.dart';
import 'package:viteezy/core/services/global_settings_service.dart';
import 'package:viteezy/presentation/main/cart/controllers/cart_controller.dart';
import 'package:viteezy/presentation/main/help_center/controllers/help_center_controller.dart';
import 'package:viteezy/presentation/main/help_details/controllers/help_details_controller.dart';
import 'package:viteezy/presentation/main/orders/controllers/orders_controller.dart';
import 'package:viteezy/presentation/main/shop_all_view/controller/shop_all_controller.dart';

/// Refreshes language-dependent API data after the user changes app language.
/// Call this after [LocaleService.setLanguage] so screens show content in the new language.
class LanguageDataRefreshService extends GetxService {
  static LanguageDataRefreshService get to => Get.find<LanguageDataRefreshService>();

  /// Refreshes all language-dependent data. Safe to call from any screen;
  /// only registered controllers are refreshed.
  Future<void> refreshAfterLanguageChange() async {
    // Landing page & general settings (home, etc.)
    if (Get.isRegistered<GlobalSettingsService>()) {
      await GlobalSettingsService.to.fetchGeneralSettings();
    }

    // Product categories and filters (browse / shop)
    if (Get.isRegistered<ShopAllController>()) {
      final shop = Get.find<ShopAllController>();
      shop.getProductCategories();
      shop.getProductFilters();
    }

    // Featured products on cart screen
    if (Get.isRegistered<CartController>()) {
      Get.find<CartController>().getFeaturedProduct(isRefresh: true);
    }

    // Featured products on orders screen
    if (Get.isRegistered<OrdersController>()) {
      Get.find<OrdersController>().getFeaturedProduct(isRefresh: true);
    }

    // FAQ categories (help center)
    if (Get.isRegistered<HelpCenterController>()) {
      Get.find<HelpCenterController>().getFaqCategory();
    }

    // FAQ list if user is on help details screen
    if (Get.isRegistered<HelpDetailsController>()) {
      Get.find<HelpDetailsController>().getFaqsByCategory();
    }
  }
}

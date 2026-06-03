import 'package:get/get.dart';
import 'package:viteezy/core/routes/app_routes.dart';
import 'package:viteezy/core/services/global_settings_service.dart';
import 'package:viteezy/core/utils/app_prefrence.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    // Fetch general settings in background (no loading indicator)
    _fetchGeneralSettings();
    navigate();
  }

  /// Fetch general settings in background without blocking UI
  void _fetchGeneralSettings() {
    // Call API in background, user won't feel any loading
    GlobalSettingsService.to.fetchGeneralSettings();
  }

  void navigate() async {
    await Future.delayed(const Duration(milliseconds: 4805));
    // Always redirect to dashboard - users can access home without login
    Get.offAllNamed(AppRoutes.dashboard);
  }
}

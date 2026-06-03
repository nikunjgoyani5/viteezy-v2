import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';
import '../../home/bindings/home_binding.dart';
import '../../shop_all_view/controller/shop_all_controller.dart';

/// Dashboard Binding
class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardController>(() => DashboardController());
    // Initialize ShopAllController as permanent singleton to persist favorites
    if (!Get.isRegistered<ShopAllController>()) {
      Get.put(ShopAllController(), permanent: true);
    }
    // Initialize Home binding
    HomeBinding().dependencies();
  }
}


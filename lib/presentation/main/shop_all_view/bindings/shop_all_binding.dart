import '../controller/shop_all_controller.dart';
import 'package:get/get.dart';
class ShopALlBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ShopAllController>(() => ShopAllController());
  }
}

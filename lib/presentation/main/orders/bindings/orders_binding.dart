import 'package:get/get.dart';
import 'package:viteezy/presentation/main/orders/controllers/orders_controller.dart';

class OrdersBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(OrdersController());
  }
}

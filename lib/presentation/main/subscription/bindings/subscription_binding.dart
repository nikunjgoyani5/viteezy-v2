import 'package:get/get.dart';
import 'package:viteezy/presentation/main/subscription/controllers/subscription_controller.dart';

class SubscriptionBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(SubscriptionController());
  }
}

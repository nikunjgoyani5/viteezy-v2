import 'package:get/get.dart';
import '../controllers/support_controller.dart';

/// Support Binding
class SupportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SupportController>(() => SupportController());
  }
}


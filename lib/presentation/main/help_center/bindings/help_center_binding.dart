import 'package:get/get.dart';
import 'package:viteezy/presentation/main/help_center/controllers/help_center_controller.dart';

class HelpCenterBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(HelpCenterController());
  }
}

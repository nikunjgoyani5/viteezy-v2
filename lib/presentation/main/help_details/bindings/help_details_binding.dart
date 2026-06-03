import 'package:get/get.dart';
import 'package:viteezy/presentation/main/help_details/controllers/help_details_controller.dart';

class HelpDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(HelpDetailsController());
  }
}

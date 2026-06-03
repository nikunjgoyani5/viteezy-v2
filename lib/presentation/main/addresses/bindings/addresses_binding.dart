import 'package:get/get.dart';
import 'package:viteezy/presentation/main/addresses/controllers/addresses_controller.dart';

class AddressesBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AddressesController());
  }
}

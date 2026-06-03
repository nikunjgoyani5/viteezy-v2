import 'package:get/get.dart';
import 'package:viteezy/presentation/main/add_address/controllers/add_address_controller.dart';

class AddAddressBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AddAddressController());
  }
}

import 'package:get/get.dart';
import 'package:viteezy/presentation/main/add_address/controllers/add_address_controller.dart';

/// Tag and lifecycle for the checkout flow when no saved addresses exist (inline add form).
class CheckoutInlineAddressHelper {
  CheckoutInlineAddressHelper._();

  static const String tag = 'checkout_inline';

  static void ensureRegistered() {
    if (!Get.isRegistered<AddAddressController>(tag: tag)) {
      Get.put(AddAddressController(embeddedInCheckout: true), tag: tag);
    }
  }

  static void removeIfRegistered() {
    if (Get.isRegistered<AddAddressController>(tag: tag)) {
      Get.delete<AddAddressController>(tag: tag);
    }
  }
}

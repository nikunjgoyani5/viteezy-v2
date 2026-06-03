import 'package:get/get.dart';
import 'package:viteezy/presentation/main/familymodule/controllers/family_controllers.dart';

class FamilyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FamilyController>(() => FamilyController());
  }
}

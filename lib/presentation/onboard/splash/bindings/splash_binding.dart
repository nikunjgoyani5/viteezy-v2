import 'package:get/get.dart';
import 'package:viteezy/presentation/onboard/splash/controllers/splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(SplashController(), permanent: false);
  }
}

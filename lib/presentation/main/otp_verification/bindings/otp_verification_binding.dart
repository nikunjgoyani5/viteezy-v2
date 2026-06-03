import 'package:get/get.dart';
import 'package:viteezy/presentation/main/otp_verification/controllers/otp_verification_controller.dart';

class OtpVerificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(OtpVerificationController());
  }
}

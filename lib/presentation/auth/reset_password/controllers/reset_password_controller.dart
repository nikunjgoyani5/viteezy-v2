import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:viteezy/core/exceptions/app_exception.dart';
import 'package:viteezy/core/models/api_response.dart';
import 'package:viteezy/core/repositories/auth_repository.dart';
import 'package:viteezy/core/routes/app_routes.dart' show AppRoutes;
import 'package:viteezy/core/theme/app_colors.dart';
import 'package:viteezy/core/utils/app_functions.dart';
import 'package:viteezy/core/utils/validators.dart';

class ResetPasswordController extends GetxController {
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  bool isNewPasswordSecure = true;
  bool isConfirmPasswordSecure = true;

  String email = '';
  String otp = '';
  String passwordError = '';
  String cPassError = '';

  validatePass() {
    passwordError = ValidationUtils.validatePassword(newPasswordController.text) ?? '';

    update();
  }

  validateCPass() {
    if (confirmPasswordController.text.isEmpty) {
      cPassError = "Password is required";
    } else if (newPasswordController.text != confirmPasswordController.text) {
      cPassError = "Password doesn't match";
    } else {
      cPassError = '';
    }
    update();
  }

  bool onTapResetPass() {
    validatePass();
    validateCPass();

    if (passwordError.isEmpty && cPassError.isEmpty) {
      return true;
    } else {
      return false;
    }
  }

  AuthRepository authRepository = AuthRepository();
  RxBool loading = false.obs;

  Future<void> resetPassApi() async {
    loading.value = true;
    await authRepository.resetPassword(
      body: {"email": email, "password": newPasswordController.text, "confirmPassword": confirmPasswordController.text},
      onSuccess: (ApiResponse response) {
        try {
          loading.value = false;
          Get.close(2);
          AppFunctions().showToast(response.message ?? '', bgColor: AppColors.green);
        } catch (e) {
          debugPrint('error:::${e.toString()} ');
          loading.value = false;
          AppFunctions().showToast(response.message ?? 'Something went wrong!!', bgColor: AppColors.red);
        }
      },
      onError: (AppException error) {
        loading.value = false;
        String message = error.message;
        AppFunctions().showToast(message, bgColor: AppColors.red);
      },
    );
    loading.value = false;
  }

  @override
  void onClose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    if (Get.arguments != null) {
      email = Get.arguments['email'] ?? '';
      otp = Get.arguments['otp'] ?? '';
    }
    super.onInit();
  }
}

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:viteezy/core/exceptions/app_exception.dart';
import 'package:viteezy/core/models/api_response.dart';
import 'package:viteezy/core/repositories/profile_repository.dart';
import 'package:viteezy/core/theme/app_colors.dart';
import 'package:viteezy/core/utils/app_functions.dart';
import 'package:viteezy/core/utils/app_prefrence.dart';
import 'package:viteezy/core/utils/validators.dart';

class ChangePasswordController extends GetxController {
  TextEditingController currentPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  bool isCurrentPasswordSecure = true;
  bool isNewPasswordSecure = true;
  bool isConfirmPasswordSecure = true;

  String passwordError = '';
  String newPassError = '';
  String confirmPassError = '';

  validatePass() {
    passwordError = ValidationUtils.validatePassword(currentPasswordController.text) ?? '';

    update();
  }

  validateNewPass() {
    newPassError = ValidationUtils.validatePassword(newPasswordController.text) ?? '';

    update();
  }

  validateConfirmPass() {
    if (confirmPasswordController.text.isEmpty) {
      confirmPassError = 'validator_password_required'.tr;
    } else if (newPasswordController.text != confirmPasswordController.text) {
      confirmPassError = 'validator_passwords_not_match'.tr;
    } else {
      confirmPassError = '';
    }
    update();
  }

  bool onTapChangePass() {
    validatePass();
    validateNewPass();
    validateConfirmPass();

    if (passwordError.isEmpty && newPassError.isEmpty && confirmPassError.isEmpty) {
      return true;
    } else {
      return false;
    }
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'validator_confirm_password'.tr;
    }
    if (value != newPasswordController.text) {
      return 'validator_passwords_not_match'.tr;
    }
    return null;
  }

  ProfileRepository profileRepository = ProfileRepository();

  RxBool loader = false.obs;

  Future<void> changePassword(BuildContext context) async {
    loader.value = true;
    await profileRepository.changePassword(
      body: {"currentPassword": currentPasswordController.text, "newPassword": newPasswordController.text},
      onSuccess: (ApiResponse response) {
        try {
          loader.value = false;
          Get.back();
          AppFunctions.showCustomToast(context, message: response.message ?? '', isSuccess: true);
        } catch (e) {
          debugPrint('error:::${e.toString()} ');

          loader.value = false;
        }
      },
      onError: (AppException error) {
        loader.value = false;
        String message = error.message;
        AppFunctions().showToast(message, bgColor: AppColors.red);
      },
    );
    loader.value = false;
  }

  @override
  void onClose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}

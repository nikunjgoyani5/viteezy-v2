import 'package:viteezy/core/l10n/locale_service.dart';
import 'package:viteezy/core/repositories/auth_repository.dart';
import 'package:viteezy/core/routes/app_routes.dart';
import 'package:viteezy/core/utils/app_functions.dart';
import 'package:viteezy/core/utils/validators.dart';

import '../../../../core/utils/app_prefrence.dart';
import '../../../../core/utils/exports.dart';

class ForgotPasswordController extends GetxController {
  TextEditingController emailController = TextEditingController();
  String emailError = '';

  validateEmail() {
    emailError = ValidationUtils.validateEmail(emailController.text) ?? '';
    update();
  }

  String selectedLanguage = PrefService.getString(PrefKeys.locale);

  void updateLanguage(String language) {
    selectedLanguage = language;
    LocaleService.setLanguage(language);
    update();
  }

  bool onTapForgotPass() {
    validateEmail();
    if (emailError.isEmpty) {
      return true;
    } else {
      return false;
    }
  }
  String localeCodeToNameFromCode(String code) {
    switch (code) {
      case 'nl':
        return 'Dutch';
      case 'de':
        return 'German';
      case 'fr':
        return 'French';
      case 'es':
        return 'Spanish';
      case 'en':
        return 'English';
      case 'Dutch':
        return 'Dutch';
      case 'German':
        return 'German';
      case 'French':
        return 'French';
      case 'Spanish':
        return 'Spanish';
      default:
        return 'English';
    }
  }

  AuthRepository authRepository = AuthRepository();
  RxBool loading = false.obs;

  void clearData() {
    emailError = '';
    emailController.clear();
    update();
  }

  Future<void> forgotPassApi() async {
    loading.value = true;
    await authRepository.forgotPass(
      body: {"email": emailController.text, "deviceInfo": "App"},
      onSuccess: (ApiResponse response) {
        try {
          loading.value = false;

          Get.toNamed(AppRoutes.verifyOtp, arguments: {'email': emailController.text, 'isFromSignUp': false});
          clearData();
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
    emailController.dispose();
    super.onClose();
  }
}

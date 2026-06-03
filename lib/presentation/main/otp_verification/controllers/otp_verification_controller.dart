import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:viteezy/core/exceptions/app_exception.dart';
import 'package:viteezy/core/repositories/auth_repository.dart';
import 'package:viteezy/core/routes/app_routes.dart';
import 'package:viteezy/core/utils/app_functions.dart';
import 'package:viteezy/core/utils/app_prefrence.dart';
import 'package:viteezy/core/l10n/locale_service.dart';
import 'package:viteezy/core/utils/login_refresh_helper.dart';

import '../../../../core/utils/exports.dart';

class OtpVerificationController extends GetxController {
  TextEditingController otpController = TextEditingController();

  Timer? _timer;
  int _remainingSeconds = 300; // 1 minute = 60 seconds
  String email = '';
  String selectedLanguage = PrefService.getString(PrefKeys.locale);

  bool get isTimerExpired => _remainingSeconds == 0;

  String get formattedTime {
    int minutes = _remainingSeconds ~/ 60;
    int seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(1, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      email = Get.arguments['email'] ?? '';
    }
    _startTimer();
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
  void _startTimer() {
    _remainingSeconds = 300;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        update();
      } else {
        _timer?.cancel();
        update();
      }
    });
  }

  Future<void> resendOtp({required bool fromSignUp}) async {
    otpController.clear();

    await resendOtpAPI(fromSignUp: fromSignUp);
  }

  void updateLanguage(String language) {
    selectedLanguage = language;
    LocaleService.setLanguage(language);
    update();
  }

  String getOtpCode() {
    return otpController.text;
  }

  bool isOtpComplete() {
    return otpController.text.length == 6;
  }

  AuthRepository authRepository = AuthRepository();
  RxBool isLoading = false.obs;
  RxBool resendLoading = false.obs;

  Future<void> verifyOtp({required bool fromSignUp}) async {
    isLoading.value = true;
    await authRepository.otpVerification(
      body: {"otp": otpController.text, "email": email, "type": fromSignUp ? "Email Verification" : "Password Reset"},
      onSuccess: (ApiResponse response) async {
        try {
          isLoading.value = false;
          if (fromSignUp) {
            PrefService.setValue(PrefKeys.accessToken, response.data['accessToken'] ?? "");
            PrefService.setValue(PrefKeys.refreshToken, response.data['refreshToken'] ?? "");
            PrefService.setValue(PrefKeys.isLogin, true);
            final userId = response.data['user']?['_id']?.toString();
            if (userId != null && userId.isNotEmpty) {
              PrefService.setValue(PrefKeys.userId, userId);
            }
            // Refresh data and execute pending actions
            await LoginRefreshHelper.handlePostLoginActions();
            // Use Get.back() instead of Get.offAllNamed() to avoid controller disposal issues
            Get.close(3);
          } else {
            Get.offAndToNamed(AppRoutes.resetPass, arguments: {"otp": otpController.text, "email": email});
          }

          AppFunctions().showToast(response.message ?? '', bgColor: AppColors.green);
        } catch (e) {
          debugPrint('error:::${e.toString()} ');

          isLoading.value = false;
          AppFunctions().showToast(response.message ?? 'Something went wrong!', bgColor: AppColors.red);
        }
      },
      onError: (AppException error) {
        isLoading.value = false;
        String message = error.message;
        AppFunctions().showToast(message, bgColor: AppColors.red);
      },
    );
    isLoading.value = false;
  }

  Future<void> resendOtpAPI({required bool fromSignUp}) async {
    resendLoading.value = true;
    await authRepository.resendOtp(
      body: {"email": email, "type": fromSignUp ? "Email Verification" : "Password Reset"},
      onSuccess: (ApiResponse response) {
        try {
          resendLoading.value = false;
          _startTimer();
          AppFunctions().showToast(response.message ?? '', bgColor: AppColors.green);
        } catch (e) {
          debugPrint('error:::${e.toString()} ');

          resendLoading.value = false;
          AppFunctions().showToast(response.message ?? 'Something went wrong!!', bgColor: AppColors.red);
        }
      },
      onError: (AppException error) {
        resendLoading.value = false;
        String message = error.message;
        AppFunctions().showToast(message, bgColor: AppColors.red);
      },
    );
    resendLoading.value = false;
  }

  @override
  void onClose() {
    _timer?.cancel();
    otpController.dispose();
    super.onClose();
  }
}

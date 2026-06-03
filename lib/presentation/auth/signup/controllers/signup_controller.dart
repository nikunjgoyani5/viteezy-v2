import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:viteezy/core/exceptions/app_exception.dart';
import 'package:viteezy/core/models/api_response.dart';
import 'package:viteezy/core/repositories/auth_repository.dart';
import 'package:viteezy/core/routes/app_routes.dart';
import 'package:viteezy/core/utils/app_functions.dart';
import 'package:viteezy/core/l10n/locale_service.dart';
import 'package:viteezy/core/utils/app_prefrence.dart';
import 'package:viteezy/core/utils/login_refresh_helper.dart';

import '../../../../core/utils/validators.dart';

class SignupController extends GetxController {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  bool isPasswordSecure = true;
  bool isConfirmPasswordSecure = true;
  bool isAgree = false;
  String selectedLanguage = PrefService.getString(PrefKeys.locale);
  String passwordError = '';
  String emailError = '';
  String firstNameError = '';
  String lastNameError = '';
  String cPassError = '';

  RxBool isGoogleLoading = false.obs;
  RxBool isAppleLoading = false.obs;

  validatePass() {
    passwordError = ValidationUtils.validatePassword(passwordController.text) ?? '';

    update();
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
  validateEmail() {
    emailError = ValidationUtils.validateEmail(emailController.text) ?? '';
    update();
  }

  validateCPass() {
    if (confirmPasswordController.text.isEmpty) {
      cPassError = "Password is required";
    } else if (passwordController.text != confirmPasswordController.text) {
      cPassError = "Password doesn't match";
    } else {
      cPassError = '';
    }
    update();
  }

  validateFName() {
    firstNameError = ValidationUtils.validateName(firstNameController.text) ?? '';
    update();
  }

  validateLName() {
    lastNameError = ValidationUtils.validateName(lastNameController.text) ?? '';
    update();
  }

  void updateLanguage(String language) {
    selectedLanguage = language;
    LocaleService.setLanguage(language);
    update();
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'validator_confirm_password'.tr;
    }
    if (value != passwordController.text) {
      return 'validator_passwords_not_match'.tr;
    }
    return null;
  }

  bool onTapSignUp() {
    validatePass();
    validateEmail();
    validateCPass();
    validateFName();
    validateLName();
    if (passwordError.isEmpty &&
        emailError.isEmpty &&
        cPassError.isEmpty &&
        firstNameError.isEmpty &&
        lastNameError.isEmpty) {
      return true;
    } else {
      return false;
    }
  }

  AuthRepository authRepository = AuthRepository();
  RxBool isLoading = false.obs;

  Future<void> signUp(BuildContext context) async {
    isLoading.value = true;
    await authRepository.signUp(
      body: {
        "email": emailController.text,
        "password": passwordController.text,
        "firstName": firstNameController.text,
        "lastName": lastNameController.text,
      },
      onSuccess: (ApiResponse response) {
        try {
          isLoading.value = false;
          Get.toNamed(AppRoutes.verifyOtp, arguments: {'email': emailController.text, 'isFromSignUp': true});
          AppFunctions.showCustomToast(context, message: response.message ?? '', isSuccess: true);
        } catch (e) {
          debugPrint('error:::${e.toString()} ');

          isLoading.value = false;
          AppFunctions.showCustomToast(
            context,
            message: response.message ?? 'Something went wrong!!',
            isSuccess: false,
          );
        }
      },
      onError: (AppException error) {
        isLoading.value = false;
        String message = error.message;
        AppFunctions.showCustomToast(context, message: message, isSuccess: false);
      },
    );
    isLoading.value = false;
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      isGoogleLoading.value = true;
      await FirebaseAuth.instance.signOut();

      GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['https://www.googleapis.com/auth/userinfo.profile', 'https://www.googleapis.com/auth/userinfo.email'],
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        isGoogleLoading.value = false;
        AppFunctions.showCustomToast(context, message: 'Google login cancelled!', isSuccess: false);
        return;
      }

      GoogleSignInAuthentication? googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      var userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      String? idToken = await userCredential.user?.getIdToken();
      log('Id Token :- $idToken}');
      log('userCredential :- ${userCredential.credential}');
      log('email :- ${userCredential.user?.email ?? ""}');
      log('name :- ${userCredential.user?.displayName ?? ""}');

      await authRepository.googleLoginAPi(
        body: {"idToken": idToken, "deviceInfo": "App"},
        onSuccess: (ApiResponse response) async {
          try {
            isGoogleLoading.value = false;
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
            AppFunctions.showCustomToast(context, message: response.message ?? '', isSuccess: true);
          } catch (e) {
            await FirebaseAuth.instance.signOut();
            await GoogleSignIn().signOut();
            debugPrint('error:::${e.toString()} ');

            isGoogleLoading.value = false;
            AppFunctions.showCustomToast(
              context,
              message: response.message ?? 'Something went wrong!!',
              isSuccess: false,
            );
          }
        },
        onError: (AppException error) async {
          await FirebaseAuth.instance.signOut();
          await GoogleSignIn().signOut();
          isGoogleLoading.value = false;
          String message = error.message;
          AppFunctions.showCustomToast(context, message: message, isSuccess: false);
        },
      );
    } catch (e) {
      isGoogleLoading.value = false;
      AppFunctions.showCustomToast(context, message: 'Something went wrong!!', isSuccess: false);
      debugPrint("Google Sign-In Error: $e");
    }
  }

  Future<void> signInWithApple(BuildContext context) async {
    try {
      isAppleLoading.value = true;
      final userCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
      );

      final oauthCredential = OAuthProvider(
        'apple.com',
      ).credential(accessToken: userCredential.authorizationCode, idToken: userCredential.identityToken);

      final authUser = await FirebaseAuth.instance.signInWithCredential(oauthCredential);

      log('Apple User Details === $authUser $userCredential');
      if (oauthCredential.idToken == null) {
        isAppleLoading.value = false;
        AppFunctions.showCustomToast(context, message: 'Something went wrong!!', isSuccess: false);
        return;
      }
      String idToken = oauthCredential.idToken ?? '';

      await authRepository.appleLoginAPi(
        body: {"idToken": idToken, "deviceInfo": "App"},
        onSuccess: (ApiResponse response) async {
          try {
            isAppleLoading.value = false;
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
            AppFunctions.showCustomToast(context, message: response.message ?? '', isSuccess: true);
          } catch (e) {
            await FirebaseAuth.instance.signOut();

            debugPrint('error:::${e.toString()} ');

            isAppleLoading.value = false;
            AppFunctions.showCustomToast(
              context,
              message: response.message ?? 'Something went wrong!!',
              isSuccess: false,
            );
          }
        },
        onError: (AppException error) async {
          await FirebaseAuth.instance.signOut();

          isAppleLoading.value = false;
          String message = error.message;
          AppFunctions.showCustomToast(context, message: message, isSuccess: false);
        },
      );
    } catch (e) {
      AppFunctions.showCustomToast(context, message: 'Something went wrong!!', isSuccess: false);
      log('Apple Login Error :===== $e');
      isAppleLoading.value = false;
    }
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}

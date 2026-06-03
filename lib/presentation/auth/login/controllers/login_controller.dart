import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import "package:google_sign_in/google_sign_in.dart";
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:viteezy/core/exceptions/app_exception.dart';
import 'package:viteezy/core/models/api_response.dart';
import 'package:viteezy/core/repositories/auth_repository.dart';
import 'package:viteezy/core/routes/app_routes.dart';
import 'package:viteezy/core/utils/app_functions.dart';
import 'package:viteezy/core/utils/app_prefrence.dart';
import 'package:viteezy/core/utils/dialog_service.dart';
import 'package:viteezy/core/l10n/locale_service.dart';
import 'package:viteezy/core/utils/login_refresh_helper.dart';
import 'package:viteezy/core/utils/validators.dart';
import 'package:viteezy/presentation/main/ai_chat/controllers/ai_chat_controller.dart';

import '../../../../core/utils/app_constant.dart';

class LoginController extends GetxController {
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();

  bool isSecure = true;
  bool isAgree = false;
  String selectedLanguage = PrefService.getString(PrefKeys.locale);
  String passwordError = '';
  String emailError = '';

  RxBool isLoading = false.obs;
  RxBool isGoogleLoading = false.obs;
  RxBool isAppleLoading = false.obs;

  @override
  onInit() {
    if (kDebugMode) {
      emailController.text = "harry@yopmail.com";
      passController.text = "Test@123";
    }
    super.onInit();
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
  validatePass() {
    passwordError = ValidationUtils.validatePassword(passController.text) ?? '';

    update();
  }

  validateEmail() {
    emailError = ValidationUtils.validateEmail(emailController.text) ?? '';
    update();
  }

  onTapLogin() {
    validatePass();
    validateEmail();
    if (passwordError.isEmpty && emailError.isEmpty) {
      return true;
    } else {
      return false;
    }
  }

  void updateLanguage(String language) {
    selectedLanguage = language;
    LocaleService.setLanguage(language);
    update();
  }

  AuthRepository authRepository = AuthRepository();

  Future<void> login(BuildContext context, {bool isFromAIChat = false, String? sessionID}) async {
    isLoading.value = true;
    await authRepository.login(
      body: {"email": emailController.text, "password": passController.text, "deviceInfo": "App"},
      onSuccess: (ApiResponse response) async {
        try {
          debugPrint('${response.toString()} ');


          PrefService.setValue(PrefKeys.accessToken, response.data['accessToken'] ?? "");
          PrefService.setValue(PrefKeys.refreshToken, response.data['refreshToken'] ?? "");
          PrefService.setValue(PrefKeys.isLogin, true);
          final userId = response.data['user']?['_id']?.toString();
          if (userId != null && userId.isNotEmpty) {
            PrefService.setValue(PrefKeys.userId, userId);
          }
          if (isFromAIChat) {
            sessionLinkFromAIChat(sessionId: sessionID ?? "", userID: response.data['user']['_id']);
          } else {
            // Refresh data and execute pending actions
            await LoginRefreshHelper.handlePostLoginActions();
            // Use Get.back() instead of Get.offAllNamed() to avoid controller disposal issues
            Future.delayed(const Duration(seconds: 1), () {
              Get.back();
            });
          }
          isLoading.value = false;
          clearData();
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

  void sessionLinkFromAIChat({required String sessionId, required String userID}) {
    // Show progress dialog
    DialogService.showProgressDialog(message: 'Redirecting back to chat...');

    authRepository.sessionLink(
      body: {"user_id": userID, "session_id": sessionId},
      onSuccess: (data) {
        // After sessionLink succeeds, call getProductRecommendation
        Get.find<AiChatController>().getProductRecommendation(
          userID,
          onComplete: () {
            // Close progress dialog after both API calls complete
            DialogService.hideProgressDialog();
          },
          onError: () {
            // Close progress dialog on error
            DialogService.hideProgressDialog();
          },
        );
      },
      onError: (error) {
        // Close progress dialog on error
        DialogService.hideProgressDialog();
      },
    );
  }

  void clearData() {
    AppFunctions().closeKeyboard();
    emailController.clear();
    passController.clear();
    emailError = '';
    passwordError = '';
    update();
  }

  Future<void> signInWithGoogle(BuildContext context, {bool isFromAIChat = false, String? sessionID}) async {
    try {
      isGoogleLoading.value = true;
      await FirebaseAuth.instance.signOut();

      GoogleSignIn googleSignIn = GoogleSignIn(
        // clientId: Platform.isAndroid
        //     ? googleLogInClientIdAndroid
        //     : googleLogInClientIdIos,
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
            clearData();
            if (isFromAIChat) {
              sessionLinkFromAIChat(sessionId: sessionID ?? "", userID: response.data['user']['_id']);
            } else {
              // Refresh data and execute pending actions
              await LoginRefreshHelper.handlePostLoginActions();
              // Use Get.back() instead of Get.offAllNamed() to avoid controller disposal issues
              Get.back();
            }
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
    dynamic token;
    try {
      isAppleLoading.value = true;
      final userCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
      );

      final oauthCredential = OAuthProvider(
        'apple.com',
      ).credential(accessToken: userCredential.authorizationCode, idToken: userCredential.identityToken);

      await FirebaseAuth.instance.signInWithCredential(oauthCredential).then((value) async {
        final firebaseToken = await value.user?.getIdToken();
        final loginRequestBody = {"token": firebaseToken.toString()};
        log("TOKEN :- $loginRequestBody");
        token = loginRequestBody;
      });
      // Map<String, dynamic> requestBody = {'token': token['token'] ?? ''};

      await authRepository.appleLoginAPi(
        body: {"idToken": token['token'], "deviceInfo": "App"},
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
            clearData();
            // Refresh data and execute pending actions
            await LoginRefreshHelper.handlePostLoginActions();
            // Use Get.back() instead of Get.offAllNamed() to avoid controller disposal issues
            Get.back();
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
  void dispose() {
    super.dispose();
  }

  @override
  void onClose() {
    super.onClose();
  }
}

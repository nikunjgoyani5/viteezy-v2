import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:viteezy/core/exceptions/app_exception.dart';
import 'package:viteezy/core/models/api_response.dart';
import 'package:viteezy/core/models/user_model.dart';
import 'package:viteezy/core/repositories/profile_repository.dart';
import 'package:viteezy/core/routes/app_routes.dart';
import 'package:viteezy/core/services/cart_count_service.dart';
import 'package:viteezy/core/services/onesignal_notification_service.dart';
import 'package:viteezy/core/utils/app_functions.dart';
import 'package:viteezy/core/utils/app_prefrence.dart';
import 'package:viteezy/core/utils/validators.dart';
import 'package:viteezy/core/l10n/locale_service.dart';
import 'package:viteezy/core/services/language_data_refresh_service.dart';
import 'package:viteezy/presentation/main/dashboard/controllers/dashboard_controller.dart';

import '../../../../core/theme/app_colors.dart';

class ProfileController extends GetxController {
  String userName = 'Alex Smith';
  String userEmail = 'alexsmith@example.com';
  String selectedLanguage = PrefService.getString(PrefKeys.locale);

  Future<void> updateLanguage(String language) async {
    selectedLanguage = language;
    await LocaleService.setLanguage(language);
    if (Get.isRegistered<LanguageDataRefreshService>()) {
      await LanguageDataRefreshService.to.refreshAfterLanguageChange();
    }
    final isLoggedIn =
        PrefService.getBool(PrefKeys.isLogin) && PrefService.getString(PrefKeys.accessToken).isNotEmpty;
    if (isLoggedIn) {
      await profileRepository.updateUserLanguage(
        language: language,
        onSuccess: (_) {},
        onError: (e) => AppFunctions().showToast(e.message, bgColor: AppColors.red),
      );
    }
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
  String userInitials = 'AS';
  bool isNotificationEnabled = false;
  String firstNameError = '';
  String lastNameError = '';
  String emailError = '';
  bool isLoggedIn = PrefService.getBool(PrefKeys.isLogin) &&
      PrefService.getString(PrefKeys.accessToken).isNotEmpty;
  TextEditingController fNameController = TextEditingController();
  TextEditingController lNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  void validateFirstName() {
    firstNameError = ValidationUtils.validateName(fNameController.text) ?? '';
    update();
  }

  validateEmail() {
    emailError = ValidationUtils.validateEmail(emailController.text) ?? '';
    update();
  }

  void validateLastName() {
    lastNameError = ValidationUtils.validateName(lNameController.text) ?? '';
    update();
  }

  String getInitials(String firstName, String lastName) {
    final f = (firstName).trim();
    final l = (lastName).trim();

    if (f.isEmpty && l.isEmpty) return '';

    if (f.isNotEmpty && l.isNotEmpty) {
      return (f[0] + l[0]).toUpperCase();
    }

    return (f.isNotEmpty ? f[0] : l[0]).toUpperCase();
  }

  void toggleNotification(bool value) {
    isNotificationEnabled = value;
    update();
  }

  RxBool loader = false.obs;
  ProfileRepository profileRepository = ProfileRepository();
  UserData userData = UserData();
  File? selectedImageFile;
  bool shouldRemoveImage = false;

  Future<void> logout(BuildContext context) async {
    loader.value = true;
    await profileRepository.logout(
      onSuccess: (ApiResponse response) async {
        try {
          await LocaleService.setLanguage("English");
          await OneSignalNotificationService.setExternalUserId(null);
          PrefService.clear();
          await FirebaseAuth.instance.signOut();
          await GoogleSignIn().signOut();
          
          // Clear cart count
          if (Get.isRegistered<CartCountService>()) {
            CartCountService.to.updateCartCount(0);
          }
          
          // Clear user data
          userData = UserData();
          fNameController.clear();
          lNameController.clear();
          emailController.clear();
          selectedImageFile = null;
          shouldRemoveImage = false;
          
          loader.value = false;
          
          // Update UI to reflect logout
          update();
          
          // Navigate to dashboard home tab instead of login view
          if (Get.isRegistered<DashboardController>()) {
            final dashboardController = Get.find<DashboardController>();
            dashboardController.changeBottomNav(0); // Switch to home tab (index 0)
          } else {
            // Fallback: navigate to dashboard if controller not registered
            Get.offAllNamed(AppRoutes.dashboard);
          }
          
          AppFunctions.showCustomToast(context, message: response.message ?? '', isSuccess: true);
        } catch (e) {
          debugPrint('error:::${e.toString()} ');

          loader.value = false;
          AppFunctions().showToast(response.message ?? 'Something went wrong!!', bgColor: AppColors.red);
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

  Future<void> getUserProfile() async {
    await profileRepository.getUserProfile(
      onSuccess: (ApiResponse response) async {
        try {
          UserModel userModel = UserModel.fromJson(response.toJson());
          userData = userModel.data ?? UserData();
          emailController.text = userData.user?.email ?? '';
          fNameController.text = userData.user?.firstName ?? '';
          lNameController.text = userData.user?.lastName ?? '';
          final userLanguage = userData.user?.language;
          if (userLanguage != null && userLanguage.trim().isNotEmpty) {
            await LocaleService.applyLanguageFromApi(userLanguage);
            selectedLanguage = LocaleService.currentLanguageName;
          }
          update();
        } catch (e) {
          debugPrint(e.toString());
        }
      },
      onError: (AppException error) {
        AppFunctions().showToast(error.message, bgColor: AppColors.red);
      },
    );
  }

  Future<void> updateUserProfile(BuildContext context) async {
    loader.value = true;
    await profileRepository.updateUserProfile(
      data: {
        'firstName': fNameController.text.trim(),
        'lastName': lNameController.text.trim(),
        'language': LocaleService.currentLanguageName,
      },
      profileImage: selectedImageFile,
      shouldRemoveImage: shouldRemoveImage,
      onSuccess: (ApiResponse response) {
        try {
          loader.value = false;
          shouldRemoveImage = false; // Reset flag after successful update
          getUserProfile();
          Get.back();
          AppFunctions.showCustomToast(context, message: response.message ?? '', isSuccess: true);
        } catch (e) {
          debugPrint('error:::${e.toString()} ');
          loader.value = false;
          AppFunctions().showToast('Something went wrong!!', bgColor: AppColors.red);
        }
      },
      onError: (AppException error) {
        loader.value = false;
        String message = error.message;
        AppFunctions().showToast(message, bgColor: AppColors.red);
      },
    );
  }

  @override
  void onInit() {
    init();
    super.onInit();
  }

  init() async {
    selectedLanguage = LocaleService.currentLanguageName;
    // Only load user profile if user is logged in
    final isLoggedIn = PrefService.getBool(PrefKeys.isLogin) && 
                      PrefService.getString(PrefKeys.accessToken).isNotEmpty;
    if (isLoggedIn) {
      await getUserProfile();
    }
  }

  void setSelectedImage(XFile? imageFile) {
    if (imageFile != null) {
      selectedImageFile = File(imageFile.path);
      shouldRemoveImage = false; // Reset remove flag when new image is selected
      update();
    }
  }

  void removeProfileImage() {
    selectedImageFile = null;
    shouldRemoveImage = true;
    debugPrint('Profile image removed. shouldRemoveImage: $shouldRemoveImage');
    update();
  }

  /// Reset unsaved edit state so the screen shows current profile (e.g. after opening again without save).
  void resetEditProfileState() {
    selectedImageFile = null;
    shouldRemoveImage = false;
    update();
  }
}

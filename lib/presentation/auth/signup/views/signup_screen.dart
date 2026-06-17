import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:viteezy/core/routes/app_routes.dart';
import 'package:viteezy/core/utils/app_functions.dart';
import 'package:viteezy/core/widgets/common_appbar.dart';
import 'package:viteezy/core/widgets/common_checkbox.dart';
import 'package:viteezy/core/widgets/common_loader.dart';
import 'package:viteezy/core/widgets/common_textfield.dart';
import 'package:get/get.dart';
import 'package:viteezy/core/widgets/language_selection_bottom_sheet.dart';
import 'package:viteezy/gen/assets.gen.dart';

import '../../../../core/utils/exports.dart';
import '../../../../core/widgets/common_button.dart';
import '../controllers/signup_controller.dart';

class SignupScreen extends GetView<SignupController> {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        AppFunctions().closeKeyboard();
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        resizeToAvoidBottomInset: true,
        appBar: CommonAppbar(
          title: '',
          actionWidget: InkWell(
            onTap: () {
              _showLanguageBottomSheet(context, controller);
            },
            child: Row(
              children: [
                Image.asset(Assets.icons.icLanguageLogo.path, scale: 3),
                Gap(10),
                Text(controller.localeCodeToNameFromCode(controller.selectedLanguage), style: TextStyles.medium(16.sp)),
                Icon(Icons.keyboard_arrow_down_outlined, size: 30, color: AppColors.black1414141),
              ],
            ),
          ),
        ),
        body: GetBuilder<SignupController>(
          builder: (controller) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                children: [
                  Gap(50.h),
                  Image.asset(Assets.images.logo.path, scale: 3.5, color: AppColors.primaryColor),
                  Gap(30.h),
                  CommonMainTextField(
                    onChanged: (val) {
                      controller.validateFName();
                    },
                    hintText: 'auth_first_name'.tr,
                    labelText: 'auth_first_name'.tr,
                    controller: controller.firstNameController,
                    // validator: ValidationUtils.validateName,
                    errorText: controller.firstNameError,
                  ),
                  Gap(13.h),
                  CommonMainTextField(
                    onChanged: (val) {
                      controller.validateLName();
                    },
                    hintText: 'auth_last_name'.tr,
                    labelText: 'auth_last_name'.tr,
                    controller: controller.lastNameController,
                    errorText: controller.lastNameError,
                    // validator: ValidationUtils.validateName,
                  ),
                  Gap(13.h),
                  CommonMainTextField(
                    onChanged: (val) {
                      controller.validateEmail();
                    },
                    hintText: 'auth_email'.tr,
                    labelText: 'auth_email'.tr,
                    controller: controller.emailController,
                    // validator: ValidationUtils.validateEmail,
                    keyboardType: TextInputType.emailAddress,
                    errorText: controller.emailError,
                  ),
                  Gap(13.h),
                  CommonMainTextField(
                    onChanged: (val) {
                      controller.validateMemberId();
                    },
                    hintText: 'address_member_id'.tr,
                    labelText: 'address_member_id'.tr,
                    controller: controller.memberIdController,
                    errorText: controller.memberIdError,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9-]')),
                      LengthLimitingTextInputFormatter(12),
                      TextInputFormatter.withFunction(
                        (oldValue, newValue) => TextEditingValue(
                          text: newValue.text.toUpperCase(),
                          selection: newValue.selection,
                        ),
                      ),
                    ],
                  ),
                  Gap(13.h),
                  CommonMainTextField(
                    onChanged: (val) {
                      controller.validatePass();
                    },
                    // validator: ValidationUtils.validatePassword,
                    obscureText: controller.isPasswordSecure,
                    hintText: 'auth_password'.tr,
                    labelText: 'auth_password'.tr,
                    controller: controller.passwordController,
                    errorText: controller.passwordError,
                    suffixIcon: InkWell(
                      radius: 60,
                      onTap: () {
                        controller.isPasswordSecure = !controller.isPasswordSecure;
                        controller.update();
                      },
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: controller.isPasswordSecure == true
                            ? Image.asset(Assets.icons.icCloseEye.path)
                            : Image.asset(Assets.icons.icEye.path),
                      ),
                    ),
                  ),
                  Gap(13.h),
                  CommonMainTextField(
                    onChanged: (val) {
                      controller.validateCPass();
                    },
                    // validator: controller.validateConfirmPassword,
                    obscureText: controller.isConfirmPasswordSecure,
                    hintText: 'auth_confirm_password'.tr,
                    labelText: 'auth_confirm_password'.tr,
                    controller: controller.confirmPasswordController,
                    errorText: controller.cPassError,
                    suffixIcon: InkWell(
                      radius: 60,
                      onTap: () {
                        controller.isConfirmPasswordSecure = !controller.isConfirmPasswordSecure;
                        controller.update();
                      },
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: controller.isConfirmPasswordSecure == true
                            ? Image.asset(Assets.icons.icCloseEye.path)
                            : Image.asset(Assets.icons.icEye.path),
                      ),
                    ),
                  ),
                  Gap(30.h),
                  Obx(() {
                    return CommonButtonWidget(
                      height: 48.h,
                      color:
                          controller.firstNameController.text.isNotEmpty &&
                              controller.lastNameController.text.isNotEmpty &&
                              controller.emailController.text.isNotEmpty &&
                              controller.passwordController.text.isNotEmpty &&
                              controller.confirmPasswordController.text.isNotEmpty &&
                              controller.firstNameError.isEmpty &&
                              controller.lastNameError.isEmpty &&
                              controller.emailError.isEmpty &&
                              controller.passwordError.isEmpty &&
                              controller.cPassError.isEmpty &&
                              controller.memberIdError.isEmpty
                          ? AppColors.primaryColor
                          : AppColors.lightPrimaryColor,
                      child: controller.isLoading.value
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [CommonLoader(size: 25, color: AppColors.white)],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('auth_create_account'.tr, style: TextStyles.semiBold(17.sp, fontColor: AppColors.white)),
                              ],
                            ),
                      onPressed: () async {
                        if (controller.firstNameController.text.isNotEmpty &&
                            controller.lastNameController.text.isNotEmpty &&
                            controller.emailController.text.isNotEmpty &&
                            controller.passwordController.text.isNotEmpty &&
                            controller.confirmPasswordController.text.isNotEmpty &&
                            (controller.onTapSignUp() == true)) {
                          if (controller.isAgree == false) {
                            AppFunctions().showToast('auth_accept_terms'.tr, bgColor: AppColors.red);
                            return;
                          }

                          await controller.signUp(context);
                        } else if (controller.emailController.text.isEmpty &&
                            controller.firstNameController.text.isEmpty &&
                            controller.lastNameController.text.isEmpty &&
                            controller.passwordController.text.isEmpty) {
                          AppFunctions().showToast('auth_please_enter_name_email_password'.tr, bgColor: AppColors.red);
                          return;
                        }
                      },
                    );
                  }),
                  Gap(15.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'auth_have_account'.tr,
                        style: TextStyles.regular(14.sp, fontColor: AppColors.grey545454),
                      ),
                      InkWell(
                        onTap: () {
                          Get.back();
                        },
                        child: Text(
                          'auth_log_in'.tr,
                          style: TextStyles.medium(14.sp, textDecoration: TextDecoration.underline),
                        ),
                      ),
                    ],
                  ),
                  Gap(15.h),
                  Row(
                    children: [
                      Expanded(child: Container(height: 1, color: AppColors.greyDFDFDF)),
                      Gap(30.w),
                      Text('auth_or_lower'.tr, style: TextStyles.medium(16.sp, fontColor: AppColors.gray919191)),
                      Gap(30.w),
                      Expanded(child: Container(height: 1, color: AppColors.greyDFDFDF)),
                    ],
                  ),
                  Gap(15.h),
                  Obx(() {
                    return CommonButtonWidget(
                      color: AppColors.white,
                      borderColor: AppColors.greyDFDFDF,
                      child: controller.isGoogleLoading.value
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [CommonLoader(size: 25, color: AppColors.primaryColor)],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(Assets.icons.icGoogle.path, scale: 3),
                                Gap(10.w),
                                Text('auth_login_google'.tr, style: TextStyles.medium(16.sp)),
                              ],
                            ),
                      onPressed: () async {
                        if (controller.isAgree == false) {
                          AppFunctions().showToast('auth_accept_terms'.tr, bgColor: AppColors.red);
                          return;
                        }
                        AppFunctions().closeKeyboard();
                        await controller.signInWithGoogle(context);
                      },
                    );
                  }),
                  Gap(15.h),
                  if (Platform.isIOS)
                    Obx(() {
                      return CommonButtonWidget(
                        color: AppColors.white,
                        borderColor: AppColors.greyDFDFDF,
                        child: controller.isAppleLoading.value
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [CommonLoader(size: 25, color: AppColors.primaryColor)],
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(Assets.icons.icApple.path, scale: 3),
                                  Gap(10.w),
                                  Text('auth_login_apple'.tr, style: TextStyles.medium(16.sp)),
                                ],
                              ),
                        onPressed: () async {
                          if (controller.isAgree == false) {
                            AppFunctions().showToast('auth_accept_terms'.tr, bgColor: AppColors.red);
                            return;
                          }
                          AppFunctions().closeKeyboard();
                          await controller.signInWithApple(context);
                        },
                      );
                    }),
                ],
              ),
            );
          },
        ),
        bottomNavigationBar: GetBuilder<SignupController>(
          builder: (controller) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0.w, vertical: 20.h),
              child: GestureDetector(
                onTap: () {
                  controller.isAgree = !controller.isAgree;
                  controller.update();
                },
                behavior: HitTestBehavior.translucent,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonCheckBox(
                      onChanged: (value) {
                        controller.isAgree = !controller.isAgree;
                        controller.update();
                      },
                      value: controller.isAgree,
                    ),
                    // Gap(10.w),
                    Expanded(
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          text: 'auth_by_continuing'.tr,
                          style: TextStyles.regular(14.sp, fontColor: AppColors.grey545454),
                          children: [
                            TextSpan(
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Get.toNamed(
                                    AppRoutes.webview,
                                    arguments: {'title': 'auth_terms_of_use'.tr, 'url': 'https://example.com/terms'},
                                  );
                                },
                              text: 'auth_terms_of_use'.tr,
                              style: TextStyles.regular(14.sp, fontColor: AppColors.primaryColor),
                            ),
                            TextSpan(
                              text: 'auth_and'.tr,
                              style: TextStyles.regular(14.sp, fontColor: AppColors.grey545454),
                            ),
                            TextSpan(
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Get.toNamed(
                                    AppRoutes.webview,
                                    arguments: {'title': 'auth_privacy_policy'.tr, 'url': 'https://example.com/privacy'},
                                  );
                                },
                              text: 'auth_privacy_policy'.tr,
                              style: TextStyles.regular(14.sp, fontColor: AppColors.primaryColor),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showLanguageBottomSheet(BuildContext context, SignupController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => LanguageSelectionBottomSheet(
        selectedLanguage: controller.selectedLanguage,
        onLanguageSelected: (language) {
          controller.updateLanguage(language);
        },
        onOkPressed: () {
          Get.back();
        },
      ),
    );
  }
}

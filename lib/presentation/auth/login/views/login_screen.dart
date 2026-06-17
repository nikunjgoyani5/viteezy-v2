import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:viteezy/core/routes/app_routes.dart';
import 'package:viteezy/core/utils/app_functions.dart';
import 'package:viteezy/core/widgets/common_appbar.dart';
import 'package:get/get.dart';
import 'package:viteezy/core/widgets/common_checkbox.dart';
import 'package:viteezy/core/widgets/common_loader.dart';
import 'package:viteezy/core/widgets/common_textfield.dart';
import 'package:viteezy/core/widgets/language_selection_bottom_sheet.dart';
import 'package:viteezy/gen/assets.gen.dart';
import 'package:viteezy/presentation/auth/forgot_password/views/forgot_password_screen.dart';

import '../../../../core/utils/exports.dart';
import '../../../../core/widgets/common_button.dart';
import '../controllers/login_controller.dart';

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        AppFunctions().closeKeyboard();
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        resizeToAvoidBottomInset: false,
        appBar: CommonAppbar(
          title: '',
          bgColor: AppColors.white,
          showBackButton: true,
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
        body: GetBuilder<LoginController>(
          builder: (controller) {
            return Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Gap(50.h),
                        // Image.asset(Assets.images.logo.path, scale: 3.5, color: AppColors.primaryColor),
                        Assets.animations.loginAnimation.lottie(
                          height: 38.h,
                          width: Get.width * 0.65,
                          fit: BoxFit.fill,
                          // fills screen, may crop
                          alignment: Alignment.center,
                          repeat: false,
                        ),
                        Gap(30.h),
                        // CommonTextField(
                        //   onChanged: (val) {
                        //     controller.update();
                        //   },
                        //   hintText: 'Email',
                        //   controller: controller.emailController,
                        //   keyboardType: TextInputType.emailAddress,
                        //   validator: ValidationUtils.validateEmail,
                        // ),
                        CommonMainTextField(
                          onChanged: (val) {
                            controller.onLoginIdentifierChanged(val);
                          },
                          errorText: controller.emailError,
                          hintText: 'auth_email_or_member_id'.tr,
                          controller: controller.emailController,
                          keyboardType: controller.isMemberIdLogin
                              ? TextInputType.text
                              : TextInputType.emailAddress,
                          labelText: 'auth_email_or_member_id'.tr,
                          inputFormatters: controller.isMemberIdLogin
                              ? [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'[A-Za-z0-9-]'),
                                  ),
                                  LengthLimitingTextInputFormatter(12),
                                ]
                              : null,
                        ),
                        if ( controller. emailController.text.trim().startsWith('M')) ...[
                          Gap(15.h),
                          CommonMainTextField(
                            onChanged: (val) {
                              controller.validateName();
                            },
                            errorText: controller.nameError,
                            hintText: 'auth_user_name'.tr,
                            controller: controller.nameController,
                            labelText: 'auth_user_name'.tr,
                          ),
                        ],
                        Gap(15.h),

                        // CommonTextField(
                        //   onChanged: (val) {
                        //     controller.update();
                        //   },
                        //
                        //   validator: ValidationUtils.validatePassword,
                        //   obscureText: controller.isSecure,
                        //   hintText: 'Password',
                        //   controller: controller.passController,
                        //   suffixIcon: InkWell(
                        //     radius: 60,
                        //     onTap: () {
                        //       controller.isSecure = !controller.isSecure;
                        //       controller.update();
                        //     },
                        //     child: Padding(
                        //       padding: EdgeInsets.all(12),
                        //       child: controller.isSecure == true
                        //           ? Image.asset(Assets.icons.icCloseEye.path)
                        //           : Image.asset(Assets.icons.icEye.path),
                        //     ),
                        //   ),
                        // ),
                        CommonMainTextField(
                          obscureText: controller.isSecure,
                          onChanged: (value) {
                            controller.validatePass();
                          },
                          errorText: controller.passwordError,
                          hintText: 'auth_password'.tr,
                          controller: controller.passController,
                          labelText: 'auth_password'.tr,
                          suffixIcon: InkWell(
                            radius: 60,
                            onTap: () {
                              controller.isSecure = !controller.isSecure;
                              controller.update();
                            },
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: controller.isSecure == true
                                  ? Image.asset(Assets.icons.icCloseEye.path)
                                  : Image.asset(Assets.icons.icEye.path),
                            ),
                          ),
                        ),

                        Gap(15.h),
                        Align(
                          alignment: Alignment.centerRight,
                          child: InkWell(
                            onTap: () {
                              controller.clearData();
                              Get.toNamed(AppRoutes.forgotPass);
                            },
                            child: Text(
                              'auth_forgot_password'.tr,
                              style: TextStyles.medium(14.sp, textDecoration: TextDecoration.underline),
                            ),
                          ),
                        ),
                        Gap(30.h),
                        Obx(() {
                          final bool isFormValid = controller.emailController.text.trim().isNotEmpty &&
                              controller.passController.text.trim().isNotEmpty &&
                              (!controller.isMemberIdLogin || controller.nameController.text.trim().isNotEmpty);

                          return CommonButtonWidget(
                            height: 48.h,
                            color: isFormValid
                                ? AppColors.primaryColor
                                : AppColors.lightPrimaryColor,
                            onPressed: () async {
                              if (isFormValid) {
                                AppFunctions().closeKeyboard();
                                if (controller.onTapLogin() == true) {
                                  if (controller.isAgree == false) {
                                    AppFunctions.showCustomToast(
                                      context,
                                      message: 'auth_accept_terms'.tr,
                                      isSuccess: false,
                                    );
                                    return;
                                  } else {
                                    final arguments = Get.arguments;
                                    if (arguments == null) {
                                      await controller.login(context);
                                    } else {
                                      final bool? isFromAIChat = arguments?['isFromAIChat'] ?? false;
                                      final String? sessionID = arguments?['sessionID'] ?? false;
                                      await controller.login(
                                        context,
                                        isFromAIChat: isFromAIChat as bool,
                                        sessionID: sessionID,
                                      );
                                    }
                                  }
                                }
                              } else if (controller.emailController.text.isEmpty &&
                                  controller.passController.text.isEmpty) {
                                AppFunctions.showCustomToast(
                                  context,
                                  message: 'auth_enter_email_password'.tr,
                                  isSuccess: false,
                                );
                                return;
                              }
                            },
                            child: controller.isLoading.value
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [CommonLoader(size: 25, color: AppColors.white)],
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('auth_login'.tr, style: TextStyles.semiBold(17.sp, fontColor: AppColors.white)),
                                    ],
                                  ),
                          );
                        }),

                        Gap(20.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'auth_no_account'.tr,
                              style: TextStyles.regular(14.sp, fontColor: AppColors.grey545454),
                            ),
                            InkWell(
                              onTap: () {
                                Get.toNamed(AppRoutes.signUp);
                              },
                              child: Text(
                                'auth_create_account_link'.tr,
                                style: TextStyles.medium(14.sp, textDecoration: TextDecoration.underline),
                              ),
                            ),
                          ],
                        ),
                        Gap(20.h),
                        Row(
                          children: [
                            Expanded(child: Container(height: 1, color: AppColors.greyDFDFDF)),
                            Gap(30.w),
                            Text('auth_or'.tr, style: TextStyles.medium(16.sp, fontColor: AppColors.grey6D6D6D)),
                            Gap(30.w),
                            Expanded(child: Container(height: 1, color: AppColors.greyDFDFDF)),
                          ],
                        ),
                        Gap(20.h),

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
                                AppFunctions().showToast(
                                  'auth_accept_terms'.tr,
                                  bgColor: AppColors.red,
                                );
                                return;
                              }
                              AppFunctions().closeKeyboard();

                              final arguments = Get.arguments;
                              if (arguments == null) {
                                await controller.signInWithGoogle(context);
                              } else {
                                final bool? isFromAIChat = arguments?['isFromAIChat'] ?? false;
                                final String? sessionID = arguments?['sessionID'] ?? false;
                                await controller.signInWithGoogle(
                                  context,
                                  isFromAIChat: isFromAIChat as bool,
                                  sessionID: sessionID,
                                );
                              }
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
                                  AppFunctions().showToast(
                                    'auth_accept_terms'.tr,
                                    bgColor: AppColors.red,
                                  );
                                  return;
                                }
                                AppFunctions().closeKeyboard();
                                await controller.signInWithApple(context);
                              },
                            );
                          }),
                        Spacer(),
                        GestureDetector(
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
                                              arguments: {
                                                'title': 'auth_privacy_policy'.tr,
                                                'url': 'https://example.com/privacy',
                                              },
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
                        Gap(20.h),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showLanguageBottomSheet(BuildContext context, LoginController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => LanguageSelectionBottomSheet(
        selectedLanguage: controller.selectedLanguage,
        onLanguageSelected: (language) {
          // Update controller only when OK is pressed
          controller.updateLanguage(language);
        },
        onOkPressed: () {
          Get.back();
        },
      ),
    );
  }
}

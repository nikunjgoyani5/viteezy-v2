import 'package:viteezy/core/routes/app_routes.dart';
import 'package:viteezy/core/utils/app_functions.dart';
import 'package:viteezy/core/widgets/common_appbar.dart';
import 'package:viteezy/core/widgets/common_loader.dart';
import 'package:viteezy/core/widgets/common_textfield.dart';

import '../../../../core/utils/exports.dart';
import '../../../../core/widgets/common_button.dart';
import '../../../../core/widgets/language_selection_bottom_sheet.dart';
import '../../../../gen/assets.gen.dart';
import '../controllers/forgot_password_controller.dart';

class ForgotPasswordScreen extends GetView<ForgotPasswordController> {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      resizeToAvoidBottomInset: false,
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
              Text(controller.localeCodeToNameFromCode(controller.selectedLanguage),style: TextStyles.medium(16.sp)),
              Icon(Icons.keyboard_arrow_down_outlined, size: 30, color: AppColors.black1414141),
            ],
          ),
        ),
      ),
      body: GetBuilder<ForgotPasswordController>(
        builder: (controller) {
          return Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Gap(30.h),
                      Text('auth_forgot_password_title'.tr, style: TextStyles.bold(24.sp)),
                      Gap(10.h),
                      Text(
                        'auth_forgot_instructions'.tr,
                        style: TextStyles.regular(14.sp, fontColor: AppColors.grey545454),
                      ),
                      Gap(40.h),
                      CommonMainTextField(
                        onChanged: (val) {
                          controller.validateEmail();
                        },
                        keyboardType: TextInputType.emailAddress,
                        hintText: 'auth_email'.tr,
                        labelText: 'Email',
                        controller: controller.emailController,
                        // validator: ValidationUtils.validateEmail,
                        errorText: controller.emailError,
                      ),
                      Gap(40.h),
                      Obx(() {
                        return CommonButtonWidget(
                          height: 48.h,
                          color: controller.emailController.text.isNotEmpty && controller.emailError.isEmpty
                              ? AppColors.primaryColor
                              : AppColors.lightPrimaryColor,
                          child: controller.loading.value
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [CommonLoader(size: 25, color: AppColors.white)],
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('auth_submit'.tr, style: TextStyles.semiBold(16.sp, fontColor: AppColors.white)),
                                  ],
                                ),
                          onPressed: () async {
                            if (controller.emailController.text.isNotEmpty && controller.emailError.isEmpty) {
                              AppFunctions().closeKeyboard();
                              if (controller.onTapForgotPass()) {
                                await controller.forgotPassApi();
                              }
                            } else if (controller.emailController.text.isEmpty) {
                              AppFunctions().showToast('auth_enter_email'.tr, bgColor: AppColors.red);
                              return;
                            }
                          },
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showLanguageBottomSheet(BuildContext context, ForgotPasswordController controller) {
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

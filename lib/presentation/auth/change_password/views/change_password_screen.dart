import 'package:viteezy/core/widgets/common_appbar.dart';
import 'package:viteezy/core/widgets/common_textfield.dart';
import 'package:viteezy/gen/assets.gen.dart';
import '../../../../core/utils/exports.dart';
import '../../../../core/widgets/common_button.dart';
import '../../../../core/widgets/common_loader.dart';
import '../controllers/change_password_controller.dart';

class ChangePasswordScreen extends GetView<ChangePasswordController> {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      resizeToAvoidBottomInset: false,
      appBar: CommonAppbar(title: 'auth_change_password'.tr),
      body: GetBuilder<ChangePasswordController>(
        builder: (controller) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gap(40.h),
                // Text('Change password', style: TextStyles.bold(24.sp)),
                // Gap(10.h),
                // Text(
                //   'Create a new password for your account.',
                //   style: TextStyles.regular(16.sp, fontColor: AppColors.grey545454),
                // ),
                // Gap(40.h),
                CommonMainTextField(
                  borderColor: AppColors.greyF0EFE4,
                  onChanged: (val) {
                    controller.validatePass();
                  },
                  // validator: ValidationUtils.validatePassword,
                  obscureText: controller.isCurrentPasswordSecure,
                  hintText: 'auth_current_password'.tr,
                  labelText: 'auth_current_password'.tr,
                  controller: controller.currentPasswordController,
                  suffixIcon: InkWell(
                    radius: 60,
                    onTap: () {
                      controller.isCurrentPasswordSecure = !controller.isCurrentPasswordSecure;
                      controller.update();
                    },
                    child: Padding(
                      padding: EdgeInsets.all(13),
                      child: controller.isCurrentPasswordSecure == true
                          ? Image.asset(Assets.icons.icCloseEye.path)
                          : Image.asset(Assets.icons.icEye.path),
                    ),
                  ),
                  errorText: controller.passwordError,
                ),
                Gap(9.h),
                CommonMainTextField(
                  borderColor: AppColors.greyF0EFE4,
                  onChanged: (val) {
                    if (controller.currentPasswordController.text.isEmpty) {
                      controller.validatePass();
                    }
                    controller.validateNewPass();
                    if (controller.confirmPasswordController.text.isNotEmpty) {
                      controller.validateConfirmPass();
                    }
                  },
                  // validator: ValidationUtils.validatePassword,
                  obscureText: controller.isNewPasswordSecure,
                  hintText: 'auth_new_password'.tr,
                  labelText: 'auth_new_password'.tr,
                  errorText: controller.newPassError,
                  controller: controller.newPasswordController,
                  suffixIcon: InkWell(
                    radius: 60,
                    onTap: () {
                      controller.isNewPasswordSecure = !controller.isNewPasswordSecure;
                      controller.update();
                    },
                    child: Padding(
                      padding: EdgeInsets.all(13),
                      child: controller.isNewPasswordSecure == true
                          ? Image.asset(Assets.icons.icCloseEye.path)
                          : Image.asset(Assets.icons.icEye.path),
                    ),
                  ),
                ),
                Gap(9.h),
                CommonMainTextField(
                  borderColor: AppColors.greyF0EFE4,
                  onChanged: (val) {
                    if (controller.newPasswordController.text.isEmpty || controller.currentPasswordController.text.isEmpty) {
                      controller.validateNewPass();
                      controller.validatePass();
                    }
                    controller.validateConfirmPass();
                  },
                  errorText: controller.confirmPassError,
                  // validator: controller.validateConfirmPassword,
                  obscureText: controller.isConfirmPasswordSecure,
                  hintText: 'auth_confirm_password'.tr,
                  labelText: 'auth_confirm_password'.tr,
                  controller: controller.confirmPasswordController,
                  suffixIcon: InkWell(
                    radius: 60,
                    onTap: () {
                      controller.isConfirmPasswordSecure = !controller.isConfirmPasswordSecure;
                      controller.update();
                    },
                    child: Padding(
                      padding: EdgeInsets.all(13),
                      child: controller.isConfirmPasswordSecure == true
                          ? Image.asset(Assets.icons.icCloseEye.path)
                          : Image.asset(Assets.icons.icEye.path),
                    ),
                  ),
                ),
                Spacer(),
                Obx(() {
                  return CommonButtonWidget(
                    color:
                        controller.currentPasswordController.text.isNotEmpty &&
                            controller.newPasswordController.text.isNotEmpty &&
                            controller.confirmPasswordController.text.isNotEmpty &&
                            controller.passwordError.isEmpty &&
                            controller.newPassError.isEmpty &&
                            controller.confirmPassError.isEmpty
                        ? AppColors.primaryColor
                        : AppColors.lightPrimaryColor,

                    child: controller.loader.value
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [CommonLoader(size: 25, color: AppColors.white)],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('auth_change_password'.tr, style: TextStyles.semiBold(16.sp, fontColor: AppColors.white)),
                            ],
                          ),
                    onPressed: () async {
                      if (controller.currentPasswordController.text.isNotEmpty &&
                          controller.newPasswordController.text.isNotEmpty &&
                          controller.confirmPasswordController.text.isNotEmpty &&
                          controller.passwordError.isEmpty &&
                          controller.newPassError.isEmpty &&
                          controller.confirmPassError.isEmpty) {
                        if (controller.onTapChangePass()) {
                          await controller.changePassword(context);
                        }
                      }
                    },
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}

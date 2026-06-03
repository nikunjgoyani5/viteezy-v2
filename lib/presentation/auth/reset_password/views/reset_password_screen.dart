import 'package:viteezy/core/routes/app_routes.dart';
import 'package:viteezy/core/utils/app_functions.dart';
import 'package:viteezy/core/widgets/common_appbar.dart';
import 'package:viteezy/core/widgets/common_textfield.dart';
import 'package:viteezy/gen/assets.gen.dart';
import '../../../../core/utils/exports.dart';
import '../../../../core/widgets/common_button.dart';
import '../../../../core/widgets/common_loader.dart';
import '../controllers/reset_password_controller.dart';

class ResetPasswordScreen extends GetView<ResetPasswordController> {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: CommonAppbar(title: ''),
      body: GetBuilder<ResetPasswordController>(
        builder: (controller) {
          return Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Gap(40.h),
                      Text('auth_reset_password_title'.tr, style: TextStyles.bold(28.sp)),
                      Gap(10.h),
                      Text('auth_enter_new_password'.tr, style: TextStyles.regular(16.sp, fontColor: AppColors.grey545454)),
                      Gap(40.h),
                      CommonMainTextField(
                        onChanged: (val) {
                          controller.validatePass();
                        },
                        errorText: controller.passwordError,

                        obscureText: controller.isNewPasswordSecure,
                        hintText: 'New Password',
                        labelText: 'New Password',
                        controller: controller.newPasswordController,
                        suffixIcon: InkWell(
                          radius: 60,
                          onTap: () {
                            controller.isNewPasswordSecure = !controller.isNewPasswordSecure;
                            controller.update();
                          },
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: controller.isNewPasswordSecure == true
                                ? Image.asset(Assets.icons.icCloseEye.path)
                                : Image.asset(Assets.icons.icEye.path),
                          ),
                        ),
                      ),
                      Gap(15.h),
                      CommonMainTextField(
                        onChanged: (val) {
                          controller.validateCPass();
                        },
                        errorText: controller.cPassError,
                        obscureText: controller.isConfirmPasswordSecure,
                        hintText: 'Confirm password',
                        labelText: 'Confirm password',
                        controller: controller.confirmPasswordController,
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
                      Gap(40.h),
                      Obx(() {
                        return CommonButtonWidget(
                          height: 48.h,
                          color:
                          controller.newPasswordController.text.isNotEmpty &&
                              controller.confirmPasswordController.text.isNotEmpty &&
                              controller.passwordError.isEmpty &&
                              controller.cPassError.isEmpty
                              ? AppColors.primaryColor
                              : AppColors.lightPrimaryColor,

                         child : controller.loading.value
                              ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [CommonLoader(size: 25, color: AppColors.white)],
                          )
                              : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('auth_reset_password_btn'.tr, style: TextStyles.semiBold(17.sp, fontColor: AppColors.white)),
                            ],
                          ),
                          onPressed: () async {
                            if (controller.newPasswordController.text.isNotEmpty &&
                                controller.confirmPasswordController.text.isNotEmpty &&
                                controller.passwordError.isEmpty &&
                                controller.cPassError.isEmpty) {
                              if (controller.onTapResetPass()) {
                                await controller.resetPassApi();
                              }


                            }
                            else if(controller.newPasswordController.text.isEmpty &&
                                controller.confirmPasswordController.text.isEmpty ){
                              AppFunctions().showToast('Please enter password', bgColor: AppColors.red);
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
}

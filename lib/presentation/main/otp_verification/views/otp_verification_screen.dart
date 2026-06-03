import 'package:pinput/pinput.dart';
import 'package:viteezy/core/utils/app_functions.dart';
import 'package:viteezy/core/widgets/common_appbar.dart';
import 'package:viteezy/core/widgets/common_loader.dart';
import 'package:viteezy/core/widgets/language_selection_bottom_sheet.dart';
import 'package:viteezy/gen/assets.gen.dart';
import 'package:viteezy/presentation/main/otp_verification/controllers/otp_verification_controller.dart';

import 'package:viteezy/core/utils/exports.dart';
import 'package:viteezy/core/widgets/common_button.dart';

class OtpVerificationScreen extends GetView<OtpVerificationController> {
  const OtpVerificationScreen({super.key});

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
              Text(controller.localeCodeToNameFromCode(controller.selectedLanguage), style: TextStyles.medium(16.sp)),
              Icon(Icons.keyboard_arrow_down_outlined, size: 30, color: AppColors.black1414141),
            ],
          ),
        ),
      ),
      body: GetBuilder<OtpVerificationController>(
        builder: (controller) {
          return Column(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Gap(40.h),
                      Text('auth_otp_verification'.tr, style: TextStyles.bold(24.sp)),
                      Gap(10.h),
                      RichText(
                        text: TextSpan(
                          text: 'Please enter the 6-digit codes sent to ',
                          style: TextStyles.regular(16.sp, fontColor: AppColors.grey545454),
                          children: [TextSpan(text: controller.email, style: TextStyles.regular(16.sp))],
                        ),
                      ),
                      Gap(40.h),
                      Pinput(
                        preFilledWidget: Text('-', style: TextStyles.semiBold(18.sp, fontColor: AppColors.grey888888)),

                        length: 6,
                        controller: controller.otpController,
                        defaultPinTheme: PinTheme(
                          width: 50.w,
                          height: 50.h,
                          textStyle: TextStyles.semiBold(20.sp),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.greyDFDFDF),
                          ),
                        ),
                        focusedPinTheme: PinTheme(
                          width: 50.w,
                          height: 50.h,
                          textStyle: TextStyles.semiBold(20.sp),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.primaryColor, width: 1),
                          ),
                        ),
                        submittedPinTheme: PinTheme(
                          width: 50.w,
                          height: 50.h,
                          textStyle: TextStyles.semiBold(20.sp),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.greyDFDFDF, width: 1),
                          ),
                        ),
                        onChanged: (value) {
                          controller.update();
                        },
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                        ],
                      ),
                      Gap(30.h),
                      controller.isTimerExpired
                          ? InkWell(
                              onTap: () async {
                                bool isFromSignUp = Get.arguments?['isFromSignUp'] ?? false;

                                await controller.resendOtp(fromSignUp: isFromSignUp);
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                                decoration: BoxDecoration(
                                  color: AppColors.lightPrimaryColor.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.primaryColor, width: 0.7),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('auth_code_expired'.tr, style: TextStyles.medium(16.sp)),
                                    Spacer(),
                                    Obx(() {
                                      return controller.resendLoading.value
                                          ? CommonLoader(color: AppColors.primaryColor, size: 16)
                                          : Text(
                                              'Resend',
                                              style: TextStyles.medium(16.sp, fontColor: AppColors.primaryColor),
                                            );
                                    }),
                                  ],
                                ),
                              ),
                            )
                          : Container(
                              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                              decoration: BoxDecoration(
                                color: AppColors.lightPrimaryColor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.primaryColor, width: 0.7),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.access_time, size: 20),
                                  Gap(10.w),
                                  Text('auth_code_expires_in'.tr, style: TextStyles.medium(16.sp)),
                                  Spacer(),
                                  Text(controller.formattedTime, style: TextStyles.medium(16.sp)),
                                ],
                              ),
                            ),
                      Gap(30.h),
                      Obx(() {
                        return CommonButtonWidget(
                          height: 48.h,
                          color: controller.isOtpComplete() ? AppColors.primaryColor : AppColors.lightPrimaryColor,
                          child: controller.isLoading.value
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [CommonLoader(size: 25, color: AppColors.white)],
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('auth_verify_code'.tr, style: TextStyles.semiBold(16.sp, fontColor: AppColors.white)),
                                  ],
                                ),
                          onPressed: () async {
                            if (controller.otpController.text.isNotEmpty) {
                              if (controller.isOtpComplete()) {
                                bool isFromSignUp = Get.arguments?['isFromSignUp'] ?? false;

                                await controller.verifyOtp(fromSignUp: isFromSignUp);
                              }
                            } else {
                              AppFunctions().showToast('Please enter OTP', bgColor: AppColors.red);
                              return;
                            }
                          },
                        );
                      }),
                      Gap(20.h),
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

  void _showLanguageBottomSheet(BuildContext context, OtpVerificationController controller) {
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

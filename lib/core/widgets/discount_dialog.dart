import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../gen/assets.gen.dart';
import '../theme/app_colors.dart';
import '../theme/text_styles.dart';
import 'common_textfield.dart';

/// Discount Dialog Widget
class DiscountDialog extends StatefulWidget {
  final Function(String email)? onClaimDiscount;
  final VoidCallback? onClose;

  const DiscountDialog({super.key, this.onClaimDiscount, this.onClose});

  @override
  State<DiscountDialog> createState() => _DiscountDialogState();
}

class _DiscountDialogState extends State<DiscountDialog> {
  final TextEditingController _emailController = TextEditingController();
  String? _emailError;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
      child: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(color: AppColors.secondaryColor, borderRadius: BorderRadius.circular(16.r)),
          child: Stack(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top Section - Image and Social Proof
                  Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      // Placeholder for woman with product image
                      Container(
                        padding: EdgeInsets.all(2.5.h),
                        width: double.infinity,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16.r)),
                        // TODO: Replace with actual image asset when provided
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16.r),
                          child: Stack(
                            children: [
                              Assets.images.discountDialogBg.image(fit: BoxFit.contain),
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  padding: EdgeInsets.all(35.h),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [Colors.transparent, Colors.black.withValues(alpha: 0.9)],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 10.h,
                        child: Column(
                          children: [
                            Text(
                              'Trusted by 400,000+ people',
                              style: TextStyles.medium(16.sp, fontColor: AppColors.white),
                              textAlign: TextAlign.center,
                            ),
                            // SizedBox(height: 8.h),
                            // Star rating
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(5, (index) => Icon(Icons.star, size: 16.sp, color: Colors.white)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Bottom Section - Discount Offer and Form
                  Padding(
                    padding: EdgeInsets.all(24.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Discount Heading
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: TextStyles.semiBold(24.sp, fontColor: Colors.white),
                            children: [
                              TextSpan(text: '30% Discount for '),
                              TextSpan(
                                text: ' three',
                                style: TextStyle(color: AppColors.primaryColor),
                              ),
                              TextSpan(text: ' months?'),
                            ],
                          ),
                        ),
                        SizedBox(height: 12.h),
                        // Description
                        Text(
                          'Sign up for our newsletter and receive a 30% discount on your first three months.',
                          textAlign: TextAlign.center,
                          style: TextStyles.regular(
                            14.sp,
                            fontColor: Colors.white.withValues(alpha: 0.9),
                          ).copyWith(height: 1.4),
                        ),
                        SizedBox(height: 24.h),
                        // Email Input Field
                        CommonMainTextField(
                          onChanged: (val) {
                            // controller.validateEmail();
                          },
                          errorText: _emailError,
                          hintText: 'Email',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          labelText: 'Email',
                        ),
                        SizedBox(height: 20.h),
                        // Claim Discount Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              final email = _emailController.text.trim();
                              String? error;
                              if (email.isEmpty) {
                                error = 'Please enter your email';
                              } else if (!GetUtils.isEmail(email)) {
                                error = 'Please enter a valid email';
                              }
                              setState(() {
                                _emailError = error;
                              });
                              if (error == null) {
                                widget.onClaimDiscount?.call(email);
                                Get.back();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.orangeF7A173,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 16.h),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
                              elevation: 0,
                            ),
                            child: Text(
                              'Claim my discount',
                              style: TextStyles.semiBold(16.sp, fontColor: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Close Button
              Positioned(
                right: 0,
                child: Padding(
                  padding: EdgeInsets.all(12.w),
                  child: GestureDetector(
                    onTap: () {
                      Get.back();
                      widget.onClose?.call();
                    },
                    child: Container(
                      width: 32.w,
                      height: 32.w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: Offset(0, 2)),
                        ],
                      ),
                      child: Icon(Icons.close, size: 20.sp, color: Colors.black),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

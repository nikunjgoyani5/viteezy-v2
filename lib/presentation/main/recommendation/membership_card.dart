import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:viteezy/core/theme/app_colors.dart';
import 'package:viteezy/core/theme/text_styles.dart';

class MembershipCard extends StatelessWidget {
  final bool selected;

  const MembershipCard({super.key, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Add Membership",
            // style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
            style: TextStyles.semiBold(20, fontColor: AppColors.black),
          ),
          SizedBox(height: 4.h),
          Text(
            "Longer commitments unlock better pricing and premium perks.",
            // style: TextStyle(color: Colors.grey.shade500, fontSize: 12.sp),
            style: TextStyles.regular(14, fontColor: AppColors.grey5F5E5B),
          ),
          Divider(color: AppColors.yellowF0EFE4),
          SizedBox(height: 14.h),
          _planRow(
            title: "Quarterly",
            price: "\$85.00",
            badge: "Save 15%",
            badgeColor: const Color(0xFFFFF0C2),
            badgeTextColor: const Color(0xFF8A6000),
            actionLabel: selected ? "Remove" : "+Add",
            actionColor: selected ? Colors.red.shade400 : Colors.black,
          ),
          SizedBox(height: 12.h),
          Divider(color: Colors.grey.shade200, height: 1),
          SizedBox(height: 12.h),
          _planRow(
            title: "Annual",
            price: "\$100.00",
            badge: "Save 30% Best Value",
            badgeColor: const Color(0xFFFFF0C2),
            badgeTextColor: const Color(0xFF8A6000),
            actionLabel: "+Add",
            actionColor: Colors.black,
          ),
        ],
      ),
    );
  }

  Widget _planRow({
    required String title,
    required String price,
    required String badge,
    required Color badgeColor,
    required Color badgeTextColor,
    required String actionLabel,
    required Color actionColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    // style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500)
                    style: TextStyles.medium(18.sp, fontColor: AppColors.black),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 3.h,
                    ),
                    decoration: BoxDecoration(
                      color: Color(0xFFEDDFA5),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      badge,
                      // style: TextStyle(fontSize: 11.sp, color: badgeTextColor, fontWeight: FontWeight.w500)),
                      style: TextStyles.medium(
                        14,
                        fontColor: AppColors.black141414,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Text(
                price,
                // style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600)
                style: TextStyles.semiBold(
                  16.sp,
                  fontColor: AppColors.black141414,
                ),
              ),
            ],
          ),
        ),
        Text(
          actionLabel,
          style: TextStyles.semiBold(
            16.sp,
            fontColor: AppColors.black141414,
          ),
        ),
      ],
    );
  }
}

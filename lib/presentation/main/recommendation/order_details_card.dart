import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:viteezy/core/theme/app_colors.dart';
import 'package:viteezy/core/theme/text_styles.dart';

class OrderDetailsCard extends StatelessWidget {
  final double total;

  const OrderDetailsCard({super.key, required this.total});

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
            "Order Details",
            style: TextStyles.semiBold(18.sp,fontColor: AppColors.black141414),
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Personalized Pack for vivek",
                    style: TextStyles.medium(16.sp,fontColor: AppColors.black141414),
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Icon(Icons.sync, size: 14.sp, color: AppColors.gray686767),
                      SizedBox(width: 4.w),
                      Text(
                        "Auto Renews Every 30 Days",
                        style: TextStyles.regular(12.sp,fontColor: AppColors.gray686767),
                      ),
                    ],
                  ),
                ],
              ),
              Text(
                "\$${total.toStringAsFixed(2)}",
                style: TextStyles.regular(16.sp,fontColor: AppColors.black141414),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Subtotal", style: TextStyles.regular(14.sp,fontColor: AppColors.black141414),),
              Text("\$${total.toStringAsFixed(2)}",style: TextStyles.regular(14.sp,fontColor: AppColors.black141414),),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Shipping",  style: TextStyles.regular(14.sp,fontColor: AppColors.black141414),),
              Text("Free",  style: TextStyles.regular(14.sp,fontColor: AppColors.black141414),),


            ],
          ),
          SizedBox(height: 8.h),
          Divider(color: Colors.grey.shade200, height: 1),
        ],
      ),
    );
  }
}
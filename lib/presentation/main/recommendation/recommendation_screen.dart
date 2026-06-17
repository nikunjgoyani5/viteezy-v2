import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:viteezy/core/theme/app_colors.dart';
import 'package:viteezy/core/theme/text_styles.dart';
import 'package:viteezy/core/widgets/common_appbar.dart';
import 'package:viteezy/gen/assets.gen.dart';
import 'package:viteezy/presentation/main/recommendation/custom_toggle_btn.dart';
import 'package:viteezy/presentation/main/recommendation/membership_card.dart';
import 'package:viteezy/presentation/main/recommendation/order_details_card.dart';
import 'package:viteezy/presentation/main/recommendation/recommendation_controller.dart';
import 'package:viteezy/presentation/main/recommendation/supplement_card.dart';

class RecommendationScreen extends GetView<RecommendationController> {
  const RecommendationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CommonAppbar(title: "Our Recommendations", showBackButton: true),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16.w),
        child: SizedBox(
          height: 55.h,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: const StadiumBorder(),
            ),
            onPressed: () {},
            child: const Text("Add to Cart"),
          ),
        ),
      ),

      body: SafeArea(
        child: Obx(
          () => ListView(
            padding: EdgeInsets.all(16.w),
            children: [
              SizedBox(height: 10.h),

              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.r),
                  image: DecorationImage(
                    image: AssetImage(Assets.images.imgOurRecommendations.path),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Personalized Recommendations",
                      style: TextStyles.regular(
                        14.sp,
                        fontColor: AppColors.blackColor,
                      ),
                    ),
                    Text(
                      "Made for Vivek",
                      style: TextStyles.medium(
                        20.sp,
                        fontColor: AppColors.blackColor,
                      ),
                    ),
                    Text(
                      "Based on your responses, we've created a science-backed routine tailored specifically to your needs.",
                      style: TextStyles.regular(
                        14.sp,
                        fontColor: AppColors.grey5F5E5B,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Row(
                      children: [
                        Assets.icons.icRights.svg(),
                        SizedBox(width: 8),
                        Text(
                          "Quality vitamins",
                          style: TextStyles.regular(
                            14.sp,
                            fontColor: AppColors.black110E21,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Assets.icons.icRights.svg(),
                        SizedBox(width: 8),
                        Text(
                          "28 daily packs",
                          style: TextStyles.regular(
                            14.sp,
                            fontColor: AppColors.black110E21,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Assets.icons.icRights.svg(),
                        SizedBox(width: 8),
                        Text(
                          "Personalized to you",
                          style: TextStyles.regular(
                            14.sp,
                            fontColor: AppColors.black110E21,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              CustomToggleTab(),
              SizedBox(height: 12.h),

              Text("Advanced Bundle", style: TextStyles.medium(18.sp)),

              SizedBox(height: 12.h),

              ...List.generate(controller.supplements.length, (index) {
                final item = controller.supplements[index];

                return SupplementCard(
                  name: item.name,
                  desc: item.desc,
                  price: item.price,
                  quantity: item.quantity,
                  plus: () => controller.increase(index),
                  minus: () => controller.decrease(index),
                );
              }),

              MembershipCard(selected: controller.quarterlyAdded.value),

              SizedBox(height: 16.h),

              OrderDetailsCard(total: controller.total),
            ],
          ),
        ),
      ),
    );
  }
}

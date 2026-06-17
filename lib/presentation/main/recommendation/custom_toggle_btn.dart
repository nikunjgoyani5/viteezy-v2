
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:viteezy/core/theme/app_colors.dart';
import 'package:viteezy/core/theme/text_styles.dart';
import 'package:viteezy/presentation/main/recommendation/recommendation_controller.dart';

class CustomToggleTab extends GetView<RecommendationController> {
  const CustomToggleTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Padding(
        padding:  EdgeInsets.symmetric(horizontal: 44.w),
        child: Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: const Color(0xFFEEEDE6), // outer beige/cream pill
            borderRadius: BorderRadius.circular(50.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _tabItem(label: "Essential (2)", index: 0),
              _tabItem(label: "Advanced (3)", index: 1),
            ],
          ),
        ),
      );
    });
  }

  Widget _tabItem({required String label, required int index}) {
    final bool isSelected = controller.selectedTab.value == index;
    return GestureDetector(
      onTap: () => controller.selectedTab.value = index,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(50.r),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ]
              : [],
        ),
        child: Text(
          label,
          style: isSelected
              ? TextStyles.semiBold(14.sp, fontColor: AppColors.black141414)
              : TextStyles.medium(14.sp, fontColor: AppColors.black717171),
        ),
      ),
    );
  }
}

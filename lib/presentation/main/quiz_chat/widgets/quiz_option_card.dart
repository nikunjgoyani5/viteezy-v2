import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:viteezy/core/theme/app_colors.dart';

class QuizOptionCard extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const QuizOptionCard({
    super.key,
    required this.selected,
    required this.onTap,
    required this.child,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(width: double.infinity,
        margin: margin ?? EdgeInsets.only(bottom: 12.h),
        padding: padding ?? EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: selected ? AppColors.primaryColor : Color(0xFFF0EFE4),
            width: selected ? 2 : 1,
          ),
        ),
        child: child,
      ),
    );
  }
}

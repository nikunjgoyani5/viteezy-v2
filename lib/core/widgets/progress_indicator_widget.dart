import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:viteezy/core/theme/app_colors.dart';

class QuizProgressBar extends StatelessWidget {
  final double value;

  const QuizProgressBar({
    super.key,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(100.r),
      child: LinearProgressIndicator(
        value: value,
        minHeight: 6.h,
        backgroundColor: AppColors.greyE5E4DC,
        valueColor: const AlwaysStoppedAnimation<Color>(
          AppColors.primaryColor,
        ),
      ),
    );
  }
}

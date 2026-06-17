import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:viteezy/core/models/quiz_model/quiz_question_model.dart';
import 'package:viteezy/core/theme/app_colors.dart';
import 'package:viteezy/core/theme/text_styles.dart';
import 'package:viteezy/presentation/main/quiz_chat/controllers/quiz_controller.dart';

class DateQuestionWidget extends GetView<QuizController> {
  final QuizQuestionModel question;

  const DateQuestionWidget({
    super.key,
    required this.question,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final date = controller.dateAnswer(question.id);
      final label = date != null
          ? DateFormat('dd MMM yyyy').format(date)
          : 'Select date';

      return GestureDetector(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: date ?? DateTime(2000),
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
          );
          if (picked != null) {
            controller.saveDate(question.id, picked);
          }
        },
        child: Container(
          height: 56.h,
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: AppColors.surfaceColor,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: date != null
                  ? AppColors.primaryColor
                  : AppColors.greyE5E4DC,
              width: date != null ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyles.medium(
                    16.sp,
                    fontColor: date != null
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
              Icon(
                Icons.calendar_today_outlined,
                size: 20.sp,
                color: AppColors.primaryColor,
              ),
            ],
          ),
        ),
      );
    });
  }
}

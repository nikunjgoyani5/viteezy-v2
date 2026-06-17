import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:viteezy/core/models/quiz_model/enum.dart';
import 'package:viteezy/core/models/quiz_model/quiz_question_model.dart';
import 'package:viteezy/core/theme/app_colors.dart';
import 'package:viteezy/core/theme/text_styles.dart';
import 'package:viteezy/presentation/main/quiz_chat/controllers/quiz_controller.dart';
import 'package:viteezy/presentation/main/quiz_chat/widgets/question_widget_builder.dart';
import 'package:viteezy/presentation/main/quiz_chat/widgets/selection_question_widget.dart';

class NestedQuestionWidget extends GetView<QuizController> {
  final QuizQuestionModel question;

  const NestedQuestionWidget({
    super.key,
    required this.question,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = controller.selectedOption(question.id);
      final childQuestion = selected?.childQuestion;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectionQuestionWidget(
            question: QuizQuestionModel(
              id: question.id,
              question: question.question,
              type: QuestionType.selection,
              selectionUiType: SelectionUiType.iconTitleSubtitle,
              options: question.options,
            ),
          ),
          if (childQuestion != null) ...[
            SizedBox(height: 24.h),
            Text(
              childQuestion.question,
              style: TextStyles.semiBold(18.sp),
            ),
            if (childQuestion.subtitle != null) ...[
              SizedBox(height: 8.h),
              Text(
                childQuestion.subtitle!,
                style: TextStyles.regular(
                  14.sp,
                  fontColor: AppColors.textSecondary,
                ),
              ),
            ],
            SizedBox(height: 16.h),
            QuestionWidgetBuilder.build(childQuestion),
          ],
        ],
      );
    });
  }
}

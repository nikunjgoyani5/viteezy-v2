/*
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:viteezy/core/models/quiz_model/enum.dart';
import 'package:viteezy/core/routes/app_routes.dart';
import 'package:viteezy/core/theme/app_colors.dart';
import 'package:viteezy/core/theme/text_styles.dart';
import 'package:viteezy/core/widgets/common_appbar.dart';
import 'package:viteezy/core/widgets/common_button.dart';
import 'package:viteezy/presentation/main/quiz_chat/controllers/quiz_controller.dart';
import 'package:viteezy/presentation/main/quiz_chat/widgets/quiz_option_card.dart';

class QuizQuestionsScreen extends GetView<QuizController> {
  const QuizQuestionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const CommonAppbar(title: 'Take the Quiz'),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your health quiz',
                      style: TextStyles.semiBold(24.sp),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Tap a question to preview its widget, or start the full quiz.',
                      style: TextStyles.regular(
                        14.sp,
                        fontColor: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    ...List.generate(controller.questions.length, (index) {
                      final question = controller.questions[index];
                      return QuizOptionCard(
                        selected: false,
                        onTap: () {
                          controller.jumpTo(index);
                          Get.toNamed(AppRoutes.quizFlow);
                        },
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    question.question,
                                    style: TextStyles.semiBold(16.sp),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    _questionTypeLabel(question),
                                    style: TextStyles.regular(
                                      13.sp,
                                      fontColor: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20.w),
              child: CommonButton(
                text: 'Start full quiz',
                color: AppColors.black1414141,
                onPressed: () {
                  controller.jumpTo(0);
                  Get.toNamed(AppRoutes.quizFlow);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _questionTypeLabel(dynamic question) {
    switch (question.type) {
      case QuestionType.selection:
        return 'Selection · ${_selectionLabel(question.selectionUiType)}';
      case QuestionType.text:
        return 'Text input';
      case QuestionType.date:
        return 'Date picker';
      case QuestionType.nested:
        return 'Nested question';
      default:
        return 'Question';
    }
  }

  String _selectionLabel(SelectionUiType? type) {
    switch (type) {
      case SelectionUiType.titleOnly:
        return 'Simple list';
      case SelectionUiType.iconTitleSubtitle:
        return 'Icon + subtitle';
      case SelectionUiType.iconTitle:
        return 'Grid multi-select';
      case SelectionUiType.imageTitle:
        return 'Image cards';
      default:
        return 'Selection';
    }
  }
}
*/

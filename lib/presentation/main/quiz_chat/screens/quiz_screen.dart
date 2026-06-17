import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:viteezy/core/theme/app_colors.dart';
import 'package:viteezy/core/theme/text_styles.dart';
import 'package:viteezy/core/widgets/common_appbar.dart';
import 'package:viteezy/core/widgets/common_button.dart';
import 'package:viteezy/core/widgets/progress_indicator_widget.dart';
import 'package:viteezy/gen/assets.gen.dart';
import 'package:viteezy/presentation/main/quiz_chat/controllers/quiz_controller.dart';
import 'package:viteezy/presentation/main/quiz_chat/widgets/question_widget_builder.dart';

class QuizScreen extends GetView<QuizController> {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Obx(() {
        // final question = controller.currentQuestion;

        return Stack(
          children: [
            Column(
              children: [
                CommonAppbar(
                  title: 'Take the Quiz',
                  onLeadPress: controller.previous,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: QuizProgressBar(value: controller.progress),
                ),
                SizedBox(height: 32.h),
                Expanded(
                  child:
                  PageView.builder(
                    controller: controller.pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.questions.length,
                    itemBuilder: (_, index) {
                      final question = controller.questions[index];

                      return
                        SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Center(
                          //   child: Text(
                          //     question.question,
                          //     style: TextStyles.medium(23.sp,fontColor: AppColors.black141414),
                          //   ),
                          // ),
                          SizedBox(
                            width: double.infinity,
                            child: Text(
                              question.question,
                              textAlign: TextAlign.center,
                              style: TextStyles.medium(
                                23.sp,
                                fontColor: AppColors.black141414,
                              ),
                            ),
                          ),
                        /*  if (question.subtitle != null) ...[
                            SizedBox(height: 6.h),
                            Text(
                              question.subtitle!,
                              style: TextStyles.regular(
                                14.sp,
                                fontColor: AppColors.grey6E6E6E,
                              ),
                            ),
                          ],*/
                          if (controller.currentQuestion.subtitle != null)
                            Padding(
                              padding: EdgeInsets.only(top: 8.h),
                              child: Text(
                                controller.currentQuestion.subtitle!,
                                textAlign: TextAlign.center,
                                style: TextStyles.regular(
                                  14.sp,
                                  fontColor: AppColors.grey6E6E6E,
                                ),
                              ),
                            ),

                          SizedBox(height: 20.h),
                          QuestionWidgetBuilder.build(question),
                        ],
                      ),
                    ),
                  );
      },
      ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 12.h),
                  child: Column(
                    children: [
                      CommonButton(
                        text: controller.currentIndex.value ==
                                controller.questions.length - 1
                            ? 'Finish'
                            : 'Next',
                        color: controller.canContinue
                            ? AppColors.black1414141
                            : AppColors.greyD7D7D7,
                        onPressed: controller.canContinue
                            ? controller.next
                            : () {},
                      ),
                      SizedBox(height: 12.h),
                      GestureDetector(
                        onTap: controller.previous,
                        child: Text(
                          'Previous',
                          style: TextStyles.medium(
                            14.sp,
                            fontColor: AppColors.textPrimary,
                          ).copyWith(
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            /// First Question Stars
            if (controller.currentIndex.value == 0) ...[
              Positioned(
                left: 35.w,
                bottom: 110.h,
                child: SvgPicture.asset(
                  Assets.icons.icYellowStar.path,
                  width: 35.w,
                ),
              ),
              Positioned(
                left: 65.w,
                bottom: 150.h,
                child: SvgPicture.asset(
                  Assets.icons.icYellowStar.path,
                  width: 14.w,
                ),
              ),
              Positioned(
                left: 65.w,
                bottom: 100.h,
                child: SvgPicture.asset(
                  Assets.icons.icYellowStar.path,
                  width: 10.w,
                ),
              ),
              Positioned(
                right: 60.w,
                bottom: 270.h,
                child: SvgPicture.asset(
                  Assets.icons.icYellowStar.path,
                  width: 35.w,
                ),
              ),
              Positioned(
                right: 45.w,
                bottom: 310.h,
                child: SvgPicture.asset(
                  Assets.icons.icYellowStar.path,
                  width: 14.w,
                ),
              ),
              Positioned(
                right: 45.w,
                bottom: 250.h,
                child: SvgPicture.asset(
                  Assets.icons.icYellowStar.path,
                  width: 10.w,
                ),
              ),
            ],
          ],
        );
      }),
    );
  }
}

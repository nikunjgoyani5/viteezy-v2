import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:viteezy/core/models/quiz_model/enum.dart';
import 'package:viteezy/core/models/quiz_model/quiz_question_model.dart';
import 'package:viteezy/core/theme/app_colors.dart';
import 'package:viteezy/core/theme/text_styles.dart';

import '../controllers/quiz_controller.dart';
import 'quiz_option_card.dart';

class SelectionQuestionWidget extends GetView<QuizController> {
  final QuizQuestionModel question;

  const SelectionQuestionWidget({
    super.key,
    required this.question,
  });

  @override
  Widget build(BuildContext context) {

      switch (question.selectionUiType) {
        case SelectionUiType.titleOnly:
          return _titleOnly();
        case SelectionUiType.iconTitle:
          return _iconTitle();
        case SelectionUiType.iconTitleSubtitle:
          return _iconTitleSubtitle();
        case SelectionUiType.imageTitle:
          return _imageTitle();
        default:
          return _titleOnly();
      }

  }

/*  Widget _titleOnly() {
    return Column(
      children: question.options!.map((option) {
        final selected = controller.isSelected(question.id, option.id);
        return QuizOptionCard(
          selected: selected,
          onTap: () => controller.selectOption(question.id, option.id),
          child: Text(
            option.title,
            style: TextStyles.medium(16.sp),
          ),
        );
      }).toList(),
    );
  }*/

  Widget _titleOnly() {
    return Obx(
          () => Column(
        children: question.options!.map((option) {
          final selected =
          controller.isSelected(question.id, option.id);

          return QuizOptionCard(
            selected: selected,
            onTap: () =>
                controller.selectOption(question.id, option.id),
            child: Text(option.title),
          );
        }).toList(),
      ),
    );
  }

/*
  Widget _iconTitleSubtitle() {
    return Column(
      children: question.options!.map((option) {
        final selected = controller.isSelected(question.id, option.id);
        return QuizOptionCard(
          selected: selected,
          onTap: () => controller.selectOption(question.id, option.id),
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (option.icon != null)
                SvgPicture.asset(
                  option.icon!,
                  width: 45.w,
                  height: 45.w,
                ),
              SizedBox(height: 12.h),
              Text(
                option.title,
                style: TextStyles.medium(17.sp, fontColor: AppColors.black1414141,),
              ),
              if (option.subtitle != null) ...[
                SizedBox(height: 3.h),
                Text(
                  option.subtitle!,
                  style: TextStyles.regular(
                    13.sp,
                    fontColor: AppColors.grey6E6E6E,
                  ),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }
*/

/*
  Widget _iconTitleSubtitle() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: question.options!.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 0.9,
      ),
      itemBuilder: (_, index) {
        final option = question.options![index];
        final selected = controller.isSelected(question.id, option.id);

        return QuizOptionCard(
          selected: selected,
          margin: EdgeInsets.zero,
          padding: EdgeInsets.all(16.w),
          onTap: () => controller.selectOption(question.id, option.id),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (option.icon != null)
                SvgPicture.asset(
                  option.icon!,
                  width: 45.w,
                  height: 45.w,
                ),

              SizedBox(height: 12.h),

              Text(
                option.title,
                style: TextStyles.medium(
                  17.sp,
                  fontColor: AppColors.black1414141,
                ),
              ),

              if (option.subtitle != null) ...[
                SizedBox(height: 3.h),
                Text(
                  option.subtitle!,
                  style: TextStyles.regular(
                    13.sp,
                    fontColor: AppColors.grey6E6E6E,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
*/

  Widget _iconTitleSubtitle() {
    final options = question.options!;

    return Wrap(
      spacing: 12.w,
      runSpacing: 12.h,
      children: List.generate(options.length, (index) {
        final option = options[index];
        final selected = controller.isSelected(question.id, option.id);

        final bool isLastOddItem =
            options.length.isOdd && index == options.length - 1;

        // return SizedBox(
        //   width: isLastOddItem
        //       ? double.infinity
        //       : (Get.width - 44.w) / 2,
     return   SizedBox(
          width: isLastOddItem
              ? double.infinity
              : (Get.width - 44.w) / 2,
          height: 175.h,
          child: QuizOptionCard(
            selected: selected,
            margin: EdgeInsets.zero,
            padding: EdgeInsets.all(16.w),
            onTap: () => controller.selectOption(question.id, option.id),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (option.icon != null)
                  SvgPicture.asset(
                    option.icon!,
                    width: 45.w,
                    height: 45.w,
                  ),
                SizedBox(height: 12.h),
                Text(
                  option.title,
                  style: TextStyles.medium(
                    17.sp,
                    fontColor: AppColors.black1414141,
                  ),
                ),
                if (option.subtitle != null) ...[
                  SizedBox(height: 3.h),
                  Text(
                    option.subtitle!,
                    style: TextStyles.regular(
                      13.sp,
                      fontColor: AppColors.grey6E6E6E,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }),
    );
  }
  Widget _iconTitle() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: question.options!.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10.w,
        mainAxisSpacing: 10.h,
        childAspectRatio: 2.4,
      ),
      itemBuilder: (_, index) {
        final option = question.options![index];
        final selected = controller.isSelected(question.id, option.id);
        final badge = controller.selectionBadgeIndex(question.id, option.id);

        return QuizOptionCard(
          selected: selected,
          margin: EdgeInsets.zero,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
          onTap: () => controller.selectOption(question.id, option.id),
          child: Row(
            children: [
              if (option.icon != null)
                SvgPicture.asset(
                  option.icon!,
                  width: 24.w,
                  height: 24.w,
                ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  option.title,
                  style: TextStyles.medium(14.sp),
                ),
              ),
              if (badge != null)
                Container(
                  width: 24.w,
                  height: 24.w,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$badge',
                    style: TextStyles.medium(12.sp, fontColor: AppColors.white),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

/*
  Widget _imageTitle() {
    return Column(
      children: question.options!.map((option) {
        final selected = controller.isSelected(question.id, option.id);
        return QuizOptionCard(
          selected: selected,
          onTap: () => controller.selectOption(question.id, option.id),
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              if (option.image != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Image.asset(
                    option.image!,
                    width: double.infinity,
                    height: 140.h,
                    fit: BoxFit.cover,
                  ),
                ),
              SizedBox(height: 12.h),
              Text(
                option.title,
                style: TextStyles.semiBold(16.sp),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
*/
  Widget _imageTitle() {
    return Column(
      children: question.options!.map((option) {
        final selected = controller.isSelected(question.id, option.id);

        return Padding(
          padding: EdgeInsets.only(bottom: 32.h),
          child: GestureDetector(
            onTap: () => controller.selectOption(
              question.id,
              option.id,
            ),
            child: Column(
              children: [
                Container(
                  width: 140.w,
                  height: 140.w,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: selected
                          ? AppColors.primaryColor
                          : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(12.w),
                    child: Image.asset(
                      option.image!,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  option.title,
                  textAlign: TextAlign.center,
                  style: TextStyles.medium(
                    16.sp,
                    fontColor: AppColors.black141414,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

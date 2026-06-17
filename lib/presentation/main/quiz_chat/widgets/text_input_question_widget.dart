import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:viteezy/core/models/quiz_model/quiz_question_model.dart';
import 'package:viteezy/core/theme/app_colors.dart';
import 'package:viteezy/core/theme/text_styles.dart';
import 'package:viteezy/presentation/main/quiz_chat/controllers/quiz_controller.dart';

class TextInputQuestionWidget extends StatefulWidget {
  final QuizQuestionModel question;

  const TextInputQuestionWidget({
    super.key,
    required this.question,
  });

  @override
  State<TextInputQuestionWidget> createState() =>
      _TextInputQuestionWidgetState();
}

class _TextInputQuestionWidgetState extends State<TextInputQuestionWidget> {
  late final TextEditingController _textController;
  late final QuizController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<QuizController>();
    _textController = TextEditingController(
      text: _controller.textAnswer(widget.question.id) ?? '',
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _textController,
      onChanged: (text) =>
          _controller.saveText(widget.question.id, text),
      style: TextStyles.regular(16.sp),
      decoration: InputDecoration(
        hintText: 'Enter your answer',
        hintStyle: TextStyles.regular(
          16.sp,
          fontColor: AppColors.textSecondary,
        ),
        filled: true,
        fillColor: AppColors.surfaceColor,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 16.h,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: const BorderSide(color: AppColors.greyE5E4DC),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: const BorderSide(
            color: AppColors.primaryColor,
            width: 2,
          ),
        ),
      ),
    );
  }
}

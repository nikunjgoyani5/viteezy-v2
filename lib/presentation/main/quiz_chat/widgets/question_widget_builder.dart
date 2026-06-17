import 'package:flutter/widgets.dart';
import 'package:viteezy/core/models/quiz_model/enum.dart';
import 'package:viteezy/core/models/quiz_model/quiz_question_model.dart';

import 'date_question_widget.dart';
import 'nested_question_widget.dart';
import 'selection_question_widget.dart';
import 'text_input_question_widget.dart';

class QuestionWidgetBuilder {
  static Widget build(
      QuizQuestionModel question,
      ) {
    switch (question.type) {
      case QuestionType.selection:
        return SelectionQuestionWidget(
          question: question,
        );

      case QuestionType.text:
        return TextInputQuestionWidget(
          question: question,
        );

      case QuestionType.date:
        return DateQuestionWidget(
          question: question,
        );

      case QuestionType.nested:
        return NestedQuestionWidget(
          question: question,
        );
    }
  }
}
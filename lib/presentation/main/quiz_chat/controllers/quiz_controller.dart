import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:viteezy/core/models/quiz_model/enum.dart';
import 'package:viteezy/core/models/quiz_model/quiz_option_model.dart';
import 'package:viteezy/core/models/quiz_model/quiz_question_model.dart';
import 'package:viteezy/core/routes/app_routes.dart';
import 'package:viteezy/gen/assets.gen.dart';
import 'package:viteezy/presentation/main/recommendation/recommendation_controller.dart';
import 'package:viteezy/presentation/main/recommendation/recommendation_screen.dart';

class QuizController extends GetxController {
  RxInt currentIndex = 0.obs;
  RxMap<String, dynamic> answers = <String, dynamic>{}.obs;

  late List<QuizQuestionModel> questions;
  late PageController pageController;

  @override
  void onInit() {
    super.onInit();
    loadQuestions();
    pageController = PageController();

  }

  void jumpTo(int index) {
    if (index >= 0 && index < questions.length) {
      currentIndex.value = index;
    }
  }
  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void loadQuestions() {
    questions = [
      QuizQuestionModel(
        id: 'vitamins',
        question: 'How many vitamins do you take daily?',
        type: QuestionType.selection,
        selectionUiType: SelectionUiType.titleOnly,
        options: [
          QuizOptionModel(id: 'none', title: 'None'),
          QuizOptionModel(id: '1_3', title: '1 to 3'),
          QuizOptionModel(id: '4_plus', title: '4+'),
        ],
      ),
      QuizQuestionModel(
        id: 'goal',
        question: 'How can we help you?',
        type: QuestionType.selection,
        selectionUiType: SelectionUiType.iconTitleSubtitle,
        options: [
          QuizOptionModel(
            id: 'specific',
            title: 'A specific health goal',
            subtitle: 'You want to work on something',
            icon: Assets.icons.icSpecific.path,
          ),
          QuizOptionModel(
            id: 'overall',
            title: 'Overall health',
            subtitle: 'You want to take good care of yourself',
            icon: Assets.icons.icOverall.path,
          ),
          QuizOptionModel(
            id: 'discover',
            title: 'Discover',
            subtitle: 'You want to experience what vitamins can do for you',
            icon: Assets.icons.icDiscover.path,
          ),
        ],
      ),
      QuizQuestionModel(
        id: 'concerns',
        question: 'What are your Top 2 concerns?',
        subtitle: 'We ask you about 3 to 5 questions per goal',
        type: QuestionType.selection,
        selectionUiType: SelectionUiType.iconTitle,
        maxSelection: 2,
        options: [
          QuizOptionModel(
            id: 'sleep',
            title: 'Sleep',
            icon: Assets.icons.icSleepData.path,
          ),
          QuizOptionModel(
            id: 'stress',
            title: 'Stress',
            icon: Assets.icons.icStress.path,
          ),
          QuizOptionModel(
            id: 'energy',
            title: 'Energy',
            icon: Assets.icons.icEnergy.path,
          ),
          QuizOptionModel(
            id: 'gutproblems',
            title: 'Gut Problems',
            icon: Assets.icons.icGutProblems.path,
          ),
          QuizOptionModel(
            id: 'skin',
            title: 'Skin',
            icon: Assets.icons.icSkin.path,
          ),
          QuizOptionModel(
            id: 'resistance',
            title: 'Resistance',
            icon: Assets.icons.icResistance.path,
          ),
          QuizOptionModel(
            id: 'balanceissues',
            title: 'Balance Issues',
            icon: Assets.icons.icBalance.path,
          ),
          QuizOptionModel(
            id: 'libido',
            title: 'Libido',
            icon: Assets.icons.icLibido.path,
          ),
          QuizOptionModel(
            id: 'brain',
            title: 'Brain',
            icon: Assets.icons.icEnergy.path,
          ),
          QuizOptionModel(
            id: 'hairnails',
            title: 'Hair Nails',
            icon: Assets.icons.icBrainData.path,
          ),
          QuizOptionModel(
            id: 'fitness',
            title: 'Fitness',
            icon: Assets.icons.icHairNails.path,
          ),
        ],
      ),
      QuizQuestionModel(
        id: 'packs',
        question: 'Lastly, How would you like your packs to be?',
        subtitle:
            'Get them in one box of alternating morning and night packs or split them into day/night boxes.',
        type: QuestionType.selection,
        selectionUiType: SelectionUiType.imageTitle,
        options: [
          QuizOptionModel(
            id: 'one_sachet',
            title: 'One Sachet / Day',
            image: Assets.images.imgS.path,
          ),
          QuizOptionModel(
            id: 'Separate',
            title: 'Separate AM / PM Sachets',
            image: Assets.images.imgSeparate.path,
          ),
        ],
      ),
      QuizQuestionModel(
        id: 'name',
        question: 'What is your name?',
        subtitle: 'We will personalize your vitamin plan',
        type: QuestionType.text,
      ),
      QuizQuestionModel(
        id: 'birthday',
        question: 'When is your birthday?',
        subtitle: 'This helps us tailor recommendations for your age',
        type: QuestionType.date,
      ),
    ];
  }

  QuizQuestionModel get currentQuestion => questions[currentIndex.value];

  double get progress => (currentIndex.value + 1) / questions.length;

  bool isSelected(String questionId, String optionId) {
    final answer = answers[questionId];
    if (answer is List) {
      return answer.contains(optionId);
    }
    return answer == optionId;
  }

  int? selectionBadgeIndex(String questionId, String optionId) {
    final answer = answers[questionId];
    if (answer is List) {
      final index = answer.indexOf(optionId);
      return index >= 0 ? index + 1 : null;
    }
    return null;
  }

  void selectOption(String questionId, String optionId) {
    final question = _findQuestion(questionId);
    if (question == null) return;

    final maxSelection = question.maxSelection ?? 1;

    if (question.type == QuestionType.selection && maxSelection > 1) {
      final selected = List<String>.from(answers[questionId] ?? []);
      if (selected.contains(optionId)) {
        selected.remove(optionId);
      } else if (selected.length < maxSelection) {
        selected.add(optionId);
      }
      answers[questionId] = selected;
    } else {
      final previousAnswer = answers[questionId];
      if (previousAnswer != optionId && question.type == QuestionType.nested) {
        _clearNestedChildAnswers(question, previousAnswer?.toString());
      }
      answers[questionId] = optionId;
    }

    answers.refresh();
  }

  QuizOptionModel? selectedOption(String questionId) {
    final selectedId = answers[questionId];
    if (selectedId == null) return null;

    final question = _findQuestion(questionId);
    if (question?.options == null) return null;

    try {
      return question!.options!.firstWhere((e) => e.id == selectedId);
    } catch (_) {
      return null;
    }
  }

  void saveText(String questionId, String text) {
    answers[questionId] = text;
    answers.refresh();
  }

  void saveDate(String questionId, DateTime date) {
    answers[questionId] = date;
    answers.refresh();
  }

  String? textAnswer(String questionId) => answers[questionId] as String?;

  DateTime? dateAnswer(String questionId) => answers[questionId] as DateTime?;

  bool get canContinue => _isQuestionComplete(currentQuestion);

  bool _isQuestionComplete(QuizQuestionModel question) {
    final answer = answers[question.id];

    switch (question.type) {
      case QuestionType.selection:
        final max = question.maxSelection ?? 1;
        if (max > 1) {
          return (answer as List?)?.length == max;
        }
        return answer != null;

      case QuestionType.text:
        return (answer as String?)?.trim().isNotEmpty ?? false;

      case QuestionType.date:
        return answer != null;

      case QuestionType.nested:
        if (answer == null) return false;
        final option = selectedOption(question.id);
        if (option?.childQuestion != null) {
          return _isQuestionComplete(option!.childQuestion!);
        }
        return true;
    }
  }

/*  void next() {
    if (currentIndex.value < questions.length - 1) {
      currentIndex.value++;
    } else {
      submitQuiz();
    }
  }*/

  void next() {
    if (currentIndex.value < questions.length - 1) {
      currentIndex.value++;

      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Get.toNamed(AppRoutes.recommendation);
    }
  }
  // void next() {
  //   if (currentIndex.value < questions.length - 1) {
  //     currentIndex.value++;
  //
  //     pageController.nextPage(
  //       duration: const Duration(milliseconds: 300),
  //       curve: Curves.easeInOut,
  //     );
  //   } else {
  //     Get.put(RecommendationController());
  //
  //     Get.off(
  //           () => const RecommendationScreen(),
  //     );
  //   }
  // }

/*  void previous() {
    if (currentIndex.value > 0) {
      currentIndex.value--;
    } else {
      Get.back();
    }
  }*/
  void previous() {
    if (currentIndex.value > 0) {
      currentIndex.value--;

      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Get.back();
    }
  }

  void submitQuiz() {
    print(answers);
  }

  QuizQuestionModel? _findQuestion(String questionId) {
    for (final question in questions) {
      final found = _findQuestionRecursive(question, questionId);
      if (found != null) return found;
    }
    return null;
  }

  QuizQuestionModel? _findQuestionRecursive(
    QuizQuestionModel question,
    String questionId,
  ) {
    if (question.id == questionId) return question;
    for (final option in question.options ?? []) {
      if (option.childQuestion != null) {
        final found = _findQuestionRecursive(option.childQuestion!, questionId);
        if (found != null) return found;
      }
    }
    return null;
  }

  void _clearNestedChildAnswers(
    QuizQuestionModel question,
    String? previousOptionId,
  ) {
    if (previousOptionId == null) return;
    try {
      final prevOption = question.options!.firstWhere(
        (e) => e.id == previousOptionId,
      );
      _clearQuestionAnswers(prevOption.childQuestion);
    } catch (_) {}
  }

  void _clearQuestionAnswers(QuizQuestionModel? question) {
    if (question == null) return;
    answers.remove(question.id);
    for (final option in question.options ?? []) {
      _clearQuestionAnswers(option.childQuestion);
    }
  }
}

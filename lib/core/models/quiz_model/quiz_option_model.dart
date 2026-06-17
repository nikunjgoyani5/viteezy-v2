import 'quiz_question_model.dart';

class QuizOptionModel {
  final String id;
  final String title;
  final String? subtitle;
  final String? icon;
  final String? image;
  final QuizQuestionModel? childQuestion;

  const QuizOptionModel({
    required this.id,
    required this.title,
    this.subtitle,
    this.icon,
    this.image,
    this.childQuestion,
  });

  factory QuizOptionModel.fromJson(Map<String, dynamic> json) {
    return QuizOptionModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString(),
      icon: json['icon']?.toString(),
      image: json['image']?.toString(),
      childQuestion: json['child_question'] != null
          ? QuizQuestionModel.fromJson(json['child_question'])
          : null,
    );
  }
}

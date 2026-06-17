import 'enum.dart';
import 'quiz_option_model.dart';

class QuizQuestionModel {
  final String id;
  final String question;
  final String? subtitle;
  final QuestionType type;
  final SelectionUiType? selectionUiType;
  final int? maxSelection;
  final List<QuizOptionModel>? options;

  const QuizQuestionModel({
    required this.id,
    required this.question,
    this.subtitle,
    required this.type,
    this.selectionUiType,
    this.maxSelection,
    this.options,
  });

  factory QuizQuestionModel.fromJson(Map<String, dynamic> json) {
    final options = json['options'] != null
        ? List<QuizOptionModel>.from(
            (json['options'] as List).map((e) => QuizOptionModel.fromJson(e)),
          )
        : null;

    final inferredUiType = options != null
        ? _inferSelectionUiType(options)
        : null;

    return QuizQuestionModel(
      id: json['id']?.toString() ?? '',
      question: json['question']?.toString() ?? '',
      subtitle: json['subtitle']?.toString(),
      type: _parseQuestionType(json['type']),
      selectionUiType: json['selection_ui_type'] != null
          ? _parseSelectionUiType(json['selection_ui_type'])
          : inferredUiType,
      maxSelection: json['max_selection'] as int?,
      options: options,
    );
  }

  static QuestionType _parseQuestionType(dynamic value) {
    final type = value?.toString().toLowerCase() ?? '';
    switch (type) {
      case 'text':
        return QuestionType.text;
      case 'date':
        return QuestionType.date;
      case 'nested':
        return QuestionType.nested;
      default:
        return QuestionType.selection;
    }
  }

  static SelectionUiType _parseSelectionUiType(dynamic value) {
    final type = value?.toString().toLowerCase() ?? '';
    switch (type) {
      case 'icon_title':
        return SelectionUiType.iconTitle;
      case 'icon_title_subtitle':
        return SelectionUiType.iconTitleSubtitle;
      case 'image_title':
        return SelectionUiType.imageTitle;
      default:
        return SelectionUiType.titleOnly;
    }
  }

  static SelectionUiType _inferSelectionUiType(List<QuizOptionModel> options) {
    if (options.any((o) => o.image != null)) {
      return SelectionUiType.imageTitle;
    }
    if (options.any((o) => o.icon != null && o.subtitle != null)) {
      return SelectionUiType.iconTitleSubtitle;
    }
    if (options.any((o) => o.icon != null)) {
      return SelectionUiType.iconTitle;
    }
    return SelectionUiType.titleOnly;
  }
}

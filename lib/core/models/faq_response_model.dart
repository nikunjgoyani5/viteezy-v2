class FaqResponseModel {
  bool? success;
  String? message;
  FaqResponseData? data;

  FaqResponseModel({this.success, this.message, this.data});

  FaqResponseModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? FaqResponseData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = success;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class FaqResponseData {
  List<FaqCategoryWithFaqs>? categories;

  FaqResponseData({this.categories});

  FaqResponseData.fromJson(Map<String, dynamic> json) {
    if (json['categories'] != null) {
      categories = <FaqCategoryWithFaqs>[];
      json['categories'].forEach((v) {
        categories!.add(FaqCategoryWithFaqs.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (categories != null) {
      data['categories'] = categories!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class FaqCategoryWithFaqs {
  String? categoryId;
  String? categoryTitle;
  String? categorySlug;
  List<FaqItem>? faqs;

  FaqCategoryWithFaqs({
    this.categoryId,
    this.categoryTitle,
    this.categorySlug,
    this.faqs,
  });

  FaqCategoryWithFaqs.fromJson(Map<String, dynamic> json) {
    categoryId = json['categoryId'];
    categoryTitle = json['categoryTitle'];
    categorySlug = json['categorySlug'];
    if (json['faqs'] != null) {
      faqs = <FaqItem>[];
      json['faqs'].forEach((v) {
        faqs!.add(FaqItem.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['categoryId'] = categoryId;
    data['categoryTitle'] = categoryTitle;
    data['categorySlug'] = categorySlug;
    if (faqs != null) {
      data['faqs'] = faqs!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class FaqItem {
  String? id;
  String? question;
  String? answer;

  FaqItem({this.id, this.question, this.answer});

  FaqItem.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    question = json['question'];
    answer = json['answer'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = id;
    data['question'] = question;
    data['answer'] = answer;
    return data;
  }
}


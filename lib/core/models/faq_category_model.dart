class FaqCategoryModel {
  bool? success;
  String? message;
  FaqCategoryData? data;

  FaqCategoryModel({this.success, this.message, this.data});

  FaqCategoryModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? FaqCategoryData.fromJson(json['data']) : null;
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

class FaqCategoryData {
  List<FaqCategory>? categories;

  FaqCategoryData({this.categories});

  FaqCategoryData.fromJson(Map<String, dynamic> json) {
    if (json['categories'] != null) {
      categories = <FaqCategory>[];
      json['categories'].forEach((v) {
        categories!.add(FaqCategory.fromJson(v));
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

class FaqCategory {
  String? id;
  String? title;
  bool? isActive;
  String? slug;
  String? icon;
  int? articleCount;

  FaqCategory({this.id, this.title, this.isActive, this.slug, this.icon, this.articleCount});

  FaqCategory.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    title = json['title'];
    isActive = json['isActive'];
    slug = json['slug'];
    icon = json['icon'];
    articleCount = json['faqCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = id;
    data['title'] = title;
    data['isActive'] = isActive;
    data['slug'] = slug;
    data['icon'] = icon;
    return data;
  }
}

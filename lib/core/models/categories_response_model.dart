import 'dart:convert';

CategoriesModel categoriesModelFromJson(String str) => CategoriesModel.fromJson(json.decode(str));

String categoriesModelToJson(CategoriesModel data) => json.encode(data.toJson());

class CategoriesModel {
  bool? success;
  String? message;
  Categories? data;

  CategoriesModel({this.success, this.message, this.data});

  CategoriesModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? Categories.fromJson(json['data']) : null;
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

class Categories {
  List<Category>? categories;

  Categories({this.categories});

  Categories.fromJson(Map<String, dynamic> json) {
    if (json['categories'] != null) {
      categories = <Category>[];
      json['categories'].forEach((v) {
        categories!.add(Category.fromJson(v));
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

class Category {
  String? sId;
  String? slug;
  String? name;
  String? description;
  int? sortOrder;
  String? icon;
  Images? image;
  int? productCount;

  Category({
    this.sId,
    this.slug,
    this.name,
    this.description,
    this.sortOrder,
    this.icon,
    this.image,
    this.productCount,
  });

  Category.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    slug = json['slug'];
    name = json['name'];
    description = json['description'];
    sortOrder = json['sortOrder'];
    icon = json['icon'];
    image = json['image'] != null ? Images.fromJson(json['image']) : null;
    productCount = json['productCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['slug'] = slug;
    data['name'] = name;
    data['description'] = description;
    data['sortOrder'] = sortOrder;
    data['icon'] = icon;
    if (image != null) {
      data['image'] = image!.toJson();
    }
    data['productCount'] = productCount;
    return data;
  }
}

class Images {
  String? type;
  String? url;
  String? alt;
  int? sortOrder;

  Images({this.type, this.url, this.alt, this.sortOrder});

  Images.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    url = json['url'];
    // alt = json['alt'];
    sortOrder = json['sortOrder'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['type'] = type;
    data['url'] = url;
    if (alt != null) {
      data['alt'] = alt;
    }
    data['sortOrder'] = sortOrder;
    return data;
  }
}

class Alt {
  String? en;
  String? nl;

  Alt({this.en, this.nl});

  Alt.fromJson(Map<String, dynamic> json) {
    en = json['en'];
    nl = json['nl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['en'] = en;
    data['nl'] = nl;
    return data;
  }
}

// To parse this JSON data, do
//
//     final homeDataModel = homeDataModelFromJson(jsonString);

import 'dart:convert';

import 'package:viteezy/core/models/product_response_model.dart';

HomeDataModel homeDataModelFromJson(String str) => HomeDataModel.fromJson(json.decode(str));

String homeDataModelToJson(HomeDataModel data) => json.encode(data.toJson());

class HomeDataModel {
  bool? success;
  String? message;
  HomeData? data;

  HomeDataModel({this.success, this.message, this.data});

  factory HomeDataModel.fromJson(Map<String, dynamic> json) => HomeDataModel(
    success: json["success"],
    message: json["message"],
    data: json["data"] == null ? null : HomeData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {"success": success, "message": message, "data": data?.toJson()};
}

class HomeData {
  LandingPage? landingPage;
  String? language;

  HomeData({this.landingPage, this.language});

  factory HomeData.fromJson(Map<String, dynamic> json) => HomeData(
    landingPage: json["landingPage"] == null ? null : LandingPage.fromJson(json["landingPage"]),
    language: json["language"],
  );

  Map<String, dynamic> toJson() => {"landingPage": landingPage?.toJson(), "language": language};
}

class LandingPage {
  String? id;
  bool? isActive;
  List<String>? sectionOrder;
  DateTime? createdAt;
  DateTime? updatedAt;
  HeroSection? heroSection;
  MembershipSection? membershipSection;
  HowItWorksSection? howItWorksSection;
  Section? productCategorySection;
  CommunitySection? communitySection;
  Section? featuresSection;
  Section? designedByScienceSection;
  TestimonialsSection? testimonialsSection;
  Section? blogSection;
  Section? faqSection;

  LandingPage({
    this.id,
    this.isActive,
    this.sectionOrder,
    this.createdAt,
    this.updatedAt,
    this.heroSection,
    this.membershipSection,
    this.howItWorksSection,
    this.productCategorySection,
    this.communitySection,
    this.featuresSection,
    this.designedByScienceSection,
    this.testimonialsSection,
    this.blogSection,
    this.faqSection,
  });

  factory LandingPage.fromJson(Map<String, dynamic> json) => LandingPage(
    id: json["_id"],
    isActive: json["isActive"],
    sectionOrder: json["sectionOrder"] == null ? [] : List<String>.from(json["sectionOrder"]!.map((x) => x)),
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    heroSection: json["heroSection"] == null ? null : HeroSection.fromJson(json["heroSection"]),
    membershipSection: json["membershipSection"] == null ? null : MembershipSection.fromJson(json["membershipSection"]),
    howItWorksSection: json["howItWorksSection"] == null ? null : HowItWorksSection.fromJson(json["howItWorksSection"]),
    productCategorySection: json["productCategorySection"] == null
        ? null
        : Section.fromJson(json["productCategorySection"]),
    communitySection: json["communitySection"] == null ? null : CommunitySection.fromJson(json["communitySection"]),
    featuresSection: json["featuresSection"] == null ? null : Section.fromJson(json["featuresSection"]),
    designedByScienceSection: json["designedByScienceSection"] == null
        ? null
        : Section.fromJson(json["designedByScienceSection"]),
    testimonialsSection: json["testimonialsSection"] == null
        ? null
        : TestimonialsSection.fromJson(json["testimonialsSection"]),
    blogSection: json["blogSection"] == null ? null : Section.fromJson(json["blogSection"]),
    faqSection: json["faqSection"] == null ? null : Section.fromJson(json["faqSection"]),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "isActive": isActive,
    "sectionOrder": sectionOrder == null ? [] : List<dynamic>.from(sectionOrder!.map((x) => x)),
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "heroSection": heroSection?.toJson(),
    "membershipSection": membershipSection?.toJson(),
    "howItWorksSection": howItWorksSection?.toJson(),
    "productCategorySection": productCategorySection?.toJson(),
    "communitySection": communitySection?.toJson(),
    "featuresSection": featuresSection?.toJson(),
    "designedByScienceSection": designedByScienceSection?.toJson(),
    "testimonialsSection": testimonialsSection?.toJson(),
    "blogSection": blogSection?.toJson(),
    "faqSection": faqSection?.toJson(),
  };
}

class Section {
  String? title;
  String? description;
  List<Blog>? blogs;
  bool? isEnabled;
  int? order;
  List<Feature>? steps;
  List<Faq>? faqs;
  List<Feature>? features;
  List<ProductCategory>? productCategories;

  Section({
    this.title,
    this.description,
    this.blogs,
    this.isEnabled,
    this.order,
    this.steps,
    this.faqs,
    this.features,
    this.productCategories,
  });

  factory Section.fromJson(Map<String, dynamic> json) => Section(
    title: json["title"],
    description: json["description"],
    blogs: json["blogs"] == null ? [] : List<Blog>.from(json["blogs"]!.map((x) => Blog.fromJson(x))),
    isEnabled: json["isEnabled"],
    order: json["order"],
    steps: json["steps"] == null ? [] : List<Feature>.from(json["steps"]!.map((x) => Feature.fromJson(x))),
    faqs: json["faqs"] == null ? [] : List<Faq>.from(json["faqs"]!.map((x) => Faq.fromJson(x))),
    features: json["features"] == null ? [] : List<Feature>.from(json["features"]!.map((x) => Feature.fromJson(x))),
    productCategories: json["productCategories"] == null
        ? []
        : List<ProductCategory>.from(json["productCategories"]!.map((x) => ProductCategory.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "title": title,
    "description": description,
    "blogs": blogs == null ? [] : List<dynamic>.from(blogs!.map((x) => x.toJson())),
    "isEnabled": isEnabled,
    "order": order,
    "steps": steps == null ? [] : List<dynamic>.from(steps!.map((x) => x.toJson())),
    "faqs": faqs == null ? [] : List<dynamic>.from(faqs!.map((x) => x.toJson())),
    "features": features == null ? [] : List<dynamic>.from(features!.map((x) => x.toJson())),
    "productCategories": productCategories == null ? [] : List<dynamic>.from(productCategories!.map((x) => x.toJson())),
  };
}

class Blog {
  String? id;
  String? title;
  String? description;
  String? coverImage;
  Seo? seo;
  DateTime? createdAt;
  int? viewCount;

  Blog({this.id, this.title, this.description, this.coverImage, this.seo, this.createdAt, this.viewCount});

  factory Blog.fromJson(Map<String, dynamic> json) => Blog(
    id: json["_id"],
    title: json["title"],
    description: json["description"],
    coverImage: json["coverImage"],
    seo: json["seo"] == null ? null : Seo.fromJson(json["seo"]),
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    viewCount: json["viewCount"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "title": title,
    "description": description,
    "coverImage": coverImage,
    "seo": seo?.toJson(),
    "createdAt": createdAt?.toIso8601String(),
    "viewCount": viewCount,
  };
}

class Seo {
  String? metaTitle;
  String? metaSlug;
  String? metaDescription;

  Seo({this.metaTitle, this.metaSlug, this.metaDescription});

  factory Seo.fromJson(Map<String, dynamic> json) =>
      Seo(metaTitle: json["metaTitle"], metaSlug: json["metaSlug"], metaDescription: json["metaDescription"]);

  Map<String, dynamic> toJson() => {"metaTitle": metaTitle, "metaSlug": metaSlug, "metaDescription": metaDescription};
}

class Faq {
  String? question;
  String? answer;
  int? order;

  Faq({this.question, this.answer, this.order});

  factory Faq.fromJson(Map<String, dynamic> json) =>
      Faq(question: json["question"], answer: json["answer"], order: json["order"]);

  Map<String, dynamic> toJson() => {"question": question, "answer": answer, "order": order};
}

class Feature {
  String? image;
  String? title;
  String? description;
  int? order;
  String? icon;

  Feature({this.image, this.title, this.description, this.order, this.icon});

  factory Feature.fromJson(Map<String, dynamic> json) => Feature(
    image: json["image"],
    title: json["title"],
    description: json["description"],
    order: json["order"],
    icon: json["icon"],
  );

  Map<String, dynamic> toJson() => {
    "image": image,
    "title": title,
    "description": description,
    "order": order,
    "icon": icon,
  };
}

class ProductCategory {
  String? id;
  String? slug;
  String? name;
  String? description;
  int? sortOrder;
  String? icon;
  Image? image;
  int? productCount;

  ProductCategory({
    this.id,
    this.slug,
    this.name,
    this.description,
    this.sortOrder,
    this.icon,
    this.image,
    this.productCount,
  });

  factory ProductCategory.fromJson(Map<String, dynamic> json) => ProductCategory(
    id: json["_id"],
    slug: json["slug"],
    name: json["name"],
    description: json["description"],
    sortOrder: json["sortOrder"],
    icon: json["icon"],
    image: json["image"] == null ? null : Image.fromJson(json["image"]),
    productCount: json["productCount"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "slug": slug,
    "name": name,
    "description": description,
    "sortOrder": sortOrder,
    "icon": icon,
    "image": image?.toJson(),
    "productCount": productCount,
  };
}

class Image {
  String? type;
  String? url;
  int? sortOrder;

  Image({this.type, this.url, this.sortOrder});

  factory Image.fromJson(Map<String, dynamic> json) =>
      Image(type: json["type"], url: json["url"], sortOrder: json["sortOrder"]);

  Map<String, dynamic> toJson() => {"type": type, "url": url, "sortOrder": sortOrder};
}

class CommunitySection {
  String? backgroundImage;
  String? title;
  String? subTitle;
  List<Metric>? metrics;
  bool? isEnabled;
  int? order;

  CommunitySection({this.backgroundImage, this.title, this.subTitle, this.metrics, this.isEnabled, this.order});

  factory CommunitySection.fromJson(Map<String, dynamic> json) => CommunitySection(
    backgroundImage: json["backgroundImage"],
    title: json["title"],
    subTitle: json["subTitle"],
    metrics: json["metrics"] == null ? [] : List<Metric>.from(json["metrics"]!.map((x) => Metric.fromJson(x))),
    isEnabled: json["isEnabled"],
    order: json["order"],
  );

  Map<String, dynamic> toJson() => {
    "backgroundImage": backgroundImage,
    "title": title,
    "subTitle": subTitle,
    "metrics": metrics == null ? [] : List<dynamic>.from(metrics!.map((x) => x.toJson())),
    "isEnabled": isEnabled,
    "order": order,
  };
}

class Metric {
  String? label;
  String? value;
  int? order;

  Metric({this.label, this.value, this.order});

  factory Metric.fromJson(Map<String, dynamic> json) =>
      Metric(label: json["label"], value: json["value"], order: json["order"]);

  Map<String, dynamic> toJson() => {"label": label, "value": value, "order": order};
}

class HeroSection {
  String? videoUrl;
  String? backgroundImage;
  String? title;
  List<String>? highlightedText;
  String? subTitle;
  String? description;
  List<PrimaryCta>? primaryCta;
  bool? isEnabled;
  int? order;

  HeroSection({
    this.videoUrl,
    this.backgroundImage,
    this.title,
    this.highlightedText,
    this.subTitle,
    this.description,
    this.primaryCta,
    this.isEnabled,
    this.order,
  });

  factory HeroSection.fromJson(Map<String, dynamic> json) => HeroSection(
    videoUrl: json["videoUrl"],
    backgroundImage: json["backgroundImage"],
    title: json["title"],
    highlightedText: json["highlightedText"] == null ? [] : List<String>.from(json["highlightedText"]!.map((x) => x)),
    subTitle: json["subTitle"],
    description: json["description"],
    primaryCta: json["primaryCTA"] == null
        ? []
        : List<PrimaryCta>.from(json["primaryCTA"]!.map((x) => PrimaryCta.fromJson(x))),
    isEnabled: json["isEnabled"],
    order: json["order"],
  );

  Map<String, dynamic> toJson() => {
    "videoUrl": videoUrl,
    "backgroundImage": backgroundImage,
    "title": title,
    "highlightedText": highlightedText == null ? [] : List<dynamic>.from(highlightedText!.map((x) => x)),
    "subTitle": subTitle,
    "description": description,
    "primaryCTA": primaryCta == null ? [] : List<dynamic>.from(primaryCta!.map((x) => x.toJson())),
    "isEnabled": isEnabled,
    "order": order,
  };
}

class PrimaryCta {
  String? label;
  String? image;
  String? link;
  int? order;

  PrimaryCta({this.label, this.image, this.link, this.order});

  factory PrimaryCta.fromJson(Map<String, dynamic> json) =>
      PrimaryCta(label: json["label"], image: json["image"], link: json["link"], order: json["order"]);

  Map<String, dynamic> toJson() => {"label": label, "image": image, "link": link, "order": order};
}

class HowItWorksSection {
  String? title;
  String? subTitle;
  int? stepsCount;
  List<Feature>? steps;
  bool? isEnabled;
  int? order;

  HowItWorksSection({this.title, this.subTitle, this.stepsCount, this.steps, this.isEnabled, this.order});

  factory HowItWorksSection.fromJson(Map<String, dynamic> json) => HowItWorksSection(
    title: json["title"],
    subTitle: json["subTitle"],
    stepsCount: json["stepsCount"],
    steps: json["steps"] == null ? [] : List<Feature>.from(json["steps"]!.map((x) => Feature.fromJson(x))),
    isEnabled: json["isEnabled"],
    order: json["order"],
  );

  Map<String, dynamic> toJson() => {
    "title": title,
    "subTitle": subTitle,
    "stepsCount": stepsCount,
    "steps": steps == null ? [] : List<dynamic>.from(steps!.map((x) => x.toJson())),
    "isEnabled": isEnabled,
    "order": order,
  };
}

class MembershipSection {
  String? backgroundImage;
  String? title;
  String? description;
  List<Feature>? benefits;
  bool? isEnabled;
  int? order;

  MembershipSection({this.backgroundImage, this.title, this.description, this.benefits, this.isEnabled, this.order});

  factory MembershipSection.fromJson(Map<String, dynamic> json) => MembershipSection(
    backgroundImage: json["backgroundImage"],
    title: json["title"],
    description: json["description"],
    benefits: json["benefits"] == null ? [] : List<Feature>.from(json["benefits"]!.map((x) => Feature.fromJson(x))),
    isEnabled: json["isEnabled"],
    order: json["order"],
  );

  Map<String, dynamic> toJson() => {
    "backgroundImage": backgroundImage,
    "title": title,
    "description": description,
    "benefits": benefits == null ? [] : List<dynamic>.from(benefits!.map((x) => x.toJson())),
    "isEnabled": isEnabled,
    "order": order,
  };
}

class TestimonialsSection {
  String? title;
  String? subTitle;
  List<Testimonial>? testimonials;
  bool? isEnabled;
  int? order;

  TestimonialsSection({this.title, this.subTitle, this.testimonials, this.isEnabled, this.order});

  factory TestimonialsSection.fromJson(Map<String, dynamic> json) => TestimonialsSection(
    title: json["title"],
    subTitle: json["subTitle"],
    testimonials: json["testimonials"] == null
        ? []
        : List<Testimonial>.from(json["testimonials"]!.map((x) => Testimonial.fromJson(x))),
    isEnabled: json["isEnabled"],
    order: json["order"],
  );

  Map<String, dynamic> toJson() => {
    "title": title,
    "subTitle": subTitle,
    "testimonials": testimonials == null ? [] : List<dynamic>.from(testimonials!.map((x) => x)),
    "isEnabled": isEnabled,
    "order": order,
  };
}

class Testimonial {
  String? id;
  String? videoUrl;
  String? videoThumbnail;
  List<Product>? products;
  bool? isFeatured;
  int? displayOrder;

  Testimonial({this.id, this.videoUrl, this.videoThumbnail, this.products, this.isFeatured, this.displayOrder});

  factory Testimonial.fromJson(Map<String, dynamic> json) => Testimonial(
    id: json["_id"],
    videoUrl: json["videoUrl"],
    videoThumbnail: json["videoThumbnail"],
    products: json["products"] == null ? [] : List<Product>.from(json["products"]!.map((x) => Product.fromJson(x))),
    isFeatured: json["isFeatured"],
    displayOrder: json["displayOrder"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "videoUrl": videoUrl,
    "videoThumbnail": videoThumbnail,
    "products": products == null ? [] : List<dynamic>.from(products!.map((x) => x.toJson())),
    "isFeatured": isFeatured,
    "displayOrder": displayOrder,
  };
}

class TestimonialProduct {
  String? id;
  String? title;
  String? slug;

  TestimonialProduct({this.id, this.title, this.slug});

  factory TestimonialProduct.fromJson(Map<String, dynamic> json) =>
      TestimonialProduct(id: json["_id"], title: json["title"], slug: json["slug"]);

  Map<String, dynamic> toJson() => {"_id": id, "title": title, "slug": slug};
}

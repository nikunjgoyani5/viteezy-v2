// To parse this JSON data, do
//
//     final generalSettingsModel = generalSettingsModelFromJson(jsonString);

import 'dart:convert';

GeneralSettingsModel generalSettingsModelFromJson(String str) => GeneralSettingsModel.fromJson(json.decode(str));

String generalSettingsModelToJson(GeneralSettingsModel data) => json.encode(data.toJson());

class GeneralSettingsModel {
  bool? success;
  String? message;
  GeneralSettingsData? data;

  GeneralSettingsModel({this.success, this.message, this.data});

  factory GeneralSettingsModel.fromJson(Map<String, dynamic> json) => GeneralSettingsModel(
    success: json["success"],
    message: json["message"],
    data: json["data"] == null ? null : GeneralSettingsData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {"success": success, "message": message, "data": data?.toJson()};
}

class GeneralSettingsData {
  Settings? settings;

  GeneralSettingsData({this.settings});

  factory GeneralSettingsData.fromJson(Map<String, dynamic> json) =>
      GeneralSettingsData(settings: json["settings"] == null ? null : Settings.fromJson(json["settings"]));

  Map<String, dynamic> toJson() => {"settings": settings?.toJson()};
}

class Settings {
  String? id;
  String? logoLight;
  String? logoDark;
  String? tagline;
  String? supportEmail;
  String? supportPhone;
  // Address? address;
  String? address;
  List<Language>? languages;
  SocialMedia? socialMedia;
  DateTime? createdAt;
  DateTime? updatedAt;

  Settings({
    this.id,
    this.logoLight,
    this.logoDark,
    this.tagline,
    this.supportEmail,
    this.supportPhone,
    this.address,
    this.languages,
    this.socialMedia,
    this.createdAt,
    this.updatedAt,
  });

  // Default values from the provided JSON
  factory Settings.defaultValues() => Settings(
    id: "692d8382c561872809254c54",
    logoLight:
        "https://guardianshot.blr1.digitaloceanspaces.com/viteezy-phase-2/general-settings/logos/2025-12-01/eddf356e-6ff5-4137-bd70-d4c5eff2c071.png",
    logoDark:
        "https://guardianshot.blr1.digitaloceanspaces.com/viteezy-phase-2/general-settings/logos/2025-12-01/24e89411-74c3-46ae-bd1a-2597c4006e66.png",
    tagline: "here's the tagline",
    supportEmail: "support@viteezy.com",
    supportPhone: "+91 7069482828",
    address: "",
    languages: [
      Language(code: "EN", name: "English", isEnabled: true),
      Language(code: "NL", name: "Dutch", isEnabled: true),
      Language(code: "DE", name: "German", isEnabled: false),
      Language(code: "FR", name: "French", isEnabled: false),
      Language(code: "ES", name: "Spanish", isEnabled: false),
    ],
    socialMedia: SocialMedia.defaultValues(),
    createdAt: DateTime.parse("2025-12-01T12:01:06.740Z"),
    updatedAt: DateTime.parse("2025-12-30T05:03:39.473Z"),
  );

  factory Settings.fromJson(Map<String, dynamic> json) => Settings(
    id: json["_id"],
    logoLight: json["logoLight"],
    logoDark: json["logoDark"],
    tagline: json["tagline"],
    supportEmail: json["supportEmail"],
    supportPhone: json["supportPhone"],
    address: json["address"],
    languages: json["languages"] == null
        ? []
        : List<Language>.from(json["languages"]!.map((x) => Language.fromJson(x))),
    socialMedia: json["socialMedia"] == null ? null : SocialMedia.fromJson(json["socialMedia"]),
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "logoLight": logoLight,
    "logoDark": logoDark,
    "tagline": tagline,
    "supportEmail": supportEmail,
    "supportPhone": supportPhone,
    "address": address,
    "languages": languages == null ? [] : List<dynamic>.from(languages!.map((x) => x.toJson())),
    "socialMedia": socialMedia?.toJson(),
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
  };
}

class Address {
  String? street;
  String? city;
  String? state;
  String? zip;
  String? country;
  String? addressLine1;
  String? addressLine2;

  Address({this.street, this.city, this.state, this.zip, this.country, this.addressLine1, this.addressLine2});

  factory Address.defaultValues() => Address(
    street: "street",
    city: "surat",
    state: "state",
    zip: "zip",
    country: "india",
    addressLine1: "China",
    addressLine2: "China",
  );

  factory Address.fromJson(Map<String, dynamic> json) => Address(
    street: json["street"],
    city: json["city"],
    state: json["state"],
    zip: json["zip"],
    country: json["country"],
    addressLine1: json["addressLine1"],
    addressLine2: json["addressLine2"],
  );

  Map<String, dynamic> toJson() => {
    "street": street,
    "city": city,
    "state": state,
    "zip": zip,
    "country": country,
    "addressLine1": addressLine1,
    "addressLine2": addressLine2,
  };
}

class Language {
  String? code;
  String? name;
  bool? isEnabled;

  Language({this.code, this.name, this.isEnabled});

  factory Language.fromJson(Map<String, dynamic> json) =>
      Language(code: json["code"], name: json["name"], isEnabled: json["isEnabled"]);

  Map<String, dynamic> toJson() => {"code": code, "name": name, "isEnabled": isEnabled};
}

class SocialMedia {
  String? facebook;
  String? instagram;
  String? youtube;
  String? linkedin;
  String? tiktok;

  SocialMedia({this.facebook, this.instagram, this.youtube, this.linkedin, this.tiktok});

  factory SocialMedia.defaultValues() => SocialMedia(
    facebook: "https://www.facebook.com/",
    instagram: "https://www.instagram.com/",
    youtube: "https://www.youtube.com",
    linkedin: "https://in.linkedin.com/",
    tiktok: "https://www.tiktok.com",
  );

  factory SocialMedia.fromJson(Map<String, dynamic> json) => SocialMedia(
    facebook: json["facebook"],
    instagram: json["instagram"],
    youtube: json["youtube"],
    linkedin: json["linkedin"],
    tiktok: json["tiktok"],
  );

  Map<String, dynamic> toJson() => {
    "facebook": facebook,
    "instagram": instagram,
    "youtube": youtube,
    "linkedin": linkedin,
    "tiktok": tiktok,
  };
}

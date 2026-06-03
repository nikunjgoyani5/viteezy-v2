// To parse this JSON data, do
//
//     final userModel = userModelFromJson(jsonString);

import 'dart:convert';

UserModel userModelFromJson(String str) => UserModel.fromJson(json.decode(str));

String userModelToJson(UserModel data) => json.encode(data.toJson());

class UserModel {
  bool? success;
  String? message;
  UserData? data;

  UserModel({
    this.success,
    this.message,
    this.data,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    success: json["success"],
    message: json["message"],
    data: json["data"] == null ? null : UserData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data?.toJson(),
  };
}

class UserData {
  User? user;

  UserData({
    this.user,
  });

  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
    user: json["user"] == null ? null : User.fromJson(json["user"]),
  );

  Map<String, dynamic> toJson() => {
    "user": user?.toJson(),
  };
}

class User {
  dynamic phone;
  dynamic countryCode;
  String? language;
  String? registeredAt;
  String? id;

  String? email;
  String? role;
  bool? isActive;
  bool? isEmailVerified;
  dynamic avatar;
  dynamic profileImage;
  dynamic gender;
  dynamic age;
  String? memberId;
  bool? isMember;
  String? membershipStatus;
  String? lastLogin;
  List<SessionId>? sessionIds;
  String? createdAt;
  String? updatedAt;
  int? v;
  String? membershipActivatedAt;
  String? membershipExpiresAt;
  String? membershipPlanId;
  String? userId;
  String? firstName;
  String? lastName;
  String? name;
  bool? isSubMember;
  String? parentMemberId;
  String? parentId;
  String? relationshipToParent;
  bool? isDeleted;
  String? deletedAt;
  String? refrelCode;

  User({
    this.phone,
    this.countryCode,
    this.language,
    this.registeredAt,
    this.id,

    this.firstName,
    this.email,
    this.role,
    this.isActive,
    this.isEmailVerified,
    this.avatar,
    this.profileImage,
    this.gender,
    this.age,
    this.memberId,
    this.isMember,
    this.membershipStatus,
    this.lastLogin,
    this.sessionIds,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.membershipActivatedAt,
    this.membershipExpiresAt,
    this.membershipPlanId,
    this.userId,
    this.lastName,
    this.name,
    this.isSubMember,
    this.parentMemberId,
    this.parentId,
    this.relationshipToParent,
    this.isDeleted,
    this.deletedAt,
    this.refrelCode,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    phone: json["phone"],
    countryCode: json["countryCode"],
    language: json["language"],
    registeredAt: json["registeredAt"],
    id: json["_id"],

    email: json["email"],
    firstName: json["firstName"],
    lastName: json["lastName"],
    name: json["name"],
    isSubMember: json["isSubMember"],
    parentMemberId: json["parentMemberId"],
    parentId: json["parentId"],
    relationshipToParent: json["relationshipToParent"],
    isDeleted: json["isDeleted"],
    deletedAt: json["deletedAt"],
    refrelCode: json["referralCode"],

    role: json["role"],
    isActive: json["isActive"],
    isEmailVerified: json["isEmailVerified"],
    avatar: json["avatar"],
    profileImage: json["profileImage"],
    gender: json["gender"],
    age: json["age"],
    memberId: json["memberId"],
    isMember: json["isMember"],
    membershipStatus: json["membershipStatus"],
    lastLogin: json["lastLogin"],
    sessionIds: json["sessionIds"] == null ? [] : List<SessionId>.from(json["sessionIds"]!.map((x) => SessionId.fromJson(x))),
    createdAt: json["createdAt"],
    updatedAt: json["updatedAt"],
    v: json["__v"],
    membershipActivatedAt: json["membershipActivatedAt"],
    membershipExpiresAt: json["membershipExpiresAt"],
    membershipPlanId: json["membershipPlanId"],
    userId: json["id"],
  );

  Map<String, dynamic> toJson() => {
    "phone": phone,
    "countryCode": countryCode,
    "language": language,
    "registeredAt": registeredAt,
    "_id": id,
    "lastName": lastName,
    "firstName": firstName,
    "name": name,
    "isSubMember": isSubMember,
    "parentMemberId": parentMemberId,
    "parentId": parentId,
    "relationshipToParent": relationshipToParent,
    "isDeleted": isDeleted,
    "deletedAt": deletedAt,
    "refrelCode": refrelCode,

    "email": email,
    "role": role,
    "isActive": isActive,
    "isEmailVerified": isEmailVerified,
    "avatar": avatar,
    "profileImage": profileImage,
    "gender": gender,
    "age": age,
    "memberId": memberId,
    "isMember": isMember,
    "membershipStatus": membershipStatus,
    "lastLogin": lastLogin,
    "sessionIds": sessionIds == null ? [] : List<dynamic>.from(sessionIds!.map((x) => x.toJson())),
    "createdAt": createdAt,
    "updatedAt": updatedAt,
    "__v": v,
    "membershipActivatedAt": membershipActivatedAt,
    "membershipExpiresAt": membershipExpiresAt,
    "membershipPlanId": membershipPlanId,
    "id": userId,
  };
}

class SessionId {
  String? sessionId;
  String? status;
  bool? revoked;
  String? deviceInfo;
  String? id;
  String? sessionIdId;

  SessionId({
    this.sessionId,
    this.status,
    this.revoked,
    this.deviceInfo,
    this.id,
    this.sessionIdId,
  });

  factory SessionId.fromJson(Map<String, dynamic> json) => SessionId(
    sessionId: json["sessionId"],
    status: json["status"],
    revoked: json["revoked"],
    deviceInfo: json["deviceInfo"],
    id: json["_id"],
    sessionIdId: json["id"],
  );

  Map<String, dynamic> toJson() => {
    "sessionId": sessionId,
    "status": status,
    "revoked": revoked,
    "deviceInfo": deviceInfo,
    "_id": id,
    "id": sessionIdId,
  };
}

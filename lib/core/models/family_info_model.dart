class FamilyInfoModel {
  final bool success;
  final String message;
  final FamilyInfoData data;

  FamilyInfoModel({required this.success, required this.message, required this.data});

  factory FamilyInfoModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    return FamilyInfoModel(
      success: json['success'] == true,
      message: (json['message'] ?? '').toString(),
      data: FamilyInfoData.fromJson(
        rawData is Map ? Map<String, dynamic>.from(rawData) : <String, dynamic>{},
      ),
    );
  }
}

class FamilyInfoData {
  final String role;
  final FamilyMember? mainMember;
  final List<FamilyMember> subMembers;

  FamilyInfoData({required this.role, required this.mainMember, required this.subMembers});

  factory FamilyInfoData.fromJson(Map<String, dynamic> json) {
    final rawSubMembers = (json['subMembers'] as List?) ?? <dynamic>[];
    final rawMainMember = json['mainMember'];

    return FamilyInfoData(
      role: (json['role'] ?? '').toString(),
      mainMember: rawMainMember is Map
          ? FamilyMember.fromJson(Map<String, dynamic>.from(rawMainMember))
          : null,
      subMembers: rawSubMembers
          .where((item) => item is Map)
          .map((item) => FamilyMember.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList(),
    );
  }
}

class FamilyMember {
  final String id;
  final String name;
  final String firstName;
  final String lastName;
  final String email;
  final String memberId;
  final String relationshipToParent;

  FamilyMember({
    required this.id,
    required this.name,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.memberId,
    required this.relationshipToParent,
  });

  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    final firstName = (json['firstName'] ?? '').toString();
    final lastName = (json['lastName'] ?? '').toString();
    final combinedName = '$firstName $lastName'.trim();

    return FamilyMember(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? combinedName).toString(),
      firstName: firstName,
      lastName: lastName,
      email: (json['email'] ?? '').toString(),
      memberId: (json['memberId'] ?? '').toString(),
      relationshipToParent: (json['relationshipToParent'] ?? '').toString(),
    );
  }
}

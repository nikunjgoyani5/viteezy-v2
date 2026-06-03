class SubMember {
  final String id;
  final String? firstName;
  final String? lastName;
  final String? memberId;
  final String? email;

  SubMember({
    required this.id,
    this.firstName,
    this.lastName,
    this.memberId,
    this.email,
  });

  factory SubMember.fromJson(Map<String, dynamic> json) => SubMember(
        id: json['_id']?.toString() ?? '',
        firstName: json['firstName']?.toString(),
        lastName: json['lastName']?.toString(),
        memberId: json['memberId']?.toString(),
        email: json['email']?.toString(),
      );

  String get displayLabel {
    final name = '${firstName ?? ''} ${lastName ?? ''}'.trim();
    final mid = memberId ?? '';
    if (name.isNotEmpty && mid.isNotEmpty) return '$name ($mid)';
    if (name.isNotEmpty) return name;
    if (mid.isNotEmpty) return mid;
    return email ?? id;
  }
}

class AddressModel {
  final String id;
  final String name;
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final String email;
  final String phone;
  final bool isHomeAddress;

  AddressModel({
    required this.id,
    required this.name,
    required this.addressLine1,
    required this.addressLine2,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    required this.email,
    required this.phone,
    this.isHomeAddress = true,
  });

  String get fullAddress => '$addressLine1, $postalCode $city, $country';
  String get stateAndPostal => '$state $postalCode';
}


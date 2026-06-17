class SupplementModel {
  String name;
  String desc;
  double price;
  int quantity;

  SupplementModel({
    required this.name,
    required this.desc,
    required this.price,
    this.quantity = 2,
  });
}
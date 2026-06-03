class CartItemModel {
  final String id;
  final String productName;
  final String productImage;
  final String packInfo;
  final double currentPrice;
  final double originalPrice;
  final double membershipDiscount;
  final int quantity;

  CartItemModel({
    required this.id,
    required this.productName,
    required this.productImage,
    required this.packInfo,
    required this.currentPrice,
    required this.originalPrice,
    this.membershipDiscount = 0.0,
    this.quantity = 1,
  });

  double get totalPrice => (currentPrice * quantity) - (membershipDiscount * quantity);
}


class PackagingOption {
  final String title;
  final int capsules;
  final double? monthlyPrice;
  final double totalPrice;
  final String? period;
  final int? savePercentage;
  final bool hasFreeShipping;
  final bool canBeCancelled;
  final bool isTrustedByMostUsers;
  final bool isOneTimePurchase;

  PackagingOption({
    required this.title,
    required this.capsules,
    this.monthlyPrice,
    required this.totalPrice,
    this.period,
    this.savePercentage,
    this.hasFreeShipping = false,
    this.canBeCancelled = false,
    this.isTrustedByMostUsers = false,
    this.isOneTimePurchase = false,
  });
}


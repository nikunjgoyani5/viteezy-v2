import 'package:get/get.dart';
import 'package:viteezy/core/models/supply/supply_model.dart';


class RecommendationController extends GetxController {
  RxInt selectedTab = 1.obs;

  RxBool quarterlyAdded = false.obs;

  final supplements = <SupplementModel>[
    SupplementModel(
      name: "Energy Assistant",
      desc: "Contributes to Normal Energy",
      price: 13,
    ),
    SupplementModel(
      name: "Stress Less",
      desc: "Contributes to Normal Energy",
      price: 13,
    ),
    SupplementModel(
      name: "Vitamin D3 + K2",
      desc: "Contributes to Normal Energy",
      price: 13,
    ),
  ].obs;

  void increase(int index) {
    supplements[index].quantity++;
    supplements.refresh();
  }

  void decrease(int index) {
    if (supplements[index].quantity > 1) {
      supplements[index].quantity--;
      supplements.refresh();
    }
  }

  double get total {
    double sum = 0;

    for (var item in supplements) {
      sum += item.price;
    }

    return sum;
  }
}
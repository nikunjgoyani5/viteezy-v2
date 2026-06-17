import 'package:get/get.dart';
import 'package:viteezy/presentation/main/recommendation/recommendation_controller.dart';


class RecommendationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RecommendationController>(() => RecommendationController());
  }
}
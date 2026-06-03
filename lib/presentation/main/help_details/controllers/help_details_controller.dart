import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:viteezy/core/exceptions/app_exception.dart';
import 'package:viteezy/core/models/api_response.dart';
import 'package:viteezy/core/models/faq_response_model.dart';
import 'package:viteezy/core/repositories/profile_repository.dart';

class HelpDetailsController extends GetxController {
  ProfileRepository profileRepository = ProfileRepository();

  RxBool isLoading = false.obs;
  RxBool hasError = false.obs;
  String errorMessage = '';

  String categoryTitle = '';

  List<FaqItem> faqs = [];
  FaqItem? selectedFaq;
  bool showFaqDetail = false;

  @override
  void onInit() {
    super.onInit();
    // Get category info from arguments
    final arguments = Get.arguments;
    categoryTitle = arguments?['categoryTitle'] ?? '';

    if (categoryTitle.isNotEmpty) {
      getFaqsByCategory();
    }
  }

  Future<void> getFaqsByCategory() async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage = '';
    update();

    await profileRepository.getFaqsByCategory(
      data: {"category": categoryTitle},
      onSuccess: (ApiResponse response) {
        try {
          isLoading.value = false;
          hasError.value = false;
          final faqResponseModel = FaqResponseModel.fromJson(response.toJson());
          if (faqResponseModel.data?.categories != null && faqResponseModel.data!.categories!.isNotEmpty) {
            final categoryData = faqResponseModel.data!.categories![0];
            categoryTitle = categoryData.categoryTitle ?? categoryTitle;
            faqs = categoryData.faqs ?? [];
          } else {
            faqs = [];
          }
          update();
        } catch (e) {
          isLoading.value = false;
          hasError.value = true;
          errorMessage = 'Failed to load FAQs';
          debugPrint('error:::${e.toString()} ');
          update();
        }
      },
      onError: (AppException error) {
        isLoading.value = false;
        hasError.value = true;
        errorMessage = error.message;
        debugPrint('error:::${error.message} ');
        update();
      },
    );
  }

  void selectFaq(FaqItem faq) {
    selectedFaq = faq;
    showFaqDetail = true;
    update();
  }

  void goBackToList() {
    showFaqDetail = false;
    selectedFaq = null;
    update();
  }
}

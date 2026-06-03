import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:viteezy/core/exceptions/app_exception.dart';
import 'package:viteezy/core/models/api_response.dart';
import 'package:viteezy/core/models/faq_category_model.dart';
import 'package:viteezy/core/repositories/profile_repository.dart';
import 'package:viteezy/gen/assets.gen.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_functions.dart';

class HelpCategory {
  final String id;
  final String title;
  final String subtitle;
  final String? iconUrl; // Network image URL
  final String? iconName; // Local asset path (fallback)
  final String? slug; // Category slug for API calls
  final int articleCount;

  HelpCategory({
    required this.id,
    required this.title,
    required this.subtitle,
    this.iconUrl,
    this.iconName,
    this.slug,
    required this.articleCount,
  });

  // Factory constructor to create from FaqCategory
  factory HelpCategory.fromFaqCategory(FaqCategory faqCategory) {
    return HelpCategory(
      id: faqCategory.id ?? '',
      title: faqCategory.title ?? '',
      subtitle: '0 articles',
      // Default since API doesn't provide article count
      iconUrl: faqCategory.icon,
      slug: faqCategory.slug,
      articleCount: faqCategory.articleCount ?? 0,
    );
  }
}

class HelpCenterController extends GetxController {
  TextEditingController searchController = TextEditingController();
  List<HelpCategory> categories = [];
  List<HelpCategory> filteredCategories = [];
  RxBool isLoading = false.obs;
  RxBool hasError = false.obs;
  String errorMessage = '';

  ProfileRepository profileRepository = ProfileRepository();

  @override
  void onInit() {
    super.onInit();
    getFaqCategory();
  }

  void searchCategories(String query) {
    if (query.isEmpty) {
      filteredCategories = categories;
    } else {
      filteredCategories = categories
          .where(
            (category) =>
                category.title.toLowerCase().contains(query.toLowerCase()) ||
                category.subtitle.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    }
    update();
  }

  Future<void> getFaqCategory() async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage = '';
    update();

    await profileRepository.getFaqCategory(
      data: {if (searchController.text.isNotEmpty) "title": searchController.text},
      onSuccess: (ApiResponse response) {
        try {
          isLoading.value = false;
          hasError.value = false;

          // Parse the response
          final faqCategoryModel = FaqCategoryModel.fromJson(response.toJson());

          if (faqCategoryModel.data?.categories != null && faqCategoryModel.data!.categories!.isNotEmpty) {
            // Filter only active categories
            final activeCategories = faqCategoryModel.data!.categories!.where((cat) => cat.isActive == true).toList();

            // Convert FaqCategory to HelpCategory
            categories = activeCategories.map((faqCat) => HelpCategory.fromFaqCategory(faqCat)).toList();

            filteredCategories = categories;
          } else {
            categories = [];
            filteredCategories = [];
          }

          update();
        } catch (e) {
          isLoading.value = false;
          hasError.value = true;
          errorMessage = 'Failed to load categories';
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
        AppFunctions().showToast(error.message, bgColor: AppColors.red);
      },
    );
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}

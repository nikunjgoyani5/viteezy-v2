import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/models/api_response.dart';
import '../../../../core/models/product_response_model.dart';
import '../../../../core/repositories/product_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_functions.dart';
import '../../../../core/utils/app_prefrence.dart';

class BrowseController extends GetxController {
  final ProductRepository _productRepository = ProductRepository();
  // Search
  final TextEditingController searchController = TextEditingController();
  final RxBool isSearching = false.obs;
  Timer? _debounceTimer;

  // Categories
  final RxList<String> categories = [
    "Trending",
    'All Products',
    'Spices',
    'Minerals',
    'Specialties',
    'Vitamins',
  ].obs;
  final RxString selectedCategory = ''.obs;

  // Products
  final RxList<Product> products = <Product>[].obs;
  // Pagination for all products
  int currentPage = 1;
  final int limit = 10;
  bool hasMore = true;
  Pagination? pagination;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(_onSearchChanged);
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.onClose();
  }

  void _onSearchChanged() {
    final query = searchController.text.trim();
    isSearching.value = query.isNotEmpty;

    // Cancel previous timer
    _debounceTimer?.cancel();

    // If search is empty, show initial products
    if (query.isEmpty) {
      // Reset to initial products
      currentPage = 1;
      hasMore = true;
      getFeaturedProduct(isRefresh: true);
      return;
    }

    // Debounce search API call
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (query.isNotEmpty) {
        // Reset pagination for search
        currentPage = 1;
        hasMore = true;
        products.clear();
        // Call API with search parameter
        getProductByFilters(isRefresh: true, parms: {"search": query});
      }
    });
  }

  void selectCategory(String category) {
    if (category == selectedCategory.value) {
      return;
    }
    if (category != "Trending") {
      selectedCategory.value = category;
      // Clear products and show shimmer when category is selected
      products.clear();
      getProductByFilters(
        isRefresh: true,
        parms: {"categories": category, "search": searchController.text},
      );
    } else {
      selectedCategory.value = category;
      // Clear products and show shimmer when category is selected
      products.clear();
      getProductByFilters(
        isRefresh: true,
        parms: {"sort": "trending", "search": searchController.text},
      );
    }
  }

  /// Reset all browse state to initial values
  void resetBrowseState() {
    // Reset search
    searchController.clear();
    isSearching.value = false;
    _debounceTimer?.cancel();

    // Reset category
    selectedCategory.value = '';

    // Reset products and pagination
    products.clear();
    currentPage = 1;
    hasMore = true;
    pagination = null;
  }

  void getProductByFilters({
    bool isRefresh = false,
    Map<String, dynamic>? parms,
  }) {
    if (isRefresh) {
      currentPage = 1;
      hasMore = true;
    }

    if (!hasMore && !isRefresh) return;

    isLoading.value = products.isEmpty;
    isLoadingMore.value = !isRefresh && products.isNotEmpty;

    _productRepository.getProduct(
      page: currentPage,
      limit: limit,
      queryParams: parms ?? {"sort": "trending"},
      onSuccess: (data) {
        try {
          if (data.data != null) {
            ProductResponseModel productResponse;
            final productsList = (data.data as List)
                .map((x) {
                  try {
                    return Product.fromJson(x as Map<String, dynamic>);
                  } catch (e) {
                    print('Error parsing product: $e');
                    return null;
                  }
                })
                .whereType<Product>()
                .toList();
            productResponse = ProductResponseModel(
              success: data.success,
              message: data.message,
              data: productsList,
              pagination: data.pagination,
            );

            if (productResponse.data != null &&
                productResponse.data!.isNotEmpty) {
              final newProducts = productResponse.data!;

              if (isRefresh) {
                // On refresh, replace all products
                products.value = newProducts;
              } else {
                // On load more, append products
                products.addAll(newProducts);
              }

              // Update pagination
              pagination = productResponse.pagination;

              // Determine if there are more pages
              if (pagination != null) {
                hasMore = pagination!.hasNext ?? false;
              } else {
                // If no pagination info, assume hasMore based on the number of products received
                hasMore = newProducts.length >= limit;
              }

              if (hasMore) {
                currentPage++;
              }
            } else {
              hasMore = false;
            }
          } else {
            hasMore = false;
          }
        } catch (e, stackTrace) {
          log('Error parsing products: $e');
          log('Stack trace: $stackTrace');
          log('Data type: ${data.data?.runtimeType}');
          hasMore = false;
        } finally {
          isLoading.value = false;
          isLoadingMore.value = false;
        }
      },
      onError: (error) {
        isLoading.value = false;
        isLoadingMore.value = false;
        log('Error loading products: ${error.message}');
        AppFunctions().showToast(error.message, bgColor: AppColors.red);
      },
    );
  }

  void getFeaturedProduct({bool isRefresh = false}) {
    // Check if user is logged in before calling API
    final isLoggedIn =
        PrefService.getBool(PrefKeys.isLogin) &&
        PrefService.getString(PrefKeys.accessToken).isNotEmpty;
    if (!isLoggedIn) {
      return; // Don't call API if user is not logged in
    }

    if (isRefresh) {
      currentPage = 1;
      hasMore = true;
    }

    if (!hasMore && !isRefresh) return;

    isLoading.value = products.isEmpty;
    isLoadingMore.value = !isRefresh && products.isNotEmpty;

    _productRepository.getFeaturedProduct(
      onSuccess: (data) {
        try {
          if (data.data != null) {
            ProductResponseModel productResponse;
            final productsList = (data.data as List)
                .map((x) {
                  try {
                    return Product.fromJson(x as Map<String, dynamic>);
                  } catch (e) {
                    print('Error parsing product: $e');
                    return null;
                  }
                })
                .whereType<Product>()
                .toList();
            productResponse = ProductResponseModel(
              success: data.success,
              message: data.message,
              data: productsList,
              pagination: data.pagination,
            );

            if (productResponse.data != null &&
                productResponse.data!.isNotEmpty) {
              final newProducts = productResponse.data!;
              // Featured products are not paginated. Always replace the list to avoid duplicates
              // when this endpoint is called multiple times (e.g. tab switches / rebuilds).
              products.value = newProducts;
            }
          }
        } catch (e, stackTrace) {
          log('Error parsing products: $e');
          log('Stack trace: $stackTrace');
          log('Data type: ${data.data?.runtimeType}');
          hasMore = false;
        } finally {
          isLoading.value = false;
          isLoadingMore.value = false;
        }
      },
      onError: (error) {
        isLoading.value = false;
        isLoadingMore.value = false;
        log('Error loading products: ${error.message}');
        AppFunctions().showToast(error.message, bgColor: AppColors.red);
      },
    );
  }
}

import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/models/api_response.dart';
import '../../../../core/models/categories_response_model.dart';
import '../../../../core/models/filters_response_model.dart' hide Category;
import '../../../../core/models/product_response_model.dart';
import '../../../../core/models/product_review_response_model.dart';
import '../../../../core/repositories/cart_repository.dart';
import '../../../../core/repositories/product_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_functions.dart';
import '../../../../core/utils/app_prefrence.dart';
import '../../../../core/utils/dialog_service.dart';
import '../../../../core/routes/app_routes.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../wishlist/controllers/wishlist_controller.dart';
import '../views/health_goal_filter_sheet.dart';
import '../views/ingredient_filter_sheet.dart';
import '../views/product_type_filter_sheet.dart';
import '../views/shop_all_filter_bottom_sheet.dart';
import '../views/sort_by_filter_sheet.dart';

class ShopAllController extends GetxController {
  final ProductRepository _productRepository = ProductRepository();
  final CartRepository _cartRepository = CartRepository();
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;

  // Categories loaded from API
  RxList<Category>? categories = <Category>[].obs;
  final selectedCategory = 0.obs;

  // Pagination for all products
  int currentPage = 1;
  final int limit = 10;
  bool hasMore = true;
  Pagination? pagination;

  // Pagination for category products
  int categoryCurrentPage = 1;
  final int categoryLimit = 10;
  bool categoryHasMore = true;
  Pagination? categoryPagination;

  // Filter states
  RxList<String> selectedIngredients = <String>[].obs;
  RxList<String> selectedHealthGoals = <String>[].obs;
  RxList<String> selectedProductTypes = <String>[].obs;
  RxString selectedSortBy = 'relevance'.obs;
  RxString selectedSortByLabel = ''.obs;

  // Saved filter states (for restoring when coming back from category product view)
  List<String> _savedSelectedIngredients = [];
  List<String> _savedSelectedHealthGoals = [];
  List<String> _savedSelectedProductTypes = [];
  String _savedSelectedSortBy = 'relevance';

  final productTypeOptions = ['Stand-up pouch', 'Viteezy Sachets'];

  // Products loaded from API
  final products = <Product>[].obs;
  final categoryProducts = <Product>[].obs;
  FiltersData? filtersData;
  RxList<ProductReview>? productReviews = <ProductReview>[].obs;

  // Selected product detail
  final Rx<Product?> selectedProduct = Rx<Product?>(null);
  final RxBool isLoadingProductDetail = false.obs;

  // Favorite products (using String for product IDs)
  final favorites = <String>{}.obs;

  void getProductCategories() {
    isLoading.value = true;
    _productRepository.getProductCategories(
      onSuccess: (data) {
        try {
          if (data.data != null) {
            // ApiResponse.data already contains the inner "data" object: { "categories": [ ... ] }
            final categoriesWrapper = Categories.fromJson(data.data as Map<String, dynamic>);
            categories?.value = categoriesWrapper.categories ?? <Category>[];
          } else {
            categories?.clear();
          }
        } catch (e) {
          categories?.clear();
        } finally {
          isLoading.value = false;
        }
      },
      onError: (error) {
        isLoading.value = false;
        AppFunctions().showToast(error.message, bgColor: AppColors.red);
        // Handle error if needed
      },
    );
  }

  /// Refresh all data (categories, products, and filters) - used for pull-to-refresh
  Future<void> refreshAllData() async {
    // Call all APIs in parallel for faster refresh
    await Future.wait([
      Future(() => getProductCategories()),
      Future(() => getProductAll(isRefresh: true)),
      Future(() => getProductFilters()),
    ]);
  }

  void getProductAll({bool isRefresh = false}) {
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

            if (productResponse.data != null && productResponse.data!.isNotEmpty) {
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
          if (data.data is Map) {
            log('Data keys: ${(data.data as Map).keys}');
          } else if (data.data is List) {
            log('Data list length: ${(data.data as List).length}');
          }
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

  void getProductById(String id) {
    if (id.isEmpty) return;

    isLoadingProductDetail.value = true;
    selectedProduct.value = null;

    _productRepository.getProductById(
      id: id,
      onSuccess: (data) {
        try {
          if (data.data != null) {
            final product = Product.fromJson(data.data['product']);
            selectedProduct.value = product;
            print('Product parsed - Title: ${product.title}, ID: ${product.id}');
          } else {
            print('Response data is null');
          }
        } catch (e, stackTrace) {
          print('Error parsing product detail: $e');
          print('Stack trace: $stackTrace');
          selectedProduct.value = null;
        } finally {
          isLoadingProductDetail.value = false;
        }
      },
      onError: (error) {
        isLoadingProductDetail.value = false;
        selectedProduct.value = null;
        print('Error loading product detail: ${error.message}');
        AppFunctions().showToast(error.message, bgColor: AppColors.red);
      },
    );
  }

  /// Toggle like/dislike for a product
  void toggleLikeDislike(Product product) {
    if (product.id == null || product.id!.isEmpty) return;

    // Check if user is logged in
    final isLoggedIn = PrefService.getBool(PrefKeys.isLogin) && PrefService.getString(PrefKeys.accessToken).isNotEmpty;
    if (!isLoggedIn) {
      // Store pending like action
      DialogService.showLoginRequiredDialog(
        message: 'product_detail_login_wishlist'.tr,
        pendingActionType: 'toggle_like',
        pendingActionData: {'productId': product.id},
        pendingCallback: () {
          // Execute like action after login
          toggleLikeDislike(product);
        },
        onLogin: () {
          Get.toNamed(AppRoutes.login);
        },
      );
      return;
    }

    final status = (product.isLiked ?? false) ? 0 : 1;

    _productRepository.toggleLike(
      body: {"productId": product.id, "status": status},
      onSuccess: (data) {
        // Update the product in the products list if it exists
        final index = products.indexWhere((p) => p.id == product.id);
        if (index != -1) {
          products[index].isLiked = product.isLiked;
          products.refresh();
        }
        // Update the product in the categoryProducts list if it exists
        final categoryIndex = categoryProducts.indexWhere((p) => p.id == product.id);
        if (categoryIndex != -1) {
          categoryProducts[categoryIndex].isLiked = product.isLiked;
          categoryProducts.refresh();
        }
        // Update selectedProduct if it's the same product
        if (selectedProduct.value?.id == product.id) {
          selectedProduct.value = product;
        }
        if (Get.isRegistered<CartController>()) {
          final categoryProductsIndex = Get.find<CartController>().featuredProducts.indexWhere(
            (p) => p.id == product.id,
          );
          if (categoryProductsIndex != -1) {
            Get.find<CartController>().featuredProducts[categoryProductsIndex].isLiked = product.isLiked;
            Get.find<CartController>().featuredProducts.refresh();
          }
        }
        if (Get.isRegistered<WishlistController>()) {
          Get.find<WishlistController>().getProductWishlist(isRefresh: true);
          update();
        }
      },
      onError: (error) {
        // Revert the optimistic update on error
        product.isLiked = !(product.isLiked ?? false);
        final index = products.indexWhere((p) => p.id == product.id);
        if (index != -1) {
          products[index].isLiked = product.isLiked;
          products.refresh();
        }
        // Revert in categoryProducts list if it exists
        final categoryIndex = categoryProducts.indexWhere((p) => p.id == product.id);
        if (categoryIndex != -1) {
          categoryProducts[categoryIndex].isLiked = product.isLiked;
          categoryProducts.refresh();
        }
        if (selectedProduct.value?.id == product.id) {
          selectedProduct.value = product;
        }
        AppFunctions().showToast(error.message, bgColor: AppColors.red);
      },
    );
  }

  void getProductTestimonials(String id) {
    if (id.isEmpty) return;

    _productRepository.productTestimonials(
      id: id,
      onSuccess: (data) {
        try {
          if (data.data != null) {
            ProductReviewModel reviewResponse;
            final reviewsList = (data.data as List)
                .map((x) {
                  try {
                    return ProductReview.fromJson(x as Map<String, dynamic>);
                  } catch (e) {
                    print('Error parsing product review: $e');
                    return null;
                  }
                })
                .whereType<ProductReview>()
                .toList();

            reviewResponse = ProductReviewModel(
              success: data.success,
              message: data.message,
              data: reviewsList,
              pagination: data.pagination,
            );

            // Update productReviews list
            if (reviewResponse.data != null && reviewResponse.data!.isNotEmpty) {
              productReviews?.value = reviewResponse.data!;
            } else {
              productReviews?.clear();
            }
          } else {
            productReviews?.clear();
          }
        } catch (e) {
          productReviews?.clear();
        }
      },
      onError: (error) {
        print('Error loading product testimonials: ${error.message}');
        productReviews?.clear();
        AppFunctions().showToast(error.message, bgColor: AppColors.red);
      },
    );
  }

  void getCategoryProduct({String? category, bool isRefresh = false, bool isCategory = false}) {
    if (isRefresh) {
      if (isCategory) {
        categoryCurrentPage = 1;
        categoryHasMore = true;
      } else {
        currentPage = 1;
        hasMore = true;
      }
    }
    if (isCategory) {
      if (!categoryHasMore && !isRefresh) return;
    } else {
      if (!hasMore && !isRefresh) return;
    }

    if (isCategory) {
      isLoading.value = categoryProducts.isEmpty;
      isLoadingMore.value = !isRefresh && categoryProducts.isNotEmpty;
    } else {
      isLoading.value = products.isEmpty;
      isLoadingMore.value = !isRefresh && products.isNotEmpty;
    }

    _productRepository.getProduct(
      page: isCategory ? categoryCurrentPage : currentPage,
      limit: isCategory ? categoryLimit : limit,
      queryParams: {
        if (category != null) 'categories': category,
        if (selectedIngredients.isNotEmpty) "ingredients": selectedIngredients.join(','),
        if (selectedHealthGoals.isNotEmpty) "healthGoals": selectedHealthGoals.join(','),
        if (selectedProductTypes.isNotEmpty && selectedProductTypes.contains("Viteezy Sachets")) "variant": "SACHETS",
        if (selectedProductTypes.isNotEmpty && selectedProductTypes.contains("Stand-up pouch")) "hasStandupPouch": true,
        if (selectedSortBy.isNotEmpty) "sortBy": selectedSortBy,
      },
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

            if (productResponse.data != null) {
              final newProducts = productResponse.data!;

              if (isRefresh) {
                // On refresh, replace all products
                if (isCategory) {
                  categoryProducts.value = newProducts;
                } else {
                  products.value = newProducts;
                }
              } else {
                // On load more, append products
                if (isCategory) {
                  categoryProducts.addAll(newProducts);
                } else {
                  products.addAll(newProducts);
                }
              }

              // Update pagination
              if (isCategory) {
                categoryPagination = productResponse.pagination;
                // Determine if there are more pages
                if (categoryPagination != null) {
                  categoryHasMore = categoryPagination!.hasNext ?? false;
                } else {
                  // If no pagination info, assume hasMore based on the number of products received
                  categoryHasMore = newProducts.length >= categoryLimit;
                }

                if (categoryHasMore) {
                  categoryCurrentPage++;
                }
              } else {
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
              }
            } else {
              if (isCategory) {
                categoryHasMore = false;
              } else {
                hasMore = false;
              }
            }
          } else {
            if (isCategory) {
              categoryHasMore = false;
            } else {
              hasMore = false;
            }
          }
        } catch (e, stackTrace) {
          log('Error parsing products: $e');
          log('Stack trace: $stackTrace');
        } finally {
          isLoading.value = false;
          isLoadingMore.value = false;
        }
      },
      onError: (error) {
        isLoading.value = false;
        isLoadingMore.value = false;
        print('Error loading category products: ${error.message}');
        AppFunctions().showToast(error.message, bgColor: AppColors.red);
      },
    );
  }

  /// Loads category products for a single screen (e.g. product detail similar products).
  /// Does not update [categoryProducts], category pagination, or loading flags used by shop/category views.
  void fetchSimilarProductsForProductDetail({
    String? category,
    required void Function(List<Product> products) onSuccess,
  }) {
    _productRepository.getProduct(
      page: 1,
      limit: categoryLimit,
      queryParams: {
        'categories': ?category,
        // if (selectedIngredients.isNotEmpty) "ingredients": selectedIngredients.join(','),
        // if (selectedHealthGoals.isNotEmpty) "healthGoals": selectedHealthGoals.join(','),
        // if (selectedProductTypes.isNotEmpty && selectedProductTypes.contains("Viteezy Sachets")) "variant": "SACHETS",
        // if (selectedProductTypes.isNotEmpty && selectedProductTypes.contains("Stand-up pouch")) "hasStandupPouch": true,
        // if (selectedSortBy.isNotEmpty) "sortBy": selectedSortBy,
      },
      onSuccess: (data) {
        try {
          if (data.data != null) {
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
            onSuccess(productsList);
          } else {
            onSuccess([]);
          }
        } catch (e, stackTrace) {
          log('Error parsing similar products: $e');
          log('Stack trace: $stackTrace');
          onSuccess([]);
        }
      },
      onError: (error) {
        print('Error loading similar products: ${error.message}');
        AppFunctions().showToast(error.message, bgColor: AppColors.red);
        onSuccess([]);
      },
    );
  }

  void getProductFilters() {
    _productRepository.getProductFilters(
      onSuccess: (data) {
        try {
          if (data.data != null) {
            filtersData = FiltersData.fromJson(data.data);
            // Initialize the sort by label after filters are loaded
            _initializeSortByLabel();
          }
        } catch (e, stackTrace) {
          log('Error parsing product filters: $e');
          log('Stack trace: $stackTrace');
        }
      },
      onError: (error) {
        log('Error loading product filters: ${error.message}');
        AppFunctions().showToast(error.message, bgColor: AppColors.red);
      },
    );
  }

  void _initializeSortByLabel() {
    // Initialize the label for the current selected sort value
    if (selectedSortBy.value.isNotEmpty) {
      final sortByOptions = filtersData?.sortBy ?? [];
      try {
        final selectedOption = sortByOptions.firstWhere((option) => option.value == selectedSortBy.value);
        selectedSortByLabel.value = selectedOption.label ?? '';
      } catch (e) {
        selectedSortByLabel.value = '';
      }
    }
  }

  void loadMoreProducts() {
    if (!isLoadingMore.value && hasMore) {
      getProductAll();
    }
  }

  void showSortAndFilters(bool isCategory, {String? category}) {
    Get.bottomSheet(
      ShopAllFilterBottomSheet(isCategory: isCategory, category: category),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  int get activeFilterCount {
    int count = 0;
    if (selectedIngredients.isNotEmpty) count++;
    if (selectedHealthGoals.isNotEmpty) count++;
    if (selectedProductTypes.isNotEmpty) count++;
    return count;
  }

  void clearAllFilters({bool isCategory = false, String? category}) {
    selectedIngredients.clear();
    selectedHealthGoals.clear();
    selectedProductTypes.clear();
    selectedSortBy.value = 'relevance';
    Get.back();
    getCategoryProduct(isRefresh: true, isCategory: isCategory, category: category);
    getProductAll(isRefresh: true);
  }

  /// Save current filter state (used when navigating to category product view)
  void saveFilterState() {
    _savedSelectedIngredients = List.from(selectedIngredients);
    _savedSelectedHealthGoals = List.from(selectedHealthGoals);
    _savedSelectedProductTypes = List.from(selectedProductTypes);
    _savedSelectedSortBy = selectedSortBy.value;
  }

  /// Restore saved filter state (used when coming back from category product view)
  void restoreFilterState() {
    selectedIngredients.value = List.from(_savedSelectedIngredients);
    selectedHealthGoals.value = List.from(_savedSelectedHealthGoals);
    selectedProductTypes.value = List.from(_savedSelectedProductTypes);
    selectedSortBy.value = _savedSelectedSortBy;
  }

  /// Clear filter state for category product view
  void clearFiltersForCategoryView() {
    selectedIngredients.clear();
    selectedHealthGoals.clear();
    selectedProductTypes.clear();
    selectedSortBy.value = 'relevance';
  }

  void applyFilters(bool isCategory, {String? category}) {
    Get.back();
    getCategoryProduct(isRefresh: true, isCategory: isCategory, category: category);
  }

  // Ingredient filter methods
  void toggleIngredient(String ingredient) {
    if (selectedIngredients.contains(ingredient)) {
      selectedIngredients.remove(ingredient);
    } else {
      selectedIngredients.add(ingredient);
    }
  }

  void clearIngredientFilter() {
    selectedIngredients.clear();
  }

  void showIngredientFilter() {
    Get.bottomSheet(const IngredientFilterSheet(), isScrollControlled: true, backgroundColor: Colors.transparent);
  }

  // Health goal filter methods
  void toggleHealthGoal(String goal) {
    if (selectedHealthGoals.contains(goal)) {
      selectedHealthGoals.remove(goal);
    } else {
      selectedHealthGoals.add(goal);
    }
  }

  void clearHealthGoalFilter() {
    selectedHealthGoals.clear();
  }

  void showHealthGoalFilter() {
    Get.bottomSheet(const HealthGoalFilterSheet(), isScrollControlled: true, backgroundColor: Colors.transparent);
  }

  // Product type filter methods
  void toggleProductType(String productType) {
    if (selectedProductTypes.contains(productType)) {
      selectedProductTypes.remove(productType);
    } else {
      selectedProductTypes.add(productType);
    }
  }

  void clearProductTypeFilter() {
    selectedProductTypes.clear();
  }

  void showProductTypeFilter() {
    Get.bottomSheet(const ProductTypeFilterSheet(), isScrollControlled: true, backgroundColor: Colors.transparent);
  }

  // Sort by methods
  void selectSortBy(String sortBy) {
    selectedSortBy.value = sortBy;
    // Find and store the label for the selected sort value
    final sortByOptions = filtersData?.sortBy ?? [];
    try {
      final selectedOption = sortByOptions.firstWhere((option) => option.value == sortBy);
      selectedSortByLabel.value = selectedOption.label ?? '';
    } catch (e) {
      selectedSortByLabel.value = '';
    }
  }

  void clearSortByFilter() {
    selectedSortBy.value = 'relevance';
    // Find and store the label for 'relevance'
    final sortByOptions = filtersData?.sortBy ?? [];
    try {
      final relevanceOption = sortByOptions.firstWhere((option) => option.value == 'relevance');
      selectedSortByLabel.value = relevanceOption.label ?? '';
    } catch (e) {
      selectedSortByLabel.value = '';
    }
  }

  void showSortByFilter() {
    Get.bottomSheet(const SortByFilterSheet(), isScrollControlled: true, backgroundColor: Colors.transparent);
  }

  /// [variantType] "SACHETS" | "STAND_UP_POUCH". Body: SACHETS → productId + variantType only; STAND_UP_POUCH → quantity, productId, variantType, planDays, isOneTime: true.
  Future<Map<String, dynamic>> addToCart(String productId, String variantType, {int? quantity, int? planDays}) async {
    // Check if user is logged in
    final isLoggedIn = PrefService.getBool(PrefKeys.isLogin) && PrefService.getString(PrefKeys.accessToken).isNotEmpty;
    if (!isLoggedIn) {
      DialogService.showLoginRequiredDialog(
        message: 'product_detail_login_cart'.tr,
        pendingActionType: 'add_to_cart',
        pendingActionData: {
          'productId': productId,
          'variantType': variantType,
          if (quantity != null) 'quantity': quantity,
          if (planDays != null) 'planDays': planDays,
        },
        pendingCallback: () {
          addToCart(productId, variantType, quantity: quantity, planDays: planDays);
        },
        onLogin: () {
          Get.toNamed(AppRoutes.login);
        },
      );
      return {'success': false, 'message': 'product_detail_login_cart'.tr};
    }

    final completer = Completer<Map<String, dynamic>>();
    final Map<String, dynamic> body;
    if (variantType.toUpperCase() == 'SACHETS') {
      body = {'productId': productId, 'variantType': 'SACHETS'};
    } else {
      body = {
        'quantity': quantity ?? 1,
        'productId': productId,
        'variantType': 'STAND_UP_POUCH',
        'isOneTime': true,
        'planDays': planDays,
      };
    }

    _cartRepository.addToCartItem(
      body: body,
      onSuccess: (data) {
        final message = data.message;

        // Update product's isInCart flag in products list
        final productIndex = products.indexWhere((p) => p.id == productId);
        if (productIndex != -1) {
          products[productIndex].isInCart = true;
          products.refresh();
        }

        // Update product's isInCart flag in categoryProducts list
        final categoryProductIndex = categoryProducts.indexWhere((p) => p.id == productId);
        if (categoryProductIndex != -1) {
          categoryProducts[categoryProductIndex].isInCart = true;
          categoryProducts.refresh();
        }

        // Refresh cart data silently if CartController is registered (getCart will update cart count = items.length)
        if (Get.isRegistered<CartController>()) {
          final cartController = Get.find<CartController>();
          cartController.refreshCartSilently();
        }

        // Cart count = cart.items.length; updated only when getCart completes in refreshCartSilently (not per-item quantity)

        completer.complete({
          'success': true,
          'message': message != null && message.isNotEmpty ? message : 'product_detail_item_added'.tr,
        });
      },
      onError: (error) {
        completer.complete({
          'success': false,
          'message': error.message.isNotEmpty ? error.message : 'home_failed_to_add_cart'.tr,
        });
      },
    );

    return completer.future;
  }
}

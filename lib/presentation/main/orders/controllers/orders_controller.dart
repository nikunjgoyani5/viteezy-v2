import 'dart:developer';

import 'package:get/get.dart';

import '../../../../core/repositories/order_repository.dart';
import '../../../../core/repositories/product_repository.dart';
import '../../../../core/models/oders_history_model.dart';
import '../../../../core/models/product_response_model.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_functions.dart';
import '../../shop_all_view/controller/shop_all_controller.dart';

class MostLikedProduct {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double currentPrice;
  final double originalPrice;
  final double rating;
  final int discountPercent;
  final bool isFavorite;

  MostLikedProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.currentPrice,
    required this.originalPrice,
    required this.rating,
    required this.discountPercent,
    this.isFavorite = false,
  });
}

class OrdersController extends GetxController {
  final RxList<OrderData> orders = <OrderData>[].obs;
  List<MostLikedProduct> mostLikedProducts = [];
  final _ordersRepository = OrdersRepository();
  final ProductRepository _productRepository = ProductRepository();
  final RxBool isLoading = false.obs;
  final Rx<OrderData?> selectedOrderData = Rx<OrderData?>(null);
  final RxBool isLoadingOrderDetail = false.obs;

  // Featured Products
  final RxList<Product> featuredProducts = <Product>[].obs;
  final RxBool isLoadingFeaturedProducts = false.obs;

  /// Product ID for which "Buy again" is in progress (null = none).
  final Rx<String?> buyingAgainProductId = Rx<String?>(null);

  @override
  void onInit() {
    super.onInit();
    _loadOrders();
  }

  void reviewProduct(String productId) {
    // TODO: Navigate to review screen
    Get.snackbar('Review', 'Review product $productId');
  }

  /// Buy-now flow: add product to cart then navigate to checkout (same as product detail "Buy Now").
  Future<void> buyAgain(String productId) async {
    buyingAgainProductId.value = productId;
    try {
      final shopAllController = Get.find<ShopAllController>();
      // Use order's variant if available, else default to SACHETS (same as product detail)
      final orderVariant = selectedOrderData.value?.variantType?.toUpperCase();
      final variant = (orderVariant == 'STAND_UP_POUCH' || (orderVariant?.contains('POUCH') ?? false))
          ? 'STAND_UP_POUCH'
          : 'SACHETS';

      final result = await shopAllController.addToCart(productId, variant);

      if (result['success'] == true) {
        Get.toNamed(AppRoutes.checkout);
      }
    } catch (e) {
      log('buyAgain error: $e');
      AppFunctions().showToast('Failed to add to cart. Please try again.', bgColor: AppColors.red);
    } finally {
      buyingAgainProductId.value = null;
    }
  }

  void _loadOrders() {
    isLoading.value = true;
    _ordersRepository.getOrders(
      onSuccess: (data) {
        isLoading.value = false;
        if (data.data != null) {
          try {
            final orderHistoryModel = List<OrderData>.from(data.data.map((x) => OrderData.fromJson(x)));
            orders.assignAll(orderHistoryModel);

            // Call getFeaturedProduct only if orders list is empty
            if (orders.isEmpty) {
              getFeaturedProduct();
            } else {
              // Clear featured products if orders exist
              featuredProducts.clear();
            }
          } catch (e) {
            orders.clear();
            // Call getFeaturedProduct if orders are empty after error
            getFeaturedProduct();
          }
        } else {
          orders.clear();
          // Call getFeaturedProduct if orders are empty
          getFeaturedProduct();
        }
      },
      onError: (error) {
        isLoading.value = false;
        orders.clear();
        // Call getFeaturedProduct if orders are empty after error
        getFeaturedProduct();
        AppFunctions().showToast(error.message, bgColor: AppColors.red);
      },
    );
  }

  void getFeaturedProduct({bool isRefresh = false}) {
    isLoadingFeaturedProducts.value = true;

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
                    log('Error parsing product: $e');
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
                featuredProducts.value = newProducts;
              } else {
                // On load more, append products
                featuredProducts.addAll(newProducts);
              }
            }
          }
        } catch (e, stackTrace) {
          log('Error parsing featured products: $e');
          log('Stack trace: $stackTrace');
          log('Data type: ${data.data?.runtimeType}');
        } finally {
          isLoadingFeaturedProducts.value = false;
        }
      },
      onError: (error) {
        isLoadingFeaturedProducts.value = false;
        log('Error loading featured products: ${error.message}');
        AppFunctions().showToast(error.message, bgColor: AppColors.red);
      },
    );
  }

  void toggleFavorite(String productId) {
    // Static data - no logic needed
  }

  void addToCart(String productId) {
    // Static data - no logic needed
  }

  void continueShopping() {
    // TODO: Navigate to shop/home
    Get.back();
  }

  void getOrderDetail(String orderId) {
    isLoadingOrderDetail.value = true;
    selectedOrderData.value = null;
    _ordersRepository.getOrderDetail(
      orderId: orderId,
      onSuccess: (data) {
        isLoadingOrderDetail.value = false;
        if (data.data != null) {
          try {
            // print("-----------------------${data.data['order'].runtimeType}");
            final orderData = OrderData.fromJson(data.data['order']);
            selectedOrderData.value = orderData;
          } catch (e) {
            selectedOrderData.value = null;
          }
        } else {
          selectedOrderData.value = null;
        }
      },
      onError: (error) {
        isLoadingOrderDetail.value = false;
        selectedOrderData.value = null;
        AppFunctions().showToast(error.message, bgColor: AppColors.red);
      },
    );
  }
}

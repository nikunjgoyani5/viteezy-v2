import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:viteezy/core/routes/app_routes.dart';
import 'package:viteezy/core/services/cart_count_service.dart';
import 'package:viteezy/core/services/global_settings_service.dart';
import 'package:viteezy/core/widgets/custom_toast.dart';

import '../../../../core/models/cart_response_model.dart';
import '../../../../core/models/product_response_model.dart';
import '../../../../core/repositories/cart_repository.dart';
import '../../../../core/repositories/product_repository.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_functions.dart';
import '../../../../core/utils/app_prefrence.dart';
import '../../../../core/utils/dialog_service.dart';
import '../../shop_all_view/controller/shop_all_controller.dart';

class CartController extends GetxController {
  // Cart data
  final cartData = Rx<CartData?>(null);
  final CartRepository _cartRepository = CartRepository();
  final ProductRepository _productRepository = ProductRepository();
  // Discount code
  final RxString appliedDiscountCode = ''.obs;
  final TextEditingController discountCodeController = TextEditingController();
  final RxBool isDiscountFieldExpanded = false.obs;

  // Loading state
  final RxBool isLoading = true.obs;

  // Subscription update flow (when cart was opened from subscription products update)
  final RxBool fromSubscriptionUpdate = false.obs;
  final RxString subscriptionId = ''.obs;

  // Featured Products
  final RxList<Product> featuredProducts = <Product>[].obs;
  final RxBool isLoadingFeaturedProducts = false.obs;

  // Progress bar data
  int get totalProducts {
    final items = cartData.value?.cart?.items;
    if (items == null || items.isEmpty) return 0;
    return items.length;
  }

  // Payment details - use paymentDetails from model if available, otherwise fallback to cart
  double get mrp {
    final cart = cartData.value?.cart;
    return cart?.subtotal ?? 0.0;
  }

  num get totalDiscount {
    final cart = cartData.value?.cart;
    return cart?.discount ?? 0.0;
  }

  double get membershipDiscount => 0.0; // Calculate from cart items if needed

  double get grandTotal {
    final cart = cartData.value?.cart;
    return cart?.total ?? 0.0;
  }

  String get currency {
    return cartData.value?.cart?.currency ?? "";
  }

  num get shipping {
    final cart = cartData.value?.cart;
    return cart?.shipping ?? 0.0;
  }

  num get tax {
    final cart = cartData.value?.cart;
    return cart?.tax ?? 0.0;
  }

  @override
  void onInit() {
    super.onInit();
    // Clear cart data and show shimmer
    // cartData.value = null;
    // isLoading.value = true;
    // // Load featured products only if user is logged in
    // final isLoggedIn = PrefService.getBool(PrefKeys.isLogin) && PrefService.getString(PrefKeys.accessToken).isNotEmpty;
    // if (isLoggedIn) {
    //   getFeaturedProduct();
    // }
  }

  void initializeCartItems({bool fromSubscriptionUpdate = false, String? subscriptionId}) async {
    isLoading.value = true;
    this.fromSubscriptionUpdate.value = fromSubscriptionUpdate;
    this.subscriptionId.value = subscriptionId ?? '';

    final Map<String, dynamic>? queryParams;
    if (fromSubscriptionUpdate && subscriptionId != null && subscriptionId.isNotEmpty) {
      queryParams = {
        'type': 'SUBSCRIPTION_UPDATE',
        'subscriptionId': subscriptionId,
      };
    } else {
      queryParams = null;
    }

    _cartRepository.getCart(
      queryParams: queryParams,
      onSuccess: (data) {
        try {
          if (data.data != null) {
            CartData? cartResponse;

            // Check if data.data is already a Map
            if (data.data is Map<String, dynamic>) {
              try {
                cartResponse = CartData.fromJson(data.data as Map<String, dynamic>);
                cartData.value = cartResponse;

                // Update cart count in preferences
                if (Get.isRegistered<CartCountService>()) {
                  final cartCountService = CartCountService.to;
                  final items = cartResponse.cart?.items;
                  final count = items != null && items.isNotEmpty ? items.length : 0;
                  cartCountService.updateCartCount(count);
                }
              } catch (e, stackTrace) {
                log('Error parsing cart data as Map: $e');
                log('Stack trace: $stackTrace');
              }
            }
          }
        } catch (e, stackTrace) {
          log('Error parsing cart data: $e');
          log('Stack trace: $stackTrace');
        } finally {
          isLoading.value = false;
        }
      },
      onError: (error) {
        log('Error loading cart: ${error.message}');
        isLoading.value = false;
        // AppFunctions().showToast(error.message, bgColor: AppColors.red);
      },
    );

    final isLoggedIn = PrefService.getBool(PrefKeys.isLogin) && PrefService.getString(PrefKeys.accessToken).isNotEmpty;
    if (isLoggedIn) {
      getFeaturedProduct();
    }
  }

  /// Refresh cart data (used for pull-to-refresh).
  /// When fromSubscriptionUpdate is true, passes same queryParams as initializeCartItems (type: SUBSCRIPTION_UPDATE, subscriptionId).
  Future<void> refreshCart() async {
    final completer = Completer<void>();

    isLoading.value = true;

    final Map<String, dynamic>? queryParams;
    if (fromSubscriptionUpdate.value && subscriptionId.value.isNotEmpty) {
      queryParams = {
        'type': 'SUBSCRIPTION_UPDATE',
        'subscriptionId': subscriptionId.value,
      };
    } else {
      queryParams = null;
    }

    _cartRepository.getCart(
      queryParams: queryParams,
      onSuccess: (data) {
        try {
          if (data.data != null) {
            CartData? cartResponse;

            // Check if data.data is already a Map
            if (data.data is Map<String, dynamic>) {
              try {
                cartResponse = CartData.fromJson(data.data as Map<String, dynamic>);
                cartData.value = cartResponse;

                // Update cart count in preferences
                if (Get.isRegistered<CartCountService>()) {
                  final cartCountService = CartCountService.to;
                  final items = cartResponse.cart?.items;
                  final count = items != null && items.isNotEmpty ? items.length : 0;
                  cartCountService.updateCartCount(count);
                }
              } catch (e, stackTrace) {
                log('Error parsing cart data as Map: $e');
                log('Stack trace: $stackTrace');
              }
            }
          }
        } catch (e, stackTrace) {
          log('Error parsing cart data: $e');
          log('Stack trace: $stackTrace');
        } finally {
          isLoading.value = false;
          if (!completer.isCompleted) {
            completer.complete();
          }
        }
      },
      onError: (error) {
        log('Error loading cart: ${error.message}');
        isLoading.value = false;
        if (!completer.isCompleted) {
          completer.complete();
        }
      },
    );

    // Wait for cart API to complete
    await completer.future;

    // Refresh featured products if user is logged in (don't wait for this)
    final isLoggedIn = PrefService.getBool(PrefKeys.isLogin) && PrefService.getString(PrefKeys.accessToken).isNotEmpty;
    if (isLoggedIn) {
      getFeaturedProduct(isRefresh: true);
    }
  }

  /// Invoked when getCart completes (success or error). Used e.g. to hide progress dialog after refresh.
  VoidCallback? _onRefreshComplete;

  /// Refresh cart data silently without showing loading/shimmer. If [_onRefreshComplete] is set, it is called when getCart response is received.
  void refreshCartSilently() {
    final Map<String, dynamic>? queryParams;
    if (fromSubscriptionUpdate.value && subscriptionId.value.isNotEmpty) {
      queryParams = {'type': 'SUBSCRIPTION_UPDATE', 'subscriptionId': subscriptionId.value};
    } else {
      queryParams = null;
    }
    _cartRepository.getCart(
      queryParams: queryParams,
      onSuccess: (data) {
        try {
          if (data.data != null) {
            CartData? cartResponse;

            // Check if data.data is already a Map
            if (data.data is Map<String, dynamic>) {
              try {
                cartResponse = CartData.fromJson(data.data as Map<String, dynamic>);
                cartData.value = cartResponse;

                // Sync isInCart status with ShopAllController's product lists
                _syncCartStatusWithProductLists(cartResponse);

                // Update cart count in preferences
                if (Get.isRegistered<CartCountService>()) {
                  final cartCountService = CartCountService.to;
                  final items = cartResponse.cart?.items;
                  final count = items != null && items.isNotEmpty ? items.length : 0;
                  cartCountService.updateCartCount(count);
                }
              } catch (e, stackTrace) {
                log('Error parsing cart data as Map: $e');
                log('Stack trace: $stackTrace');
              }
            }
          }
        } catch (e, stackTrace) {
          log('Error parsing cart data: $e');
          log('Stack trace: $stackTrace');
        } finally {
          _onRefreshComplete?.call();
          _onRefreshComplete = null;
        }
      },
      onError: (error) {
        log('Error refreshing cart: ${error.message}');
        _onRefreshComplete?.call();
        _onRefreshComplete = null;
      },
    );
  }

  /// Sync cart status with ShopAllController's product lists
  void _syncCartStatusWithProductLists(CartData? cartData) {
    if (cartData == null) return;

    // Get all product IDs currently in cart
    final cartProductIds = <String>{};
    cartData.cart?.items?.forEach((item) {
      if (item.productId != null && item.productId!.isNotEmpty) {
        cartProductIds.add(item.productId!);
      }
    });

    // Update ShopAllController if registered
    if (Get.isRegistered<ShopAllController>()) {
      try {
        final shopAllController = Get.find<ShopAllController>();

        // Update products list
        for (var product in shopAllController.products) {
          if (product.id != null) {
            product.isInCart = cartProductIds.contains(product.id);
          }
        }
        shopAllController.products.refresh();

        // Update categoryProducts list
        for (var product in shopAllController.categoryProducts) {
          if (product.id != null) {
            product.isInCart = cartProductIds.contains(product.id);
          }
        }
        shopAllController.categoryProducts.refresh();

        // Update selectedProduct if it exists
        if (shopAllController.selectedProduct.value?.id != null) {
          shopAllController.selectedProduct.value?.isInCart = cartProductIds.contains(
            shopAllController.selectedProduct.value?.id,
          );
          shopAllController.selectedProduct.refresh();
        }
      } catch (e) {
        log('Error syncing cart status with product lists: $e');
      }
    }
  }

  void removeCartItem(CartItem item, {VoidCallback? onRemoved}) {
    final productId = item.productId;
    if (productId == null || productId.isEmpty) return;

    void onRemoveSuccess() {
      _updateProductInCartStatus(productId, false);
      refreshCartSilently();
      if (Get.isRegistered<CartCountService>()) {
        final cartCountService = CartCountService.to;
        final newCount = (cartCountService.cartItemCount.value - 1).clamp(0, double.infinity).toInt();
        cartCountService.updateCartCount(newCount);
      }
      onRemoved?.call();
    }

    if (fromSubscriptionUpdate.value && subscriptionId.value.isNotEmpty) {
      _cartRepository.removeSubscriptionUpdateProduct(
        subscriptionId: subscriptionId.value,
        productId: productId,
        onSuccess: (_) => onRemoveSuccess(),
        onError: (error) {
          log('Error removing subscription update product: ${error.message}');
          AppFunctions().showToast(error.message, bgColor: AppColors.red);
        },
      );
    } else {
      _cartRepository.deleteCartItem(
        body: {'productId': productId},
        onSuccess: (_) => onRemoveSuccess(),
        onError: (error) {
          log('Error delete cart item: ${error.message}');
          AppFunctions().showToast(error.message, bgColor: AppColors.red);
        },
      );
    }
  }

  /// Update cart item quantity: update locally first for instant UI, then call addToCart; revert on API failure. Progress dialog stays until getCart completes.
  void updateCartItemQuantity(CartItem item, int newQuantity) {
    if (item.productId == null || item.productId!.isEmpty || newQuantity < 1) return;
    final oldQuantity = item.quantity ?? item.effectiveQuantity;
    item.quantity = newQuantity;
    cartData.refresh();

    DialogService.showProgressDialog(message: 'cart_updating'.tr);
    _onRefreshComplete = () => DialogService.hideProgressDialog();

    final variantType = item.variantType ?? 'SACHETS';
    final shopAllController = Get.find<ShopAllController>();
    shopAllController
        .addToCart(
          item.productId!,
          variantType,
          quantity: variantType == 'STAND_UP_POUCH' ? newQuantity : null,
          planDays: (variantType == 'STAND_UP_POUCH' && item.planDays != null && item.planDays! > 0)
              ? item.planDays
              : null,
        )
        .then((result) {
          if (result['success'] != true) {
            _onRefreshComplete = null;
            DialogService.hideProgressDialog();
            item.quantity = oldQuantity;
            cartData.refresh();
            AppFunctions().showToast(
              result['message'] as String? ?? 'cart_update_quantity_failed'.tr,
              bgColor: AppColors.red,
            );
          }
          // On success, getCart is called by ShopAllController.addToCart onSuccess; dialog hides when getCart completes via _onRefreshComplete.
        });
  }

  /// Update product's isInCart status in ShopAllController's product lists, home view testimonials, and featured products
  void _updateProductInCartStatus(String? productId, bool isInCart) {
    if (productId == null || productId.isEmpty) return;

    // Update in featuredProducts list (Recently Viewed section in cart)
    try {
      final featuredProductIndex = featuredProducts.indexWhere((p) => p.id == productId);
      if (featuredProductIndex != -1) {
        featuredProducts[featuredProductIndex].isInCart = isInCart;
        featuredProducts.refresh();
      }
    } catch (e) {
      log('Error updating product in featuredProducts: $e');
    }

    // Update in ShopAllController if registered
    if (Get.isRegistered<ShopAllController>()) {
      try {
        final shopAllController = Get.find<ShopAllController>();

        // Update in products list
        final productIndex = shopAllController.products.indexWhere((p) => p.id == productId);
        if (productIndex != -1) {
          shopAllController.products[productIndex].isInCart = isInCart;
          shopAllController.products.refresh();
        }

        // Update in categoryProducts list
        final categoryProductIndex = shopAllController.categoryProducts.indexWhere((p) => p.id == productId);
        if (categoryProductIndex != -1) {
          shopAllController.categoryProducts[categoryProductIndex].isInCart = isInCart;
          shopAllController.categoryProducts.refresh();
        }

        // Update selectedProduct if it matches
        if (shopAllController.selectedProduct.value?.id == productId) {
          shopAllController.selectedProduct.value?.isInCart = isInCart;
          shopAllController.selectedProduct.refresh();
        }
      } catch (e) {
        log('Error updating product in cart status: $e');
      }
    }

    // Update products in home view testimonials (review cards)
    try {
      if (Get.isRegistered<GlobalSettingsService>()) {
        final globalSettings = GlobalSettingsService.to;
        final homeData = globalSettings.landingPageData.value;

        if (homeData?.landingPage?.testimonialsSection?.testimonials != null) {
          bool updated = false;
          // Iterate through all testimonials
          for (var testimonial in homeData!.landingPage!.testimonialsSection!.testimonials!) {
            if (testimonial.products != null) {
              // Update products in each testimonial
              for (var product in testimonial.products!) {
                if (product.id == productId) {
                  product.isInCart = isInCart;
                  updated = true;
                }
              }
            }
          }

          // Refresh the reactive value to trigger UI updates
          // Reassign the value to ensure GetX detects the change
          if (updated) {
            globalSettings.landingPageData.value = homeData;
            globalSettings.landingPageData.refresh();
          }
        }
      }
    } catch (e) {
      log('Error updating product in home view testimonials: $e');
    }
  }

  void toggleDiscountField() {
    isDiscountFieldExpanded.value = !isDiscountFieldExpanded.value;
  }

  void applyDiscountCode(String code) async {
    if (code.isEmpty) return;

    // Show loading state
    isLoading.value = true;

    // Call API to validate coupon code
    _cartRepository.validateCoupon(
      body: {"cartId": cartData.value?.cart?.id, "couponCode": code},
      onSuccess: (data) {
        try {
          if (data.data != null && data.data is Map<String, dynamic>) {
            final responseData = data.data as Map<String, dynamic>;

            // Check if coupon was successfully applied
            if (data.success == true && responseData['cart'] != null) {
              try {
                // Access cart object directly from response
                final cartMap = responseData['cart'] as Map<String, dynamic>;

                // Update only specific fields directly without parsing full model
                if (cartData.value?.cart != null) {
                  final currentCart = cartData.value!.cart!;

                  // Update only the specified fields
                  if (cartMap['subtotal'] != null) {
                    currentCart.subtotal = (cartMap['subtotal'] as num?)?.toDouble();
                  }
                  if (cartMap['discount'] != null) {
                    currentCart.discount = (cartMap['discount'] as num?)?.toDouble();
                  }
                  if (cartMap['couponDiscountAmount'] != null) {
                    currentCart.couponDiscountAmount = (cartMap['couponDiscountAmount'] as num?)?.toDouble();
                  }
                  if (cartMap['total'] != null) {
                    currentCart.total = (cartMap['total'] as num?)?.toDouble();
                  }
                  if (cartMap['shipping'] != null) {
                    currentCart.shipping = (cartMap['shipping'] as num?)?.toDouble();
                  }
                  if (cartMap['tax'] != null) {
                    currentCart.tax = (cartMap['tax'] as num?)?.toDouble();
                  }

                  // Update coupon code if present
                  if (cartMap['couponCode'] != null) {
                    currentCart.couponCode = cartMap['couponCode'];
                  }

                  // Trigger update by refreshing the observable
                  cartData.refresh();
                }

                // Store the coupon code if it was applied
                final couponCode = responseData['couponCode'] as String?;
                if (couponCode != null && couponCode.isNotEmpty) {
                  appliedDiscountCode.value = couponCode;
                } else {
                  // If couponCode is null but success is true, use the entered code
                  appliedDiscountCode.value = code;
                }
                CustomToast.show(message: "Discount code applied successfully", context: Get.context!);
                // Get.snackbar('Success', 'Discount code applied successfully');
                isDiscountFieldExpanded.value = false;
                discountCodeController.clear();
              } catch (e, stackTrace) {
                log('Error updating cart fields from coupon validation: $e');
                log('Stack trace: $stackTrace');
                Get.snackbar('common_error'.tr, 'cart_discount_apply_failed'.tr);
              }
            } else {
              // Coupon validation failed
              final message = data.message ?? 'cart_discount_invalid'.tr;
              Get.snackbar('common_error'.tr, message);
            }
          } else {
            Get.snackbar('common_error'.tr, 'cart_discount_invalid'.tr);
          }
        } catch (e, stackTrace) {
          log('Error processing coupon validation response: $e');
          log('Stack trace: $stackTrace');
          Get.snackbar('common_error'.tr, 'cart_discount_apply_failed'.tr);
        } finally {
          isLoading.value = false;
        }
      },
      onError: (error) {
        log('Error validating coupon code: ${error.message}');
        isLoading.value = false;
        AppFunctions().showToast(error.message, bgColor: AppColors.red);
      },
    );
  }

  void removeCouponCode() async {
    if (cartData.value?.cart?.id == null) return;

    // Show loading state
    isLoading.value = true;

    // Call API to remove coupon code by sending without couponCode
    _cartRepository.validateCoupon(
      body: {"cartId": cartData.value?.cart?.id},
      onSuccess: (data) {
        try {
          if (data.data != null && data.data is Map<String, dynamic>) {
            final responseData = data.data as Map<String, dynamic>;

            // Update cart fields if cart data is present
            if (responseData['cart'] != null && cartData.value?.cart != null) {
              final cartMap = responseData['cart'] as Map<String, dynamic>;
              final currentCart = cartData.value!.cart!;

              // Update cart fields
              if (cartMap['subtotal'] != null) {
                currentCart.subtotal = (cartMap['subtotal'] as num?)?.toDouble();
              }
              if (cartMap['discount'] != null) {
                currentCart.discount = (cartMap['discount'] as num?)?.toDouble();
              }
              if (cartMap['couponDiscountAmount'] != null) {
                currentCart.couponDiscountAmount = (cartMap['couponDiscountAmount'] as num?)?.toDouble();
              }
              if (cartMap['total'] != null) {
                currentCart.total = (cartMap['total'] as num?)?.toDouble();
              }

              // Clear coupon code
              currentCart.couponCode = null;
              appliedDiscountCode.value = '';

              // Trigger update by refreshing the observable
              cartData.refresh();
            }
          }

          CustomToast.show(message: "Coupon code removed successfully", context: Get.context!);
        } catch (e, stackTrace) {
          log('Error removing coupon code: $e');
          log('Stack trace: $stackTrace');
          Get.snackbar('common_error'.tr, 'cart_coupon_remove_failed'.tr);
        } finally {
          isLoading.value = false;
        }
      },
      onError: (error) {
        log('Error removing coupon code: ${error.message}');
        isLoading.value = false;
        AppFunctions().showToast(error.message, bgColor: AppColors.red);
      },
    );
  }

  void navigateToCheckout() {
    if (fromSubscriptionUpdate.value && subscriptionId.value.isNotEmpty) {
      Get.toNamed(AppRoutes.checkout, arguments: {
        'fromSubscriptionUpdate': true,
        'subscriptionId': subscriptionId.value,
      });
    } else {
      Get.toNamed(AppRoutes.checkout);
    }
  }

  void getFeaturedProduct({bool isRefresh = false}) {
    // Check if user is logged in before calling API
    final isLoggedIn = PrefService.getBool(PrefKeys.isLogin) && PrefService.getString(PrefKeys.accessToken).isNotEmpty;
    if (!isLoggedIn) {
      return; // Don't call API if user is not logged in
    }

    if (isLoadingFeaturedProducts.value && !isRefresh) return;

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
                featuredProducts.assignAll(newProducts);
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

  @override
  void onClose() {
    discountCodeController.dispose();
    super.onClose();
  }
}

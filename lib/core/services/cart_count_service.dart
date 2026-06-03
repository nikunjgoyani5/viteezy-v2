import 'dart:developer';
import 'package:get/get.dart';
import '../theme/app_colors.dart';
import '../utils/app_functions.dart';
import '../utils/app_prefrence.dart';
import '../repositories/cart_repository.dart';
import '../models/cart_response_model.dart';

/// Global service to manage cart item count throughout the app
class CartCountService extends GetxService {
  static CartCountService get to => Get.find<CartCountService>();

  final CartRepository _cartRepository = CartRepository();

  // Reactive cart count that can be accessed globally
  final RxInt cartItemCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // Load cart count from preferences on initialization
    _loadCartCountFromPreferences();
  }

  /// Load cart count from SharedPreferences
  void _loadCartCountFromPreferences() {
    try {
      final savedCount = PrefService.getInt(PrefKeys.cartItemCount);
      // If count is 0, it might mean empty cart or not initialized
      // We'll check if it's null by checking if the key exists
      // For now, we'll use the saved value (0 means empty cart)
      cartItemCount.value = savedCount;
      log('Cart count loaded from preferences: $savedCount');
    } catch (e) {
      // If preferences are not initialized yet, set count to 0
      log('Error loading cart count from preferences: $e');
      cartItemCount.value = 0;
    }
  }

  /// Check if cart count is initialized (key exists in preferences)
  bool get isInitialized {
    return PrefService.containsKey(PrefKeys.cartItemCount);
  }

  /// Update cart count and save to preferences
  Future<void> updateCartCount(int count) async {
    cartItemCount.value = count;
    await PrefService.setValue(PrefKeys.cartItemCount, count);
    log('Cart count updated: $count');
  }

  /// Fetch cart count from API (called when count is null or needs refresh)
  Future<void> fetchCartCount() async {
    // Check if user is logged in before making API call
    final isLoggedIn = PrefService.getBool(PrefKeys.isLogin) && PrefService.getString(PrefKeys.accessToken).isNotEmpty;
    if (!isLoggedIn) {
      log('User not logged in, skipping cart count fetch');
      updateCartCount(0);
      return;
    }

    try {
      await _cartRepository.getCart(
        onSuccess: (data) {
          try {
            if (data.data != null) {
              CartData? cartResponse;

              // Check if data.data is already a Map
              if (data.data is Map<String, dynamic>) {
                try {
                  cartResponse = CartData.fromJson(data.data as Map<String, dynamic>);
                  final items = cartResponse.cart?.items;
                  final count = items != null && items.isNotEmpty ? items.length : 0;
                  updateCartCount(count);
                  log('Cart count fetched from API: $count');
                } catch (e, stackTrace) {
                  log('Error parsing cart data as Map: $e');
                  log('Stack trace: $stackTrace');
                  updateCartCount(0);
                }
              } else {
                updateCartCount(0);
              }
            } else {
              updateCartCount(0);
            }
          } catch (e, stackTrace) {
            log('Error parsing cart data: $e');
            log('Stack trace: $stackTrace');
            updateCartCount(0);
          }
        },
        onError: (error) {
          log('Error fetching cart count: ${error.message}');
          updateCartCount(0);
          // AppFunctions().showToast(error.message, bgColor: AppColors.red);
        },
      );
    } catch (e) {
      log('Exception in fetchCartCount: $e');
      updateCartCount(0);
    }
  }

  /// Initialize cart count - checks if null, then fetches from API
  /// This should be called from DashboardController onInit
  Future<void> initializeCartCount() async {
    // Check if user is logged in before initializing
    final isLoggedIn = PrefService.getBool(PrefKeys.isLogin) && PrefService.getString(PrefKeys.accessToken).isNotEmpty;
    if (!isLoggedIn) {
      log('User not logged in, skipping cart count initialization');
      updateCartCount(0);
      return;
    }

    // Check if count is null (not initialized) by checking if key exists
    if (!isInitialized) {
      // Key doesn't exist - fetch from API
      log('Cart count not initialized, fetching from API...');
      await fetchCartCount();
    } else {
      // Key exists - load from preferences (already loaded in onInit)
      log('Cart count already initialized, using saved value: ${cartItemCount.value}');
    }
  }

  /// Get current cart count
  int get currentCount => cartItemCount.value;
}

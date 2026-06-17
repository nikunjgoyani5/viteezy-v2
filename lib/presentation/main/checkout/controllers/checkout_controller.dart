import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:viteezy/core/models/cart_item_model.dart';
import 'package:viteezy/core/models/oders_history_model.dart';
import 'package:viteezy/core/repositories/cart_repository.dart';
import 'package:viteezy/core/repositories/checkout_repository.dart';
import 'package:viteezy/core/repositories/order_repository.dart';
import 'package:viteezy/core/repositories/profile_repository.dart';
import 'package:viteezy/core/routes/app_routes.dart';
import 'package:viteezy/core/services/cart_count_service.dart';
import 'package:viteezy/core/theme/app_colors.dart';
import 'package:viteezy/core/theme/text_styles.dart';
import 'package:viteezy/core/utils/dialog_service.dart';
import 'package:viteezy/core/widgets/custom_toast.dart';
import '../../../../core/models/cart_response_model.dart' as cart_model;
import '../../../../core/models/checkout_summary_model.dart';
import '../../../../core/utils/app_functions.dart';
import '../../addresses/controllers/addresses_controller.dart';
import '../../add_address/checkout_inline_address_helper.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../membership/views/payment_webview.dart';
import '../../shop_all_view/controller/shop_all_controller.dart';

class CheckoutController extends GetxController {
  /// Set to true before redirecting to order complete after subscription update; skip addresses & subscription summary in onInit.
  static bool _skipApisAfterSubscriptionCompleteRedirect = false;

  final CheckoutRepository _checkoutRepository = CheckoutRepository();
  final ProfileRepository _profileRepository = ProfileRepository();
  final OrdersRepository _ordersRepository = OrdersRepository();
  final CartRepository _cartRepository = CartRepository();
  // Current step (1: Packaging, 2: Address, 3: Payment)
  final RxInt currentStep = 1.obs;

  // Selected subscription plan
  final Rx<SubscriptionPlan?> selectedSubscriptionPlan = Rx<SubscriptionPlan?>(null);

  // Subscription plans from API
  final RxList<SubscriptionPlan> subscriptionPlans = <SubscriptionPlan>[].obs;
  final RxBool isLoadingSubscriptionPlans = false.obs;

  // Track selected capsule count for one-time purchase plans (key: planKey, value: capsuleCount)
  final RxMap<String, int> selectedCapsuleCounts = <String, int>{}.obs;

  // Selected stand-up pouch plan per productId (from standUpPouchPlans)
  final RxMap<String, SubscriptionPlan> selectedStandUpPouchPlanByProductId = <String, SubscriptionPlan>{}.obs;

  // Local quantity per productId for stand-up pouch (used by _buildCheckoutSummaryBody; no API call on +/-).
  final RxMap<String, int> standUpPouchQuantityByProductId = <String, int>{}.obs;

  // Selected address
  final Rx<Address?> selectedAddress = Rx<Address?>(null);
  final Rx<CheckoutSummaryData?> checkoutSummaryData = Rx<CheckoutSummaryData?>(null);

  // Variant type from initial API call
  final RxString variantType = 'SACHETS'.obs;

  // Addresses list
  final RxList<Address> addresses = <Address>[].obs;
  final RxBool isLoadingAddresses = false.obs;

  // Cart items
  final RxList<CartItemModel> cartItems = <CartItemModel>[].obs;

  // Discount code
  final TextEditingController discountCodeController = TextEditingController();
  final RxString appliedDiscountCode = ''.obs;

  // Subscription update flow (when opened from cart after subscription products update)
  final RxBool fromSubscriptionUpdate = false.obs;
  final RxString subscriptionId = ''.obs;

  // Payment details
  double get mrp => cartItems.fold(0.0, (sum, item) => sum + (item.originalPrice * item.quantity));
  double get totalDiscount =>
      cartItems.fold(0.0, (sum, item) => sum + ((item.originalPrice - item.currentPrice) * item.quantity));
  double get membershipDiscount => cartItems.fold(0.0, (sum, item) => sum + (item.membershipDiscount * item.quantity));
  double get shipping => 100.0; // Fixed shipping for now
  double get subtotal => cartItems.fold(0.0, (sum, item) => sum + item.totalPrice) + shipping;
  double get grandTotal => subtotal;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      fromSubscriptionUpdate.value = args['fromSubscriptionUpdate'] == true;
      subscriptionId.value = args['subscriptionId']?.toString() ?? '';
    }
    _initializeCartItems();
    // After redirect to order complete (subscription update), do not call addresses or subscription summary
    if (_skipApisAfterSubscriptionCompleteRedirect) {
      _skipApisAfterSubscriptionCompleteRedirect = false;
      return;
    }
    if (fromSubscriptionUpdate.value) {
      _loadSubscriptionActionsSummary();
    } else {
      _loadCheckoutPageSummary();
    }
    loadAddresses();
  }

  /// Build checkout page summary request body from cart items.
  /// - If any item has variantType SACHETS: include "sachets": {"planDurationDays": 180}.
  /// - If any item has variantType STAND_UP_POUCH: include "standUpPouch": {"itemQuantities": [...]}.
  Map<String, dynamic> _buildCheckoutSummaryBody(
    cart_model.Cart? cart, {
    String? shippingAddressId,
    int sachetsPlanDurationDays = 180,
    Map<String, int>? standUpPouchCapsuleByProductId,
    Map<String, int>? standUpPouchQuantityByProductId,
  }) {
    final items = cart?.items ?? [];
    final hasSachets = items.any((i) => i.variantType == 'SACHETS');
    final standUpPouchItems = items.where((i) => i.variantType == 'STAND_UP_POUCH').toList();

    final Map<String, dynamic> body = {};
    if (hasSachets) {
      body['sachets'] = {'planDurationDays': sachetsPlanDurationDays};
    }
    if (standUpPouchItems.isNotEmpty) {
      body['standUpPouch'] = {
        'itemQuantities': standUpPouchItems
            .map((i) {
              final capsuleCount = standUpPouchCapsuleByProductId?[i.productId] ?? i.planDays ?? 0;
              final quantity = standUpPouchQuantityByProductId?[i.productId] ?? i.quantity ?? 1;
              return {
                'capsuleCount': capsuleCount,
                'productId': i.productId,
                'quantity': quantity,
              };
            })
            .toList(),
      };
    }
    final couponCode = cart?.couponCode;
    if (couponCode != null && couponCode.toString().trim().isNotEmpty) {
      body['couponCode'] = couponCode;
    }
    if (shippingAddressId != null && shippingAddressId.isNotEmpty) {
      body['shippingAddressId'] = shippingAddressId;
    }
    return body;
  }

  /// Returns couponCode from cart (CartController) or from checkoutSummaryData if present in response.
  String? _getCouponCodeForSubscriptionSummary() {
    if (Get.isRegistered<CartController>()) {
      final cart = Get.find<CartController>().cartData.value?.cart;
      final cc = cart?.couponCode;
      if (cc != null && cc.toString().trim().isNotEmpty) {
        return cc.toString().trim();
      }
    }
    return null;
  }

  /// Load subscription actions summary (when fromSubscriptionUpdate).
  /// Uses same checkoutSummaryData shape; couponCode from cart if present.
  void _loadSubscriptionActionsSummary() {
    isLoadingSubscriptionPlans.value = true;
    _checkoutRepository.getSubscriptionActionsSummary(
      couponCode: _getCouponCodeForSubscriptionSummary(),
      onSuccess: (data) {
        try {
          if (data.data != null && data.data is Map<String, dynamic>) {
            checkoutSummaryData.value = CheckoutSummaryData.fromJson(data.data as Map<String, dynamic>);
            final summary = checkoutSummaryData.value!;
            if (summary.cart != null && summary.cart!.items != null && summary.cart!.items!.isNotEmpty) {
              final firstVariant = summary.cart!.items!.first.variant;
              variantType.value = firstVariant ?? 'SACHETS';
            }
            if (summary.sachetsPlans != null && summary.sachetsPlans!.isNotEmpty) {
              subscriptionPlans.value = summary.sachetsPlans!;
              final defaultPlan = subscriptionPlans.firstWhere(
                (plan) => plan.isSelected == true,
                orElse: () => subscriptionPlans.first,
              );
              selectedSubscriptionPlan.value = defaultPlan;
            } else {
              subscriptionPlans.clear();
            }
            if (summary.standUpPouchPlans != null) {
              for (final entry in summary.standUpPouchPlans!.entries) {
                final selected = entry.value.firstWhere(
                  (p) => p.isSelected == true,
                  orElse: () => entry.value.first,
                );
                selectedStandUpPouchPlanByProductId[entry.key] = selected;
              }
            }
          }
        } catch (e, stackTrace) {
          log('Error parsing subscription actions summary: $e');
          log('Stack trace: $stackTrace');
          subscriptionPlans.clear();
        } finally {
          isLoadingSubscriptionPlans.value = false;
        }
      },
      onError: (error) {
        log('Error loading subscription actions summary: ${error.message}');
        subscriptionPlans.clear();
        isLoadingSubscriptionPlans.value = false;
        AppFunctions().showToast(error.message, bgColor: AppColors.red);
      },
    );
  }

  /// Call subscription actions summary with shipping address and coupon (when fromSubscriptionUpdate, continuing from address step).
  /// On success moves to payment step.
  void continueFromAddressStepWithSubscriptionSummary() {
    final addressId = selectedAddress.value?.id;
    if(addresses.isEmpty){
      AppFunctions().showToast('checkout_add_address_required'.tr, bgColor: AppColors.red);
      return;
    }
    if (addressId == null || addressId.toString().trim().isEmpty) {
      AppFunctions().showToast('checkout_select_address_required'.tr, bgColor: AppColors.red);
      return;
    }
    isLoadingSubscriptionPlans.value = true;
    _checkoutRepository.getSubscriptionActionsSummary(
      couponCode: _getCouponCodeForSubscriptionSummary(),
      shippingAddressId: addressId.toString().trim(),
      onSuccess: (data) {
        try {
          if (data.data != null && data.data is Map<String, dynamic>) {
            checkoutSummaryData.value = CheckoutSummaryData.fromJson(data.data as Map<String, dynamic>);
            final summary = checkoutSummaryData.value!;
            if (summary.sachetsPlans != null && summary.sachetsPlans!.isNotEmpty) {
              subscriptionPlans.value = summary.sachetsPlans!;
              final defaultPlan = subscriptionPlans.firstWhere(
                (plan) => plan.isSelected == true,
                orElse: () => subscriptionPlans.first,
              );
              selectedSubscriptionPlan.value = defaultPlan;
            }
            if (summary.standUpPouchPlans != null) {
              for (final entry in summary.standUpPouchPlans!.entries) {
                final selected = entry.value.firstWhere(
                  (p) => p.isSelected == true,
                  orElse: () => entry.value.first,
                );
                selectedStandUpPouchPlanByProductId[entry.key] = selected;
              }
            }
            currentStep.value++;
          }
        } catch (e, stackTrace) {
          log('Error parsing subscription actions summary: $e');
          log('Stack trace: $stackTrace');
          AppFunctions().showToast('checkout_update_summary_failed'.tr, bgColor: AppColors.red);
        } finally {
          isLoadingSubscriptionPlans.value = false;
        }
      },
      onError: (error) {
        isLoadingSubscriptionPlans.value = false;
        AppFunctions().showToast(error.message, bgColor: AppColors.red);
      },
    );
  }

  /// Load checkout page summary from API
  void _loadCheckoutPageSummary() {
    // Get CartController
    CartController? cartController;
    if (Get.isRegistered<CartController>()) {
      cartController = Get.find<CartController>();
    } else {
      cartController = Get.put(CartController());
    }

    if (cartController == null) return;

    // Check if cartData is null, if so initialize cart items first
    if (cartController.cartData.value == null) {
      // Call initializeCartItems (it's async but returns void)
      cartController.initializeCartItems();
      // Wait for cart to be loaded, then call checkout API
      // Use ever() to listen for cartData changes
      ever(cartController.cartData, (cartData) {
        if (cartData != null) {
          _callCheckoutPageSummary(cartData.cart);
        }
      });
    } else {
      _callCheckoutPageSummary(cartController.cartData.value?.cart);
    }
  }

  /// Call checkout page summary API with body built from cart items
  void _callCheckoutPageSummary(cart_model.Cart? cart) {
    variantType.value = cart?.variantType ?? 'SACHETS';
    isLoadingSubscriptionPlans.value = true;
    final body = _buildCheckoutSummaryBody(
      cart,
      shippingAddressId: selectedAddress.value?.id,
      standUpPouchCapsuleByProductId: selectedStandUpPouchPlanByProductId.isEmpty ? null : selectedStandUpPouchPlanByProductId.map((k, v) => MapEntry(k, v.capsuleCount ?? 0)),
      standUpPouchQuantityByProductId: standUpPouchQuantityByProductId.isEmpty ? null : standUpPouchQuantityByProductId,
    );
    _checkoutRepository.getCheckoutPageSummary(
      body: body,
      onSuccess: (data) {
        try {
          if (data.data != null && data.data is Map<String, dynamic>) {
            checkoutSummaryData.value = CheckoutSummaryData.fromJson(data.data as Map<String, dynamic>);
            final summary = checkoutSummaryData.value!;
            if (summary.sachetsPlans != null && summary.sachetsPlans!.isNotEmpty) {
              subscriptionPlans.value = summary.sachetsPlans!;
              final defaultPlan = subscriptionPlans.firstWhere(
                (plan) => plan.isSelected == true,
                orElse: () => subscriptionPlans.first,
              );
              selectedSubscriptionPlan.value = defaultPlan;
            } else {
              subscriptionPlans.clear();
            }
            if (summary.standUpPouchPlans != null) {
              for (final entry in summary.standUpPouchPlans!.entries) {
                final selected = entry.value.firstWhere(
                  (p) => p.isSelected == true,
                  orElse: () => entry.value.first,
                );
                selectedStandUpPouchPlanByProductId[entry.key] = selected;
              }
            }
          }
        } catch (e, stackTrace) {
          log('Error parsing checkout page summary: $e');
          log('Stack trace: $stackTrace');
          subscriptionPlans.clear();
        } finally {
          isLoadingSubscriptionPlans.value = false;
        }
      },
      onError: (error) {
        log('Error loading checkout page summary: ${error.message}');
        subscriptionPlans.clear();
        isLoadingSubscriptionPlans.value = false;
     //   AppFunctions().showToast(error.message, bgColor: AppColors.red);
      },
    );
  }

  /// Call checkout page summary API with plan and address details
  void _callCheckoutPageSummaryWithParams({VoidCallback? onSuccessCallback}) {
    // Show loading dialog
    DialogService.showProgressDialog(message: 'checkout_updating_details'.tr);

    final cart = Get.find<CartController>().cartData.value?.cart;
    final sachetsPlanDurationDays = selectedSubscriptionPlan.value?.durationDays ?? 180;
    final shippingAddressId = selectedAddress.value?.id;
    final standUpPouchCapsules = selectedStandUpPouchPlanByProductId.map((k, v) => MapEntry(k, v.capsuleCount ?? 0));
    final body = _buildCheckoutSummaryBody(
      cart,
      shippingAddressId: shippingAddressId,
      sachetsPlanDurationDays: sachetsPlanDurationDays,
      standUpPouchCapsuleByProductId: standUpPouchCapsules.isEmpty ? null : standUpPouchCapsules,
      standUpPouchQuantityByProductId: standUpPouchQuantityByProductId.isEmpty ? null : standUpPouchQuantityByProductId,
    );

    isLoadingSubscriptionPlans.value = true;
    // Call checkout page summary API
    _checkoutRepository.getCheckoutPageSummary(
      body: body,
      onSuccess: (data) {
        try {
          if (data.data != null && data.data is Map<String, dynamic>) {
            checkoutSummaryData.value = CheckoutSummaryData.fromJson(data.data as Map<String, dynamic>);
            final summary = checkoutSummaryData.value!;
            if (summary.sachetsPlans != null && summary.sachetsPlans!.isNotEmpty) {
              subscriptionPlans.value = summary.sachetsPlans!;
            }
            if (summary.standUpPouchPlans != null) {
              for (final entry in summary.standUpPouchPlans!.entries) {
                final selected = entry.value.firstWhere(
                  (p) => p.isSelected == true,
                  orElse: () => entry.value.first,
                );
                selectedStandUpPouchPlanByProductId[entry.key] = selected;
              }
            }
          }
          // Hide loading dialog
          DialogService.hideProgressDialog();
          // Call success callback if provided
          onSuccessCallback?.call();
        } catch (e, stackTrace) {
          log('Error parsing checkout page summary: $e');
          log('Stack trace: $stackTrace');
          // Hide loading dialog on error
          DialogService.hideProgressDialog();
        } finally {
          isLoadingSubscriptionPlans.value = false;
        }
      },
      onError: (error) {
        log('Error loading checkout page summary: ${error.message}');
        // Hide loading dialog on error
        DialogService.hideProgressDialog();
        isLoadingSubscriptionPlans.value = false;
      ///  AppFunctions().showToast(error.message, bgColor: AppColors.red);
      },
    );
  }

  void _initializeCartItems() {
    cartItems.value = [
      CartItemModel(
        id: '1',
        productName: 'Green Tea Extract',
        productImage: 'assets/images/product_one.png',
        packInfo: 'Pack 3 months',
        currentPrice: 15.22,
        originalPrice: 19.59,
        membershipDiscount: 2.09,
        quantity: 1,
      ),
      CartItemModel(
        id: '2',
        productName: 'Green Tea Extract',
        productImage: 'assets/images/product_one.png',
        packInfo: 'Pack 3 months',
        currentPrice: 15.22,
        originalPrice: 19.59,
        membershipDiscount: 2.09,
        quantity: 1,
      ),
    ];
  }

  void _applyAddressesAfterFetch(List<Address> list) {
    addresses.value = list;
    if (list.isEmpty) {
      selectedAddress.value = null;
      CheckoutInlineAddressHelper.ensureRegistered();
    } else {
      CheckoutInlineAddressHelper.removeIfRegistered();
      final defaultAddress = list.firstWhere(
        (addr) => addr.isDefault == true,
        orElse: () => list.first,
      );
      selectedAddress.value = defaultAddress;
    }
  }

  void loadAddresses() {
    isLoadingAddresses.value = true;
    _profileRepository.getAddresses(
      onSuccess: (response) {
        try {
          isLoadingAddresses.value = false;
          if (response.data != null && response.data['addresses'] != null) {
            final List<dynamic> addressesList = response.data['addresses'];
            _applyAddressesAfterFetch(
              addressesList.map((addressJson) => Address.fromJson(addressJson)).toList(),
            );
          } else {
            _applyAddressesAfterFetch([]);
          }
        } catch (e, stackTrace) {
          log('Error parsing addresses: $e');
          log('Stack trace: $stackTrace');
          isLoadingAddresses.value = false;
          _applyAddressesAfterFetch([]);
        }
      },
      onError: (error) {
        log('Error loading addresses: ${error.message}');
        isLoadingAddresses.value = false;
        _applyAddressesAfterFetch([]);
      },
    );
  }

  void selectSubscriptionPlan(SubscriptionPlan plan) {
    selectedSubscriptionPlan.value = plan;
    if (plan.isSubscription == false && plan.planKey != null) {
      if (!selectedCapsuleCounts.containsKey(plan.planKey!)) {
        selectedCapsuleCounts[plan.planKey!] = 60;
      }
    }
    // Only update local state; _buildCheckoutSummaryBody will use it when API is called (e.g. on continue).
  }

  void selectCapsuleCount(String planKey, int capsuleCount) {
    selectedCapsuleCounts[planKey] = capsuleCount;

    try {
      final plan = subscriptionPlans.firstWhere((p) => p.planKey == planKey);
      selectedSubscriptionPlan.value = plan;
    } catch (e) {
      if (checkoutSummaryData.value?.sachetsPlans != null) {
        try {
          final planFromData = checkoutSummaryData.value!.sachetsPlans!.firstWhere((p) => p.planKey == planKey);
          selectedSubscriptionPlan.value = planFromData;
        } catch (e2) {
          log('Plan with planKey $planKey not found');
        }
      }
    }
  }

  /// Selected stand-up pouch plan for a product (from map or from API response)
  SubscriptionPlan? getSelectedStandUpPouchPlan(String productId) {
    if (selectedStandUpPouchPlanByProductId.containsKey(productId)) {
      return selectedStandUpPouchPlanByProductId[productId];
    }
    final plans = checkoutSummaryData.value?.standUpPouchPlans?[productId];
    if (plans == null || plans.isEmpty) return null;
    try {
      return plans.firstWhere((p) => p.isSelected == true, orElse: () => plans.first);
    } catch (_) {
      return plans.first;
    }
  }

  /// User selected a different stand-up pouch plan (capsule option). Only update local state; _buildCheckoutSummaryBody will use it when API is called.
  void selectStandUpPouchPlan(String productId, SubscriptionPlan plan) {
    selectedStandUpPouchPlanByProductId[productId] = plan;
  }

  int getSelectedCapsuleCount(String planKey, int defaultCount) {
    return selectedCapsuleCounts[planKey] ?? defaultCount;
  }

  /// Update stand-up pouch quantity locally only; _buildCheckoutSummaryBody will use it when API is called. No cart/checkout API.
  void updateStandUpPouchQuantity(String productId, int newQuantity) {
    if (productId.isEmpty) return;
    final qty = newQuantity.clamp(1, 99);
    standUpPouchQuantityByProductId[productId] = qty;
  }

  /// Resolved quantity for stand-up pouch item: local override or from checkout summary cart.
  int getStandUpPouchQuantity(String productId) {
    final q = standUpPouchQuantityByProductId[productId];
    if (q != null) return q;
    final items = checkoutSummaryData.value?.cart?.items ?? [];
    for (final i in items) {
      if (i.productId == productId && i.variant == 'STAND_UP_POUCH') return i.quantity ?? 1;
    }
    return 1;
  }

  /// When quantity is 1 and user taps decrement: show confirmation dialog, then remove item from cart via API (same as cart_view).
  void confirmRemoveStandUpPouchItem(String productId) {
    if (productId.isEmpty) return;
    _showRemoveStandUpPouchItemDialog(productId);
  }

  void _showRemoveStandUpPouchItemDialog(String productId) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(20.r)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.center,
                child: Text('checkout_remove_item'.tr, style: TextStyles.medium(21.sp, fontColor: AppColors.black1414141)),
              ),
              Gap(6.h),
              Align(
                alignment: Alignment.center,
                child: Text(
                  'checkout_remove_item_confirm'.tr,
                  textAlign: TextAlign.center,
                  style: TextStyles.regular(16.sp, fontColor: AppColors.black1414141),
                ),
              ),
              Gap(18.h),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.red,
                        foregroundColor: AppColors.white,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40.r)),
                        elevation: 0,
                      ),
                      child: Text('common_cancel'.tr, style: TextStyles.medium(16.sp, fontColor: AppColors.white)),
                    ),
                  ),
                  Gap(10.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        final cartController = Get.isRegistered<CartController>() ? Get.find<CartController>() : null;
                        if (cartController == null || cartController.cartData.value?.cart?.items == null) {
                          CustomToast.show(message: 'checkout_cart_unavailable'.tr, context: Get.context!);
                          return;
                        }
                        cart_model.CartItem? cartItem;
                        for (final i in cartController.cartData.value!.cart!.items!) {
                          if (i.productId == productId && i.variantType == 'STAND_UP_POUCH') {
                            cartItem = i;
                            break;
                          }
                        }
                        if (cartItem == null) {
                          CustomToast.show(message: 'checkout_item_not_found'.tr, context: Get.context!);
                          return;
                        }
                        standUpPouchQuantityByProductId.remove(productId);
                        selectedStandUpPouchPlanByProductId.remove(productId);
                        cartController.removeCartItem(cartItem, onRemoved: () {
                          refreshCheckoutSummary();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.black1414141,
                        foregroundColor: AppColors.white,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40.r)),
                        elevation: 0,
                      ),
                      child: Text('common_remove'.tr, style: TextStyles.medium(16.sp, fontColor: AppColors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Public refresh of checkout summary from current cart (e.g. after quantity change).
  void refreshCheckoutSummary() {
    final cart = Get.isRegistered<CartController>() ? Get.find<CartController>().cartData.value?.cart : null;
    _callCheckoutPageSummary(cart);
  }

  void continueToNextStep() {
    if (currentStep.value < 3) {
      // If moving from address step (step 2) to payment step (step 3), call API first
      if (currentStep.value == 2) {
        _callCheckoutPageSummaryWithParams(
          onSuccessCallback: () {
            // Only increment step after API response is received
            currentStep.value++;
          },
        );
      } else {
        // For other steps, increment immediately
        currentStep.value++;
      }
    } else if (currentStep.value == 3) {
      // On payment step, show payment method selection
      // This will be handled in the view
    }
  }

  /// Create order with selected payment method
  void createOrder(String paymentMethod) {
    final checkoutData = checkoutSummaryData.value;
    if (checkoutData == null) {
      Get.snackbar('common_error'.tr, 'checkout_data_unavailable'.tr);
      return;
    }

    final pricing = checkoutData.pricing;
    final cartId = checkoutData.cart?.cartId;
    if (pricing == null || cartId == null || cartId.toString().isEmpty) {
      CustomToast.show(message: "Cart data not available", context: Get.context!);
      return;
    }

    final cart = Get.find<CartController>().cartData.value?.cart;
    final sachetsPlanDurationDays = selectedSubscriptionPlan.value?.durationDays ?? 180;
    final shippingAddressId = selectedAddress.value?.id;
    final standUpPouchCapsules = selectedStandUpPouchPlanByProductId.map((k, v) => MapEntry(k, v.capsuleCount ?? 0));
    final baseBody = _buildCheckoutSummaryBody(
      cart,
      shippingAddressId: shippingAddressId,
      sachetsPlanDurationDays: sachetsPlanDurationDays,
      standUpPouchCapsuleByProductId: standUpPouchCapsules.isEmpty ? null : standUpPouchCapsules,
      standUpPouchQuantityByProductId: standUpPouchQuantityByProductId.isEmpty ? null : standUpPouchQuantityByProductId,
    );

    final Map<String, dynamic> body = {
      ...baseBody,
      'cartId': cartId.toString(),
      'pricing': pricing.toJson(),
      'paymentMethod': paymentMethod,
    };
    if (appliedDiscountCode.value.isNotEmpty) {
      body['couponCode'] = appliedDiscountCode.value;
    }

    DialogService.showProgressDialog(message: 'checkout_processing_order'.tr);

    _checkoutRepository.createOrder(
      body: body,
      onSuccess: (orderData) {
        log('Order created successfully: ${orderData.data}');
        // Extract orderId from response (or use empty string for now)
        String orderId = '';
        if (orderData.data != null && orderData.data is Map<String, dynamic>) {
          final orderResponse = orderData.data as Map<String, dynamic>;
          orderId = orderResponse['order']['id']?.toString() ?? '';
        }
        DialogService.hideProgressDialog();
        // Call payment API after order creation
        _createPayment(orderId: orderId, paymentMethod: paymentMethod);
      },
      onError: (error) {
        DialogService.hideProgressDialog();
        AppFunctions().showToast(error.message, bgColor: AppColors.red);
        // log('Error creating order: ${error.message}');
        // Get.snackbar('Error', error.message);
      },
    );
  }

  /// Create payment for the order
  void _createPayment({required String orderId, required String paymentMethod}) {
    DialogService.showProgressDialog(message: 'checkout_processing_payment'.tr);
    final Map<String, dynamic> body = {'orderId': orderId.isEmpty ? '' : orderId, 'paymentMethod': paymentMethod};

    _checkoutRepository.createPayment(
      body: body,
      onSuccess: (data) {
        DialogService.hideProgressDialog();
        log('Payment created successfully: ${data.data}');

        // Extract payment URL from response
        String? paymentUrl;
        String? orderId;
        if (data.data != null && data.data is Map<String, dynamic>) {
          final responseData = data.data as Map<String, dynamic>;
          // Try different possible keys for the URL
          paymentUrl = responseData['gateway']['redirectUrl'];
          orderId = responseData['payment']['orderId'];
        }

        if (paymentUrl != null && paymentUrl.isNotEmpty) {
          // Navigate to payment webview with the URL
          Get.to(() => PaymentWebView(webUrl: paymentUrl!, orderId: orderId));
        }
      },
      onError: (error) {
        DialogService.hideProgressDialog();
        AppFunctions().showToast(error.message, bgColor: AppColors.red);
        // log('Error creating payment: ${error.message}');
        // Get.snackbar('Error', error.message);
      },
    );
  }

  void goToPreviousStep() {
    if (currentStep.value > 1) {
      currentStep.value--;
    }
  }

  /// Confirm subscription update (fromSubscriptionUpdate flow). Then get order detail and redirect to order complete.
  void confirmSubscriptionUpdateAndRedirect() {
    final cartId = checkoutSummaryData.value?.cart?.cartId?.toString();
    final subId = subscriptionId.value.toString().trim();
    if (cartId == null || cartId.isEmpty) {
      AppFunctions().showToast('checkout_cart_unavailable'.tr, bgColor: AppColors.red);
      return;
    }
    if (subId.isEmpty) {
      AppFunctions().showToast('checkout_subscription_unavailable'.tr, bgColor: AppColors.red);
      return;
    }

    DialogService.showProgressDialog(message: 'checkout_updating_plan'.tr);

    _checkoutRepository.confirmSubscriptionUpdate(
      subscriptionId: subId,
      cartId: cartId,
      onSuccess: (data) {
        try {
          final renewalOrderId = data.data is Map<String, dynamic>
              ? (data.data as Map<String, dynamic>)['renewalOrderId']?.toString()
              : null;
          if (renewalOrderId == null || renewalOrderId.isEmpty) {
            DialogService.hideProgressDialog();
            AppFunctions().showToast('common_invalid_response'.tr, bgColor: AppColors.red);
            return;
          }
          _fetchOrderAndRedirectToOrderComplete(renewalOrderId);
        } catch (e) {
          DialogService.hideProgressDialog();
          log('Error parsing subscription update confirm: $e');
          AppFunctions().showToast('common_error'.tr, bgColor: AppColors.red);
        }
      },
      onError: (error) {
        DialogService.hideProgressDialog();
        AppFunctions().showToast(error.message, bgColor: AppColors.red);
      },
    );
  }

  /// Fetch order details by orderId then clear cart and redirect to order complete (same as payment_webview).
  void _fetchOrderAndRedirectToOrderComplete(String orderId) {
    _ordersRepository.getOrderDetail(
      orderId: orderId,
      onSuccess: (data) {
        DialogService.hideProgressDialog();
        OrderData? orderData;
        if (data.data != null && data.data is Map<String, dynamic>) {
          try {
            final map = data.data as Map<String, dynamic>;
            if (map['order'] != null) {
              orderData = OrderData.fromJson(map['order'] as Map<String, dynamic>);
            }
          } catch (e) {
            log('Error parsing OrderData: $e');
          }
        }
        _clearCartAfterSubscriptionUpdate();
        CheckoutController._skipApisAfterSubscriptionCompleteRedirect = true;
        Get.offNamedUntil(
          AppRoutes.orderComplete,
          (route) => route.settings.name == AppRoutes.dashboard,
          arguments: {'orderData': orderData, 'fromSubscriptionUpdate': true},
        );
      },
      onError: (error) {
        DialogService.hideProgressDialog();
        log('Error fetching order details: ${error.message}');
        _clearCartAfterSubscriptionUpdate();
        CheckoutController._skipApisAfterSubscriptionCompleteRedirect = true;
        Get.offNamedUntil(
          AppRoutes.orderComplete,
          (route) => route.settings.name == AppRoutes.dashboard,
          arguments: {'fromSubscriptionUpdate': true},
        );
        AppFunctions().showToast(error.message, bgColor: AppColors.red);
      },
    );
  }

  void _clearCartAfterSubscriptionUpdate() {
    _cartRepository.clearCart(
      onSuccess: (_) {
        log('Cart cleared after subscription update');
        _clearLocalCartObjectsAfterSubscriptionUpdate();
      },
      onError: (error) {
        log('Error clearing cart: $error');
        _clearLocalCartObjectsAfterSubscriptionUpdate();
      },
    );
  }

  void _clearLocalCartObjectsAfterSubscriptionUpdate() {
    if (Get.isRegistered<CartController>()) {
      try {
        final cartController = Get.find<CartController>();
        cartController.cartData.value = null;
        cartController.appliedDiscountCode.value = '';
        cartController.discountCodeController.clear();
      } catch (e) {
        log('Error clearing cart controller: $e');
      }
    }
    if (Get.isRegistered<CartCountService>()) {
      try {
        CartCountService.to.updateCartCount(0);
      } catch (e) {
        log('Error updating cart count: $e');
      }
    }
    if (Get.isRegistered<ShopAllController>()) {
      try {
        final shopAllController = Get.find<ShopAllController>();
        for (var product in shopAllController.products) {
          product.isInCart = false;
        }
        shopAllController.products.refresh();
        for (var product in shopAllController.categoryProducts) {
          product.isInCart = false;
        }
        shopAllController.categoryProducts.refresh();
        if (shopAllController.selectedProduct.value != null) {
          shopAllController.selectedProduct.value?.isInCart = false;
          shopAllController.selectedProduct.refresh();
        }
      } catch (e) {
        log('Error clearing product cart status: $e');
      }
    }
  }

  void selectAddress(Address address) {
    selectedAddress.value = address;
    // Store selected address; shippingAddressId is selectedAddress.value?.id, passed when building body (no API call here)
  }

  void addNewAddress() {
    Get.toNamed(AppRoutes.addAddress, arguments: {'isEdit': false});
  }

  void editAddress(Address address) {
    // Navigate to edit address screen
    Get.toNamed(AppRoutes.addAddress, arguments: {'isEdit': true, 'addressId': address.id ?? ''});
  }

  void deleteAddress(Address address) {
    if (address.id == null || address.id!.isEmpty) {
      CustomToast.show(message: "Address ID not available", context: Get.context!);
      return;
    }

    // Show confirmation dialog
    _showDeleteAddressDialog(address);
  }

  void _showDeleteAddressDialog(Address address) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(20.r)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.center,
                child: Text('checkout_delete_address'.tr, style: TextStyles.medium(21.sp, fontColor: AppColors.black1414141)),
              ),
              Gap(6.h),
              Align(
                alignment: Alignment.center,
                child: Text(
                  'checkout_delete_address_confirm'.tr,
                  style: TextStyles.regular(16.sp, fontColor: AppColors.black1414141),
                ),
              ),
              Gap(18.h),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.red,
                        foregroundColor: AppColors.white,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40.r)),
                        elevation: 0,
                      ),
                      child: Text('common_cancel'.tr, style: TextStyles.medium(16.sp, fontColor: AppColors.white)),
                    ),
                  ),
                  Gap(10.w),
                  Expanded(
                    child: Obx(() {
                      return ElevatedButton(
                        onPressed: isDeletingAddress.value
                            ? null
                            : () async {
                                await _performDeleteAddress(address);
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.black1414141,
                          foregroundColor: AppColors.white,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40.r)),
                          elevation: 0,
                        ),
                        child: isDeletingAddress.value
                            ? SizedBox(
                                width: 20.w,
                                height: 20.w,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                                ),
                              )
                            : Text('common_yes'.tr, style: TextStyles.medium(16.sp, fontColor: AppColors.white)),
                      );
                    }),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  final RxBool isDeletingAddress = false.obs;

  Future<void> _performDeleteAddress(Address address) async {
    if (address.id == null || address.id!.isEmpty) return;

    isDeletingAddress.value = true;

    await _profileRepository.deleteAddressAPI(
      addressId: address.id!,
      onSuccess: (response) {
        isDeletingAddress.value = false;
        Get.back(); // Close dialog
        CustomToast.show(message: response.message ?? 'address_deleted_success'.tr, context: Get.context!);

        // Remove address from list with animation
        final index = addresses.indexWhere((a) => a.id == address.id);
        if (index != -1) {
          addresses.removeAt(index);

          // If deleted address was selected, pick another or clear
          if (selectedAddress.value?.id == address.id) {
            if (addresses.isNotEmpty) {
              selectedAddress.value = addresses.firstWhere(
                (a) => a.isDefault == true,
                orElse: () => addresses.first,
              );
            } else {
              selectedAddress.value = null;
            }
          }
        }
        if (addresses.isEmpty) {
          selectedAddress.value = null;
          CheckoutInlineAddressHelper.ensureRegistered();
        }
      },
      onError: (error) {
        isDeletingAddress.value = false;
        Get.back(); // Close dialog
        CustomToast.show(message: error.message, context: Get.context!);
      },
    );
  }

  void removeCartItem(CartItemModel item) {
    cartItems.remove(item);
  }

  void applyDiscountCode(String code) async {
    if (code.isEmpty) return;

    // Get CartController to access cart ID
    CartController? cartController;
    if (Get.isRegistered<CartController>()) {
      cartController = Get.find<CartController>();
    } else {
      cartController = Get.put(CartController());
    }

    if (cartController == null || cartController.cartData.value?.cart?.id == null) {
      CustomToast.show(message: 'checkout_cart_unavailable'.tr, context: Get.context!);
      return;
    }

    // Show loading state
    DialogService.showProgressDialog(message: 'cart_applying_discount'.tr);

    // Call API to validate coupon code (using CartRepository)
    final cartRepository = CartRepository();
    cartRepository.validateCoupon(
      body: {"cartId": cartController.cartData.value?.cart?.id, "couponCode": code},
      onSuccess: (data) {
        try {
          if (data.data != null && data.data is Map<String, dynamic>) {
            final responseData = data.data as Map<String, dynamic>;

            // Check if coupon was successfully applied
            if (data.success == true && responseData['cart'] != null) {
              try {
                // Access cart object directly from response
                final cartMap = responseData['cart'] as Map<String, dynamic>;

                // Update cart in CartController
                if (cartController != null && cartController.cartData.value?.cart != null) {
                  final currentCart = cartController.cartData.value!.cart!;

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
                  if (cartController != null) {
                    cartController.cartData.refresh();
                  }
                }

                // Store the coupon code if it was applied
                final couponCode = responseData['couponCode'] as String?;
                if (couponCode != null && couponCode.isNotEmpty) {
                  appliedDiscountCode.value = couponCode;
                } else {
                  // If couponCode is null but success is true, use the entered code
                  appliedDiscountCode.value = code;
                }

                // Refresh checkout summary to update pricing
                if (currentStep.value == 3) {
                  _callCheckoutPageSummaryWithParams();
                }

                discountCodeController.clear();
                DialogService.hideProgressDialog();
              } catch (e, stackTrace) {
                log('Error updating cart fields from coupon validation: $e');
                log('Stack trace: $stackTrace');
                DialogService.hideProgressDialog();
              }
            } else {
              // Coupon validation failed
              DialogService.hideProgressDialog();
              final message = data.message ?? 'cart_invalid_discount_code'.tr;
            }
          } else {
            DialogService.hideProgressDialog();
          }
        } catch (e, stackTrace) {
          log('Error processing coupon validation response: $e');
          log('Stack trace: $stackTrace');
          DialogService.hideProgressDialog();
        }
      },
      onError: (error) {
        log('Error validating coupon code: ${error.message}');
        DialogService.hideProgressDialog();
        AppFunctions().showToast(error.message, bgColor: AppColors.red);
      },
    );
  }

  void removeCouponCode() async {
    // Get CartController to access cart ID
    CartController? cartController;
    if (Get.isRegistered<CartController>()) {
      cartController = Get.find<CartController>();
    } else {
      cartController = Get.put(CartController());
    }

    if (cartController == null || cartController.cartData.value?.cart?.id == null) {
      CustomToast.show(message: 'checkout_cart_unavailable'.tr, context: Get.context!);
      return;
    }

    // Show loading state
    DialogService.showProgressDialog(message: 'cart_removing_coupon'.tr);

    // Call API to remove coupon code by sending without couponCode
    final cartRepository = CartRepository();
    cartRepository.validateCoupon(
      body: {"cartId": cartController.cartData.value?.cart?.id},
      onSuccess: (data) {
        try {
          if (data.data != null && data.data is Map<String, dynamic>) {
            final responseData = data.data as Map<String, dynamic>;

            // Update cart fields if cart data is present
            if (responseData['cart'] != null && cartController != null && cartController.cartData.value?.cart != null) {
              final cartMap = responseData['cart'] as Map<String, dynamic>;
              final currentCart = cartController.cartData.value!.cart!;

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
              if (cartController != null) {
                cartController.cartData.refresh();
              }
            }
          }

          // Close dialog first before refreshing checkout summary
          DialogService.hideProgressDialog();

          // Refresh checkout summary to update pricing

          CustomToast.show(message: "Coupon code removed successfully", context: Get.context!);
        } catch (e, stackTrace) {
          log('Error removing coupon code: $e');
          log('Stack trace: $stackTrace');
          DialogService.hideProgressDialog();
        }
      },
      onError: (error) {
        log('Error removing coupon code: ${error.message}');
        DialogService.hideProgressDialog();
        AppFunctions().showToast(error.message, bgColor: AppColors.red);
      },
    );
  }

  @override
  void onClose() {
    CheckoutInlineAddressHelper.removeIfRegistered();
    discountCodeController.dispose();
    super.onClose();
  }
}

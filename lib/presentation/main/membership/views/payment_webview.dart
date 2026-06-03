import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:gap/gap.dart';
import 'dart:developer';
import 'package:viteezy/core/theme/app_colors.dart';
import 'package:viteezy/core/theme/text_styles.dart';
import 'package:viteezy/core/widgets/custom_toast.dart';
import 'package:viteezy/core/widgets/common_appbar.dart';
import 'package:viteezy/core/widgets/common_button.dart';
import 'package:viteezy/core/repositories/order_repository.dart';
import 'package:viteezy/core/repositories/cart_repository.dart';
import 'package:viteezy/core/routes/app_routes.dart';
import 'package:viteezy/core/models/oders_history_model.dart';
import 'package:viteezy/core/services/cart_count_service.dart';
import '../../../../core/utils/app_functions.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../shop_all_view/controller/shop_all_controller.dart';

class PaymentWebView extends StatefulWidget {
  final String webUrl;
  final String? orderId;

  const PaymentWebView({super.key, required this.webUrl, this.orderId});

  @override
  State<PaymentWebView> createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  late final WebViewController _webViewController;
  bool _isLoading = true;
  bool _hasShownStatusDialog = false;
  final OrdersRepository _ordersRepository = OrdersRepository();
  final CartRepository _cartRepository = CartRepository();

  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });

            // Check payment status from URL
            if (!_hasShownStatusDialog) {
              _checkPaymentStatusFromUrl(url);
            }
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.webUrl));
  }

  void _checkPaymentStatusFromUrl(String url) {
    if (_hasShownStatusDialog || !mounted) return;

    final lowerUrl = url.toLowerCase();

    // Check for success patterns
    if (lowerUrl.contains('success') ||
        lowerUrl.contains('payment-success') ||
        lowerUrl.contains('payment_success') ||
        lowerUrl.contains('completed') ||
        lowerUrl.contains('payment-completed')) {
      _hasShownStatusDialog = true;
      Future.delayed(Duration(seconds: 1), () {
        if (mounted) {
          // If orderId is provided, call orders API and redirect to order complete
          if (widget.orderId != null && widget.orderId!.isNotEmpty) {
            _fetchOrderAndRedirect();
          } else {
            // Otherwise, show payment status dialog (membership flow)
            _showPaymentStatusDialog(
              title: 'payment_successful'.tr,
              message: 'Your payment has been processed successfully. Your membership is now active.',
              isSuccess: true,
            );
          }
        }
      });
    }
    // Check for failure patterns
    else if (lowerUrl.contains('failed') ||
        lowerUrl.contains('payment-failed') ||
        lowerUrl.contains('payment_failed') ||
        lowerUrl.contains('error') ||
        lowerUrl.contains('payment-error')) {
      _hasShownStatusDialog = true;
      Future.delayed(Duration(seconds: 1), () {
        if (mounted) {
          // For checkout flow (with orderId), remove all routes until dashboard
          if (widget.orderId != null && widget.orderId!.isNotEmpty) {
            Get.offNamedUntil(AppRoutes.dashboard, (route) => route.settings.name == AppRoutes.dashboard);
          } else {
            // For membership flow, show dialog
            _showPaymentStatusDialog(
              title: 'payment_failed'.tr,
              message: 'Your payment could not be processed. Please try again.',
              isSuccess: false,
            );
          }
        }
      });
    }
    // Check for cancel patterns
    else if (lowerUrl.contains('cancel') ||
        lowerUrl.contains('payment-cancel') ||
        lowerUrl.contains('payment_cancel') ||
        lowerUrl.contains('cancelled')) {
      _hasShownStatusDialog = true;
      Future.delayed(Duration(seconds: 1), () {
        if (mounted) {
          // For checkout flow (with orderId), remove all routes until dashboard
          if (widget.orderId != null && widget.orderId!.isNotEmpty) {
            Get.offNamedUntil(AppRoutes.dashboard, (route) => route.settings.name == AppRoutes.dashboard);
          } else {
            // For membership flow, show dialog
            _showPaymentStatusDialog(
              title: 'payment_cancelled'.tr,
              message: 'Your payment has been cancelled.',
              isSuccess: false,
            );
          }
        }
      });
    }
    // Check for refund patterns
    else if (lowerUrl.contains('refund') ||
        lowerUrl.contains('payment-refund') ||
        lowerUrl.contains('payment_refund') ||
        lowerUrl.contains('refunded')) {
      _hasShownStatusDialog = true;
      Future.delayed(Duration(seconds: 1), () {
        if (mounted) {
          _showPaymentStatusDialog(
            title: 'payment_refunded'.tr,
            message: 'Your payment has been refunded.',
            isSuccess: false,
          );
        }
      });
    }
  }

  /// Fetch order details and redirect to order complete screen
  void _fetchOrderAndRedirect() {
    if (widget.orderId == null || widget.orderId!.isEmpty) {
      return;
    }

    _ordersRepository.getOrderDetail(
      orderId: widget.orderId!,
      onSuccess: (data) {
        log('Order details fetched successfully: ${data.data}');
        // Parse OrderData from response
        OrderData? orderData;
        if (data.data != null && data.data is Map<String, dynamic>) {
          try {
            orderData = OrderData.fromJson(data.data['order'] as Map<String, dynamic>);
          } catch (e) {
            log('Error parsing OrderData: $e');
          }
        }

        // Clear cart after successful order
        _clearCart();

        // Remove all routes until dashboard, then navigate to order complete
        // This ensures back button goes to dashboard
        Get.offNamedUntil(
          AppRoutes.orderComplete,
          (route) => route.settings.name == AppRoutes.dashboard,
          arguments: {'orderData': orderData},
        );
      },
      onError: (error) {
        log('Error fetching order details: ${error.message}');
        // If order fetch fails, remove all routes until dashboard, then navigate to order complete
        Get.offNamedUntil(AppRoutes.orderComplete, (route) => route.settings.name == AppRoutes.dashboard);
        AppFunctions().showToast(error.message, bgColor: AppColors.red);
      },
    );
  }

  /// Clear cart API and local cart objects
  void _clearCart() {
    _cartRepository.clearCart(
      onSuccess: (data) {
        log('Cart cleared successfully');
        _clearLocalCartObjects();
      },
      onError: (error) {
        log('Error clearing cart: ${error.message}');
        // Still clear local cart objects even if API fails
        _clearLocalCartObjects();
        AppFunctions().showToast(error.message, bgColor: AppColors.red);
      },
    );
  }

  /// Clear local cart objects in CartController and update product cart status
  void _clearLocalCartObjects() {
    // Clear cart objects in CartController if registered
    if (Get.isRegistered<CartController>()) {
      try {
        final cartController = Get.find<CartController>();
        cartController.cartData.value = null;
        // Also clear discount code if needed
        cartController.appliedDiscountCode.value = '';
        cartController.discountCodeController.clear();
      } catch (e) {
        log('Error clearing cart controller: $e');
      }
    }

    // Update cart count to 0 in preferences
    if (Get.isRegistered<CartCountService>()) {
      try {
        final cartCountService = CartCountService.to;
        cartCountService.updateCartCount(0);
      } catch (e) {
        log('Error clearing cart count: $e');
      }
    }

    // Clear isInCart flags in ShopAllController if registered
    if (Get.isRegistered<ShopAllController>()) {
      try {
        final shopAllController = Get.find<ShopAllController>();

        // Update products list
        for (var product in shopAllController.products) {
          product.isInCart = false;
        }
        shopAllController.products.refresh();

        // Update categoryProducts list
        for (var product in shopAllController.categoryProducts) {
          product.isInCart = false;
        }
        shopAllController.categoryProducts.refresh();

        // Update selectedProduct if it exists
        if (shopAllController.selectedProduct.value != null) {
          shopAllController.selectedProduct.value?.isInCart = false;
          shopAllController.selectedProduct.refresh();
        }
      } catch (e) {
        log('Error clearing product cart status: $e');
      }
    }
  }

  void _showPaymentStatusDialog({
    required String title,
    required String message,
    required bool isSuccess,
    bool shouldCloseWebView = false,
  }) {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          title: Row(
            children: [
              Icon(
                isSuccess ? Icons.check_circle : Icons.error,
                color: isSuccess ? AppColors.successColor : AppColors.errorColor,
                size: 28.sp,
              ),
              Gap(12.w),
              Expanded(
                child: Text(title, style: TextStyles.bold(20.sp, fontColor: AppColors.black1414141)),
              ),
            ],
          ),
          content: Text(message, style: TextStyles.regular(14.sp, fontColor: AppColors.grey888888)),
          actions: [
            SizedBox(
              width: double.infinity,
              child: CommonButton(
                text: 'OK',
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  if (shouldCloseWebView) {
                    Get.back(); // Close WebView
                  } else {
                    Get.close(2); // Close WebView and membership view
                  }
                },
                color: isSuccess ? AppColors.primaryColor : AppColors.errorColor,
                height: 44.h,
                borderRadius: 8,
              ),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _onWillPop() async {
    // Show confirmation dialog
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          title: Text('payment_cancel_confirm'.tr, style: TextStyles.bold(20.sp, fontColor: AppColors.black1414141)),
          content: Text(
            'Are you sure you want to cancel the payment? Your transaction will be cancelled.',
            style: TextStyles.regular(14.sp, fontColor: AppColors.grey888888),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text('common_no'.tr, style: TextStyles.medium(16.sp, fontColor: AppColors.grey888888)),
            ),
            TextButton(
              onPressed: () {
                Get.close(2);
              },
              child: Text('payment_yes_cancel'.tr, style: TextStyles.medium(16.sp, fontColor: AppColors.errorColor)),
            ),
          ],
        );
      },
    );

    if (shouldPop == true) {
      CustomToast.show(context: context, message: 'Payment cancelled');
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) async {
        if (didPop) {
          return;
        }
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: CommonAppbar(
          title: 'payment_title'.tr,
          onLeadPress: () async {
            final shouldPop = await _onWillPop();
            if (shouldPop) {
              Get.back();
            }
          },
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _webViewController),
            if (_isLoading)
              Container(
                color: AppColors.white.withValues(alpha: 0.9),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: AppColors.primaryColor),
                      Gap(24.h),
                      Text('payment_please_wait'.tr, style: TextStyles.semiBold(18.sp, fontColor: AppColors.black1414141)),
                      Gap(12.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40.w),
                        child: Text(
                          'Do not refresh or close the app while payment is processing',
                          style: TextStyles.regular(14.sp, fontColor: AppColors.grey888888),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

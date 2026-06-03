import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:gap/gap.dart';

import '../../gen/assets.gen.dart';
import '../models/product_response_model.dart';
import '../theme/app_colors.dart';
import '../theme/text_styles.dart';
import 'custom_toast.dart';
import 'common_network_image.dart';

/// Reusable Product Card Widget
/// When using Hero, pass [screenName] so the tag is unique per screen (e.g. 'browse', 'shop_all').
/// Or pass [heroTag] for a custom tag (e.g. similar products with index).
class ProductCardWidget extends StatelessWidget {
  final Product product;
  final VoidCallback? onFavoriteTap;
  final Future<Map<String, dynamic>> Function()? onAddToCart;
  final VoidCallback? onTap;

  /// Screen name to build unique hero tag per screen: 'screenName_product_image_productId'
  final String? screenName;

  /// Custom hero tag (overrides screenName). Use for e.g. similar products with index.
  final Object? heroTag;
  final VoidCallback? onGoToCart;
  final bool isSubscriptionFlow;

  const ProductCardWidget({
    super.key,
    required this.product,
    this.onFavoriteTap,
    this.onAddToCart,
    this.onTap,
    this.screenName,
    this.heroTag,
    this.onGoToCart,
    this.isSubscriptionFlow = false,
  });

  /// Hero tag: custom [heroTag] if set, else 'screenName_product_image_productId' when [screenName] is set.
  Object? get _effectiveHeroTag =>
      heroTag ?? (screenName != null ? '${screenName}_product_image_${product.id ?? ''}' : null);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(color: AppColors.whiteFBF9F8, borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image Section
            Expanded(
              flex: 1,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.whiteFBF9F8,
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                      ),
                      child: _effectiveHeroTag != null
                          ? Hero(
                              tag: _effectiveHeroTag!,
                              child: CommonNetworkImage(
                                imageUrl: product.productImage ?? "",
                                fit: BoxFit.cover,
                                height: double.infinity,
                                width: double.infinity,
                              ),
                            )
                          : CommonNetworkImage(
                              imageUrl: product.productImage ?? "",
                              fit: BoxFit.cover,
                              height: double.infinity,
                              width: double.infinity,
                            ),
                    ),
                  ),
                  if (onFavoriteTap != null)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: onFavoriteTap,
                        child: Container(
                          padding: EdgeInsets.all(6.sp),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            (product.isLiked ?? false) ? Icons.favorite : Icons.favorite_border,
                            size: 18,
                            color: AppColors.black1414141,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Product Info Section
            Padding(
              padding: EdgeInsets.all(8.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name and Discount Tag
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.title ?? "",
                          style: TextStyles.semiBold(12.sp),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      Gap(4.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: AppColors.orangeF7A173,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(50),
                            bottomRight: Radius.circular(50),
                          ),
                        ),
                        child: Text(
                          'Save ${product.sachetPrices?.thirtyDays?.savingsPercentage}%',
                          style: TextStyles.medium(8.sp, fontColor: AppColors.white),
                        ),
                      ),
                    ],
                  ),
                  Gap(4.h),
                  // Product Description
                  HtmlWidget(
                    product.shortDescription ?? "",
                    textStyle: TextStyles.regular(8.sp, fontColor: AppColors.black1414141),
                  ),
                  // Text(
                  //   product.shortDescription ?? "",
                  //   style: TextStyles.regular(8.sp, fontColor: AppColors.black1414141),
                  //   maxLines: 2,
                  //   overflow: TextOverflow.ellipsis,
                  // ),
                  Gap(10.h),
                  Row(
                    children: [
                      Text('\$${product.sachetPrices?.thirtyDays?.totalAmount}', style: TextStyles.semiBold(12.sp)),
                      Gap(4),
                      Text(
                        '\$${product.sachetPrices?.thirtyDays?.amount}',
                        style: TextStyles.medium(
                          12.sp,
                          fontColor: AppColors.grey949597,
                          textDecoration: TextDecoration.lineThrough,
                        ),
                      ),
                      Spacer(),
                      Icon(Icons.star, size: 12.sp, color: AppColors.black1414141),
                      Gap(2.w),
                      Text("${product.ratingCount}", style: TextStyles.medium(12.sp)),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(
              width: double.infinity,
              child: _AnimatedAddToCartButton(
                product: product,
                onAddToCart: onAddToCart,
                onGoToCart: onGoToCart,
                isSubscriptionFlow: isSubscriptionFlow,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedAddToCartButton extends StatefulWidget {
  final Product product;
  final Future<Map<String, dynamic>> Function()? onAddToCart;
  final VoidCallback? onGoToCart;
  final bool isSubscriptionFlow;

  const _AnimatedAddToCartButton({
    required this.product,
    this.onAddToCart,
    this.onGoToCart,
    this.isSubscriptionFlow = false,
  });

  @override
  State<_AnimatedAddToCartButton> createState() => _AnimatedAddToCartButtonState();
}

enum _ButtonState { initial, adding, grayWithCheck, blackFilling, success }

class _AnimatedAddToCartButtonState extends State<_AnimatedAddToCartButton> with TickerProviderStateMixin {
  late AnimationController _grayFillAnimationController;
  late AnimationController _blackFillAnimationController;
  late AnimationController _scaleAnimationController;
  late Animation<double> _grayFillAnimation;
  late Animation<double> _blackFillAnimation;
  late Animation<double> _scaleAnimation;
  _ButtonState _buttonState = _ButtonState.initial;

  @override
  void initState() {
    super.initState();
    // Animation controller for gray fill animation
    _grayFillAnimationController = AnimationController(duration: const Duration(milliseconds: 400), vsync: this);
    _grayFillAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _grayFillAnimationController, curve: Curves.easeInOut));

    // Animation controller for black fill animation (faster than gray)
    _blackFillAnimationController = AnimationController(duration: const Duration(milliseconds: 250), vsync: this);
    _blackFillAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _blackFillAnimationController, curve: Curves.easeInOut));

    // Animation controller for checkmark scale
    _scaleAnimationController = AnimationController(duration: const Duration(milliseconds: 200), vsync: this);
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _scaleAnimationController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _grayFillAnimationController.dispose();
    _blackFillAnimationController.dispose();
    _scaleAnimationController.dispose();
    super.dispose();
  }

  void _onButtonPressed() async {
    // Don't allow adding if already in cart / subscription
    final alreadyAdded = widget.isSubscriptionFlow
        ? (widget.product.isInSubscription == true)
        : (widget.product.isInCart == true);
    if (alreadyAdded) return;
    if (_buttonState != _ButtonState.initial) return;
    if (widget.onAddToCart == null) return;

    setState(() {
      _buttonState = _ButtonState.adding;
    });

    // Start gray fill animation
    _grayFillAnimationController.forward(from: 0.0);

    try {
      // Wait for API call to complete
      final result = await widget.onAddToCart!();
      final success = result['success'] as bool;
      final message = result['message'] as String? ?? '';

      if (!mounted) return;

      if (success) {
        // Update product flag depending on flow
        if (widget.isSubscriptionFlow) {
          widget.product.isInSubscription = true;
        } else {
          widget.product.isInCart = true;
        }

        // API call succeeded - ensure gray fill is complete before proceeding
        // Wait for gray fill animation to complete (minimum 400ms for visual feedback)
        await Future.wait([_grayFillAnimationController.forward(), Future.delayed(const Duration(milliseconds: 400))]);

        if (!mounted) return;

        setState(() {
          _buttonState = _ButtonState.grayWithCheck;
        });

        // Start checkmark scale animation
        _scaleAnimationController.forward(from: 0.0);

        // Hold gray with checkmark for a moment, then start black fill
        await Future.delayed(const Duration(milliseconds: 500));
        if (!mounted) return;

        setState(() {
          _buttonState = _ButtonState.blackFilling;
        });

        // Start black fill animation (gray stays visible underneath)
        await _blackFillAnimationController.forward();
        if (!mounted) return;

        // Show snackbar with API message (only if login was successful, not showing login dialog)
        if (widget.onGoToCart != null) {
          CustomToast.showItemAddedToCart(
            context: context,
            message: message.isNotEmpty ? message : 'Item added to cart',
            onGoToCart: () {
              // Let parent handle navigation
              widget.onGoToCart?.call();
            },
          );
        } else {
          CustomToast.show(context: context, message: message.isNotEmpty ? message : 'Item added to cart');
        }

        // After animation completes, show "Added" state
        await Future.delayed(const Duration(milliseconds: 400));
        if (!mounted) return;

        _grayFillAnimationController.reset();
        _blackFillAnimationController.reset();
        _scaleAnimationController.reset();

        setState(() {
          _buttonState = _ButtonState.success;
        });
      } else {
        // Login failed or other error - reset button state without showing toast
        // (Login dialog is already shown by controller, so no need for toast)
        _grayFillAnimationController.stop();
        _grayFillAnimationController.reset();
        _blackFillAnimationController.reset();
        _scaleAnimationController.reset();

        if (mounted) {
          setState(() {
            _buttonState = _ButtonState.initial;
          });
        }
        // Don't show error toast if login dialog was shown (login check failed)
        // Only show toast for other API errors
        if (message.isNotEmpty && !message.toLowerCase().contains('login')) {
          CustomToast.show(context: context, message: message);
        }
      }
    } catch (e) {
      // Handle any errors
      if (!mounted) return;

      _grayFillAnimationController.stop();
      _grayFillAnimationController.reset();
      _blackFillAnimationController.reset();
      _scaleAnimationController.reset();

      setState(() {
        _buttonState = _ButtonState.initial;
      });

      // Show error message
      CustomToast.show(context: context, message: 'An error occurred. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if product is already in cart or subscription (depending on flow)
    final isInCart = widget.isSubscriptionFlow
        ? (widget.product.isInSubscription == true)
        : (widget.product.isInCart == true);
    if (widget.product.isInCart ?? false) {
      _buttonState = _ButtonState.success;
    } else {
      _buttonState = _ButtonState.initial;
    }

    return SizedBox(
      width: double.infinity,
      child: ClipRRect(
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10.r), bottomRight: Radius.circular(10.r)),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            // Base button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isInCart ? null : _onButtonPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isInCart ? AppColors.gray949391 : AppColors.textPrimary,
                  foregroundColor: AppColors.textOnPrimary,
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  minimumSize: Size(double.infinity, 40.h),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10.r),
                      bottomRight: Radius.circular(10.r),
                    ),
                  ),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  side: BorderSide.none,
                  surfaceTintColor: Colors.transparent,
                ),
                child: _buildButtonContent(),
              ),
            ),
            // Gray color fill animation overlay (during adding state)
            if (_buttonState == _ButtonState.adding)
              AnimatedBuilder(
                animation: _grayFillAnimation,
                builder: (context, child) {
                  return Positioned.fill(
                    child: IgnorePointer(
                      child: Stack(
                        children: [
                          // Gray fill animation
                          ClipRect(
                            child: FractionallySizedBox(
                              widthFactor: _grayFillAnimation.value,
                              alignment: Alignment.centerLeft,
                              child: SizedBox.expand(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.gray949391,
                                    borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(10.r),
                                      bottomRight: Radius.circular(10.r),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // "Adding" text on top of gray fill
                          Center(
                            child: Text(
                              'product_adding'.tr,
                              style: TextStyles.semiBold(14.sp, fontColor: AppColors.surfaceColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            // Gray background with checkmark (after gray fill completes)
            if (_buttonState == _ButtonState.grayWithCheck || _buttonState == _ButtonState.blackFilling)
              Positioned.fill(
                child: IgnorePointer(
                  child: Stack(
                    children: [
                      // Gray background (fully filled)
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.gray949391,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(10.r),
                            bottomRight: Radius.circular(10.r),
                          ),
                        ),
                      ),
                      // Black fill animation (only during blackFilling state)
                      if (_buttonState == _ButtonState.blackFilling)
                        AnimatedBuilder(
                          animation: _blackFillAnimation,
                          builder: (context, child) {
                            return ClipRect(
                              child: FractionallySizedBox(
                                widthFactor: _blackFillAnimation.value,
                                alignment: Alignment.centerLeft,
                                child: SizedBox.expand(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.textPrimary,
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(10.r),
                                        bottomRight: Radius.circular(10.r),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      // Checkmark icon on top of gray/black background
                      Center(
                        child: AnimatedBuilder(
                          animation: _scaleAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _scaleAnimation.value,
                              child: Assets.icons.icCheck.svg(
                                colorFilter: ColorFilter.mode(AppColors.white, BlendMode.srcIn),
                                width: 15.w,
                              ),
                            );
                          },
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

  Widget _buildButtonContent() {
    // If product is already in cart/subscription, show "Added" state
    final alreadyAdded = widget.isSubscriptionFlow
        ? (widget.product.isInSubscription == true)
        : (widget.product.isInCart == true);
    if (alreadyAdded) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Assets.icons.icCheck.svg(width: 15, height: 15, color: AppColors.surfaceColor),
          Gap(6.w),
          Text('product_added'.tr, style: TextStyles.semiBold(14.sp, fontColor: AppColors.surfaceColor)),
        ],
      );
    }

    switch (_buttonState) {
      case _ButtonState.initial:
        return Text('product_add_to_cart'.tr, style: TextStyles.semiBold(14.sp, fontColor: AppColors.surfaceColor));
      case _ButtonState.adding:
        return Text('product_adding'.tr, style: TextStyles.semiBold(14.sp, fontColor: AppColors.surfaceColor));
      case _ButtonState.grayWithCheck:
      case _ButtonState.blackFilling:
        // Icon is shown in overlay, so return empty widget
        return const SizedBox.shrink();
      case _ButtonState.success:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Assets.icons.icCheck.svg(width: 15, height: 15, color: AppColors.surfaceColor),
            Gap(6.w),
            Text('product_added'.tr, style: TextStyles.semiBold(14.sp, fontColor: AppColors.surfaceColor)),
          ],
        );
    }
  }
}

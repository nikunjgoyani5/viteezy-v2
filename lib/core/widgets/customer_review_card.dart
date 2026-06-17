import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gap/gap.dart';
import 'package:viteezy/presentation/main/home/views/home_view.dart';

import '../models/product_review_response_model.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';
import '../theme/text_styles.dart';
import 'common_network_image.dart';

/// Reusable Customer Review Card Widget
class CustomerReviewCard extends StatelessWidget {
  final ProductReview? review;

  const CustomerReviewCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        Get.toNamed(AppRoutes.productDetail, arguments: {'productId': review?.products?.first.id});
      },
      child: Container(
        width: 200.w,
        height: 375.h,
        margin: EdgeInsets.only(right: 16.w),
        decoration: BoxDecoration(
          color: AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border(
            left: BorderSide(width: 1.1, color: AppColors.grayE3E3DC),
            right: BorderSide(width: 1.1, color: AppColors.grayE3E3DC),
            top: BorderSide(width: 1.1, color: AppColors.grayE3E3DC),
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Half - Customer Image with Product Overlay
                Expanded(
                  flex: 2,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(12.r), topRight: Radius.circular(12.r)),
                      image: DecorationImage(
                        image: CachedNetworkImageProvider(review?.products?.first.productImage ?? ""),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Product Overlay - Bottom Lef
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    width: Get.width,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceColor,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(12.r),
                        bottomRight: Radius.circular(12.r),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: 40.h),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: Text(
                                review?.products?.first.shortDescription ?? '',
                                textAlign: TextAlign.center,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyles.regular(12.sp, fontColor: AppColors.black1414141),
                              ),
                            ),
                          ),
                        ),
                        Gap(8.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${review?.products?.first.sachetPrices?.thirtyDays?.currency} '
                                '${review?.products?.first.sachetPrices?.thirtyDays?.totalAmount}',
                                style: TextStyles.semiBold(18.sp, fontColor: AppColors.primaryColor),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                '${review?.products?.first.sachetPrices?.thirtyDays?.amount}',
                                style: TextStyles.medium(
                                  14.sp,
                                  fontColor: AppColors.gray919191,
                                  textDecoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          ),
                        ),
                        AnimatedReviewAddButton(
                          key: ValueKey('${review?.id}_${review?.products?.first.isInCart}'),
                          product: review?.products?.first,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              // bottom: 120.h,
              // left: 120.w,
              child: Padding(
                padding: EdgeInsets.only(top: 0.h),
                child: Center(
                  child: Container(
                    width: 55.w,
                    height: 60.h,
                    decoration: BoxDecoration(
                      // color: AppColors.surfaceColor,
                      borderRadius: BorderRadius.circular(8.r),
                      // image: DecorationImage(
                      //   image: CachedNetworkImageProvider(review?.videoThumbnail ?? ""),
                      //   fit: BoxFit.cover,
                      // ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: CommonNetworkImage(imageUrl: review?.videoThumbnail ?? ""),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// class _AnimatedReviewAddButton extends StatefulWidget {
//   final Product? product;
//
//   const _AnimatedReviewAddButton({super.key, required this.product});
//
//   @override
//   State<_AnimatedReviewAddButton> createState() => _AnimatedReviewAddButtonState();
// }
//
// enum _ReviewButtonState { initial, adding, grayWithCheck, blackFilling, success }
//
// class _AnimatedReviewAddButtonState extends State<_AnimatedReviewAddButton> with TickerProviderStateMixin {
//   late AnimationController _grayFillAnimationController;
//   late AnimationController _blackFillAnimationController;
//   late AnimationController _scaleAnimationController;
//   late Animation<double> _grayFillAnimation;
//   late Animation<double> _blackFillAnimation;
//   late Animation<double> _scaleAnimation;
//   _ReviewButtonState _buttonState = _ReviewButtonState.initial;
//
//   @override
//   void initState() {
//     super.initState();
//     // Animation controller for gray fill animation
//     _grayFillAnimationController = AnimationController(duration: const Duration(milliseconds: 400), vsync: this);
//     _grayFillAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(parent: _grayFillAnimationController, curve: Curves.easeInOut));
//
//     // Animation controller for black fill animation (faster than gray)
//     _blackFillAnimationController = AnimationController(duration: const Duration(milliseconds: 250), vsync: this);
//     _blackFillAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(parent: _blackFillAnimationController, curve: Curves.easeInOut));
//
//     // Animation controller for checkmark scale
//     _scaleAnimationController = AnimationController(duration: const Duration(milliseconds: 200), vsync: this);
//     _scaleAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(parent: _scaleAnimationController, curve: Curves.easeInOut));
//   }
//
//   @override
//   void dispose() {
//     _grayFillAnimationController.dispose();
//     _blackFillAnimationController.dispose();
//     _scaleAnimationController.dispose();
//     super.dispose();
//   }
//
//   void _onButtonPressed() async {
//     // Don't allow adding if already in cart
//     if (widget.product?.isInCart == true) return;
//     if (_buttonState != _ReviewButtonState.initial) return;
//     if (widget.product?.id == null || widget.product!.id!.isEmpty) {
//       CustomToast.show(context: context, message: 'Product ID is missing');
//       return;
//     }
//
//     setState(() {
//       _buttonState = _ReviewButtonState.adding;
//     });
//
//     // Start gray fill animation
//     _grayFillAnimationController.forward(from: 0.0);
//
//     try {
//       // Get ShopAllController for add to cart
//       if (Get.isRegistered<ShopAllController>()) {
//         final shopAllController = Get.find<ShopAllController>();
//         // Call add to cart API
//         final result = await shopAllController.addToCart(widget.product!.id!, "SACHETS");
//         final success = result['success'] as bool;
//         final message = result['message'] as String? ?? '';
//
//         if (!mounted) return;
//
//         if (success) {
//           // Update product's isInCart flag
//           widget.product!.isInCart = true;
//           // Update the product in the products list if it exists
//           final index = shopAllController.products.indexWhere((p) => p.id == widget.product!.id);
//           if (index != -1) {
//             shopAllController.products[index].isInCart = true;
//             shopAllController.products.refresh();
//           }
//           // Update categoryProducts if it exists
//           final categoryIndex = shopAllController.categoryProducts.indexWhere((p) => p.id == widget.product!.id);
//           if (categoryIndex != -1) {
//             shopAllController.categoryProducts[categoryIndex].isInCart = true;
//             shopAllController.categoryProducts.refresh();
//           }
//
//           // API call succeeded - ensure gray fill is complete before proceeding
//           // Wait for gray fill animation to complete (minimum 400ms for visual feedback)
//           await Future.wait([
//             _grayFillAnimationController.forward(),
//             Future.delayed(const Duration(milliseconds: 400)),
//           ]);
//
//           if (!mounted) return;
//
//           setState(() {
//             _buttonState = _ReviewButtonState.grayWithCheck;
//           });
//
//           // Start checkmark scale animation
//           _scaleAnimationController.forward(from: 0.0);
//
//           // Hold gray with checkmark for a moment, then start black fill
//           await Future.delayed(const Duration(milliseconds: 500));
//           if (!mounted) return;
//
//           setState(() {
//             _buttonState = _ReviewButtonState.blackFilling;
//           });
//
//           // Start black fill animation (gray stays visible underneath)
//           await _blackFillAnimationController.forward();
//           if (!mounted) return;
//
//           // Show snackbar with API message
//           CustomToast.showItemAddedToCart(
//             context: context,
//             message: message.isNotEmpty ? message : 'Item added to cart',
//             onGoToCart: () {
//               Get.toNamed(AppRoutes.cart);
//             },
//           );
//
//           // After animation completes, show "Added" state
//           await Future.delayed(const Duration(milliseconds: 400));
//           if (!mounted) return;
//
//           _grayFillAnimationController.reset();
//           _blackFillAnimationController.reset();
//           _scaleAnimationController.reset();
//
//           setState(() {
//             _buttonState = _ReviewButtonState.success;
//           });
//         } else {
//           // API call failed - stop animations and reset to initial state
//           _grayFillAnimationController.stop();
//           _grayFillAnimationController.reset();
//           _blackFillAnimationController.reset();
//           _scaleAnimationController.reset();
//
//           setState(() {
//             _buttonState = _ReviewButtonState.initial;
//           });
//
//           // Show error message from API
//           CustomToast.show(
//             context: context,
//             message: message.isNotEmpty ? message : 'Failed to add item to cart. Please try again.',
//           );
//         }
//       } else {
//         // ShopAllController not registered - reset animations
//         _grayFillAnimationController.stop();
//         _grayFillAnimationController.reset();
//         _blackFillAnimationController.reset();
//         _scaleAnimationController.reset();
//
//         setState(() {
//           _buttonState = _ReviewButtonState.initial;
//         });
//
//         CustomToast.show(context: context, message: 'Failed to add to cart');
//       }
//     } catch (e) {
//       // Handle any errors
//       if (!mounted) return;
//
//       _grayFillAnimationController.stop();
//       _grayFillAnimationController.reset();
//       _blackFillAnimationController.reset();
//       _scaleAnimationController.reset();
//
//       setState(() {
//         _buttonState = _ReviewButtonState.initial;
//       });
//
//       // Show error message
//       CustomToast.show(context: context, message: 'An error occurred. Please try again.');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // Wrap in Obx to make it reactive to changes in landingPageData
//     return Obx(() {
//       // Observe landingPageData to trigger rebuilds when products are updated
//       GlobalSettingsService.to.landingPageData.value;
//       // Check if product is already in cart (re-evaluate on each build)
//       final isInCart = widget.product?.isInCart == true;
//
//       // Reset button state if product was removed from cart
//       if (!isInCart && _buttonState == _ReviewButtonState.success) {
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           if (mounted) {
//             setState(() {
//               _buttonState = _ReviewButtonState.initial;
//             });
//           }
//         });
//       }
//
//       // Determine background color based on state
//       final backgroundColor =
//           (isInCart ||
//               _buttonState == _ReviewButtonState.success ||
//               _buttonState == _ReviewButtonState.grayWithCheck ||
//               _buttonState == _ReviewButtonState.blackFilling)
//           ? AppColors.gray949391
//           : AppColors.whiteFAF6E4;
//
//       return Container(
//         decoration: BoxDecoration(
//           color: backgroundColor,
//           border: Border(bottom: BorderSide(color: AppColors.grayE3E3DC, width: 1)),
//           borderRadius: BorderRadius.only(bottomLeft: Radius.circular(12.r), bottomRight: Radius.circular(12.r)),
//         ),
//         child: ClipRRect(
//           clipBehavior: Clip.antiAlias,
//           borderRadius: BorderRadius.only(bottomLeft: Radius.circular(12.r), bottomRight: Radius.circular(12.r)),
//           child: Stack(
//             clipBehavior: Clip.hardEdge,
//             children: [
//               // Base button
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: isInCart ? null : _onButtonPressed,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: backgroundColor,
//                     foregroundColor: AppColors.textPrimary,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.only(
//                         bottomLeft: Radius.circular(12.r),
//                         bottomRight: Radius.circular(12.r),
//                       ),
//                     ),
//                     elevation: 0,
//                     shadowColor: Colors.transparent,
//                     side: BorderSide.none,
//                     surfaceTintColor: Colors.transparent,
//                   ),
//                   child: _buildButtonContent(isInCart),
//                 ),
//               ),
//               // Gray color fill animation overlay (during adding state)
//               if (_buttonState == _ReviewButtonState.adding)
//                 AnimatedBuilder(
//                   animation: _grayFillAnimation,
//                   builder: (context, child) {
//                     return Positioned.fill(
//                       child: IgnorePointer(
//                         child: Stack(
//                           children: [
//                             // Gray fill animation
//                             ClipRect(
//                               child: FractionallySizedBox(
//                                 widthFactor: _grayFillAnimation.value,
//                                 alignment: Alignment.centerLeft,
//                                 child: SizedBox.expand(
//                                   child: Container(
//                                     decoration: BoxDecoration(
//                                       color: AppColors.gray949391,
//                                       borderRadius: BorderRadius.only(
//                                         bottomLeft: Radius.circular(12.r),
//                                         bottomRight: Radius.circular(12.r),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             // "Adding" text on top of gray fill
//                             Center(
//                               child: Text(
//                                 'Adding',
//                                 style: TextStyles.semiBold(15.sp, fontColor: AppColors.surfaceColor),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               // Gray background with checkmark (after gray fill completes) - only during animation states
//               // Note: success state and isInCart don't need overlay, button content will show through
//               if (_buttonState == _ReviewButtonState.grayWithCheck || _buttonState == _ReviewButtonState.blackFilling)
//                 Positioned.fill(
//                   child: IgnorePointer(
//                     child: Container(
//                       decoration: BoxDecoration(
//                         color: AppColors.gray949391,
//                         borderRadius: BorderRadius.only(
//                           bottomLeft: Radius.circular(12.r),
//                           bottomRight: Radius.circular(12.r),
//                         ),
//                       ),
//                       child: Stack(
//                         children: [
//                           // Black fill animation (only during blackFilling state)
//                           if (_buttonState == _ReviewButtonState.blackFilling)
//                             AnimatedBuilder(
//                               animation: _blackFillAnimation,
//                               builder: (context, child) {
//                                 return ClipRect(
//                                   child: FractionallySizedBox(
//                                     widthFactor: _blackFillAnimation.value,
//                                     alignment: Alignment.centerLeft,
//                                     child: SizedBox.expand(
//                                       child: Container(
//                                         decoration: BoxDecoration(
//                                           color: AppColors.secondaryColor,
//                                           borderRadius: BorderRadius.only(
//                                             bottomLeft: Radius.circular(12.r),
//                                             bottomRight: Radius.circular(12.r),
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 );
//                               },
//                             ),
//                           // Checkmark icon on top of gray/black background (only show during animation states)
//                           if (_buttonState == _ReviewButtonState.grayWithCheck ||
//                               _buttonState == _ReviewButtonState.blackFilling)
//                             Center(
//                               child: AnimatedBuilder(
//                                 animation: _scaleAnimation,
//                                 builder: (context, child) {
//                                   return Transform.scale(
//                                     scale: _scaleAnimation.value,
//                                     child: Assets.icons.icCheck.svg(
//                                       colorFilter: ColorFilter.mode(AppColors.whiteFAF6E4, BlendMode.srcIn),
//                                       width: 15.w,
//                                     ),
//                                   );
//                                 },
//                               ),
//                             ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       );
//     });
//   }
//
//   Widget _buildButtonContent(bool isInCart) {
//     // If product is already in cart, show "Added" state
//     if (isInCart) {
//       return Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.check, size: 16.sp, color: AppColors.whiteFAF6E4),
//           Gap(6.w),
//           Text('product_added'.tr, style: TextStyles.bold(15.sp, fontColor: AppColors.whiteFAF6E4)),
//         ],
//       );
//     }
//
//     switch (_buttonState) {
//       case _ReviewButtonState.initial:
//         return Text('home_add'.tr, style: TextStyles.bold(15.sp, fontColor: AppColors.secondaryColor));
//       case _ReviewButtonState.adding:
//         return Text('product_adding'.tr, style: TextStyles.bold(15.sp, fontColor: AppColors.secondaryColor));
//       case _ReviewButtonState.grayWithCheck:
//       case _ReviewButtonState.blackFilling:
//         // Icon is shown in overlay, so return empty widget
//         return const SizedBox.shrink();
//       case _ReviewButtonState.success:
//         return Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.check, size: 16.sp, color: AppColors.whiteFAF6E4),
//             Gap(6.w),
//             Text('product_added'.tr, style: TextStyles.bold(15.sp, fontColor: AppColors.whiteFAF6E4)),
//           ],
//         );
//     }
//   }
// }

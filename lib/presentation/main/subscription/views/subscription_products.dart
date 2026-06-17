import 'package:flutter/material.dart';
import 'package:viteezy/core/utils/app_functions.dart';
import 'package:viteezy/core/utils/exports.dart';
import 'package:viteezy/gen/assets.gen.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/common_appbar.dart';
import '../../../../core/widgets/product_card_widget.dart';
import '../../../../core/widgets/shimmer_widget.dart';
import '../controllers/subscription_controller.dart';

class SubscriptionProducts extends StatefulWidget {
  const SubscriptionProducts({super.key});

  @override
  State<SubscriptionProducts> createState() => _CategoryProductViewState();
}

class _CategoryProductViewState extends State<SubscriptionProducts> {
  final SubscriptionController controller = Get.find<SubscriptionController>();
  String? subscriptionId;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Always start with a fresh list for this screen
      controller.subscriptionStatusProducts.clear();
       controller.subscriptionSelectedProductIds.clear();
      final id = Get.arguments['subscriptionId']?.toString() ?? '';
      subscriptionId = id;
      if (id.isNotEmpty) {
        controller.loadSubscriptionProductsStatus(id);
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    // Optionally clear when leaving the screen
    controller.subscriptionStatusProducts.clear();
    super.dispose();
  }

  void _onCartIconPressed(BuildContext context) {
    if (subscriptionId == null || subscriptionId!.isEmpty) {
      AppFunctions().showToast('subscription_not_found'.tr, bgColor: AppColors.red);
      return;
    }
    if (controller.subscriptionSelectedProductIds.isEmpty) {
      AppFunctions().showToast('subscription_add_product_required'.tr, bgColor: AppColors.red);
      return;
    }
    Get.dialog(
      Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
          constraints: BoxConstraints(
            // Prevent horizontal overflow on small screens
            maxWidth: 280.w,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 40.w,
                height: 40.w,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.primaryColor),
              ),
              Gap(12.h),
              Text(
                'subscription_updating'.tr,
                textAlign: TextAlign.center,
                style: TextStyles.medium(14.sp, fontColor: AppColors.black1414141),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
    controller.updateSubscriptionProducts(
      subscriptionId: subscriptionId!,
      onSuccess: () {
        // Close progress dialog and go to cart with subscription update params
        Get.back(); // dialog
        Get.offNamed(
          AppRoutes.cart,
          arguments: {
            'fromSubscriptionUpdate': true,
            'subscriptionId': subscriptionId,
          },
        );
      },
      onError: (_) {
        // Just close progress dialog
        Get.back();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = 'subscription_products_title'.tr;
    return Scaffold(
      appBar: CommonAppbar(
        title: title,
        bgColor: AppColors.white,
        actionWidget: Obx(() {
          final count = controller.subscriptionSelectedProductIds.length;
          return GestureDetector(
            onTap: () => _onCartIconPressed(context),
            child: Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Center(
                    child: Assets.icons.icCart.svg(width: 18.w, height: 18.w),
                  ),
                  if (count > 0)
                    Positioned(
                      top: -5,
                      right: -5,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                        constraints: BoxConstraints(minWidth: 18.w, minHeight: 18.w),
                        decoration: BoxDecoration(
                          color: AppColors.black1414141,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.white, width: 1),
                        ),
                        child: Center(
                          child: Text(
                            count > 99 ? '99+' : '$count',
                            style: TextStyles.bold(10.sp, fontColor: AppColors.white),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        }),
      ),
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [


            // Products Grid
            Expanded(child: _buildProductsGrid()),
          ],
        ),
      ),
    );
  }





  Widget _buildProductsGrid() {
    return Obx(() {
      final shouldShowShimmer = controller.isLoadingSubscriptionStatus.value &&
          controller.subscriptionStatusProducts.isEmpty;

      if (shouldShowShimmer) {
        return _buildProductsShimmer();
      }

      // Show empty state only if not loading and no products
      if (controller.subscriptionStatusProducts.isEmpty && !controller.isLoadingSubscriptionStatus.value) {
        return Center(
          child: Text('browse_no_products_found'.tr, style: TextStyles.regular(16.sp, fontColor: AppColors.textSecondary)),
        );
      }

      return NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            if (subscriptionId != null &&
                subscriptionId!.isNotEmpty &&
                !controller.isLoadingMoreSubscriptionStatus.value &&
                controller.subscriptionStatusHasMore) {
              controller.loadSubscriptionProductsStatus(subscriptionId!, loadMore: true);
            }
          }
          return false;
        },
        child: GridView.builder(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.55,
          ),
          itemCount: controller.subscriptionStatusProducts.length +
              (controller.isLoadingMoreSubscriptionStatus.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= controller.subscriptionStatusProducts.length) {
              // Show loading indicator at the bottom
              return const Center(child: CircularProgressIndicator());
            }
            final product = controller.subscriptionStatusProducts[index];
            return ProductCardWidget(
              product: product,
              screenName: 'subscription_products',
              isSubscriptionFlow: true,
              onTap: () {
                if (product.id != null && product.id!.isNotEmpty) {
                  Get.toNamed(AppRoutes.productDetail, arguments: {
                    'productId': product.id,
                    'heroTag': 'category_product_product_image_${product.id}',
                  });
                }
              },
              onAddToCart: () async {
                final id = product.id ?? '';
                if (id.isNotEmpty && !controller.subscriptionSelectedProductIds.contains(id)) {
                  controller.subscriptionSelectedProductIds.add(id);
                }
                // Treat as successful add so the button updates its state
                return {'success': true, 'message': ''};
              },
              onGoToCart: () {
                // Get.toNamed(AppRoutes.cart);
              },
            );
          },
        ),
      );
    });
  }

  Widget _buildProductsShimmer() {
    return ShimmerWidget(
      child: GridView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.6,
        ),
        itemCount: 6, // Show 6 shimmer items
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Product Image Section (flex to avoid overflow in grid cell)
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.grayE3E3DC,
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                        ),
                      ),
                      // Favorite button placeholder
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          width: 30.w,
                          height: 30.w,
                          decoration: BoxDecoration(color: AppColors.grayE3E3DC, shape: BoxShape.circle),
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
                            child: Container(
                              height: 14.h,
                              decoration: BoxDecoration(
                                color: AppColors.grayE3E3DC,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          Gap(4.w),
                          // Discount tag with rounded right corners
                          Container(
                            width: 60.w,
                            height: 18.h,
                            decoration: BoxDecoration(
                              color: AppColors.grayE3E3DC,
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(50),
                                bottomRight: Radius.circular(50),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Gap(4.h),
                      // Product Description (2 lines)
                      Container(
                        width: double.infinity,
                        height: 10.h,
                        decoration: BoxDecoration(color: AppColors.grayE3E3DC, borderRadius: BorderRadius.circular(4)),
                      ),
                      Gap(4.h),
                      Container(
                        width: 100.w,
                        height: 10.h,
                        decoration: BoxDecoration(color: AppColors.grayE3E3DC, borderRadius: BorderRadius.circular(4)),
                      ),
                      Gap(10.h),
                      // Price and Rating Row
                      Row(
                        children: [
                          Container(
                            width: 45.w,
                            height: 14.h,
                            decoration: BoxDecoration(
                              color: AppColors.grayE3E3DC,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          Gap(8.w),
                          Container(
                            width: 50.w,
                            height: 12.h,
                            decoration: BoxDecoration(
                              color: AppColors.grayE3E3DC,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

import 'package:viteezy/core/routes/app_routes.dart';
import 'package:viteezy/core/widgets/common_appbar.dart';
import 'package:viteezy/presentation/main/orders/controllers/orders_controller.dart';

import 'package:viteezy/core/utils/exports.dart';
import 'package:viteezy/core/widgets/common_button.dart';
import 'package:viteezy/core/widgets/shimmer_widget.dart';
import 'package:viteezy/core/widgets/common_network_image.dart';

import '../../../../core/models/oders_history_model.dart' as order_model;
import '../../../../core/widgets/product_card_widget.dart';
import '../../shop_all_view/controller/shop_all_controller.dart';
import 'package:intl/intl.dart';

class OrdersScreen extends GetView<OrdersController> {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CommonAppbar(title: 'orders_my_orders'.tr),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildShimmerLoading();
        }

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Orders List
                          if (controller.orders.isNotEmpty) ...[
                            ...controller.orders.map((order) {
                              return Container(
                                padding: EdgeInsets.symmetric(horizontal: 16.w),
                                child: _buildOrderCard(
                                  context,
                                  order,
                                  controller,
                                ),
                              );
                            }),
                          ],
                          if (controller.orders.isNotEmpty) Gap(16.h),
                          // Show Most Likes and Continue Shopping only when orders are empty
                        ],
                      ),
                    ),
                    if (controller.orders.isEmpty) ...[
                      Gap(20.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Text(
                          'orders_featured_products'.tr,
                          style: TextStyles.semiBold(18.sp),
                        ),
                      ),
                      // Text('Our top seller', style: TextStyles.light(14.sp, fontColor: AppColors.grey9C9C98)),
                      Gap(12.h),
                      // Horizontal Scrollable Product Cards
                      Obx(() {
                        if (controller.isLoadingFeaturedProducts.value) {
                          return SizedBox(
                            height: 310.h,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              itemCount: 5,
                              itemBuilder: (context, index) {
                                return Container(
                                  width: 180.w,
                                  margin: EdgeInsets.only(
                                    right: index == 4 ? 0 : 12.w,
                                  ),
                                  child: ShimmerWidget(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          10.r,
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Product Image
                                          Expanded(
                                            flex: 1,
                                            child: Container(
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                color: AppColors.grayE3E3DC,
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(
                                                    10.r,
                                                  ),
                                                  topRight: Radius.circular(
                                                    10.r,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          // Product Info
                                          Padding(
                                            padding: EdgeInsets.all(8.w),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  height: 14.h,
                                                  width: double.infinity,
                                                  decoration: BoxDecoration(
                                                    color: AppColors.grayE3E3DC,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          4.r,
                                                        ),
                                                  ),
                                                ),
                                                Gap(4.h),
                                                Container(
                                                  height: 10.h,
                                                  width: 100.w,
                                                  decoration: BoxDecoration(
                                                    color: AppColors.grayE3E3DC,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          4.r,
                                                        ),
                                                  ),
                                                ),
                                                Gap(10.h),
                                                Row(
                                                  children: [
                                                    Container(
                                                      width: 45.w,
                                                      height: 14.h,
                                                      decoration: BoxDecoration(
                                                        color: AppColors
                                                            .grayE3E3DC,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              4.r,
                                                            ),
                                                      ),
                                                    ),
                                                    Spacer(),
                                                    Container(
                                                      width: 25.w,
                                                      height: 14.h,
                                                      decoration: BoxDecoration(
                                                        color: AppColors
                                                            .grayE3E3DC,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              4.r,
                                                            ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          // Add to Cart Button
                                          Container(
                                            width: double.infinity,
                                            height: 40.h,
                                            decoration: BoxDecoration(
                                              color: AppColors.grayE3E3DC,
                                              borderRadius: BorderRadius.only(
                                                bottomLeft: Radius.circular(
                                                  10.r,
                                                ),
                                                bottomRight: Radius.circular(
                                                  10.r,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        }

                        if (controller.featuredProducts.isEmpty &&
                            !controller.isLoadingFeaturedProducts.value) {
                          return SizedBox(
                            height: 100.h,
                            child: Center(
                              child: Text(
                                'browse_no_products_found'.tr,
                                style: TextStyles.regular(
                                  16.sp,
                                  fontColor: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          );
                        }

                        return SizedBox(
                          height: 310.h,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            itemCount: controller.featuredProducts.length,
                            itemBuilder: (context, index) {
                              final product =
                                  controller.featuredProducts[index];
                              return Container(
                                width: 180.w,
                                margin: EdgeInsets.only(
                                  right:
                                      index ==
                                          controller.featuredProducts.length - 1
                                      ? 0
                                      : 12.w,
                                ),
                                child: ProductCardWidget(
                                  product: product,
                                  screenName: 'orders',
                                  onFavoriteTap: () {
                                    // Toggle like/dislike
                                    product.isLiked =
                                        !(product.isLiked ?? false);
                                    controller.featuredProducts.refresh();
                                    // TODO: Call API to toggle like/dislike
                                  },
                                  onTap: () {
                                    if (product.id != null &&
                                        product.id!.isNotEmpty) {
                                      Get.toNamed(
                                        AppRoutes.productDetail,
                                        arguments: {
                                          'productId': product.id,
                                          'heroTag':
                                              'orders_product_image_${product.id}',
                                        },
                                      );
                                    }
                                  },
                                  onAddToCart: () async {
                                    // Get ShopAllController for add to cart
                                    if (Get.isRegistered<ShopAllController>()) {
                                      final shopAllController =
                                          Get.find<ShopAllController>();
                                      final result = await shopAllController
                                          .addToCart(
                                            product.id ?? '',
                                            "SACHETS",
                                          );
                                      if (result['success'] == true) {
                                        product.isInCart = true;
                                        controller.featuredProducts.refresh();
                                      }
                                      return result;
                                    }
                                    return {
                                      'success': false,
                                      'message': 'home_failed_to_add_cart_short'.tr,
                                    };
                                  },
                                  onGoToCart: () {
                                    Get.toNamed(AppRoutes.cart);
                                  },
                                ),
                              );
                            },
                          ),
                        );
                      }),
                      Gap(30.h),
                      // Continue Shopping Button
                      Align(
                        alignment: Alignment.center,
                        child: CommonButton(
                          textSize: 16.sp,
                          width: 190.w,
                          height: 44.h,
                          text: 'orders_continue_shopping'.tr,
                          color: AppColors.primaryColor,
                          onPressed: () {
                            controller.continueShopping();
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildOrderCard(
    BuildContext context,
    order_model.OrderData order,
    OrdersController controller,
  ) {
    // Determine status text
    String? statusText;
    if (order.status?.toLowerCase() == 'shipped' || order.shippedAt != null) {
      final dateToFormat = order.shippedAt ?? order.createdAt;
      statusText = dateToFormat != null
          ? 'orders_arriving'.trParams({'date': _formatDate(dateToFormat)})
          : null;
    } else if (order.createdAt != null) {
      statusText = '${'orders_order_placed'.tr} ${_formatDate(order.createdAt!)}';
    }

    return GestureDetector(
      onTap: () {
        Get.toNamed(AppRoutes.orderDetail, arguments: {'orderId': order.id});
      },
      behavior: HitTestBehavior.translucent,
      child: Container(
        margin: EdgeInsets.only(top: 16.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Status and View Order Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (statusText != null)
                        Text(
                          statusText,
                          style: TextStyles.semiBold(
                            14.sp,
                            fontColor: AppColors.primaryColor,
                          ),
                        ),
                      if (statusText == null && order.createdAt != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'orders_order_placed'.tr,
                              style: TextStyles.regular(
                                12.sp,
                                fontColor: AppColors.grey898989,
                              ),
                            ),
                            Gap(4.h),
                            Text(
                              _formatDate(order.createdAt!),
                              style: TextStyles.medium(14.sp),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                // View Order Button
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryColor,
                  ),
                  padding: EdgeInsets.all(4.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Text('View Order', style: TextStyles.medium(12.sp, fontColor: AppColors.white)),
                      Icon(
                        Icons.arrow_forward_ios_outlined,
                        color: AppColors.white,
                        size: 15.sp,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Gap(15.h),
            // Order Items
            if (order.items != null && order.items!.isNotEmpty)
              ...order.items!.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index < order.items!.length - 1 ? 10.h : 0,
                  ),
                  child: _buildOrderItem(context, item, order, controller),
                );
              }),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final orderDate = DateTime(date.year, date.month, date.day);
    final diffDays = today.difference(orderDate).inDays;

    if (diffDays == 0) {
      return 'Today';
    } else if (diffDays == 1) {
      return 'Yesterday';
    } else if (diffDays > 1 && diffDays < 7) {
      return DateFormat('EEEE').format(date);
    } else {
      return DateFormat('MMM dd, yyyy').format(date);
    }
  }

  Widget _buildOrderItem(
    BuildContext context,
    order_model.Item item,
    order_model.OrderData order,
    OrdersController controller,
  ) {
    final productImage = item.productId?.productImage ?? '';
    final productName = item.productId?.title ?? 'Product';
    final capsuleCount = item.capsuleCount != null
        ? '${item.capsuleCount} Capsules'
        : '0 Capsules';
    final quantity = item.quantity != null ? 'x${item.quantity}' : '';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Product Image
        Container(
          width: 60.w,
          height: 60.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.r),
            color: AppColors.backgroundColor,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5.r),
            child: productImage.isNotEmpty
                ? CommonNetworkImage(
                    imageUrl: productImage,
                    fit: BoxFit.cover,
                    width: 60.w,
                    height: 60.w,
                  )
                : Icon(Icons.image, size: 30.sp, color: AppColors.grey898989),
          ),
        ),
        Gap(15.w),
        // Product Details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(productName, style: TextStyles.medium(14.sp)),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    capsuleCount.toString(),
                    style: TextStyles.regular(
                      12.sp,
                      fontColor: AppColors.grey888888,
                    ),
                  ),
                  Gap(10.w),
                  if (quantity.isNotEmpty)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.whiteF0F0F0,
                        borderRadius: BorderRadius.circular(5.r),
                      ),
                      child: Text(
                        quantity,
                        style: TextStyles.regular(
                          12.sp,
                          fontColor: AppColors.gray686767,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...List.generate(
            3,
            (index) => Container(
              margin: EdgeInsets.only(bottom: 20.h),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerWidget(
                    child: Container(
                      height: 16.h,
                      width: 150.w,
                      decoration: BoxDecoration(
                        color: AppColors.grayE3E3DC,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ),
                  Gap(15.h),
                  ...List.generate(
                    2,
                    (itemIndex) => Padding(
                      padding: EdgeInsets.only(
                        bottom: itemIndex < 1 ? 10.h : 0,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ShimmerWidget(
                            child: Container(
                              width: 60.w,
                              height: 60.w,
                              decoration: BoxDecoration(
                                color: AppColors.grayE3E3DC,
                                borderRadius: BorderRadius.circular(5.r),
                              ),
                            ),
                          ),
                          Gap(15.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ShimmerWidget(
                                  child: Container(
                                    height: 14.h,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: AppColors.grayE3E3DC,
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                  ),
                                ),
                                Gap(8.h),
                                ShimmerWidget(
                                  child: Container(
                                    height: 12.h,
                                    width: 100.w,
                                    decoration: BoxDecoration(
                                      color: AppColors.grayE3E3DC,
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Gap(10.w),
                          ShimmerWidget(
                            child: Container(
                              width: 90.w,
                              height: 28.h,
                              decoration: BoxDecoration(
                                color: AppColors.grayE3E3DC,
                                borderRadius: BorderRadius.circular(25.r),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

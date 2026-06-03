import 'dart:math';

import 'package:viteezy/core/models/cart_response_model.dart';
import 'package:viteezy/core/utils/exports.dart';
import 'package:viteezy/core/widgets/common_textfield.dart';
import 'package:viteezy/core/widgets/common_network_image.dart';
import 'package:viteezy/core/widgets/product_card_widget.dart';
import 'package:viteezy/core/widgets/shimmer_widget.dart';
import 'package:viteezy/gen/assets.gen.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/common_appbar.dart';
import '../controllers/cart_controller.dart';
import '../widgets/discount_progress_bar.dart';
import '../../shop_all_view/controller/shop_all_controller.dart';

class CartView extends StatefulWidget {
  const CartView({super.key});

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  late CartController controller;

  @override
  void initState() {
    super.initState();
    // Ensure controller is initialized when used in IndexedStack
    if (!Get.isRegistered<CartController>()) {
      controller = Get.put(CartController());
    } else {
      controller = Get.find<CartController>();
    }
    // Defer cart load to avoid setState/markNeedsBuild during build (initializeCartItems sets isLoading)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = Get.arguments;
      final fromSubscriptionUpdate =
          args is Map && args['fromSubscriptionUpdate'] == true;
      final subscriptionId = args is Map
          ? args['subscriptionId']?.toString()
          : null;
      controller.initializeCartItems(
        fromSubscriptionUpdate: fromSubscriptionUpdate,
        subscriptionId: subscriptionId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool canPop = Navigator.canPop(context);
    return Scaffold(
      backgroundColor: AppColors.surfaceColor,
      appBar: CommonAppbar(
        title: 'cart_title'.tr,
        showBackButton: canPop,
        centerTitle: !canPop,
      ),
      body: Container(
        color: AppColors.offWhite,
        child: SafeArea(
          child: Column(
            children: [
              // Free Delivery Banner
              _buildFreeDeliveryBanner(),

              // Progress Bar Section

              // Cart Content
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    // Refresh cart data when user pulls down
                    await controller.refreshCart();
                  },
                  child: SingleChildScrollView(
                    physics:
                        const AlwaysScrollableScrollPhysics(), // Enable pull-to-refresh even when content doesn't scroll
                    child: Obx(() {
                      if (controller.isLoading.value) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Cart Summary Shimmer
                            _buildCartSummaryShimmer(),
                            // Payment Details Shimmer
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              child: ShimmerWidget(
                                child: Container(
                                  height: 18.h,
                                  width: 120.w,
                                  decoration: BoxDecoration(
                                    color: AppColors.grayE3E3DC,
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                ),
                              ),
                            ),
                            Gap(10.h),
                            _buildPaymentDetailsShimmer(),
                            Gap(20.h),
                            // Bottom spacing for footer
                            SizedBox(height: 20.h),
                          ],
                        );
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(
                            () =>
                                (controller
                                        .cartData
                                        .value
                                        ?.cart
                                        ?.items
                                        ?.isNotEmpty ??
                                    false)
                                ? controller.isLoading.value
                                      ? _buildProgressBarShimmer()
                                      : _buildProgressBar()
                                : SizedBox(),
                          ),
                          // Cart Summary
                          _buildCartSummary(),

                          // Payment Details
                          if (controller
                                  .cartData
                                  .value
                                  ?.cart
                                  ?.items
                                  ?.isNotEmpty ??
                              false) ...[
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              child: Text(
                                'Payment Details',
                                style: TextStyles.bold(
                                  18.sp,
                                  fontColor: AppColors.black1414141,
                                ),
                              ),
                            ),
                            Gap(10.h),
                            _buildPaymentDetails(),
                            Gap(20.h),
                          ],

                          _buildRecentlyViewedSection(),

                          // Bottom spacing for footer
                          SizedBox(height: 20.h),
                        ],
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Obx(
        () => (controller.cartData.value?.cart?.items?.isNotEmpty ?? false)
            ? controller.isLoading.value
                  ? SizedBox()
                  : _buildBottomFooter()
            : SizedBox(),
      ),
    );
  }

  Widget _buildRecentlyViewedSection() {
    return Obx(() {
      // Show shimmer while loading
      if (controller.isLoadingFeaturedProducts.value &&
          controller.featuredProducts.isEmpty) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: ShimmerWidget(
                child: Container(
                  height: 18.h,
                  width: 120.w,
                  decoration: BoxDecoration(
                    color: AppColors.grayE3E3DC,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ),
            ),
            Gap(16.h),
            AspectRatio(
              aspectRatio: 1.3,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: 3,
                itemBuilder: (context, index) {
                  return Container(
                    width: 180.w,
                    margin: EdgeInsets.only(right: index == 2 ? 0 : 12.w),
                    child: ShimmerWidget(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.grayE3E3DC,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }

      controller.featuredProducts;
      if (controller.featuredProducts.isEmpty) return const SizedBox.shrink();

      // Get ShopAllController for add to cart functionality
      ShopAllController? shopAllController;
      if (Get.isRegistered<ShopAllController>()) {
        shopAllController = Get.find<ShopAllController>();
      } else {
        shopAllController = Get.put(ShopAllController());
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Text(
              'cart_recently_viewed'.tr,
              style: TextStyles.bold(18.sp, fontColor: AppColors.black1414141),
            ),
          ),
          Gap(16.h),
          AspectRatio(
            aspectRatio: 1.3,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: controller.featuredProducts.length,
              itemBuilder: (context, index) {
                final product = controller.featuredProducts[index];
                return Container(
                  width: 180.w,
                  margin: EdgeInsets.only(
                    right: index == controller.featuredProducts.length - 1
                        ? 0
                        : 12.w,
                  ),
                  // Use key with isInCart to force rebuild when it changes
                  child: ProductCardWidget(
                    screenName: 'cart',
                    onTap: () {
                      if (product.id != null && product.id!.isNotEmpty) {
                        Get.toNamed(
                          AppRoutes.productDetail,
                          arguments: {
                            'productId': product.id,
                            'heroTag': 'cart_product_image_${product.id}',
                          },
                        );
                      }
                    },
                    key: ValueKey('${product.id}_${product.isInCart}'),
                    product: product,
                    onFavoriteTap: () {
                      // Optimistically update the product's isLiked flag
                      product.isLiked = !(product.isLiked ?? false);
                      // Trigger update by refreshing cart data to notify GetX observers
                      controller.featuredProducts.refresh();
                      // Call API to toggle like/dislike
                      if (shopAllController != null) {
                        shopAllController.toggleLikeDislike(product);
                      }
                    },
                    onAddToCart: shopAllController != null
                        ? () async {
                            final result = await shopAllController!.addToCart(
                              product.id ?? '',
                              "SACHETS",
                            );
                            // Update the product's isInCart flag directly
                            if (result['success'] == true) {
                              product.isInCart = true;
                              // Cart data will be refreshed silently by ShopAllController
                              // The Obx wrapper will trigger rebuild when cartData changes
                            }
                            return result;
                          }
                        : null,
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildFreeDeliveryBanner() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xffECD2BC),
            Color(0xffB8E2D0),
            Color(0xffC6E2F1),
            Color(0xffB5E5AD),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Text(
        'Free delivery on all USA orders over \$40',
        textAlign: TextAlign.center,
        style: TextStyles.medium(14.sp, fontColor: AppColors.black1414141),
      ),
    );
  }

  Widget _buildProgressBar() {
    return DiscountProgressBar(controller: controller);
  }

  Widget _buildCartSummary() {
    return Obx(() {
      final items = controller.cartData.value?.cart?.items ?? [];

      if (items.isEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 70.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Assets.icons.icEmptyWhishlist.svg(width: 80.w, height: 80.w),
                Gap(16.h),
                Text(
                  'cart_empty_title'.tr,
                  style: TextStyles.bold(
                    18.sp,
                    fontColor: AppColors.black1414141,
                  ),
                ),
                Gap(8.h),
                Text(
                  'Items added to your Cart will be saved here.',
                  style: TextStyles.regular(
                    15.sp,
                    fontColor: AppColors.grey6D6D6D,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }

      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'cart_summary'.tr,
              style: TextStyles.bold(18.sp, fontColor: AppColors.black1414141),
            ),
            Gap(20.h),
            ...items.map(
              (item) => Padding(
                key: ValueKey(item.id),
                padding: EdgeInsets.only(bottom: 12.h),
                child: _buildCartItem(item),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildCartItem(CartItem item) {
    return _CartItemTile(
      item: item,
      onRemove: () => controller.removeCartItem(item),
      onQuantityChanged: (updatedItem, newQuantity) =>
          controller.updateCartItemQuantity(updatedItem, newQuantity),
    );
  }

  Widget _buildPaymentDetails() {
    return Obx(() {
      // Use paymentDetails from model if available, otherwise fallback to cart
      final currency = controller.currency;
      final mrp = controller.mrp;
      final discount = controller.totalDiscount;
      final shipping = controller.shipping;
      final tax = controller.tax;
      final subtotal = controller.mrp;
      final grandTotal = controller.grandTotal;
      final couponDiscountAmount =
          controller.cartData.value?.cart?.couponDiscountAmount ?? 0.0;

      return Container(
        margin: EdgeInsets.symmetric(horizontal: 16.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.yellowF0EFE4,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          children: [
            _buildPaymentDetailRow(
              'Subtotal',
              '$currency${mrp.toStringAsFixed(2)}',
            ),
            Gap(12.h),
            ...[
              _buildPaymentDetailRow(
                'Discount',
                '-$currency${discount.toStringAsFixed(2)}',
              ),
              Gap(12.h),
            ],
            // Display coupon discount if applied
            if (couponDiscountAmount > 0) ...[
              _buildPaymentDetailRow(
                'Coupon Discount',
                '-$currency${couponDiscountAmount.toStringAsFixed(2)}',
              ),
              Gap(12.h),
            ],
            ...[
              _buildPaymentDetailRow(
                'Membership Discount',
                '-$currency${discount.toStringAsFixed(2)}',
              ),
              Gap(12.h),
            ],
            ...[
              _buildPaymentDetailRow(
                'Shipping',
                '$currency${shipping.toStringAsFixed(2)}',
              ),
              Gap(12.h),
            ],
            ...[
              _buildPaymentDetailRow(
                'Tax',
                '$currency${tax.toStringAsFixed(2)}',
              ),
              Gap(12.h),
            ],

            Gap(16.h),
            Divider(height: 1, color: AppColors.grayE3E3DC),
            Gap(16.h),
            _buildPaymentDetailRow(
              'Grand Total \nInc. of all taxes',
              '$currency${grandTotal.toStringAsFixed(2)}',
              isBold: true,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildPaymentDetailRow(
    String label,
    String value, {
    bool isBold = false,
  }) {
    final parts = label.split('\n');

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: parts[0],
                  style: isBold
                      ? TextStyles.bold(
                          16.sp,
                          fontColor: AppColors.black1414141,
                        )
                      : TextStyles.regular(
                          14.sp,
                          fontColor: AppColors.black1414141,
                          fontWeight: FontWeight.w500,
                        ),
                ),

                if (parts.length > 1)
                  TextSpan(
                    text: "\n${parts[1]}",
                    style: TextStyles.regular(
                      14.sp,
                      fontColor: AppColors.black1414141,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
        ),

        Text(
          value,
          style: isBold
              ? TextStyles.bold(16.sp, fontColor: AppColors.black1414141)
              : TextStyles.regular(
                  14.sp,
                  fontColor: AppColors.black1414141,
                  fontWeight: FontWeight.w500,
                ),
        ),
      ],
    );
  }

  Widget _buildProgressBarShimmer() {
    return ShimmerWidget(
      child: Container(
        padding: EdgeInsets.only(
          left: 16.w,
          right: 16.w,
          top: 20.h,
          bottom: 5.h,
        ),
        decoration: BoxDecoration(color: AppColors.offWhite),
        child: Column(
          children: [
            Container(
              height: 8.h,
              decoration: BoxDecoration(
                color: AppColors.grayE3E3DC,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            Gap(8.h),
            SizedBox(
              height: 40.h,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 50.w,
                    height: 12.h,
                    decoration: BoxDecoration(
                      color: AppColors.grayE3E3DC,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  Container(
                    width: 80.w,
                    height: 12.h,
                    decoration: BoxDecoration(
                      color: AppColors.grayE3E3DC,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  Container(
                    width: 80.w,
                    height: 12.h,
                    decoration: BoxDecoration(
                      color: AppColors.grayE3E3DC,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartSummaryShimmer() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerWidget(
            child: Container(
              height: 18.h,
              width: 120.w,
              decoration: BoxDecoration(
                color: AppColors.grayE3E3DC,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ),
          Gap(20.h),
          // Two cart item shimmers
          ...List.generate(
            2,
            (index) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: _buildCartItemShimmer(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemShimmer() {
    return Column(
      children: [
        ShimmerWidget(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceColor,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(10.r),
                topLeft: Radius.circular(10.r),
              ),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                Container(
                  width: 70.w,
                  height: 70.w,
                  decoration: BoxDecoration(
                    color: AppColors.grayE3E3DC,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                Gap(12.w),
                // Product Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 14.h,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.grayE3E3DC,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                      Gap(3.h),
                      Container(
                        height: 12.h,
                        width: 100.w,
                        decoration: BoxDecoration(
                          color: AppColors.grayE3E3DC,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                      Gap(3.h),
                      Row(
                        children: [
                          Container(
                            height: 14.h,
                            width: 60.w,
                            decoration: BoxDecoration(
                              color: AppColors.grayE3E3DC,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                          ),
                          Gap(8.w),
                          Container(
                            height: 12.h,
                            width: 50.w,
                            decoration: BoxDecoration(
                              color: AppColors.grayE3E3DC,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Delete Icon placeholder
                Container(
                  width: 24.w,
                  height: 24.w,
                  decoration: BoxDecoration(
                    color: AppColors.grayE3E3DC,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Membership Discount Bar shimmer
        ShimmerWidget(
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: AppColors.grayE3E3DC,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10.r),
                bottomRight: Radius.circular(10.r),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  height: 12.h,
                  width: 120.w,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceColor,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                Container(
                  height: 12.h,
                  width: 60.w,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceColor,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentDetailsShimmer() {
    return ShimmerWidget(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.yellowF0EFE4,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          children: [
            _buildPaymentDetailRowShimmer(),
            Gap(12.h),
            _buildPaymentDetailRowShimmer(),
            Gap(12.h),
            _buildPaymentDetailRowShimmer(),
            Gap(12.h),
            _buildPaymentDetailRowShimmer(),
            Gap(16.h),
            Divider(height: 1, color: AppColors.grayE3E3DC),
            Gap(16.h),
            _buildPaymentDetailRowShimmer(),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentDetailRowShimmer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          height: 14.h,
          width: 80.w,
          decoration: BoxDecoration(
            color: AppColors.grayE3E3DC,
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
        Container(
          height: 14.h,
          width: 60.w,
          decoration: BoxDecoration(
            color: AppColors.grayE3E3DC,
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomFooterShimmer() {
    return ShimmerWidget(
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.surfaceColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Discount field shimmer
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 14.h,
                        decoration: BoxDecoration(
                          color: AppColors.grayE3E3DC,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                    ),
                    Gap(12.w),
                    Container(
                      width: 32.w,
                      height: 32.w,
                      decoration: BoxDecoration(
                        color: AppColors.grayE3E3DC,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
              Gap(10.h),
              // Total and button shimmer
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 24.h,
                          width: 100.w,
                          decoration: BoxDecoration(
                            color: AppColors.grayE3E3DC,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                        Gap(4.h),
                        Container(
                          height: 12.h,
                          width: 120.w,
                          decoration: BoxDecoration(
                            color: AppColors.grayE3E3DC,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Gap(16.w),
                  Expanded(
                    flex: 2,
                    child: Container(
                      height: 50.h,
                      decoration: BoxDecoration(
                        color: AppColors.grayE3E3DC,
                        borderRadius: BorderRadius.circular(30.r),
                      ),
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

  Widget _buildBottomFooter() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Discount/Referral Input Field (Expandable) or Applied Coupon Code
            Obx(() {
              // Check if coupon code exists from API
              final couponCode = controller.cartData.value?.cart?.couponCode;
              final hasCouponCode =
                  couponCode != null && couponCode.toString().isNotEmpty;

              if (hasCouponCode) {
                // Show applied coupon code with Remove button
                return _buildAppliedCouponCode(couponCode.toString());
              } else {
                // Show expandable discount field
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header Row (Always Visible)
                      InkWell(
                        onTap: () => controller.toggleDiscountField(),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 12.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundColor,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Discount code or referred by a friend?',
                                      style: TextStyles.medium(
                                        14.sp,
                                        fontColor: AppColors.black1414141,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 32.w,
                                    height: 32.w,
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      controller.isDiscountFieldExpanded.value
                                          ? Icons.remove
                                          : Icons.add,
                                      size: 20.sp,
                                      color: AppColors.black1414141,
                                    ),
                                  ),
                                ],
                              ),
                              // Expandable Content
                              AnimatedSize(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                child: controller.isDiscountFieldExpanded.value
                                    ? Container(
                                        padding: EdgeInsets.only(
                                          top: 12.h,
                                          left: 5.w,
                                          right: 5.w,
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: CommonMainTextField(
                                                controller: controller
                                                    .discountCodeController,
                                                hintText: 'Enter discount code',
                                                labelText:
                                                    'Enter discount code',
                                                focusedErrorBorderSide:
                                                    BorderSide.none,
                                                fillColor:
                                                    AppColors.surfaceColor,
                                                borderColor:
                                                    AppColors.grayE3E3DC,
                                                radius: BorderRadius.circular(
                                                  8.r,
                                                ),
                                                textStyle: TextStyles.regular(
                                                  14.sp,
                                                  fontColor:
                                                      AppColors.black1414141,
                                                ),
                                                hintColor: AppColors.gray949391,
                                              ),
                                            ),
                                            Gap(12.w),
                                            ElevatedButton(
                                              onPressed: () {
                                                if (controller
                                                    .discountCodeController
                                                    .text
                                                    .isNotEmpty) {
                                                  controller.applyDiscountCode(
                                                    controller
                                                        .discountCodeController
                                                        .text,
                                                  );
                                                }
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    AppColors.black1414141,
                                                foregroundColor:
                                                    AppColors.surfaceColor,
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 24.w,
                                                  vertical: 15.5.h,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        8.r,
                                                      ),
                                                ),
                                                elevation: 0,
                                              ),
                                              child: Text(
                                                'Apply',
                                                style: TextStyles.semiBold(
                                                  14.sp,
                                                  fontColor:
                                                      AppColors.surfaceColor,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
            }),
            Gap(10.h),
            // Total Amount and Checkout Button
            Row(
              children: [
                // Total Amount
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Obx(() {
                        final currency = controller.currency;
                        return Text(
                          '$currency${controller.grandTotal.toStringAsFixed(2)}',
                          style: TextStyles.bold(
                            20.sp,
                            fontColor: AppColors.black1414141,
                          ),
                        );
                      }),
                      Text(
                        'checkout_inc_taxes'.tr,
                        style: TextStyles.medium(
                          12.sp,
                          fontColor: AppColors.black1414141,
                        ),
                      ),
                    ],
                  ),
                ),
                Gap(16.w),
                // Checkout Button
                Expanded(
                  flex: 1,
                  child: Obx(() {
                    final isEmpty =
                        (controller.cartData.value?.cart?.items?.isEmpty ??
                        true);
                    return ElevatedButton(
                      onPressed: isEmpty
                          ? null
                          : () => controller.navigateToCheckout(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.black1414141,
                        foregroundColor: AppColors.surfaceColor,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'cart_checkout'.tr,
                        style: TextStyles.semiBold(
                          16.sp,
                          fontColor: AppColors.surfaceColor,
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppliedCouponCode(String couponCode) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  size: 20.sp,
                  color: AppColors.primaryColor,
                ),
                Gap(8.w),
                Expanded(
                  child: Text(
                    'Coupon: $couponCode',
                    style: TextStyles.medium(
                      14.sp,
                      fontColor: AppColors.black1414141,
                    ),
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              controller.removeCouponCode();
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Remove',
              style: TextStyles.medium(14.sp, fontColor: AppColors.primaryColor)
                  .copyWith(
                    decoration: TextDecoration.underline,
                    decorationColor: AppColors.primaryColor,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Animated cart item tile with sparkle fade-out before removal.
class _CartItemTile extends StatefulWidget {
  final CartItem item;
  final VoidCallback onRemove;
  final void Function(CartItem item, int newQuantity)? onQuantityChanged;

  const _CartItemTile({
    required this.item,
    required this.onRemove,
    this.onQuantityChanged,
  });

  @override
  State<_CartItemTile> createState() => _CartItemTileState();
}

class _CartItemTileState extends State<_CartItemTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _size;
  late final List<_Particle> _particles;
  bool _isRemoving = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 420),
      vsync: this,
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _size = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _particles = _createParticles(widget.item);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onRemove();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<_Particle> _createParticles(CartItem item) {
    final random = Random(item.hashCode);
    // More particles, slightly smaller size for finer sparkle
    return List.generate(76, (index) {
      final dx = (random.nextDouble() * 2 - 1) * 16; // -16..16
      final dy = -(random.nextDouble() * 16 + 4); // upward drift
      final radius = random.nextDouble() * 1.2 + 1.0; // 1.0..2.2
      final hueShift = random.nextDouble() * 0.15;
      final baseColor = AppColors.primaryColor;
      final color = baseColor.withValues(alpha: 0.7 - hueShift / 2);
      final origin = Offset(random.nextDouble(), random.nextDouble());
      return _Particle(
        origin: origin,
        dx: dx,
        dy: dy,
        radius: radius,
        color: color,
      );
    });
  }

  void _handleRemove() {
    if (_isRemoving) return;
    setState(() => _isRemoving = true);
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: ReverseAnimation(_size),
      axisAlignment: -1,
      child: FadeTransition(
        opacity: ReverseAnimation(_fade),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            _CartItemContent(
              item: widget.item,
              onRemove: _handleRemove,
              onQuantityChanged: widget.onQuantityChanged,
            ),
            if (_isRemoving)
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, _) {
                      return CustomPaint(
                        painter: _SparklePainter(_particles, _controller.value),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CartItemContent extends StatelessWidget {
  final CartItem item;
  final VoidCallback onRemove;
  final void Function(CartItem item, int newQuantity)? onQuantityChanged;

  const _CartItemContent({
    required this.item,
    required this.onRemove,
    this.onQuantityChanged,
  });

  static const int _minQty = 1;
  static const int _maxQty = 99;

  @override
  Widget build(BuildContext context) {
    final product = item.product;
    final currency = item.price?.currency ?? '\$';
    final currentPrice = item.price?.totalAmount ?? 0.0;
    final qty = item.effectiveQuantity.clamp(_minQty, _maxQty);

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceColor,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(10.r),
              topLeft: Radius.circular(10.r),
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Container(
                width: 70.w,
                height: 70.w,
                decoration: BoxDecoration(
                  color: AppColors.offWhite,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child:
                      product?.productImage != null &&
                          product!.productImage!.isNotEmpty
                      ? CommonNetworkImage(
                          imageUrl: product.productImage ?? '',
                          fit: BoxFit.cover,
                          width: 70.w,
                          height: 70.w,
                        )
                      : Icon(
                          Icons.image_not_supported,
                          size: 24.sp,
                          color: AppColors.gray949391,
                        ),
                ),
              ),
              Gap(12.w),
              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product?.title ?? 'Product',
                      style: TextStyles.bold(
                        14.sp,
                        fontColor: AppColors.black1414141,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // Text(
                    //   '${item.planDays} ' ?? 'Product',
                    //   style: TextStyles.bold(14.sp, fontColor: AppColors.black1414141),
                    //   maxLines: 2,
                    //   overflow: TextOverflow.ellipsis,
                    // ),
                    Gap(3.h),
                    Text(
                      '$currency${currentPrice.toStringAsFixed(2)}',
                      style: TextStyles.bold(
                        14.sp,
                        fontColor: AppColors.black1414141,
                      ),
                    ),
                  ],
                ),
              ),
              // Delete Icon
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(onTap: onRemove, child: Assets.icons.icDelete.svg()),
                  if (onQuantityChanged != null) Gap(15.w),
                  if (onQuantityChanged != null &&
                      item.variantType == 'STAND_UP_POUCH')
                    _CartItemQuantitySelector(
                      quantity: qty,
                      onDecrement: qty == 1
                          ? onRemove
                          : () => onQuantityChanged!(item, qty - 1),
                      onIncrement: qty < _maxQty
                          ? () => onQuantityChanged!(item, qty + 1)
                          : null,
                    ),
                ],
              ),
            ],
          ),
        ),
        // Membership Discount Bar
        // if (item.product.membershipDiscount > 0) ...[
        if ((item.membershipDiscount ?? 0.0) > 0) ...[
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryLight,
                  AppColors.orangeF7A173.withValues(alpha: 0.3),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(10.r),
                bottomRight: Radius.circular(10.r),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'cart_membership_discount'.tr,
                  style: TextStyles.semiBold(
                    12.sp,
                    fontColor: AppColors.black1414141,
                  ),
                ),
                Text(
                  '$currency${item.membershipDiscount?.toStringAsFixed(2)}',
                  style: TextStyles.semiBold(
                    12.sp,
                    fontColor: AppColors.black1414141,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Compact quantity selector for cart item: three sections with vertical dividers.
class _CartItemQuantitySelector extends StatelessWidget {
  final int quantity;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;

  const _CartItemQuantitySelector({
    required this.quantity,
    this.onDecrement,
    this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.grayE3E3DC, width: 1),
      ),
      child: IntrinsicHeight(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _QuantityButton(
              icon: Icons.remove,
              onTap: onDecrement,
              size: 16.sp,
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            ),
            Container(width: 1, color: AppColors.grayE3E3DC),
            SizedBox(
              width: 28.w,
              child: Center(
                child: Text(
                  '$quantity',
                  style: TextStyles.semiBold(
                    12.sp,
                    fontColor: AppColors.black1414141,
                  ),
                ),
              ),
            ),
            Container(width: 1, color: AppColors.grayE3E3DC),
            _QuantityButton(
              icon: Icons.add,
              onTap: onIncrement,
              size: 16.sp,
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            ),
          ],
        ),
      ),
    );
  }
}

/// Minus/plus button for quantity selector (compact for cart).
class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final EdgeInsets padding;

  const _QuantityButton({
    required this.icon,
    this.onTap,
    this.size = 16,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6.r),
        child: Padding(
          padding: padding,
          child: Icon(icon, size: size, color: AppColors.black1414141),
        ),
      ),
    );
  }
}

class _Particle {
  final Offset origin;
  final double dx;
  final double dy;
  final double radius;
  final Color color;

  _Particle({
    required this.origin,
    required this.dx,
    required this.dy,
    required this.radius,
    required this.color,
  });
}

class _SparklePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  _SparklePainter(this.particles, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final paint = Paint()
        ..color = p.color.withValues(alpha: max(0, 0.8 - progress))
        ..style = PaintingStyle.fill;

      final offset = Offset(
        p.origin.dx * size.width + p.dx * progress,
        p.origin.dy * size.height + p.dy * progress,
      );
      final radius = p.radius * (1 - progress * 0.6);
      if (radius > 0) {
        canvas.drawCircle(offset, radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SparklePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.particles != particles;
  }
}

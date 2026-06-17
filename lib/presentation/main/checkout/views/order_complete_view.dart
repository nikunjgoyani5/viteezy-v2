import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:viteezy/core/routes/app_routes.dart';
import 'package:viteezy/core/models/oders_history_model.dart';
import 'package:viteezy/core/theme/app_colors.dart';
import 'package:viteezy/core/theme/text_styles.dart';
import 'package:viteezy/core/widgets/common_network_image.dart';
import '../controllers/checkout_controller.dart';

class OrderCompleteView extends GetView<CheckoutController> {
  const OrderCompleteView({super.key});

  OrderData? get orderData {
    final arguments = Get.arguments;
    if (arguments != null && arguments is Map<String, dynamic>) {
      return arguments['orderData'] as OrderData?;
    }
    return null;
  }

  bool get fromSubscriptionUpdate {
    final arguments = Get.arguments;
    if (arguments != null && arguments is Map<String, dynamic>) {
      return arguments['fromSubscriptionUpdate'] == true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceColor,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Gap(20.h),
                    // Thank you message (subscription update vs purchase)
                    Center(
                      child: Text(
                        textAlign: TextAlign.center,
                        fromSubscriptionUpdate ? 'order_complete_updated'.tr : 'order_complete_thanks'.tr,
                        style: TextStyles.bold(28.sp, fontColor: AppColors.green),
                      ),
                    ),
                    if (fromSubscriptionUpdate) ...[
                      Gap(12.h),
                      Text(
                        'order_complete_next_cycle'.tr,
                        style: TextStyles.regular(14.sp, fontColor: AppColors.gray919191),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    Gap(12.h),
                    // Order number
                    Center(
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyles.regular(15.sp, fontColor: AppColors.black1414141),
                          children: [
                            TextSpan(text: '${'order_complete_order_number'.tr} '),
                            TextSpan(
                              text: orderData?.orderNumber ?? 'N/A',
                              style: TextStyles.regular(
                                15.sp,
                                fontColor: AppColors.black1414141,
                              ).copyWith(decoration: TextDecoration.underline),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Gap(16.h),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(color: AppColors.offWhite),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Gap(20.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Text(
                        'checkout_cart_summary'.tr,
                        style: TextStyles.bold(18.sp, fontColor: AppColors.black1414141),
                      ),
                    ),
                    Gap(20.h),
                    Builder(
                      builder: (context) {
                        if (orderData?.items == null || orderData!.items!.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 40.h),
                              child: Text(
                                'order_complete_no_items'.tr,
                                style: TextStyles.regular(14.sp, fontColor: AppColors.gray949391),
                              ),
                            ),
                          );
                        }
                        return Column(
                          children: orderData!.items!.map((item) {
                            return Padding(
                              padding: EdgeInsets.only(bottom: 12.h),
                              child: _buildCartItem(item),
                            );
                          }).toList(),
                        );
                      },
                    ),
                    Gap(20.h),
                    // Payment Details Section
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Text(
                        'orders_payment_details'.tr,
                        style: TextStyles.bold(18.sp, fontColor: AppColors.black1414141),
                      ),
                    ),
                    Gap(10.h),
                    _buildPaymentDetails(),
                    Gap(20.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      foregroundColor: AppColors.black1414141,
      elevation: 0,
      centerTitle: true,
      title: Text('checkout_complete_order'.tr, style: TextStyles.medium(20.sp, fontColor: AppColors.black1414141)),
      leading: IconButton(
        icon: Icon(Icons.close, size: 24.sp, color: AppColors.black1414141),
        onPressed: () => Get.back(),
      ),
      scrolledUnderElevation: 0,
    );
  }

  Widget _buildCartItem(Item item) {
    final productImage = item.productId?.productImage ?? '';
    final productName = item.name ?? item.productId?.title ?? 'Product';
    final currency = orderData?.pricing?.overall?.currency ?? '\$';
    final currentPrice = item.discountedPrice ?? item.totalAmount ?? 0.0;
    final originalPrice = item.amount ?? item.totalAmount ?? 0.0;
    final planInfo = item.durationDays != null
        ? '${item.durationDays} days'
        : item.capsuleCount != null
        ? '${item.capsuleCount} capsules'
        : '';

    return Container(
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(10.r)),
      padding: EdgeInsets.all(16.w),
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Container(
            width: 70.w,
            height: 70.w,
            decoration: BoxDecoration(color: AppColors.surfaceColor, borderRadius: BorderRadius.circular(8.r)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: productImage.isNotEmpty
                  ? CommonNetworkImage(imageUrl: productImage, fit: BoxFit.cover, width: 70.w, height: 70.w)
                  : Icon(Icons.image_not_supported, size: 24.sp, color: AppColors.gray949391),
            ),
          ),
          Gap(12.w),
          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(productName, style: TextStyles.bold(14.sp, fontColor: AppColors.black1414141)),
                if (planInfo.isNotEmpty) ...[
                  Gap(3.h),
                  Text(planInfo, style: TextStyles.medium(12.sp, fontColor: AppColors.black1414141)),
                ],
                Gap(3.h),
                Row(
                  children: [
                    Text(
                      '$currency${currentPrice.toStringAsFixed(2)}',
                      style: TextStyles.bold(14.sp, fontColor: AppColors.black1414141),
                    ),
                    if (originalPrice > currentPrice) ...[
                      Gap(8.w),
                      Text(
                        '$currency${originalPrice.toStringAsFixed(2)}',
                        style: TextStyles.regular(
                          12.sp,
                          fontColor: AppColors.gray949391,
                          textDecoration: TextDecoration.lineThrough,
                        ).copyWith(decorationColor: AppColors.gray949391),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentDetails() {
    final pricing = orderData?.pricing?.overall;
    final currency = pricing?.currency ?? '\$';

    if (pricing == null) {
      return Container(
        padding: EdgeInsets.all(16.w),
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(color: AppColors.yellowF0EFE4, borderRadius: BorderRadius.circular(12.r)),
        child: Center(
          child: Text(
            'order_payment_unavailable'.tr,
            style: TextStyles.regular(14.sp, fontColor: AppColors.gray949391),
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(16.w),
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(color: AppColors.yellowF0EFE4, borderRadius: BorderRadius.circular(12.r)),
      child: Column(
        children: [
          if (pricing.subTotal != null)
            _buildPaymentDetailRow('cart_subtotal'.tr, '$currency${pricing.subTotal!.toStringAsFixed(2)}'),
          if (pricing.subTotal != null) Gap(12.h),
          if (pricing.discountedPrice != null && pricing.discountedPrice! > 0)
            _buildPaymentDetailRow('cart_discount'.tr, '-$currency${pricing.discountedPrice!.toStringAsFixed(2)}'),
          if (pricing.discountedPrice != null && pricing.discountedPrice! > 0) Gap(12.h),
          if (pricing.membershipDiscountAmount != null && pricing.membershipDiscountAmount! > 0) ...[
            _buildPaymentDetailRow(
              'cart_membership_discount'.tr,
              '-$currency${pricing.membershipDiscountAmount!.toStringAsFixed(2)}',
            ),
            Gap(12.h),
          ],
          if (pricing.subscriptionPlanDiscountAmount != null && pricing.subscriptionPlanDiscountAmount! > 0) ...[
            _buildPaymentDetailRow(
              'cart_subscription_discount'.tr,
              '-$currency${pricing.subscriptionPlanDiscountAmount!.toStringAsFixed(2)}',
            ),
            Gap(12.h),
          ],
          if (pricing.couponDiscountAmount != null && pricing.couponDiscountAmount! > 0) ...[
            _buildPaymentDetailRow('cart_coupon_discount'.tr, '-$currency${pricing.couponDiscountAmount!.toStringAsFixed(2)}'),
            Gap(12.h),
          ],
          if (pricing.taxAmount != null && pricing.taxAmount! > 0) ...[
            _buildPaymentDetailRow('Tax', '$currency${pricing.taxAmount!.toStringAsFixed(2)}'),
            Gap(12.h),
          ],
          Gap(16.h),
          Divider(height: 1, color: AppColors.grayE3E3DC),
          Gap(16.h),
          if (pricing.grandTotal != null)
            _buildPaymentDetailRow('cart_grand_total'.tr, '$currency${pricing.grandTotal!.toStringAsFixed(2)}', isBold: true),
        ],
      ),
    );
  }

  Widget _buildPaymentDetailRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isBold
              ? TextStyles.bold(16.sp, fontColor: AppColors.black1414141)
              : TextStyles.regular(14.sp, fontColor: AppColors.black1414141),
        ),
        Text(
          value,
          style: isBold
              ? TextStyles.bold(16.sp, fontColor: AppColors.black1414141)
              : TextStyles.regular(14.sp, fontColor: AppColors.black1414141),
        ),
      ],
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(color: AppColors.offWhite),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              if (orderData?.id != null && orderData!.id!.isNotEmpty) {
                Get.toNamed(AppRoutes.orderDetail, arguments: {'orderId': orderData!.id});
              } else {
                Get.toNamed(AppRoutes.orderDetail);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.black1414141,
              foregroundColor: AppColors.surfaceColor,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
              elevation: 0,
            ),
            child: Text(
              'checkout_go_to_order_details'.tr,
              style: TextStyles.semiBold(16.sp, fontColor: AppColors.surfaceColor),
            ),
          ),
        ),
      ),
    );
  }
}

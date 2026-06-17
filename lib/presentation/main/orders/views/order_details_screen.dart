import 'package:viteezy/core/widgets/common_appbar.dart';
import 'package:viteezy/gen/assets.gen.dart';
import 'package:intl/intl.dart';

import 'package:viteezy/core/utils/exports.dart';
import 'package:viteezy/core/widgets/common_button.dart';
import 'package:viteezy/core/widgets/shimmer_widget.dart';
import 'package:viteezy/core/widgets/common_network_image.dart';
import 'package:viteezy/core/models/oders_history_model.dart' as order_model;

import '../../../../core/services/global_settings_service.dart';
import '../controllers/orders_controller.dart';

class OrderDetailsScreen extends StatefulWidget {
  const OrderDetailsScreen({super.key});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  final OrdersController controller = Get.find<OrdersController>();
  String? _orderId;

  @override
  void initState() {
    super.initState();
    final arguments = Get.arguments;
    if (arguments != null) {
      _orderId = arguments['orderId'] as String?;
      if (_orderId != null && _orderId!.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            controller.getOrderDetail(_orderId!);
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CommonAppbar(title: 'orders_my_orders'.tr),
      body: Obx(() {
        if (controller.isLoadingOrderDetail.value) {
          return _buildShimmerLoading();
        }

        final orderData = controller.selectedOrderData.value;
        if (orderData == null) {
          return Center(
            child: Text(
              'orders_order_not_found'.tr,
              style: TextStyles.regular(14.sp),
            ),
          );
        }

        return _buildOrderDetails(orderData);
      }),
    );
  }

  Widget _buildOrderDetails(order_model.OrderData order) {
    final orderNumber = order.orderNumber ?? 'orders_na'.tr;
    final orderDate = order.createdAt != null
        ? _formatDate(order.createdAt!)
        : 'orders_na'.tr;
    final estimatedDelivery = order.deliveredAt != null
        ? _formatDate(order.deliveredAt!)
        : (order.shippedAt != null
              ? 'orders_arriving'.trParams({'date': _formatDate(order.shippedAt!)})
              : 'orders_delivery_tbd'.tr);
    final pricing = order.pricing?.overall;
    final currency = pricing?.currency ?? '\$';

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
            child: Column(
              children: [
                // Order Details Section
                _buildSectionCard(
                  title: 'orders_order_details'.tr,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(label: 'orders_order_number_label'.tr, value: orderNumber),
                      Gap(2.h),
                      _buildInfoRow(label: 'orders_order_date_label'.tr, value: orderDate),
                      Gap(2.h),
                      _buildInfoRow(
                        label: 'orders_estimated_delivery_label'.tr,
                        value: estimatedDelivery,
                      ),
                    ],
                  ),
                ),
                Gap(12.h),
                // My items Section
                if (order.items != null && order.items!.isNotEmpty)
                  _buildSectionCard(
                    title: 'orders_my_items'.tr,
                    titleColor: AppColors.primaryColor,
                    child: Column(
                      children: [
                        ...order.items!.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: index < order.items!.length - 1
                                  ? 20.h
                                  : 0,
                            ),
                            child: _buildOrderItem(item, controller),
                          );
                        }),
                      ],
                    ),
                  ),
                Gap(12.h),
                // Shipping Address Section
                _buildSectionCard(
                  title: 'orders_shipping_address'.tr,
                  child: _buildFullAddress(order.shippingAddressId),
                ),
                Gap(12.h),
                // Payment Details
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'orders_payment_details'.tr,
                        style: TextStyles.semiBold(18.sp),
                      ),
                      Gap(6.h),
                      Column(
                        children: [
                          if (pricing?.subTotal != null)
                            _buildPaymentRow(
                              label: 'cart_subtotal'.tr,
                              value:
                                  '$currency${pricing!.subTotal!.toStringAsFixed(2)}',
                            ),
                          if (pricing?.subTotal != null) Gap(6.h),
                          if (pricing?.discountedPrice != null)
                            _buildPaymentRow(
                              label: 'cart_discount'.tr,
                              value:
                                  '$currency${(pricing!.subTotal! - pricing.discountedPrice!).toStringAsFixed(2)}',
                            ),
                          if (pricing?.discountedPrice != null) Gap(6.h),
                          if (pricing?.membershipDiscountAmount != null)
                            _buildPaymentRow(
                              label: 'cart_membership_discount'.tr,
                              value:
                                  '$currency${pricing!.membershipDiscountAmount!.toStringAsFixed(2)}',
                            ),
                          if (pricing?.membershipDiscountAmount != null)
                            Gap(6.h),
                          if (pricing?.taxAmount != null)
                            _buildPaymentRow(
                              label: 'orders_tax'.tr,
                              value:
                                  '$currency${pricing!.taxAmount!.toStringAsFixed(2)}',
                            ),
                          if (pricing?.taxAmount != null) Gap(6.h),
                          _buildPaymentRow(
                            label: 'cart_shipping'.tr,
                            value: 'orders_shipping_tbd'.tr,
                          ),
                          Gap(6.h),
                          Container(height: 1, color: AppColors.greyF7F6F0),
                          Gap(10.h),
                          if (pricing?.grandTotal != null)
                            _buildPaymentRow(
                              label: 'cart_grand_total_inc_tax'.tr,
                              value:
                                  '$currency${pricing!.grandTotal!.toStringAsFixed(2)}',
                              isBold: true,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                Gap(12.h),
                // Need help? Section
                _buildSectionCard(
                  title: 'orders_need_help'.tr,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Assets.icons.icEmail.svg(
                            height: 12,
                            width: 10,
                            fit: BoxFit.cover,
                          ),
                          Gap(10.w),
                          Text(
                            GlobalSettingsService.to.supportEmail,
                            style: TextStyles.regular(
                              14.sp,
                              fontColor: AppColors.grey6A6A6A,
                            ),
                          ),
                        ],
                      ),
                      Gap(7.h),
                      Row(
                        children: [
                          Assets.icons.icPhone.svg(
                            height: 16,
                            width: 20,
                            fit: BoxFit.cover,
                          ),
                          Gap(10.w),
                          Text(
                            GlobalSettingsService.to.supportPhone,
                            style: TextStyles.regular(
                              14.sp,
                              fontColor: AppColors.grey6A6A6A,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Gap(20.h),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      child: Column(
        children: [
          // Order Details Shimmer
          ShimmerWidget(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16.h,
                    width: 120.w,
                    decoration: BoxDecoration(
                      color: AppColors.grayE3E3DC,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  Gap(12.h),
                  ...List.generate(
                    3,
                    (index) => Padding(
                      padding: EdgeInsets.only(bottom: index < 2 ? 8.h : 0),
                      child: Row(
                        children: [
                          Container(
                            height: 14.h,
                            width: 100.w,
                            decoration: BoxDecoration(
                              color: AppColors.grayE3E3DC,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                          Gap(8.w),
                          Expanded(
                            child: Container(
                              height: 14.h,
                              decoration: BoxDecoration(
                                color: AppColors.grayE3E3DC,
                                borderRadius: BorderRadius.circular(8.r),
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
          Gap(12.h),
          // My items Shimmer
          ShimmerWidget(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16.h,
                    width: 80.w,
                    decoration: BoxDecoration(
                      color: AppColors.grayE3E3DC,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  Gap(12.h),
                  ...List.generate(
                    2,
                    (index) => Padding(
                      padding: EdgeInsets.only(bottom: index < 1 ? 20.h : 0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 72.w,
                            height: 74.w,
                            decoration: BoxDecoration(
                              color: AppColors.grayE3E3DC,
                              borderRadius: BorderRadius.circular(5.r),
                            ),
                          ),
                          Gap(8.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 15.h,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: AppColors.grayE3E3DC,
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                ),
                                Gap(8.h),
                                Container(
                                  height: 13.h,
                                  width: 150.w,
                                  decoration: BoxDecoration(
                                    color: AppColors.grayE3E3DC,
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                ),
                                Gap(12.h),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        height: 28.h,
                                        decoration: BoxDecoration(
                                          color: AppColors.grayE3E3DC,
                                          borderRadius: BorderRadius.circular(
                                            6.r,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Gap(10.w),
                                    Expanded(
                                      child: Container(
                                        height: 28.h,
                                        decoration: BoxDecoration(
                                          color: AppColors.grayE3E3DC,
                                          borderRadius: BorderRadius.circular(
                                            6.r,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
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
          Gap(12.h),
          // Shipping Address Shimmer
          ShimmerWidget(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 16.h,
                    width: 120.w,
                    decoration: BoxDecoration(
                      color: AppColors.grayE3E3DC,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  Gap(12.h),
                  Container(
                    height: 13.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.grayE3E3DC,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Gap(12.h),
          // Payment Details Shimmer
          ShimmerWidget(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 18.h,
                    width: 140.w,
                    decoration: BoxDecoration(
                      color: AppColors.grayE3E3DC,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  Gap(12.h),
                  ...List.generate(
                    5,
                    (index) => Padding(
                      padding: EdgeInsets.only(bottom: index < 4 ? 6.h : 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            height: 14.h,
                            width: 80.w,
                            decoration: BoxDecoration(
                              color: AppColors.grayE3E3DC,
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                          Container(
                            height: 14.h,
                            width: 60.w,
                            decoration: BoxDecoration(
                              color: AppColors.grayE3E3DC,
                              borderRadius: BorderRadius.circular(8.r),
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

  Widget _buildSectionCard({
    required String title,
    required Widget child,
    Color? titleColor,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyles.medium(
              16.sp,
              fontColor: titleColor ?? AppColors.textPrimary,
            ),
          ),
          Gap(6.h),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow({required String label, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyles.regular(14.sp, fontColor: AppColors.grey888888),
        ),
        Gap(5.w),
        Expanded(
          child: Text(
            value,
            style: TextStyles.regular(14.sp, fontColor: AppColors.black1414141),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderItem(order_model.Item item, OrdersController controller) {
    final productImage = item.productId?.productImage ?? '';
    final productName = item.productId?.title ?? item.name ?? 'common_product'.tr;
    final packInfo = item.durationDays != null
        ? 'orders_pack_days'.trParams({'days': '${item.durationDays}'})
        : (item.capsuleCount != null ? 'orders_capsules_count'.trParams({'count': '${item.capsuleCount}'}) : '');
    final currentPrice = item.discountedPrice ?? item.totalAmount ?? 0.0;
    final originalPrice = item.amount ?? 0.0;
    final currency =
        controller.selectedOrderData.value?.pricing?.overall?.currency ?? '\$';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product Image
        Container(
          width: 72.w,
          height: 74.w,
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
                    width: 72.w,
                    height: 74.w,
                  )
                : Icon(Icons.image, size: 30.sp, color: AppColors.grey898989),
          ),
        ),
        Gap(8.w),
        // Product Details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          productName,
                          style: TextStyles.semiBold(15.sp),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        if (packInfo.isNotEmpty)
                          Text(
                            packInfo,
                            style: TextStyles.regular(
                              13.sp,
                              fontColor: AppColors.black1414141,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                      ],
                    ),
                  ),
                  if (currentPrice > 0) ...[
                    Gap(10.w),
                    Text(
                      '$currency${currentPrice.toStringAsFixed(2)}',
                      style: TextStyles.semiBold(12.sp),
                    ),
                  ],
                  if (originalPrice > 0 && originalPrice > currentPrice) ...[
                    Gap(4.w),
                    Text(
                      '$currency${originalPrice.toStringAsFixed(2)}',
                      style: TextStyles.medium(
                        12.sp,
                        fontColor: AppColors.grey949597,
                        textDecoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ],
              ),
              Gap(4.h),
              // Action Buttons
              Obx(() {
                final productId = item.productId?.id;
                final buyingAgainId = controller.buyingAgainProductId.value;
                final isBuyingAgain =
                    productId != null && buyingAgainId == productId;
                return Row(
                  children: [
                    Expanded(
                      child: CommonButtonWidget(
                        height: 28.h,
                        color: AppColors.greyEBEBEB,
                        borderRadius: 6,
                        onPressed: () => controller.reviewProduct(item),
                        child: Center(
                          child: Text(
                            'orders_review'.tr,
                            style: TextStyles.medium(
                              13.sp,
                              fontColor: AppColors.black1414141,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Gap(10.w),
                    Expanded(
                      child: AbsorbPointer(
                        absorbing: isBuyingAgain || productId == null,
                        child: CommonButtonWidget(
                          height: 28.h,
                          color: AppColors.primaryColor,
                          borderRadius: 6,
                          onPressed: () {
                            if (productId != null)
                              controller.buyAgain(productId);
                          },
                          child: Center(
                            child: isBuyingAgain
                                ? SizedBox(
                                    height: 16.h,
                                    width: 16.w,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.white,
                                      ),
                                    ),
                                  )
                                : Text(
                                    'orders_buy_again'.tr,
                                    style: TextStyles.medium(
                                      13.sp,
                                      fontColor: AppColors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentRow({
    required String label,
    required String value,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isBold
              ? TextStyles.semiBold(16.sp)
              : TextStyles.regular(14.sp),
        ),
        Text(
          value,
          style: isBold
              ? TextStyles.semiBold(16.sp)
              : TextStyles.regular(14.sp),
        ),
      ],
    );
  }

  Widget _buildFullAddress(order_model.ShippingAddressId? address) {
    if (address == null) {
      return Text(
        'orders_na'.tr,
        style: TextStyles.regular(13.sp, fontColor: AppColors.grey888888),
      );
    }

    final List<String> addressParts = [];

    // Name
    if (address.firstName != null && address.firstName!.isNotEmpty) {
      final nameParts = <String>[];
      if (address.firstName != null && address.firstName!.isNotEmpty) {
        nameParts.add(address.firstName!);
      }
      if (address.lastName != null && address.lastName!.isNotEmpty) {
        nameParts.add(address.lastName!);
      }
      if (nameParts.isNotEmpty) {
        addressParts.add(nameParts.join(' '));
      }
    }

    // Street address
    final streetParts = <String>[];
    if (address.streetName != null && address.streetName!.isNotEmpty) {
      streetParts.add(address.streetName!);
    }
    if (address.houseNumber != null && address.houseNumber!.isNotEmpty) {
      streetParts.add(address.houseNumber!);
    }
    if (address.houseNumberAddition != null &&
        address.houseNumberAddition!.isNotEmpty) {
      streetParts.add(address.houseNumberAddition!);
    }
    if (streetParts.isNotEmpty) {
      addressParts.add(streetParts.join(' '));
    }

    // City and Postal Code
    final cityParts = <String>[];
    if (address.postalCode != null && address.postalCode!.isNotEmpty) {
      cityParts.add(address.postalCode!);
    }
    if (address.city != null && address.city!.isNotEmpty) {
      cityParts.add(address.city!);
    }
    if (cityParts.isNotEmpty) {
      addressParts.add(cityParts.join(' '));
    }

    // Country
    if (address.country != null && address.country!.isNotEmpty) {
      addressParts.add(address.country!);
    }

    // Phone
    if (address.phone != null && address.phone!.isNotEmpty) {
      addressParts.add('${'orders_phone_label'.tr} ${address.phone}');
    }

    // Note
    if (address.note != null && address.note!.isNotEmpty) {
      addressParts.add('${'orders_note_label'.tr} ${address.note}');
    }

    if (addressParts.isEmpty) {
      // Fallback to address field if available
      if (address.address != null && address.address!.isNotEmpty) {
        return Text(
          address.address!,
          style: TextStyles.regular(13.sp, fontColor: AppColors.grey888888),
        );
      }
      return Text(
        'orders_na'.tr,
        style: TextStyles.regular(13.sp, fontColor: AppColors.grey888888),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: addressParts.asMap().entries.map((entry) {
        final index = entry.key;
        final part = entry.value;
        return Padding(
          padding: EdgeInsets.only(
            bottom: index < addressParts.length - 1 ? 4.h : 0,
          ),
          child: Text(
            part,
            style: TextStyles.regular(13.sp, fontColor: AppColors.grey888888),
          ),
        );
      }).toList(),
    );
  }
}

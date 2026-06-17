import 'package:viteezy/core/models/product_response_model.dart';
import 'package:viteezy/core/widgets/common_network_image.dart';
import 'package:viteezy/gen/assets.gen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';

import '../utils/exports.dart';

class ShareProductBottomSheet extends StatelessWidget {
  final Product product;

  const ShareProductBottomSheet({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.yellowF0EFE4,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20.r), topRight: Radius.circular(20.r)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Indicator
            Padding(
              padding: EdgeInsets.only(top: 12.h, bottom: 8.h),
              child: Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(color: AppColors.whiteE5E4DC, borderRadius: BorderRadius.circular(2.r)),
                ),
              ),
            ),
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: null,
                    child: Icon(Icons.close, size: 24.sp, color: Colors.transparent),
                  ),
                  Expanded(
                    child: Center(
                      child: Text('share_my_product'.tr, style: TextStyles.bold(20.sp, fontColor: AppColors.black1414141)),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Icon(Icons.close, size: 24.sp, color: AppColors.black1414141),
                  ),
                ],
              ),
            ),
            // Product Image
            Container(
              width: double.infinity,
              height: 200.h,
              margin: EdgeInsets.symmetric(horizontal: 20.w),
              decoration: BoxDecoration(color: AppColors.offWhite, borderRadius: BorderRadius.circular(12.r)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: product.productImage != null && product.productImage!.isNotEmpty
                    ? CommonNetworkImage(
                        imageUrl: product.productImage!,
                        fit: BoxFit.contain,
                        // width: double.infinity,
                        height: 200.h,
                      )
                    : Center(
                        child: Icon(Icons.image_not_supported, size: 48.sp, color: AppColors.gray949391),
                      ),
              ),
            ),
            Gap(16.h),
            // Product Name
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Text(product.title ?? "", style: TextStyles.bold(20.sp, fontColor: AppColors.black1414141)),
            ),
            Gap(4.h),
            // Tagline
            if (product.shortDescription != null && product.shortDescription!.isNotEmpty)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Text(
                  product.shortDescription!,
                  style: TextStyles.regular(14.sp, fontColor: AppColors.black1414141),
                ),
              ),
            Gap(16.h),
            // Pricing Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Get price - prefer sachetPrices thirtyDays, fallback to price
                      Builder(
                        builder: (context) {
                          final selectedPrice = product.sachetPrices?.thirtyDays;
                          final hasDiscount =
                              selectedPrice != null &&
                              selectedPrice.totalAmount != null &&
                              selectedPrice.amount != null &&
                              selectedPrice.totalAmount! < selectedPrice.amount!;

                          if (selectedPrice != null && selectedPrice.totalAmount != null) {
                            return Row(
                              children: [
                                Text(
                                  '${selectedPrice.currency ?? ''} ${selectedPrice.totalAmount}',
                                  style: TextStyles.bold(20.sp, fontColor: AppColors.primaryColor),
                                ),
                                if (hasDiscount && selectedPrice.amount != null) ...[
                                  Gap(8.w),
                                  Text(
                                    '${selectedPrice.currency ?? ''} ${selectedPrice.amount}',
                                    style: TextStyles.semiBold(
                                      16.sp,
                                      fontColor: AppColors.gray949391,
                                      textDecoration: TextDecoration.lineThrough,
                                    ).copyWith(decorationColor: AppColors.gray949391),
                                  ),
                                  if (selectedPrice.savingsPercentage != null) ...[
                                    Gap(8.w),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                      decoration: BoxDecoration(
                                        color: AppColors.black1414141,
                                        borderRadius: BorderRadius.only(
                                          bottomRight: Radius.circular(20.h),
                                          topRight: Radius.circular(20.h),
                                        ),
                                      ),
                                      child: Text(
                                        'Save ${selectedPrice.savingsPercentage?.toStringAsFixed(0) ?? 0}%',
                                        style: TextStyles.medium(12.sp, fontColor: AppColors.surfaceColor),
                                      ),
                                    ),
                                  ],
                                ],
                              ],
                            );
                          } else if (product.price != null && product.price!.amount != null) {
                            return Text(
                              '${product.price!.currency ?? ''} ${product.price!.amount}',
                              style: TextStyles.bold(20.sp, fontColor: AppColors.primaryColor),
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                        },
                      ),
                    ],
                  ),
                  Gap(4.h),
                  Text(
                    'MRP inclusive of all taxes',
                    style: TextStyles.regular(12.sp, fontColor: AppColors.black1414141),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Gap(32.h),
            // Sharing Options
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildShareOption(
                    icon: Assets.icons.icCopyLink,
                    label: 'Copy Link',
                    onTap: () {
                      Get.back();
                      _shareProduct();
                      Get.snackbar('common_success'.tr, 'share_link_copied'.tr);
                    },
                  ),
                  Gap(40.w),
                  _buildShareOption(
                    materialIcon: Icons.more_vert,
                    label: 'More',
                    onTap: () {
                      _shareProduct();
                    },
                  ),
                ],
              ),
            ),
            Gap(20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOption({
    SvgGenImage? icon,
    IconData? materialIcon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50.w,
            height: 50.w,
            decoration: BoxDecoration(color: AppColors.surfaceColor, shape: BoxShape.circle),
            child: Center(
              child: materialIcon != null
                  ? Icon(materialIcon, size: 24.sp, color: AppColors.black1414141)
                  : icon!.svg(
                      width: 20.w,
                      height: 20.w,
                      colorFilter: ColorFilter.mode(AppColors.black1414141, BlendMode.srcIn),
                    ),
            ),
          ),
          Gap(8.h),
          Text(label, style: TextStyles.regular(14.sp, fontColor: AppColors.black1414141)),
        ],
      ),
    );
  }

  /// Share product using platform's native share dialog
  Future<void> _shareProduct() async {
    try {
      // Construct shareable product link
      final productId = product.id ?? '';
      final productTitle = product.title ?? 'common_product'.tr;
      final productLink = 'https://viteezy.com/product/$productId'; // Adjust this URL as needed

      // Create share text with product name and link
      final shareText = 'share_product_message'.trParams({'title': productTitle, 'link': productLink});

      // Use share_plus to show native share sheet with all shareable apps
      await Share.share(shareText);

    } catch (e) {
      // If sharing fails, copy to clipboard as fallback
      try {
        final productId = product.id ?? '';
        final productTitle = product.title ?? 'common_product'.tr;
        final productLink = 'https://viteezy.com/product/$productId';
        final shareText = 'share_product_message'.trParams({'title': productTitle, 'link': productLink});

        await Clipboard.setData(ClipboardData(text: shareText));
        Get.back();
        Get.snackbar('common_success'.tr, 'share_product_link_copied'.tr);
      } catch (clipboardError) {
        Get.back();
        Get.snackbar('common_error'.tr, 'share_product_failed'.tr);
      }
    }
  }
}

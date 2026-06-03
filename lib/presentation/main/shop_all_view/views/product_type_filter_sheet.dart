import 'package:viteezy/core/utils/exports.dart';

import '../controller/shop_all_controller.dart';

class ProductTypeFilterSheet extends GetView<ShopAllController> {
  const ProductTypeFilterSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(child: _buildOptions(context)),
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(color: AppColors.whiteE5E4DC, borderRadius: BorderRadius.circular(50)),
            height: 7.h,
            width: 55.w,
          ),
          Gap(10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Gap(28.w),
              Text('shop_product_type'.tr, style: TextStyles.semiBold(24.sp, fontColor: AppColors.black1414141)),
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  padding: EdgeInsets.all(4.sp),
                  child: Icon(Icons.close, size: 24.sp, color: AppColors.black1414141),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOptions(BuildContext context) {
    return Obx(() {
      // Access observable list and convert to regular list for proper tracking
      final selectedProductTypesList = controller.selectedProductTypes.toList();
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
        child: Container(
          decoration: BoxDecoration(color: AppColors.surfaceColor, borderRadius: BorderRadius.circular(20.r)),
          child: ListView.builder(
            itemCount: controller.productTypeOptions.length,
            itemBuilder: (context, index) {
              final productType = controller.productTypeOptions[index];
              final isSelected = selectedProductTypesList.contains(productType);
              return Column(
                children: [
                  if (index != 0)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15.w),
                      child: Divider(height: 2.h, color: AppColors.backgroundColor),
                    ),
                  InkWell(
                    onTap: () => controller.toggleProductType(productType),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(productType, style: TextStyles.medium(16.sp, fontColor: AppColors.black1414141)),
                          Checkbox(
                            value: isSelected,
                            onChanged: (value) => controller.toggleProductType(productType),
                            activeColor: AppColors.primaryColor,
                            checkColor: AppColors.surfaceColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      );
    });
  }

  Widget _buildActionButtons(BuildContext context) {
    return Obx(
      () => Padding(
        padding: EdgeInsets.all(16.sp),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: controller.selectedProductTypes.isNotEmpty
                        ? () => controller.clearProductTypeFilter()
                        : null,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      side: BorderSide(color: AppColors.whiteE5E4DC, width: 1.w),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      backgroundColor: AppColors.surfaceColor,
                    ),
                    child: Text('shop_clear_filter'.tr, style: TextStyles.medium(16.sp, fontColor: AppColors.black1414141)),
                  ),
                ),
                SizedBox(width: 12.sp),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: AppColors.textOnPrimary,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      elevation: 0,
                    ),
                    child: Text('common_done'.tr, style: TextStyles.semiBold(16.sp, fontColor: AppColors.surfaceColor)),
                  ),
                ),
              ],
            ),
            Gap(10),
          ],
        ),
      ),
    );
  }
}

import 'package:viteezy/core/utils/exports.dart';

import '../controller/shop_all_controller.dart';

class ShopAllFilterBottomSheet extends GetView<ShopAllController> {
  const ShopAllFilterBottomSheet({super.key, required this.isCategory, this.category});
  final bool isCategory;
  final String? category;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(context),

          // Filter Options
          Expanded(child: _buildFilterOptions(context)),

          // Action Buttons
          _buildActionButtons(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(color: AppColors.whiteE5E4DC, borderRadius: BorderRadius.circular(50)),
            height: 7,
            width: 55,
          ),
          Gap(10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Gap(28),
              Text('shop_all_title'.tr, style: TextStyles.semiBold(24.sp, fontColor: AppColors.black1414141)),
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: Icon(Icons.close, size: 24, color: AppColors.black1414141),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterOptions(BuildContext context) {
    return Obx(
      () => Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.r), color: AppColors.surfaceColor),
              width: Get.width,
              child: Column(
                children: [
                  _buildFilterRow(
                    label: 'Ingredient',
                    value: controller.selectedIngredients.isEmpty ? null : controller.selectedIngredients.join(', '),
                    onTap: () {
                      // Get.back();
                      controller.showIngredientFilter();
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15.w),
                    child: Divider(height: 1, color: AppColors.backgroundColor),
                  ),
                  _buildFilterRow(
                    label: 'Health goal',
                    value: controller.selectedHealthGoals.isEmpty
                        ? null
                        : controller.selectedHealthGoals.length == 1
                        ? controller.selectedHealthGoals.first
                        : '${controller.selectedHealthGoals.length} selected',
                    onTap: () {
                      // Get.back();
                      controller.showHealthGoalFilter();
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15.w),
                    child: Divider(height: 1, color: AppColors.backgroundColor),
                  ),
                  _buildFilterRow(
                    label: 'Product Type',
                    value: controller.selectedProductTypes.isEmpty ? null : controller.selectedProductTypes.join(', '),
                    onTap: () {
                      // Get.back();
                      controller.showProductTypeFilter();
                    },
                  ),
                ],
              ),
            ),
            Gap(15),
            Container(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.r), color: AppColors.surfaceColor),
              child: _buildFilterRow(
                label: 'Sort by',
                value: controller.selectedSortByLabel.value.isNotEmpty ? controller.selectedSortByLabel.value : null,
                onTap: () {
                  // Get.back();
                  controller.showSortByFilter();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterRow({required String label, String? value, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyles.medium(16.sp, fontColor: AppColors.black1414141)),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (value != null)
                  Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: SizedBox(
                      width: 130.w,
                      child: Text(
                        value,
                        style: TextStyles.medium(12.sp, fontColor: AppColors.gray949391),
                        maxLines: 1,
                        textAlign: TextAlign.end,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                Icon(Icons.keyboard_arrow_right, size: 20.sp, color: AppColors.black1414141),
              ],
            ),
          ],
        ),
      ),
    );
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
                    onPressed: controller.activeFilterCount > 0
                        ? () => controller.clearAllFilters(isCategory: isCategory, category: category)
                        : null,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      side: BorderSide(color: AppColors.whiteE5E4DC, width: 1.w),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      backgroundColor: AppColors.surfaceColor,
                    ),
                    child: Text(
                      controller.activeFilterCount > 0 ? 'Clear all (${controller.activeFilterCount})' : 'Clear all',
                      style: TextStyles.medium(16.sp, fontColor: AppColors.black1414141),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      controller.applyFilters(isCategory, category: category);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: AppColors.textOnPrimary,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      elevation: 0,
                    ),
                    child: Text('shop_show_results'.tr, style: TextStyles.semiBold(16.sp, fontColor: AppColors.surfaceColor)),
                  ),
                ),
              ],
            ),
            Gap(10.h),
          ],
        ),
      ),
    );
  }
}

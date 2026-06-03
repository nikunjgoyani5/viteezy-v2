import 'package:viteezy/core/utils/exports.dart';

import '../controller/shop_all_controller.dart';

class SortByFilterSheet extends GetView<ShopAllController> {
  const SortByFilterSheet({super.key});

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
          Gap(10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Gap(28.w),
              Text('shop_sort_by'.tr, style: TextStyles.semiBold(24.sp, fontColor: AppColors.black1414141)),
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  padding: EdgeInsets.all(4.sp),
                  child: Icon(Icons.close, size: 24, color: AppColors.black1414141),
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
      // Access observable to ensure proper tracking
      final selectedSort = controller.selectedSortBy.value;
      // Use sortBy from filtersData if available, otherwise fallback to empty list
      final sortByOptions = controller.filtersData?.sortBy ?? [];

      if (sortByOptions.isEmpty) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
          child: Center(
            child: Text(
              'No sort options available',
              style: TextStyles.medium(16.sp, fontColor: AppColors.black1414141),
            ),
          ),
        );
      }

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
        child: Container(
          decoration: BoxDecoration(color: AppColors.surfaceColor, borderRadius: BorderRadius.circular(20.r)),
          child: ListView.builder(
            itemCount: sortByOptions.length,
            itemBuilder: (context, index) {
              final sortOption = sortByOptions[index];
              final isSelected = selectedSort == sortOption.value;
              return Column(
                children: [
                  if (index != 0)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15.w),
                      child: Divider(height: 2.h, color: AppColors.backgroundColor),
                    ),
                  InkWell(
                    onTap: () => controller.selectSortBy(sortOption.value ?? ""),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 16.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            sortOption.label ?? "",
                            style: TextStyles.medium(16.sp, fontColor: AppColors.black1414141),
                          ),
                          Container(
                            width: 24.w,
                            height: 24.h,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? AppColors.primaryColor : AppColors.gray949391,
                                width: 2.w,
                              ),
                              color: isSelected ? AppColors.primaryColor : Colors.transparent,
                            ),
                            child: isSelected
                                ? Center(
                                    child: Container(
                                      width: 12.w,
                                      height: 12.h,
                                      decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.surfaceColor),
                                    ),
                                  )
                                : null,
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
                    onPressed: controller.selectedSortBy.value.isNotEmpty ? () => controller.clearSortByFilter() : null,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      side: BorderSide(color: AppColors.whiteE5E4DC, width: 1.w),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      backgroundColor: AppColors.surfaceColor,
                    ),
                    child: Text('shop_clear_filter'.tr, style: TextStyles.medium(16.sp, fontColor: AppColors.black1414141)),
                  ),
                ),
                SizedBox(width: 12.w),
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

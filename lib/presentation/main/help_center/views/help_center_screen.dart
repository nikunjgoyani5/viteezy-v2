import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:viteezy/core/routes/app_routes.dart';
import 'package:viteezy/core/theme/text_styles.dart';
import 'package:viteezy/core/widgets/common_appbar.dart';
import 'package:viteezy/core/widgets/common_network_image.dart';
import 'package:viteezy/core/widgets/common_textfield.dart';
import 'package:viteezy/core/widgets/empty_state.dart';
import 'package:viteezy/core/widgets/shimmer_widget.dart';
import 'package:viteezy/gen/assets.gen.dart';
import 'package:viteezy/presentation/main/help_center/controllers/help_center_controller.dart';

import 'package:viteezy/core/utils/exports.dart';

class HelpCenterScreen extends GetView<HelpCenterController> {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CommonAppbar(title: ''),
      body: GetBuilder<HelpCenterController>(
        builder: (controller) {
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search Bar
                      Text('help_center_title'.tr, style: TextStyles.medium(26)),
                      Gap(15.h),
                      CommonSearchTextField(
                        hintText: 'Search for articles...',
                        controller: controller.searchController,
                        prefixIcon: Assets.icons.icSearch.svg(),
                        onChanged: (val) async {
                          await controller.getFaqCategory();
                        },
                        borderColor: AppColors.grey9BA3AA,
                      ),
                      Gap(28.h),
                      // Section Title
                      Text('help_center_subtitle'.tr, style: TextStyles.medium(18.sp)),
                      Gap(14.h),
                      // Category Cards Grid with Loading/Empty States
                      Obx(() {
                        // Show shimmer while loading
                        if (controller.isLoading.value) {
                          return _buildShimmerGrid();
                        }

                        if (controller.filteredCategories.isEmpty) {
                          return EmptyState(
                            icon: Icons.help_outline,
                            title: 'help_center_no_categories'.tr,
                            message: 'There are no FAQ categories available at the moment.',
                          );
                        }

                        // Show grid with data
                        return GridView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12.w,
                            mainAxisSpacing: 12.h,
                            childAspectRatio: 1,
                          ),
                          itemCount: controller.filteredCategories.length,
                          itemBuilder: (context, index) {
                            return _buildCategoryCard(controller.filteredCategories[index]);
                          },
                        );
                      }),
                      Gap(20.h),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategoryCard(HelpCategory category) {
    return InkWell(
      onTap: () {
        Get.toNamed(AppRoutes.helpDetails, arguments: {'categoryTitle': category.title});
      },
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.greyDDDDDD, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommonNetworkImage(imageUrl: category.iconUrl ?? '', width: 45.sp, height: 45.sp),

            Spacer(),
            Text(category.title, style: TextStyles.medium(16.sp), maxLines: 2, overflow: TextOverflow.ellipsis),
            Gap(5),
            Text(
              "${category.articleCount} articles",
              style: TextStyles.regular(14.sp, fontColor: AppColors.grey787878),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerGrid() {
    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 1,
      ),
      itemCount: 6,
      // Show 6 shimmer items
      itemBuilder: (context, index) {
        return ShimmerWidget(
          child: Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.greyDDDDDD, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 45.sp,
                  height: 45.sp,
                  decoration: BoxDecoration(color: AppColors.greyDDDDDD, borderRadius: BorderRadius.circular(8)),
                ),
                Spacer(),
                Container(
                  height: 16.h,
                  width: double.infinity,
                  decoration: BoxDecoration(color: AppColors.greyDDDDDD, borderRadius: BorderRadius.circular(4)),
                ),
                Gap(8.h),
                Container(
                  height: 14.h,
                  width: 100.w,
                  decoration: BoxDecoration(color: AppColors.greyDDDDDD, borderRadius: BorderRadius.circular(4)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

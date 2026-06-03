import 'package:viteezy/core/models/faq_response_model.dart';
import 'package:viteezy/core/widgets/common_appbar.dart';
import 'package:viteezy/core/widgets/common_loader.dart';
import 'package:viteezy/core/widgets/empty_state.dart';
import 'package:viteezy/core/widgets/shimmer_widget.dart';
import 'package:viteezy/gen/assets.gen.dart';
import 'package:viteezy/presentation/main/help_details/controllers/help_details_controller.dart';

import 'package:viteezy/core/utils/exports.dart';

class HelpDetailsScreen extends GetView<HelpDetailsController> {
  const HelpDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HelpDetailsController>(
      builder: (controller) {
        return PopScope(
          canPop: !controller.showFaqDetail,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop && controller.showFaqDetail) {
              // If we're showing FAQ detail, go back to list instead of closing screen
              controller.goBackToList();
            }
          },
          child: Scaffold(
            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
            floatingActionButton: GetBuilder<HelpDetailsController>(
              builder: (controller) {
                // if you display the comment so this condition mack true
                // return controller.showFaqDetail == false
                //     ? Padding(
                //         padding: const EdgeInsets.symmetric(horizontal: 16.0),
                //         child: Column(
                //           mainAxisAlignment: MainAxisAlignment.end,
                //           mainAxisSize: MainAxisSize.min,
                //           children: [
                //             Container(height: 1, color: AppColors.greyEDEDED),
                //
                //             Gap(10.h),
                //             Container(
                //               padding: EdgeInsets.all(20.w),
                //               decoration: BoxDecoration(
                //                 color: AppColors.greyF5F5F5,
                //                 borderRadius: BorderRadius.circular(10),
                //               ),
                //               child: Column(
                //                 crossAxisAlignment: CrossAxisAlignment.center,
                //                 children: [
                //                   Text(
                //                     'Did this answer your question?',
                //                     style: TextStyles.regular(14.sp, fontColor: AppColors.grey6A6A6A),
                //                   ),
                //                   Gap(16.h),
                //                   Row(
                //                     mainAxisAlignment: MainAxisAlignment.center,
                //                     children: [
                //                       Image.asset(Assets.images.sad.path, scale: 3),
                //                       Gap(10),
                //                       Image.asset(Assets.images.smile.path, scale: 3),
                //                       Gap(10),
                //                       Image.asset(Assets.images.happy.path, scale: 3),
                //                     ],
                //                   ),
                //                 ],
                //               ),
                //             ),
                //             Gap(15.h),
                //           ],
                //         ),
                //       ):
                    return SizedBox();
              },
            ),
            appBar: CommonAppbar(
              title: '',
              onLeadPress: () {
                if (controller.showFaqDetail == true) {
                  controller.showFaqDetail = false;
                  controller.update();
                } else {
                  Get.back();
                }
              },
            ),
            backgroundColor: AppColors.white,
            body: Column(
              children: [
                Expanded(
                  child: (controller.showFaqDetail && controller.selectedFaq != null)
                      ? _buildFaqDetailView(controller)
                      : _buildFaqListView(controller),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppBar(HelpDetailsController controller) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(Get.context!).padding.top, left: 16.w, right: 16.w, bottom: 16.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(bottom: BorderSide(color: AppColors.greyDDDDDD, width: 0.5)),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              if (controller.showFaqDetail) {
                controller.goBackToList();
              } else {
                Get.back();
              }
            },
            child: Icon(Icons.arrow_back, size: 24.sp, color: AppColors.black1414141),
          ),
          Gap(16.w),
          Expanded(
            child: Text(
              controller.showFaqDetail
                  ? controller.selectedFaq?.question ?? ''
                  : controller.categoryTitle.isNotEmpty
                  ? controller.categoryTitle
                  : 'Help Center',
              style: TextStyles.medium(18.sp, fontColor: AppColors.black1414141),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqListView(HelpDetailsController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return _buildShimmerList();
      }

      if (controller.faqs.isEmpty) {
        return EmptyState(
          icon: Icons.help_outline,
          title: 'No FAQs Found',
          message: 'There are no FAQs available for this category.',
        );
      }

      // Show FAQ list
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              controller.categoryTitle,
              style: TextStyles.medium(20.sp),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Gap(20.h),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: controller.faqs.length,
                itemBuilder: (context, index) {
                  return _buildFaqListItem(controller.faqs[index], controller);
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildFaqListItem(FaqItem faq, HelpDetailsController controller) {
    return InkWell(
      onTap: () => controller.selectFaq(faq),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.greyDDDDDD, width: 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                faq.question ?? '',
                style: TextStyles.medium(16.sp, fontColor: AppColors.black1414141),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Gap(12.w),
            Assets.icons.icArrowNext.svg(height: 15),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqDetailView(HelpDetailsController controller) {
    final faq = controller.selectedFaq;
    if (faq == null) return SizedBox.shrink();

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Gap(10.h),
          if (controller.categoryTitle.isNotEmpty)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'All articles',
                  style: TextStyles.regular(15.sp, fontColor: AppColors.black1414141),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Gap(5),
                Assets.icons.icArrowNext.svg(height: 12, width: 12),
                Gap(5),
                Expanded(
                  flex: 2,
                  child: Text(
                    controller.categoryTitle,
                    style: TextStyles.regular(15.sp, fontColor: AppColors.black1414141),
                    maxLines: 1,

                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Gap(5),
                Assets.icons.icArrowNext.svg(height: 12, width: 12),
                Gap(5),
                Expanded(
                  flex: 2,
                  child: Text(
                    '${faq.question} ',
                    style: TextStyles.regular(15.sp, fontColor: AppColors.grey949597),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

          Gap(20.h),
          Text(faq.question ?? '', style: TextStyles.semiBold(22.sp, fontColor: AppColors.black1414141)),
          Gap(6.h),
          Text('Updated recently', style: TextStyles.regular(14.sp, fontColor: AppColors.black1414141)),
          Gap(24.h),
          Text(faq.answer ?? '', style: TextStyles.regular(14.sp, fontColor: AppColors.black1414141)),
          Gap(40.h),
        ],
      ),
    );
  }

  Widget _buildFeedbackEmoji(String emoji) {
    return InkWell(
      onTap: () {
        // Handle feedback
      },
      child: Container(
        padding: EdgeInsets.all(12.w),
        child: Text(emoji, style: TextStyle(fontSize: 32.sp)),
      ),
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      itemCount: 6,
      itemBuilder: (context, index) {
        return ShimmerWidget(
          child: Container(
            margin: EdgeInsets.only(bottom: 12.h),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.greyDDDDDD, width: 1),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 16.h,
                        width: double.infinity,
                        decoration: BoxDecoration(color: AppColors.greyDDDDDD, borderRadius: BorderRadius.circular(4)),
                      ),
                      Gap(8.h),
                      Container(
                        height: 14.h,
                        width: 200.w,
                        decoration: BoxDecoration(color: AppColors.greyDDDDDD, borderRadius: BorderRadius.circular(4)),
                      ),
                    ],
                  ),
                ),
                Gap(12.w),
                Container(
                  width: 16.w,
                  height: 16.h,
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

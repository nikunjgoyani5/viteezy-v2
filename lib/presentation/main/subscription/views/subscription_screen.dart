import 'package:viteezy/core/models/subscription_model.dart';
import 'package:viteezy/core/routes/app_routes.dart';
import 'package:viteezy/core/widgets/common_appbar.dart';
import 'package:viteezy/core/widgets/shimmer_widget.dart';
import 'package:viteezy/presentation/main/subscription/controllers/subscription_controller.dart';
import 'package:viteezy/core/utils/exports.dart';
import 'package:viteezy/core/widgets/common_button.dart';

class SubscriptionScreen extends GetView<SubscriptionController> {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CommonAppbar(title: 'subscription_title'.tr),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildShimmerLoading();
        }

        if (controller.subscriptions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.subscriptions_outlined, size: 64.sp, color: AppColors.grey898989),
                Gap(16.h),
                Text('subscription_none'.tr, style: TextStyles.medium(18.sp, fontColor: AppColors.grey898989)),
                Gap(8.h),
                Text(
                  'subscription_empty_message'.tr,
                  style: TextStyles.regular(14.sp, fontColor: AppColors.grey898989),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollInfo) {
                  if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent &&
                      !controller.isLoadingMore.value &&
                      controller.hasMore) {
                    controller.getSubscriptions(isLoadMore: true);
                    return true;
                  }
                  return false;
                },
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
                  child: Column(
                    children: [
                      ...controller.subscriptions.map((subscription) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 16.h),
                          child: _buildSubscriptionCard(controller, subscription),
                        );
                      }),
                      if (controller.isLoadingMore.value)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          child: const Center(child: CircularProgressIndicator()),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSubscriptionCard(SubscriptionController controller, SubscriptionData subscription) {
    final isActive = subscription.status?.toLowerCase() == 'active';
    final isCancelled = subscription.status?.toLowerCase() == 'cancelled' || subscription.cancelledAt != null;
    final cycleDays = subscription.cycleDays ?? 30;
    final isThreeMonth = cycleDays == 90;
    final isOneMonth = cycleDays == 30;

    // Dynamic: price from first item
    final totalAmount = subscription.items?.isNotEmpty == true ? subscription.items!.first.totalAmount ?? 0.0 : 0.0;

    // Dynamic: plan name (e.g. "90 Days Plan")
    final planName = subscription.planType?.trim().isNotEmpty == true
        ? subscription.planType!
        : (cycleDays == 30 ? '30 Days Plan' : cycleDays == 90 ? '90 Days Plan' : '$cycleDays Days Plan');

    // Dynamic: status for badge
    final statusLabel = subscription.status ?? 'common_unknown'.tr;

    // Dynamic: renewal date text
    String renewalDateText = '';
    if (subscription.nextBillingDate != null) {
      final date = subscription.nextBillingDate!;
      renewalDateText = '${date.day} ${_getMonthName(date.month)} ${date.year}';
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
    border: Border.all(color: AppColors.yellowF0EFE4)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current Plan + status badge
          Row(
            children: [
              Text(
                'subscription_current_plan'.tr,
                style: TextStyles.medium(17.sp, fontColor: AppColors.black1414141),
              ),
              Gap(8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primaryColor : (isCancelled ? AppColors.red : AppColors.grey898989),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyles.medium(12.sp, fontColor: AppColors.white),
                ),
              ),
            ],
          ),
          Gap(10.h),
          // Plan name (e.g. "90 Days Plan")

          Text(
             '$cycleDays days'" Plan",
            style:TextStyles.medium(16.sp, fontColor: AppColors.black1414141),
          ),

          Text(
            '\$${totalAmount.toStringAsFixed(2)}',
            style: TextStyles.semiBold(26.sp, fontColor: AppColors.black1414141),
          ),

          Gap(8.h),
          // Renewal / end date (dynamic)
          if (isActive && renewalDateText.isNotEmpty)
            Text(
              'subscription_renews_on'.trParams({'date': renewalDateText}),
              style: TextStyles.regular(14.sp, fontColor: AppColors.grey898989),
            )
          else if (isCancelled && subscription.subscriptionEndDate != null)
            Text(
              'subscription_ends_on'.trParams({'date': _formatDate(subscription.subscriptionEndDate!)}),
              style: TextStyles.regular(14.sp, fontColor: AppColors.grey898989),
            ),
          if (isActive && isOneMonth)
            Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 18.sp, color: AppColors.grey545454),
                    Gap(8.w),
                    Expanded(
                      child: Text(
                        'subscription_cancel_not_available'.trParams({'plan': planName}),
                        style: TextStyles.regular(13.sp, fontColor: AppColors.grey545454),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Gap(16.h),
          // View Details (primary CTA)
          SizedBox(
            width: double.infinity,
            child: CommonButtonWidget(
              height: 48.h,
              color: AppColors.black1414141,
              borderRadius: 30,
              onPressed: () => Get.toNamed(
                AppRoutes.subscriptionDetails,
                arguments: {'subscription': subscription},
              ),
              child: Center(
                child: Text(
                  'subscription_view_details'.tr,
                  style: TextStyles.medium(16.sp, fontColor: AppColors.white),
                ),
              ),
            ),
          ),
          // Pause / Cancel for 90-day active
          // if (subscription.cycleDays == 90 &&
          //     subscription.status?.toLowerCase() == 'active' &&
          //     subscription.pausedAt == null) ...[
          //   Gap(12.h),
          //   Row(
          //     children: [
          //       Expanded(
          //         child: CommonButtonWidget(
          //           height: 42.h,
          //           color: AppColors.black1414141,
          //           borderRadius: 8,
          //           onPressed: () {
          //             if (subscription.id != null) controller.pausePlan(subscription.id!);
          //           },
          //           child: Center(
          //             child: Text(
          //               'subscription_pause_plan'.tr,
          //               style: TextStyles.medium(16.sp, fontColor: AppColors.white),
          //             ),
          //           ),
          //         ),
          //       ),
          //       Gap(12.w),
          //       Expanded(
          //         child: CommonButtonWidget(
          //           height: 42.h,
          //           color: AppColors.red,
          //           borderRadius: 8,
          //           onPressed: () => _showCancelDialog(controller, subscription),
          //           child: Center(
          //             child: Text(
          //               'subscription_cancel_plan'.tr,
          //               style: TextStyles.medium(16.sp, fontColor: AppColors.white),
          //             ),
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ] else if (isCancelled) ...[
          //   Gap(12.h),
          //   SizedBox(
          //     width: double.infinity,
          //     child: CommonButton(
          //       height: 42.h,
          //       borderRadius: 30,
          //       text: 'Restart Plan',
          //       color: AppColors.primaryColor,
          //       onPressed: () {
          //         // if (subscription.id != null) controller.restartPlan(subscription.id!);
          //       },
          //     ),
          //   ),
          // ],
        ],
      ),
    );
  }

  void _showCancelDialog(SubscriptionController controller, SubscriptionData subscription) {
    final accessUntilDate = subscription.subscriptionEndDate != null
        ? _formatDate(subscription.subscriptionEndDate!)
        : '';

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: AlignmentGeometry.center,
                child: Text('subscription_cancel_title'.tr, style: TextStyles.medium(21.sp)),
              ),
              Gap(6.h),
              Align(
                alignment: AlignmentGeometry.center,
                child: Text(
                  accessUntilDate.isNotEmpty
                      ? 'subscription_cancel_access_until'.trParams({'date': accessUntilDate})
                      : 'subscription_cancel_confirm'.tr,
                  style: TextStyles.regular(16.sp),
                ),
              ),
              Gap(18.h),
              Row(
                children: [
                  Expanded(
                    child: CommonButtonWidget(
                      height: 44.h,
                      color: AppColors.red,
                      borderRadius: 40,
                      onPressed: () {
                        if (subscription.id != null) {
                          controller.confirmCancel(subscription.id!);
                        }
                        Get.back();
                      },
                      child: Center(
                        child: Text('subscription_confirm_cancel'.tr, style: TextStyles.medium(16.sp, fontColor: AppColors.white)),
                      ),
                    ),
                  ),
                  Gap(10.w),
                  Expanded(
                    child: CommonButtonWidget(
                      height: 44.h,
                      color: AppColors.black1414141,
                      borderRadius: 40,
                      onPressed: () {
                        Get.back();
                      },
                      child: Center(
                        child: Text('subscription_keep_plan'.tr, style: TextStyles.medium(16.sp, fontColor: AppColors.white)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  String _formatDate(DateTime date) {
    return '${date.day} ${_getMonthName(date.month)} ${date.year}';
  }

  Widget _buildShimmerLoading() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      child: Column(
        children: [
          ShimmerWidget(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(15.w),
              decoration: BoxDecoration(color: AppColors.grayE3E3DC, borderRadius: BorderRadius.circular(20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header shimmer
                  Row(
                    children: [
                      Container(
                        width: 100.w,
                        height: 20.h,
                        decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(4.r)),
                      ),
                      Gap(10.w),
                      Container(
                        width: 60.w,
                        height: 24.h,
                        decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(20.r)),
                      ),
                    ],
                  ),
                  Gap(8.h),
                  // Plan name shimmer
                  Container(
                    width: 150.w,
                    height: 18.h,
                    decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(4.r)),
                  ),
                  Gap(4.h),
                  // Price shimmer
                  Container(
                    width: 120.w,
                    height: 28.h,
                    decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(4.r)),
                  ),
                  Gap(6.h),
                  // Renewal date shimmer
                  Container(
                    width: 200.w,
                    height: 16.h,
                    decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(4.r)),
                  ),
                  Gap(15.h),
                  // Buttons shimmer
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 42.h,
                          decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(8.r)),
                        ),
                      ),
                      Gap(12.w),
                      Expanded(
                        child: Container(
                          height: 42.h,
                          decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(8.r)),
                        ),
                      ),
                    ],
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

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:viteezy/core/widgets/common_appbar.dart';
import '../../../../core/models/membership_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/common_button.dart';
import '../../../../core/widgets/shimmer_widget.dart';
import '../controller/member_controller.dart';

class TransactionHistory extends StatelessWidget {
  final MembershipListItem membership;

  const TransactionHistory({super.key, required this.membership});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<MemberController>();

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CommonAppbar(
        title: "Transaction History",
        actionWidget: IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () {
            if (membership.status.toLowerCase() == 'active') {
              showCancelMembershipDialog(context);
            }
          },
        ),
        centerTitle: true,
        showBackButton: true,
      ),
      body: Obx(() {
        if (ctrl.isLoadingTransactions.value) {
          return transactionShimmer();
        }

        if (ctrl.transactions.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.only(top: 50.h),
              child: Text('No transactions found', style: TextStyles.medium(16, fontColor: AppColors.grey999999)),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: RefreshIndicator(
            onRefresh: () async {
              await ctrl.loadTransactions(membership.id);
            },
            child: ListView.separated(
              itemCount: ctrl.transactions.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final transaction = ctrl.transactions[index];
                return transactionCard(
                  context: context,
                  transaction: transaction,
                  onTap: () {
                    _showTransactionDetails(context, transaction);
                  },
                );
              },
            ),
          ),
        );
      }),
    );
  }

  Widget transactionCard({required BuildContext context, required dynamic transaction, required VoidCallback onTap}) {
    final amount = '${transaction.currency} ${transaction.amount.toStringAsFixed(2)}';
    final status = transaction.status;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.greyF0EFE4, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('MMM dd, yyyy').format(transaction.processedAt ?? DateTime.now()),
                  style: TextStyles.medium(18, fontWeight: FontWeight.w500, fontColor: AppColors.blackColor),
                ),
                Text(
                  amount,
                  style: TextStyles.medium(18, fontWeight: FontWeight.w500, fontColor: AppColors.blackColor),
                ),
              ],
            ),
            Gap(17.h),
            Text(
              "Transaction ID",
              style: TextStyles.medium(14, fontWeight: FontWeight.w500, fontColor: AppColors.grey6E6E6E),
            ),
            Gap(4.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    transaction.transactionId,
                    style: TextStyles.medium(16, fontWeight: FontWeight.w500, fontColor: AppColors.blackColor),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Gap(8.w),
                statusBadge(status),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String formatDate(String? dateString) {
    try {
      if (dateString == null || dateString.isEmpty) return '';

      final dateTime = DateTime.parse(dateString).toLocal();

      return DateFormat('MMM dd, yyyy').format(dateTime);
    } catch (e) {
      return '';
    }
  }

  Widget statusBadge(String status) {
    Color bgColor;

    switch (status.toLowerCase()) {
      case "completed":
        bgColor = AppColors.successColor;
        break;
      case "failed":
        bgColor = AppColors.errorColor;
        break;
      case "pending":
        bgColor = AppColors.yellow;
        break;
      default:
        bgColor = AppColors.errorColor;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20)),
      child: Text(
        status.capitalizeFirst ?? status,
        style: TextStyles.medium(13.5, fontWeight: FontWeight.w600, fontColor: AppColors.white),
      ),
    );
  }

  void _showTransactionDetails(BuildContext context, dynamic transaction) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 15),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(30, 26, 22, 22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: AppColors.white,
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 20, offset: const Offset(0, 10)),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Transaction Details",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 20),
                _detailRow("Transaction ID", transaction.transactionId),
                const SizedBox(height: 12),
                _detailRow("Amount", "${transaction.currency} ${transaction.amount.toStringAsFixed(2)}"),
                const SizedBox(height: 12),
                _detailRow("Status", transaction.status),
                const SizedBox(height: 12),
                _detailRow("Payment Method", transaction.paymentMethod),
                const SizedBox(height: 12),
                _detailRow("Date", transaction.processedAt?.toString().split(' ').first ?? 'N/A'),
                if (transaction.subscription != null) ...[
                  const SizedBox(height: 20),
                  const Text(
                    "Subscription Details",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 12),
                  _detailRow("Subscription #", transaction.subscription.subscriptionNumber),
                  const SizedBox(height: 12),
                  _detailRow("Cycle Days", transaction.subscription.cycleDays.toString()),
                ],
                const SizedBox(height: 26),
                SizedBox(
                  width: double.infinity,
                  child: CommonButton(
                    height: 52,
                    radius: 40,
                    color: AppColors.blackColor,
                    text: "Close",
                    textSize: 16,
                    onPressed: () => Get.back(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  Widget _detailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyles.medium(14, fontWeight: FontWeight.w500, fontColor: AppColors.grey6E6E6E),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyles.medium(16, fontWeight: FontWeight.w500, fontColor: AppColors.blackColor),
        ),
      ],
    );
  }

  void showCancelMembershipDialog(BuildContext context) {
    final ctrl = Get.find<MemberController>();

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 15.w),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 20.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            color: AppColors.white,
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 20, offset: const Offset(0, 10)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              /// Title
              Text(
                "Cancel Membership",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),

              Gap(14.h),

              /// Description
              Text(
                "You’ll keep full access until ${DateFormat('MMM dd, yyyy').format(ctrl.activeMembership.value.expiresAt ?? DateTime.now())}. After that, your membership benefits will end.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.sp, color: AppColors.grey, fontWeight: FontWeight.w400),
              ),

              Gap(24.h),

              /// Buttons
              Row(
                children: [
                  Expanded(
                    child: CommonButton(
                      height: 48.h,
                      radius: 40.r,
                      color: AppColors.errorColor,
                      text: "Confirm Cancel",
                      textSize: 14.sp,
                      onPressed: () async {
                        Get.back(); // close dialog
                        await ctrl.cancelMembership(membership.id, context);
                      },
                    ),
                  ),

                  Gap(12.w),

                  Expanded(
                    child: CommonButton(
                      height: 48.h,
                      radius: 40.r,
                      color: AppColors.blackColor,
                      text: "Keep Plan",
                      textSize: 14.sp,
                      onPressed: () => Get.back(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),

      /// 👇 Allow outside tap to close
      barrierDismissible: true,
    );
  }

  Widget transactionShimmer() {
    return ListView.builder(
      itemCount: 7,
      padding: EdgeInsets.all(16.w),
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.greyF0EFE4),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ShimmerWidget(
                    child: _box(width: 100.w, height: 14.h),
                  ),
                  ShimmerWidget(
                    child: _box(width: 110.w, height: 14.h),
                  ),
                ],
              ),

              Gap(12.h),

              ShimmerWidget(
                child: _box(width: 90.w, height: 10.h),
              ),

              Gap(6.h),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ShimmerWidget(
                    child: _box(width: 160.w, height: 14.h),
                  ),
                  ShimmerWidget(
                    child: _box(width: 70.w, height: 24.h, radius: 20.r),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _box({double? width, double? height, double radius = 6}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(color: AppColors.grayE3E3DC, borderRadius: BorderRadius.circular(radius)),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:viteezy/core/models/membership_model.dart';
import 'package:viteezy/core/theme/text_styles.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/common_appbar.dart';
import '../../../../core/widgets/shimmer_widget.dart';
import '../controller/member_controller.dart';
import 'transaction_history.dart';

class MemberScreen extends StatelessWidget {
  MemberScreen({super.key});

  final memberController = Get.find<MemberController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CommonAppbar(title: 'profile_membership'.tr, showBackButton: true),
      body: Obx(() {
        if (memberController.isLoading.value) {
          return membershipShimmer();
        }

        if (memberController.memberships.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.only(top: 50.h),
              child: Text('member_no_active'.tr, style: TextStyles.medium(16, fontColor: AppColors.grey999999)),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await memberController.loadMemberships();
          },
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: memberController.memberships.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final membership = memberController.memberships[index];
              return membershipCard(membership);
            },
          ),
        );
      }),
    );
  }

  Widget membershipCard(MembershipListItem membership) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () async {
        await memberController.loadTransactions(membership.id);
        await Get.to(() => TransactionHistory(membership: membership));
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.greyF0EFE4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(membership.planLabel, style: TextStyles.medium(18, fontWeight: FontWeight.w500)),
                badge(membership.status),
              ],
            ),
            Gap(20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: .start,
              children: [
                Flexible(child: _infoColumn('member_label_plan'.tr, membership.planSnapshot?.name ?? 'orders_na'.tr)),
                Flexible(child: _infoColumn('member_label_interval'.tr, membership.planSnapshot?.interval ?? 'orders_na'.tr)),
                Flexible(child: _infoColumn('member_label_amount'.tr, membership.amountDisplay)),
              ],
            ),
            Gap(20.h),
            Text(
              'member_cancel_notice'.tr,
              style: TextStyles.medium(12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget badge(String status) {
    Color bgColor;
    if (status.toLowerCase() == 'active') {
      bgColor = AppColors.successColor;
    } else if (status.toLowerCase() == 'pending') {
      bgColor = AppColors.yellow;
    } else {
      bgColor = AppColors.errorColor;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20)),
      child: Text(
        status,
        style: TextStyles.medium(12, fontWeight: FontWeight.w500, fontColor: AppColors.white),
      ),
    );
  }

  Widget _infoColumn(String title, String value) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyles.medium(12, fontColor: AppColors.grey999999, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyles.medium(14, fontColor: AppColors.blackColor, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

Widget membershipShimmer() {
  return ListView.builder(
    itemCount: 4,
    padding: EdgeInsets.all(16.w),
    itemBuilder: (context, index) {
      return Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: AppColors.greyF0EFE4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ShimmerWidget(
                  child: _box(width: 120.w, height: 16.h),
                ),
                ShimmerWidget(
                  child: _box(width: 60.w, height: 24.h, radius: 20.r),
                ),
              ],
            ),
            Gap(20.h),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [_column(), _column(), _column()]),
            Gap(20.h),
            ShimmerWidget(
              child: _box(width: double.infinity, height: 12.h),
            ),
            Gap(6.h),
            ShimmerWidget(
              child: _box(width: 250.w, height: 12.h),
            ),
          ],
        ),
      );
    },
  );
}

Widget _column() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      ShimmerWidget(
        child: _box(width: 60.w, height: 10.h),
      ),
      Gap(8.h),
      ShimmerWidget(
        child: _box(width: 80.w, height: 14.h),
      ),
    ],
  );
}

Widget _box({double? width, double? height, double radius = 6}) {
  return Container(
    width: width,
    height: height,
    decoration: BoxDecoration(color: AppColors.grayE3E3DC, borderRadius: BorderRadius.circular(radius)),
  );
}

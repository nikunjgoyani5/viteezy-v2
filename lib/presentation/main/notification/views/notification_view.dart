import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:viteezy/core/models/notification_list_response_model.dart';
import 'package:viteezy/core/theme/app_colors.dart';
import 'package:viteezy/core/theme/text_styles.dart';
import 'package:viteezy/core/widgets/common_appbar.dart';
import 'package:viteezy/core/widgets/shimmer_widget.dart';
import 'package:viteezy/gen/assets.gen.dart';
import '../controllers/notification_controller.dart';

class NotificationView extends GetView<NotificationController> {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(64.h),
        child: Obx(() {
          final isSearch = controller.isSearchMode.value;
          if (isSearch) {
            // Custom AppBar for search mode
            return AppBar(
              backgroundColor: AppColors.white,
              elevation: 0,
              automaticallyImplyLeading: false,
              titleSpacing: 0,
              title: Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(left: 12.w),
                        height: 42.h,
                        decoration: BoxDecoration(
                          color: AppColors.black1414141.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        alignment: Alignment.center,
                        child: Row(
                          children: [
                            SizedBox(width: 15.w, height: 15.w, child: Assets.icons.icSearch.svg()),
                            SizedBox(width: 8.w),
                            Expanded(child: _buildSearchField()),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    TextButton(
                      onPressed: controller.exitSearchMode,
                      child: Text('common_cancel'.tr, style: TextStyles.medium(14.sp, fontColor: AppColors.black1414141)),
                    ),
                  ],
                ),
              ),
            );
          } else {
            // CommonAppbar for normal mode
            return CommonAppbar(
              title: 'notification_title'.tr,
              actionWidget: IconButton(
                icon: SizedBox(width: 20.w, height: 20.w, child: Assets.icons.icSearch.svg()),
                onPressed: controller.enterSearchMode,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            );
          }
        }),
      ),
      body: Obx(() {
        final isLoading = controller.isLoading.value;
        final items = controller.filteredNotifications;
        final hasSearchQuery = controller.searchQuery.value.isNotEmpty;

        if (isLoading && items.isEmpty) {
          return _buildShimmerList();
        }

        // Show empty state when searching and no results found
        if (hasSearchQuery && items.isEmpty) {
          return _buildNoDataFoundWidget();
        }

        if (items.isEmpty) {
          return _buildEmptyNotificationsWidget();
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchNotifications(page: 1, limit: 10, isRefresh: true),
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            itemCount: items.length,
            itemBuilder: (context, index) {
              return _buildNotificationCard(items[index]);
            },
          ),
        );
      }),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: controller.searchController,
      autofocus: true,
      decoration: InputDecoration(
        hintText: 'Search notifications...',
        hintStyle: TextStyles.regular(14.sp, fontColor: AppColors.black1414141),
        border: InputBorder.none,
        isDense: true,
      ),
      style: TextStyles.regular(14.sp, fontColor: AppColors.black1414141),
    );
  }

  Widget _buildNotificationCard(NotificationData item) {
    final isRead = item.isRead ?? false;
    return InkWell(
      onTap: () => controller.onNotificationPressed(item),
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.yellowF0EFE4),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title ?? '',
                    style: TextStyles.semiBold(
                      14.sp,
                      fontColor: AppColors.black1414141,
                    ),
                  ),
                  if (item.message != null && item.message!.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Text(
                      item.message!,
                      style: TextStyles.regular(
                        14.sp,
                        fontColor: AppColors.gray949391,
                      ),
                    ),
                  ],
                  if (item.createdAt != null) ...[
                    SizedBox(height: 6.h),
                    Text(
                      _formatDate(item.createdAt!),
                      style: TextStyles.regular(
                        12.sp,
                        fontColor: AppColors.gray949391,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Icon(
              isRead ? Icons.done_all : Icons.circle,
              color: isRead ? AppColors.gray949391 : AppColors.primaryColor,
              size: isRead ? 20.sp : 10.sp,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);
    if (dateOnly == today) {
      return 'Today, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (dateOnly == yesterday) {
      return 'Yesterday, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      itemCount: 6,
      itemBuilder: (context, index) {
        return ShimmerWidget(
          child: Container(
            margin: EdgeInsets.only(bottom: 12.h),
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
            decoration: BoxDecoration(color: AppColors.grayE3E3DC, borderRadius: BorderRadius.circular(12.r)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 14.h,
                        width: double.infinity,
                        decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(4.r)),
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        height: 12.h,
                        width: double.infinity,
                        decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(4.r)),
                      ),
                      SizedBox(height: 4.h),
                      Container(
                        height: 12.h,
                        width: 120.w,
                        decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(4.r)),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Container(
                  width: 20.w,
                  height: 20.w,
                  decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(10.r)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyNotificationsWidget() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 60.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none, size: 80.sp, color: AppColors.gray949391),
            SizedBox(height: 16.h),
            Text('notification_none'.tr, style: TextStyles.semiBold(18.sp, fontColor: AppColors.black1414141)),
            SizedBox(height: 8.h),
            Text(
              'You don\'t have any notifications yet.',
              style: TextStyles.regular(14.sp, fontColor: AppColors.gray949391),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDataFoundWidget() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 60.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 80.sp, color: AppColors.gray949391),
            SizedBox(height: 16.h),
            Text('notification_no_data'.tr, style: TextStyles.semiBold(18.sp, fontColor: AppColors.black1414141)),
            SizedBox(height: 8.h),
            Text(
              'No notifications match your search query.',
              style: TextStyles.regular(14.sp, fontColor: AppColors.gray949391),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

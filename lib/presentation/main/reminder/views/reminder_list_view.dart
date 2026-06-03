import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:viteezy/core/models/reminder_history_item.dart';
import 'package:viteezy/core/theme/app_colors.dart';
import 'package:viteezy/core/theme/text_styles.dart';
import 'package:viteezy/core/widgets/common_appbar.dart';

import '../controllers/reminder_controller.dart';

class ReminderListView extends StatefulWidget {
  const ReminderListView({super.key});

  @override
  State<ReminderListView> createState() => _ReminderListViewState();
}

class _ReminderListViewState extends State<ReminderListView> {
  late final ReminderController _controller;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<ReminderController>() ? Get.find<ReminderController>() : Get.put(ReminderController());
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.loadReminderHistory(refresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_controller.isHistoryLoadingMore.value || _controller.isHistoryLoading.value) return;
    if (!_controller.hasMoreReminderHistory) return;

    final pos = _scrollController.position;
    if (!pos.hasContentDimensions) return;

    final maxExtent = pos.maxScrollExtent;
    final pixels = pos.pixels;

    final nearBottom = maxExtent > 0 && pixels >= maxExtent - 200;
    final underFilledViewport = maxExtent <= 0;

    if (nearBottom || underFilledViewport) {
      _controller.loadMoreReminderHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CommonAppbar(
        title: 'Reminder history',
        centerTitle: true,
      ),
      body: Obx(() {
        final loading = _controller.isHistoryLoading.value;
        final items = _controller.reminderHistory;

        if (loading && items.isEmpty) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: _buildShimmerList(),
          );
        }

        if (!loading && items.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Text(
                'No reminder activity yet.\nPull down to refresh.',
                style: TextStyles.regular(15.sp, fontColor: AppColors.grey),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => _controller.loadReminderHistory(refresh: true),
          child: ListView(
            controller: _scrollController,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            children: [
              ..._buildHistoryEntries(items),
              if (_controller.isHistoryLoadingMore.value)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.h),
                  child: Center(
                    child: SizedBox(
                      width: 24.w,
                      height: 24.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  List<Widget> _buildHistoryEntries(List<ReminderHistoryItem> items) {
    final widgets = <Widget>[];
    DateTime? lastDay;

    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      final local = item.createdAt?.toLocal();
      if (local != null) {
        final day = DateTime(local.year, local.month, local.day);
        if (lastDay == null || !_isSameDay(lastDay, day)) {
          lastDay = day;
          widgets.add(_buildDateHeader(day));
        }
      }

      widgets.add(_buildHistoryCard(item));

      if (i < items.length - 1) {
        widgets.add(Gap(10.h));
      }
    }

    return widgets;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _sectionTitleForDay(DateTime day) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    if (_isSameDay(day, today)) return 'Today';
    if (_isSameDay(day, yesterday)) return 'Yesterday';
    return DateFormat('EEEE, MMM d').format(day);
  }

  Widget _buildDateHeader(DateTime day) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h, top: 4.h),
      child: Text(
        _sectionTitleForDay(day),
        style: TextStyles.semiBold(15.sp, fontColor: AppColors.black1414141),
      ),
    );
  }

  Widget _buildHistoryCard(ReminderHistoryItem item) {
    final timeStr = item.createdAt != null
        ? DateFormat('hh:mm a').format(item.createdAt!.toLocal())
        : '';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.greyF0EFE4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AppColors.lightPrimaryColor.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _eventTypeLabel(item.eventType),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyles.medium(12.sp, fontWeight: FontWeight.w600, fontColor: AppColors.primaryDark),
                    ),
                  ),
                ),
              ),
              if (timeStr.isNotEmpty) ...[
                SizedBox(width: 8.w),
                Text(
                  timeStr,
                  style: TextStyles.regular(12.sp, fontColor: AppColors.grey),
                ),
              ],
            ],
          ),
          Gap(8.h),
          Text(
            item.message,
            style: TextStyles.regular(15.sp, fontColor: AppColors.textPrimary, fontWeight: FontWeight.w400),
          ),
          if ((item.triggeredBy ?? '').isNotEmpty) ...[
            Gap(6.h),
            Text(
              'By ${item.triggeredBy}',
              style: TextStyles.regular(12.sp, fontColor: AppColors.grey),
            ),
          ],
        ],
      ),
    );
  }

  String _eventTypeLabel(String type) {
    switch (type) {
      case 'CREATED':
        return 'Created';
      case 'DISABLED':
        return 'Disabled';
      case 'ENABLED':
        return 'Enabled';
      case 'MESSAGE_UPDATED':
        return 'Note updated';
      case 'TIME_UPDATED':
        return 'Time updated';
      case 'DELETED':
        return 'Deleted';
      default:
        if (type.isEmpty) return 'Activity';
        return type.replaceAll('_', ' ').toLowerCase().split(' ').map((w) {
          if (w.isEmpty) return w;
          return '${w[0].toUpperCase()}${w.substring(1)}';
        }).join(' ');
    }
  }

  Widget _buildShimmerList() {
    return Column(
      children: List.generate(
        6,
        (index) => Padding(
          padding: EdgeInsets.only(bottom: 10.h),
          child: Container(
            height: 88.h,
            decoration: BoxDecoration(
              color: AppColors.grayE3E3DC,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }
}

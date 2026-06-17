import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:viteezy/core/theme/app_colors.dart';
import 'package:viteezy/core/theme/text_styles.dart';
import 'package:viteezy/core/widgets/shimmer_widget.dart';
import 'package:viteezy/core/models/session_history_model.dart';
import 'package:viteezy/gen/assets.gen.dart';
import '../controllers/ai_chat_controller.dart';
import 'chat_history_detail_view.dart';

class ChatHistoryView extends StatefulWidget {
  const ChatHistoryView({super.key});

  @override
  State<ChatHistoryView> createState() => _ChatHistoryViewState();
}

class _ChatHistoryViewState extends State<ChatHistoryView> {
  final AiChatController controller = Get.find<AiChatController>();
  final Set<String> _deletingSessionIds = {};
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    controller.getSessionByUser();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      // User is near the bottom, load more sessions
      if (!controller.isLoadingMoreSessionHistory.value && controller.hasMore && !controller.isSearchMode.value) {
        controller.getSessionByUser(isLoadMore: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(64.h),
        child: Obx(() {
          final isSearch = controller.isSearchMode.value;
          return AppBar(
            scrolledUnderElevation: 0,
            backgroundColor: AppColors.white,
            elevation: 0,
            foregroundColor: AppColors.black1414141,
            automaticallyImplyLeading: false,
            titleSpacing: 0,
            // toolbarHeight: 64.h,
            title: Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: isSearch
                  ? Row(
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
                    )
                  : Row(
                      children: [
                        IconButton(
                          icon: Image.asset(Assets.icons.icBackArrow.path, scale: 3),
                          onPressed: () => Get.back(),
                        ),
                        SizedBox(width: 4.w),
                        Text('chat_history_title'.tr, style: TextStyles.semiBold(18.sp, fontColor: AppColors.black1414141)),
                        const Spacer(),
                        IconButton(
                          icon: SizedBox(width: 20.w, height: 20.w, child: Assets.icons.icSearch.svg()),
                          onPressed: controller.enterSearchMode,
                        ),
                      ],
                    ),
            ),
          );
        }),
      ),
      body: Obx(() {
        if (controller.isLoadingSessionHistory.value) {
          return _buildShimmerLoading();
        }

        if (controller.sessionHistory.isEmpty) {
          return _buildEmptyState();
        }

        // Sort sessions by updatedAt (latest first) and group by date
        final groupedSessions = _groupSessionsByDate(controller.sessionHistory);

        return NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
              // User is near the bottom, load more sessions
              if (!controller.isLoadingMoreSessionHistory.value && controller.hasMore && !controller.isSearchMode.value) {
                controller.getSessionByUser(isLoadMore: true);
              }
            }
            return false;
          },
          child: ListView(
            controller: _scrollController,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            children: [
              ...groupedSessions.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 12.h, top: entry.key == groupedSessions.keys.first ? 0 : 24.h),
                      child: Text(entry.key, style: TextStyles.semiBold(16.sp, fontColor: AppColors.black1414141)),
                    ),
                    ...entry.value.map((session) => _buildSessionCard(session)).toList(),
                  ],
                );
              }).toList(),
              // Loading more indicator
              if (controller.isLoadingMoreSessionHistory.value)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.h),
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primaryColor),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  /// Group sessions by date (Today, Yesterday, or full date)
  Map<String, List<SessionHistory>> _groupSessionsByDate(List<SessionHistory> sessions) {
    // Sort by updatedAt descending (latest first)
    final sortedSessions = List<SessionHistory>.from(sessions)
      ..sort((a, b) {
        final aDate = a.updatedAt ?? a.createdAt ?? DateTime(1970);
        final bDate = b.updatedAt ?? b.createdAt ?? DateTime(1970);
        return bDate.compareTo(aDate); // Descending order
      });

    final Map<String, List<SessionHistory>> grouped = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (final session in sortedSessions) {
      final sessionDate = session.updatedAt ?? session.createdAt;
      if (sessionDate == null) continue;

      final sessionDay = DateTime(sessionDate.year, sessionDate.month, sessionDate.day);
      String groupKey;

      if (sessionDay == today) {
        groupKey = 'Today';
      } else if (sessionDay == yesterday) {
        groupKey = 'Yesterday';
      } else {
        // For all previous days, display full date
        groupKey = DateFormat('MMM dd, yyyy').format(sessionDate);
      }

      if (!grouped.containsKey(groupKey)) {
        grouped[groupKey] = [];
      }
      grouped[groupKey]!.add(session);
    }

    return grouped;
  }

  Widget _buildSearchField() {
    return TextField(
      controller: controller.searchController,
      autofocus: true,
      decoration: InputDecoration(
        hintText: 'chat_search_hint'.tr,
        hintStyle: TextStyles.regular(14.sp, fontColor: AppColors.black1414141),
        border: InputBorder.none,
        isDense: true,
      ),
      style: TextStyles.regular(14.sp, fontColor: AppColors.black1414141),
    );
  }

  Widget _buildSessionCard(SessionHistory session) {
    final sessionName = session.sessionName ?? 'Untitled Chat';
    final updatedAt = session.updatedAt;
    final isDeleting = session.sessionId != null && _deletingSessionIds.contains(session.sessionId);
    String dateText = '';

    if (updatedAt != null) {
      final now = DateTime.now();
      final difference = now.difference(updatedAt);

      if (difference.inDays == 0) {
        dateText = 'Today';
      } else if (difference.inDays == 1) {
        dateText = 'Yesterday';
      } else if (difference.inDays < 7) {
        dateText = DateFormat('EEEE').format(updatedAt); // Day name
      } else {
        dateText = DateFormat('MMM dd, yyyy').format(updatedAt);
      }
    }

    return AnimatedOpacity(
      key: ValueKey(session.sessionId),
      duration: const Duration(milliseconds: 300),
      opacity: isDeleting ? 0.0 : 1.0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: EdgeInsets.only(bottom: 12.h),
        height: isDeleting ? 0 : null,
        child: GestureDetector(
          onTap: isDeleting
              ? null
              : () {
                  if (session.sessionId != null && session.sessionId!.isNotEmpty) {
                    Get.to(
                      () => ChatHistoryDetailView(),
                      arguments: {'sessionId': session.sessionId, 'sessionName': session.sessionName},
                    );
                  }
                },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.yellowF0EFE4),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sessionName,
                        style: TextStyles.semiBold(14.sp, fontColor: AppColors.black1414141),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (dateText.isNotEmpty) ...[
                        SizedBox(height: 4.h),
                        Text(dateText, style: TextStyles.regular(12.sp, fontColor: AppColors.gray949391)),
                      ],
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: AppColors.black1414141, size: 20.sp),
                  onSelected: (value) {
                    if (value == 'delete' && session.sessionId != null && session.sessionId!.isNotEmpty) {
                      _handleDeleteSession(session);
                    }
                  },
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, color: Colors.red, size: 20.sp),
                          SizedBox(width: 8.w),
                          Text('chat_delete'.tr, style: TextStyles.regular(14.sp, fontColor: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleDeleteSession(SessionHistory session) {
    if (session.sessionId == null || session.sessionId!.isEmpty) return;

    // Show confirmation dialog
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text('chat_delete_session'.tr, style: TextStyles.semiBold(18.sp, fontColor: AppColors.black1414141)),
        content: Text(
          'chat_delete_confirm'.tr,
          style: TextStyles.regular(14.sp, fontColor: AppColors.black1414141),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('common_cancel'.tr, style: TextStyles.medium(14.sp, fontColor: AppColors.gray949391)),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              // Add to deleting set to trigger animation
              setState(() {
                _deletingSessionIds.add(session.sessionId!);
              });

              // Wait for animation to complete, then delete
              Future.delayed(const Duration(milliseconds: 300), () {
                // Delete with animation
                controller.deleteSession(
                  session.sessionId!,
                  onSuccess: () {
                    setState(() {
                      _deletingSessionIds.remove(session.sessionId!);
                    });
                  },
                  onError: () {
                    // Revert animation on error
                    setState(() {
                      _deletingSessionIds.remove(session.sessionId!);
                    });
                    // Show error message
                    Get.snackbar(
                      'Error',
                      'chat_delete_failed'.tr,
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
                  },
                );
              });
            },
            child: Text('chat_delete'.tr, style: TextStyles.medium(14.sp, fontColor: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      children: [
        ShimmerWidget(
          child: Container(
            height: 20.h,
            width: 120.w,
            decoration: BoxDecoration(color: AppColors.grayE3E3DC, borderRadius: BorderRadius.circular(8.r)),
          ),
        ),
        SizedBox(height: 12.h),
        ...List.generate(
          5,
          (index) => Container(
            margin: EdgeInsets.only(bottom: 12.h),
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.yellowF0EFE4),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerWidget(
                        child: Container(
                          height: 16.h,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.grayE3E3DC,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      ShimmerWidget(
                        child: Container(
                          height: 12.h,
                          width: 100.w,
                          decoration: BoxDecoration(
                            color: AppColors.grayE3E3DC,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                ShimmerWidget(
                  child: Container(
                    width: 20.w,
                    height: 20.w,
                    decoration: BoxDecoration(color: AppColors.grayE3E3DC, borderRadius: BorderRadius.circular(4.r)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 80.sp, color: AppColors.gray949391),
            SizedBox(height: 16.h),
            Text('chat_no_history'.tr, style: TextStyles.semiBold(18.sp, fontColor: AppColors.black1414141)),
            SizedBox(height: 8.h),
            Text(
              'chat_no_conversations'.tr,
              style: TextStyles.regular(14.sp, fontColor: AppColors.gray949391),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

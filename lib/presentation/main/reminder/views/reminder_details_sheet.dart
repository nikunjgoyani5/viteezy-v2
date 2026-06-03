import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import '../../../../core/models/reminder_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/common_button.dart';
import '../controllers/reminder_controller.dart';
import 'add_reminder_sheet.dart';

class ReminderDetailsSheet extends StatelessWidget {
  final ReminderModel reminder;

  const ReminderDetailsSheet({super.key, required this.reminder});

  @override
  Widget build(BuildContext context) {
    final ReminderController controller = Get.find<ReminderController>();

    return Container(
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: 12.h,
        bottom: MediaQuery.of(context).padding.bottom + 20.h,
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 48.w,
              height: 5.h,
              decoration: BoxDecoration(
                color: AppColors.greyDFDFDF,
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          ),
          Gap(24.h),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Reminder Details",
                style: TextStyles.semiBold(
                  22.sp,
                  fontColor: AppColors.textPrimary,
                ),
              ),
              IconButton(
                onPressed: () => Get.back(),
                icon: Icon(Icons.close, color: AppColors.grey6A6A6A, size: 24.sp),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          Gap(24.h),

          // Details Card
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: AppColors.greyF0EFE4),
            ),
            child: Column(
              children: [
                _buildInfoRow(
                  icon: Icons.notes_rounded,
                  label: "Remind me to",
                  value: reminder.note,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: Divider(color: AppColors.greyF0EFE4, thickness: 1),
                ),
                _buildInfoRow(
                  icon: Icons.access_time_filled_rounded,
                  label: "Scheduled Time",
                  value: reminder.formattedTime,
                ),
              ],
            ),
          ),
          Gap(24.h),

          // Actions
          Row(
            children: [
              Expanded(
                child: CommonButton(
                  text: "Update",
                  height: 52.h,
                  textSize: 16.sp,
                  radius: 16.r,
                  color: AppColors.black141414,
                  onPressed: () {
                    Get.back();
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => AddReminderSheet(reminder: reminder),
                    );
                  },
                ),
              ),
              Gap(12.w),
              Expanded(
                child: CommonButton(
                  text: "Remove",
                  height: 52.h,
                  textSize: 16.sp,
                  radius: 16.r,
                  color: AppColors.errorColor,
                  textColor: AppColors.white,
                //  borderColor: AppColors.errorColor,
                  onPressed: () {
                    Get.back();
                    controller.deleteReminder(reminder.id, context);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primaryColor, size: 20.sp),
        ),
        Gap(12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyles.regular(
                  14.sp,
                  fontColor: AppColors.grey6A6A6A,
                ),
              ),
              Gap(4.h),
              Text(
                value,
                maxLines: 6,
                overflow: TextOverflow.ellipsis,
                style: TextStyles.medium(
                  16.sp,
                  fontColor: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

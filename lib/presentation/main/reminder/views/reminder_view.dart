import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:viteezy/presentation/main/reminder/views/reminder_list_view.dart';
import '../../../../core/models/reminder_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/widgets/common_appbar.dart';
import '../../../../core/widgets/common_button.dart';
import '../controllers/reminder_controller.dart';
import 'add_reminder_sheet.dart';
import 'reminder_details_sheet.dart';

class ReminderView extends StatelessWidget {
  ReminderView({super.key});

  final ReminderController controller = Get.put(ReminderController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CommonAppbar(
        title: 'Reminder',
        centerTitle: true,
        showBackButton: false,
        actionWidget: IconButton(
          icon: const Icon(Icons.history, color: Colors.black),
          onPressed: () {
            Get.to(() => const ReminderListView());
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => controller.loadReminders(force: true),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Gap(12.h),

                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.greyF0EFE4),
                        color: Colors.white,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Set your reminder",
                            style: TextStyles.medium(
                              20.sp,
                              fontWeight: FontWeight.w800,
                              fontColor: AppColors.blackColor,
                            ),
                          ),
                          SizedBox(height: 5.h),
                          Text(
                            "Turn on reminders to stay on track with your medication.",
                            style: TextStyles.regular(16.sp, fontWeight: FontWeight.w400, fontColor: AppColors.grey),
                          ),

                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 6.h),
                            child: Divider(thickness: 1.5, color: AppColors.offWhite),
                          ),

                          Obx(() {
                            if (controller.isLoading.value) {
                              return _buildShimmerLayout();
                            }

                            if (controller.reminders.isEmpty) {
                              return SizedBox(
                                height: MediaQuery.of(context).size.height * 0.4, // adjust as needed
                                child: Center(
                                  child: Text(
                                    "No reminders yet\nPull down to refresh or add a new reminder",
                                    style: TextStyles.regular(14.sp, fontColor: AppColors.grey),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            }

                            return Column(
                              children: controller.reminders
                                  .map(
                                    (reminder) => Padding(
                                      padding: EdgeInsets.symmetric(vertical: 10.h),
                                      child: _buildReminderRow(reminder, context),
                                    ),
                                  )
                                  .toList(),
                            );
                          }),
                        ],
                      ),
                    ),

                    Gap(20.h),
                  ],
                ),
              ),
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Column(
              children: [
                CommonButton(
                  text: "+ ADD ANOTHER REMINDER",
                  width: double.infinity,
                  height: 52.h,
                  textSize: 15.h,
                  radius: 40.r,
                  color: AppColors.blackColor,
                  onPressed: () {
                    _openAddReminderSheet(context);
                  },
                ),

                Gap(12.h),

                Center(
                  child: Text(
                    "Reminders will be sent at your selected time every day to help maintain your vitamin routine",
                    style: TextStyles.regular(12.sp, fontWeight: FontWeight.w400, fontColor: AppColors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLayout() {
    return Column(
      children: List.generate(
        8,
        (index) => Padding(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          child: _buildReminderShimmerItem(),
        ),
      ),
    );
  }

  Widget _buildReminderShimmerItem() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// "Remind me to"
              Container(
                height: 12.h,
                width: 100.w,
                decoration: BoxDecoration(color: AppColors.grayE3E3DC, borderRadius: BorderRadius.circular(4.r)),
              ),

              SizedBox(height: 6.h),

              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 14.h,
                      decoration: BoxDecoration(color: AppColors.grayE3E3DC, borderRadius: BorderRadius.circular(4.r)),
                    ),
                  ),

                  SizedBox(width: 8.w),
                  Container(
                    height: 14.h,
                    width: 70.w,
                    decoration: BoxDecoration(color: AppColors.grayE3E3DC, borderRadius: BorderRadius.circular(4.r)),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(width: 10.w),
        Container(
          width: 40.w,
          height: 22.h,
          decoration: BoxDecoration(color: AppColors.grayE3E3DC, borderRadius: BorderRadius.circular(20.r)),
        ),
      ],
    );
  }

  Widget _buildReminderRow(ReminderModel reminder, BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () => _showReminderOptions(context, reminder),
      // onLongPress: () => _showReminderOptions(context, reminder),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Remind me to",
                  style: TextStyles.medium(15.sp, fontColor: AppColors.textPrimary.withValues(alpha: 0.4)),
                ),
                SizedBox(height: 1.h),

                Row(
                  children: [
                    Flexible(
                      child: SizedBox(
                        width: 130.w,
                        child: Text(
                          reminder.note,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyles.medium(15.sp, fontColor: AppColors.textPrimary.withValues(alpha: 0.4)),
                        ),
                      ),
                    ),

                    SizedBox(width: 6.w),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: 80.w,
                          child: Text(
                            reminder.formattedTime,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _showReminderOptions(context, reminder),
                          child: Icon(Icons.keyboard_arrow_down_rounded, size: 24.w, color: Colors.black87),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          Transform.scale(
            scale: 0.9,
            child: CupertinoSwitch(
              value: reminder.isActive,
              onChanged: (val) => controller.toggleReminder(reminder.id, val, context),
              activeTrackColor: AppColors.successColor,
              inactiveTrackColor: AppColors.textPrimary.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }

  void _openAddReminderSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      isDismissible: true,
      builder: (_) => const AddReminderSheet(),
    );
  }

  void _showReminderOptions(BuildContext context, ReminderModel reminder) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      isDismissible: true,
      builder: (_) => ReminderDetailsSheet(reminder: reminder),
    );
  }
}

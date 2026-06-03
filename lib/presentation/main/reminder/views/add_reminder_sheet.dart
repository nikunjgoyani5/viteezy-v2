import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:get/get.dart';

import '../../../../core/models/reminder_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/exports.dart';
import '../../../../core/widgets/common_button.dart';
import '../../../../core/widgets/common_textfield.dart';
import '../controllers/reminder_controller.dart';

class AddReminderSheet extends StatefulWidget {
  final ReminderModel? reminder;

  const AddReminderSheet({super.key, this.reminder});

  @override
  State<AddReminderSheet> createState() => _AddReminderSheetState();
}

class _AddReminderSheetState extends State<AddReminderSheet> {
  @override
  void initState() {
    super.initState();
    if (widget.reminder != null) {
      final controller = Get.find<ReminderController>();
      controller.isUpdate.value = true;
      controller.editingReminder.value = widget.reminder;
      // Parse time
      final parsedTime = widget.reminder!.dateTime;
      if (parsedTime != null) {
        controller.selectedTime.value = parsedTime;
      }
      controller.noteController.text = widget.reminder!.note;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ReminderController controller = Get.find<ReminderController>();

    return Container(
      padding: EdgeInsets.only(
        left: 16.w,
        right: 16.w,
        top: 10.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16.h,
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
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
            Gap(10.h),
        
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  controller.isUpdate.value ? "Update Reminder" : "Set Reminder",
                  style: TextStyles.semiBold(22.sp, fontColor: AppColors.textPrimary),
                ),
                IconButton(
                  onPressed: (){
                    controller.resetForm();
                    Get.back();
                  },
                  icon: Icon(Icons.close, color: AppColors.grey6A6A6A, size: 24.sp),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
        
            SizedBox(
              height: 200.h,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 50,
                    margin: EdgeInsets.symmetric(horizontal: 0.10.w),
                    decoration: BoxDecoration(color: AppColors.grey1.withValues(alpha: 0.05)),
                  ),
        
                  Obx(
                    () => TimePickerSpinner(
                      time: controller.selectedTime.value,
                      is24HourMode: false,
                      normalTextStyle: TextStyles.regular(
                        24.sp,
                        fontWeight: FontWeight.w400,
                        fontColor: AppColors.grey6E6E6E,
                      ),
                      highlightedTextStyle: TextStyles.regular(
                        24.sp,
                        fontWeight: FontWeight.w400,
                        fontColor: AppColors.black141414,
                      ),
                      spacing: 75,
                      itemHeight: 50,
                      alignment: Alignment.center,
                      isForce2Digits: true,
                      onTimeChange: (time) {
                        controller.selectedTime.value = time;
                      },
                    ),
                  ),
                ],
              ),
            ),
        
            SizedBox(height: 18.h),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Reminder note",
                style: TextStyles.medium(16.sp, fontColor: AppColors.textPrimary.withValues(alpha: 0.65)),
              ),
            ),
        
            SizedBox(height: 8.h),
        
            CommonTextField(
              controller: controller.noteController,
              hintText: "Add a note for your medicine reminder",
              maxLine: 5,
              textStyle: TextStyles.regular(15.sp, fontColor: AppColors.textPrimary),
              hintColor: AppColors.grey999999,
              fillColor: AppColors.white,
              borderColor: AppColors.greyF0EFE4,
              height: 120.h,
            ),
        
            SizedBox(height: 22.h),
            Obx(() {
              final saving = controller.isSaving.value;
              final update = controller.isUpdate.value;
              return AbsorbPointer(
                absorbing: saving,
                child: Opacity(
                  opacity: saving ? 0.6 : 1,
                  child: CommonButton(
                    text: saving ? (update ? "Updating..." : "Saving...") : (update ? "Update Reminder" : "Set My Reminder"),
                    width: double.infinity,
                    height: 48.h,
                    textSize: 18.sp,
                    radius: 40.r,
                    color: AppColors.successColor,
                    onPressed: () => controller.createReminder(context),
                  ),
                ),
              );
            }),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }
}

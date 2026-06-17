import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:viteezy/gen/assets.gen.dart';

import 'package:viteezy/core/theme/app_colors.dart';
import 'package:viteezy/core/theme/text_styles.dart';
import '../controllers/support_controller.dart';

/// Support View
class SupportView extends GetView<SupportController> {
  const SupportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: Column(
          children: [
            // Chat Messages Area
            Expanded(
              child: Obx(() {
                if (controller.messages.isEmpty) {
                  // Default greeting view when no messages
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Text.rich(
                        TextSpan(
                          text: "Hi there! How can I help you today? ",
                          style: TextStyles.medium(25.sp, fontColor: Colors.black),
                          children: [
                            WidgetSpan(
                              alignment: PlaceholderAlignment.top,
                              child: Padding(
                                padding: EdgeInsets.only(left: 4.w),
                                child: Assets.icons.icSpark.svg(width: 25.w, height: 25.h),
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.start,
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                  itemCount: controller.messages.length,
                  itemBuilder: (context, index) {
                    final message = controller.messages[index];
                    return _buildMessageBubble(message, context);
                  },
                );
              }),
            ),
            // Quick Action Buttons (shown only when no messages)
            Obx(
              () => controller.messages.isEmpty ? _buildQuickActionButtonsCentered(context) : const SizedBox.shrink(),
            ),
            // Message Input Area
            _buildMessageInput(context),
          ],
        ),
      ),
    );
  }

  /// App Bar
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      centerTitle: false,
      title: Hero(
        tag: "Hello",
        child: Text('support_title'.tr, style: TextStyles.semiBold(20.sp, fontColor: Colors.black)),
      ),
      actions: [
        IconButton(
          icon: Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: Offset(0, 2))],
            ),
            child: Icon(Icons.close, size: 20.sp, color: Colors.black),
          ),
          onPressed: () => Get.back(),
        ),
        SizedBox(width: 8.w),
      ],
    );
  }

  /// Message Bubble
  Widget _buildMessageBubble(ChatMessage message, BuildContext context) {
    if (message.isBot) {
      // Bot message - center aligned, bold, no background
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: EdgeInsets.only(bottom: 12.h),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
          child: Text(
            message.text,
            // textAlign: TextAlign.center,
            style: TextStyles.bold(14.sp, fontColor: Colors.black),
          ),
        ),
      );
    } else {
      // User message - right aligned, with background
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: EdgeInsets.only(bottom: 12.h),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(color: AppColors.primaryColor, borderRadius: BorderRadius.circular(16.r)),
          child: Text(message.text, style: TextStyles.regular(14.sp, fontColor: Colors.white)),
        ),
      );
    }
  }

  /// Quick Action Buttons (centered with greeting text)
  Widget _buildQuickActionButtonsCentered(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildQuickActionButton(context, "I'd like a recommendation", 'recommendation'),
          SizedBox(height: 8.h),
          _buildQuickActionButton(context, "I need help with my order", 'order'),
          SizedBox(height: 8.h),
          _buildQuickActionButton(context, "I have a question about a product", 'product'),
        ],
      ),
    );
  }

  /// Quick Action Button
  Widget _buildQuickActionButton(BuildContext context, String text, String action) {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () => controller.onQuickActionTap(action),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.textSecondary.withValues(alpha: 0.2), width: 1),
          ),
          child: Text(text, style: TextStyles.regular(14.sp, fontColor: Colors.black)),
        ),
      ),
    );
  }

  /// Message Input Area
  Widget _buildMessageInput(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(color: Colors.white),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.all(8.h),
              decoration: BoxDecoration(color: AppColors.whiteF6F7F8, borderRadius: BorderRadius.circular(12.r)),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 6,
                      offset: Offset(0, 0),
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: TextField(
                  controller: controller.messageController,
                  decoration: InputDecoration(
                    hintText: 'support_message_hint'.tr,
                    hintStyle: TextStyles.regular(14.sp, fontColor: AppColors.textSecondary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: Colors.transparent, width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: Colors.transparent, width: 1),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(color: AppColors.primaryColor, width: 1),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                    filled: true,
                    fillColor: AppColors.backgroundColor,
                    suffixIcon: GestureDetector(
                      onTap: controller.sendMessage,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.h),
                        child: Assets.icons.icSend.svg(),
                      ),
                    ),
                  ),
                  style: TextStyles.regular(14.sp),
                  onSubmitted: (_) => controller.sendMessage(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

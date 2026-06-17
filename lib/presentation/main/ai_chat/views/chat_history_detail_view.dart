import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:viteezy/core/models/ai_chat_response_model.dart';
import 'package:viteezy/core/theme/app_colors.dart';
import 'package:viteezy/core/theme/text_styles.dart';
import 'package:viteezy/core/widgets/common_network_image.dart';
import 'package:viteezy/core/widgets/shimmer_widget.dart';
import 'package:viteezy/core/widgets/custom_toast.dart';
import 'package:viteezy/core/routes/app_routes.dart';
import 'package:viteezy/gen/assets.gen.dart';
import '../controllers/ai_chat_controller.dart';

/// Chat History Detail View - Display chat messages from history
class ChatHistoryDetailView extends StatefulWidget {
  const ChatHistoryDetailView({super.key});

  @override
  State<ChatHistoryDetailView> createState() => _ChatHistoryDetailViewState();
}

class _ChatHistoryDetailViewState extends State<ChatHistoryDetailView> {
  final ScrollController _scrollController = ScrollController();
  final AiChatController controller = Get.find<AiChatController>();
  String? _sessionId;
  String? _sessionName;

  @override
  void initState() {
    super.initState();
    final arguments = Get.arguments;
    if (arguments != null) {
      _sessionId = arguments['sessionId'] as String?;
      _sessionName = arguments['sessionName'] as String?;

      if (_sessionId != null && _sessionId!.isNotEmpty) {
        // Defer API call to after build phase
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            controller.loadSessionHistory(sessionId: _sessionId!);
          }
        });
      }
    }

    // Listen for when initialization completes and scroll to bottom
    ever(controller.isInitializing, (isInitializing) {
      if (!isInitializing && controller.historyChatData.isNotEmpty && mounted) {
        // Wait for layout to complete, then scroll
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Future.delayed(const Duration(milliseconds: 200), () {
            if (_scrollController.hasClients && mounted) {
              final maxScroll = _scrollController.position.maxScrollExtent;
              if (maxScroll > 0) {
                _scrollController.jumpTo(maxScroll);
              }
            }
          });
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(64.h),
        child: Obx(
          () => AppBar(
            backgroundColor: AppColors.white,
            elevation: 0,
            leading: IconButton(
              onPressed: () => Get.back(),
              icon: Image.asset(Assets.icons.icBackArrow.path, scale: 3),
            ),
            title: Text(
              controller.sessionName.value.isNotEmpty ? controller.sessionName.value : (_sessionName ?? 'Chat History'),
              style: TextStyles.semiBold(18.sp, fontColor: AppColors.black1414141),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isInitializing.value) {
            return _buildChatShimmer(context);
          }

          if (controller.historyChatData.isEmpty) {
            return _buildEmptyState();
          }

          return _buildChatView(context);
        }),
      ),
    );
  }

  /// Chat view with messages
  Widget _buildChatView(BuildContext context) {
    return Obx(() {
      final chatMessages = controller.historyChatData;

      if (chatMessages.isEmpty) {
        return _buildEmptyState();
      }

      // Auto-scroll to bottom when messages load - use a delayed callback to ensure layout is complete
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (_scrollController.hasClients && mounted) {
            final maxScroll = _scrollController.position.maxScrollExtent;
            if (maxScroll > 0) {
              _scrollController.animateTo(
                maxScroll,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOut,
              );
            }
          }
        });
      });

      return ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
        itemCount: chatMessages.length,
        itemBuilder: (context, index) {
          final historyChatData = chatMessages[index];
          return _buildChatDataBubble(historyChatData, context);
        },
      );
    });
  }

  /// Chat data bubble
  Widget _buildChatDataBubble(ChatData historyChatData, BuildContext context) {
    final reply = historyChatData.reply;
    if (reply == null || reply.content == null) {
      return const SizedBox();
    }

    final isUser = reply.role == 'user';

    if (isUser) {
      // User message - right aligned, white background with border
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: EdgeInsets.only(bottom: 12.h, left: 60.w),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25.r),
              bottomLeft: Radius.circular(25.r),
              topRight: Radius.circular(5.r),
              bottomRight: Radius.circular(25.r),
            ),
            border: Border.all(color: AppColors.yellowF0EFE4),
          ),
          child: Text(reply.content!, style: TextStyles.regular(14.sp, fontColor: AppColors.black1414141)),
        ),
      );
    } else {
      // Bot message - left aligned with V+ icon
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: 45.w,
                height: 45.w,
                decoration: BoxDecoration(color: AppColors.primaryColor, shape: BoxShape.circle),
                child: Center(
                  child: Text('V+', style: TextStyles.bold(20.sp, fontColor: AppColors.surfaceColor)),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(bottom: 12.h, right: 12.w),
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(16.r)),
                      child: Text(reply.content!, style: TextStyles.regular(14.sp, fontColor: AppColors.black1414141)),
                    ),
                    // Show options if available
                    if (historyChatData.options != null && historyChatData.options!.isNotEmpty)
                      _buildOptionsFromChatData(historyChatData.options, historyChatData),
                    // Show products if available
                    if (historyChatData.products != null && historyChatData.products!.isNotEmpty)
                      _buildProductsList(historyChatData.products!),
                  ],
                ),
              ),
            ],
          ),
        ],
      );
    }
  }

  /// Button options from ChatData
  Widget _buildOptionsFromChatData(List<Option>? options, ChatData currentChatData) {
    if (options == null || options.isEmpty) {
      return const SizedBox();
    }

    // Get the selected option value for this specific ChatData (if any)
    final selectedOptionValue = _getSelectedOptionValue(currentChatData, options);

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Wrap(
        spacing: 8.w,
        runSpacing: 8.h,
        children: options.map((option) {
          final isSelected = option.value == selectedOptionValue;

          return Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.yellowF0EFE4 : AppColors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: isSelected ? AppColors.black1414141 : AppColors.yellowF0EFE4,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Text(
              option.label ?? option.value ?? '',
              style: TextStyles.regular(
                12.sp,
                fontColor: AppColors.black1414141,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Get the selected option value for a specific ChatData's options
  String? _getSelectedOptionValue(ChatData currentChatData, List<Option> options) {
    final optionLabels = options
        .map((option) => option.label ?? option.value)
        .where((label) => label != null && label.isNotEmpty)
        .cast<String>()
        .toList();

    if (optionLabels.isEmpty) {
      return null;
    }

    final currentIndex = controller.historyChatData.indexOf(currentChatData);
    if (currentIndex == -1) {
      return null;
    }

    for (int i = currentIndex + 1; i < controller.historyChatData.length; i++) {
      final historyChatData = controller.historyChatData[i];
      final reply = historyChatData.reply;
      if (reply?.role == 'user' && reply?.content != null) {
        final userMessageContent = reply!.content!;
        if (optionLabels.contains(userMessageContent)) {
          final selectedOption = options.firstWhere(
            (option) => (option.label ?? option.value) == userMessageContent,
            orElse: () => options.first,
          );
          return selectedOption.value ?? selectedOption.label;
        }
      }
    }

    return null;
  }

  /// Products list widget
  Widget _buildProductsList(List<ProductRecommended> products) {
    return Padding(
      padding: EdgeInsets.only(top: 12.h, bottom: 12.h, right: 12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: products.map((product) {
          return _buildProductCard(product);
        }).toList(),
      ),
    );
  }

  /// Product card
  Widget _buildProductCard(ProductRecommended product) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.yellowF0EFE4, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () {
                  Get.toNamed(AppRoutes.productDetail, arguments: {'productId': product.id});
                },
                child: Container(
                  width: 80.w,
                  height: 80.w,
                  decoration: BoxDecoration(color: AppColors.offWhite, borderRadius: BorderRadius.circular(8.r)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: product.productImage != null && product.productImage!.isNotEmpty
                        ? CommonNetworkImage(
                            imageUrl: product.productImage!,
                            fit: BoxFit.cover,
                            width: 80.w,
                            height: 80.w,
                          )
                        : Icon(Icons.image, size: 40.sp, color: AppColors.gray949391),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Get.toNamed(AppRoutes.productDetail, arguments: {'productId': product.id});
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.title ?? '', style: TextStyles.bold(16.sp, fontColor: AppColors.black1414141)),
                      SizedBox(height: 4.h),
                      Text(
                        product.shortDescription ?? '',
                        style: TextStyles.regular(12.sp, fontColor: AppColors.gray949391),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          // Add to Cart Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: product.id != null && product.id!.isNotEmpty
                  ? () async {
                      final result = await controller.addToCart(product.id!, "SACHETS");
                      if (result['success'] == true) {
                        CustomToast.showItemAddedToCart(
                          context: context,
                          message: result['message'] as String? ?? 'product_detail_item_added'.tr,
                        );
                      } else {
                        CustomToast.show(
                          context: context,
                          message: result['message'] as String? ?? 'home_failed_to_add_cart_short'.tr,
                        );
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: AppColors.surfaceColor,
                disabledBackgroundColor: AppColors.gray949391,
                disabledForegroundColor: AppColors.surfaceColor,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                elevation: 0,
              ),
              child: Text('chat_add_to_cart'.tr, style: TextStyles.semiBold(14.sp, fontColor: AppColors.surfaceColor)),
            ),
          ),
        ],
      ),
    );
  }

  /// Chat shimmer loading view
  Widget _buildChatShimmer(BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
      children: [
        // Generate multiple shimmer messages (8 messages alternating between bot and user)
        ...List.generate(8, (index) {
          final isBot = index % 2 == 0;
          if (isBot) {
            // Bot message shimmer
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 45.w,
                  height: 45.w,
                  decoration: BoxDecoration(color: AppColors.primaryColor, shape: BoxShape.circle),
                  child: Center(
                    child: Text('V+', style: TextStyles.bold(20.sp, fontColor: AppColors.surfaceColor)),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerWidget(
                        child: Container(
                          margin: EdgeInsets.only(bottom: 12.h, right: 12.w),
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                          decoration: BoxDecoration(
                            color: AppColors.grayE3E3DC,
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          height: [60.h, 80.h, 70.h, 90.h][index % 4], // Vary heights
                          width: double.infinity,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            // User message shimmer
            return Align(
              alignment: Alignment.centerRight,
              child: ShimmerWidget(
                child: Container(
                  margin: EdgeInsets.only(bottom: 12.h, left: 60.w),
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: AppColors.grayE3E3DC,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(25.r),
                      bottomLeft: Radius.circular(25.r),
                      topRight: Radius.circular(5.r),
                      bottomRight: Radius.circular(25.r),
                    ),
                  ),
                  height: [50.h, 60.h, 45.h, 55.h][index % 4], // Vary heights
                  width: MediaQuery.of(context).size.width * [0.5, 0.6, 0.4, 0.55][index % 4], // Vary widths
                ),
              ),
            );
          }
        }),
      ],
    );
  }

  /// Empty state
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 80.sp, color: AppColors.gray949391),
            SizedBox(height: 16.h),
            Text('chat_no_messages'.tr, style: TextStyles.semiBold(18.sp, fontColor: AppColors.black1414141)),
            SizedBox(height: 8.h),
            Text(
              'This chat session has no messages.',
              style: TextStyles.regular(14.sp, fontColor: AppColors.gray949391),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

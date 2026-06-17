import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:viteezy/core/models/ai_chat_response_model.dart';
import 'package:viteezy/core/theme/app_colors.dart';
import 'package:viteezy/core/theme/text_styles.dart';
import 'package:viteezy/core/widgets/common_appbar.dart';
import 'package:viteezy/core/widgets/common_network_image.dart';
import 'package:viteezy/core/widgets/shimmer_widget.dart';
import 'package:viteezy/core/widgets/custom_toast.dart';
import 'package:viteezy/core/routes/app_routes.dart';
import 'package:viteezy/core/utils/app_prefrence.dart';
import 'package:viteezy/gen/assets.gen.dart';
import '../../profile/controllers/profile_controller.dart';
import '../controllers/ai_chat_controller.dart';
import 'chat_history_view.dart';

/// AI Chat View
class AiChatView extends StatefulWidget {
  const AiChatView({super.key});

  @override
  State<AiChatView> createState() => _AiChatViewState();
}

class _AiChatViewState extends State<AiChatView> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late final AiChatController controller;
  // Track typing animations for each message
  final RxMap<String, String> _displayedTexts = <String, String>{}.obs;
  final Map<String, Timer?> _typingTimers = {};
  final Set<String> _initializedMessages = {}; // Track which messages have been initialized
  final RxSet<String> _completedAnimations = <String>{}.obs; // Track which messages have completed typing animation
  final Map<String, DateTime> _lastScrollTime = {}; // Track last scroll time to throttle
  final RxBool _showScrollToBottomButton = false.obs; // Track if scroll-to-bottom button should be shown
  bool _isUserScrolling = false; // Track if user is manually scrolling

  @override
  void initState() {
    super.initState();
    controller = Get.find<AiChatController>();
    // Add scroll listener to detect when user scrolls up
    _scrollController.addListener(_onScroll);
    // Defer initialization to after build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        controller.chatInitialization();
      }
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final viewportHeight = _scrollController.position.viewportDimension;
    
    // Show scroll-to-bottom button if user is not near the bottom (more than 100 pixels from bottom)
    final isNearBottom = (maxScroll - currentScroll) < 100;
    _showScrollToBottomButton.value = !isNearBottom && maxScroll > viewportHeight;
    
    // Track if user is manually scrolling (not programmatic scroll)
    if (_scrollController.position.isScrollingNotifier.value) {
      _isUserScrolling = true;
      // Reset flag after a delay
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _isUserScrolling = false;
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    // Cancel all typing timers
    for (var timer in _typingTimers.values) {
      timer?.cancel();
    }
    _typingTimers.clear();
    _displayedTexts.clear();
    _initializedMessages.clear();
    _completedAnimations.clear();
    _lastScrollTime.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Obx(() {
                // Show chat view if:
                // 1. User has started chat, OR
                // 2. First chatData item has options (skip initial view)
                final firstItemHasOptions =
                    controller.chatData.isNotEmpty &&
                    controller.chatData.first.options != null &&
                    controller.chatData.first.options!.isNotEmpty;

                return (controller.hasStartedChat.value || firstItemHasOptions)
                    ? _buildChatView(context)
                    : _buildInitialView(context);
              }),
            ),
            // Show input area based on last message state
            Obx(() {
              // Check the last message in chatData (including all messages)
              final lastMessage = controller.chatData.isNotEmpty ? controller.chatData.last : null;

              // If last message is a user message (option selected), hide input area (waiting for API response)
              if (lastMessage?.reply?.role == 'user') {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.0, 1.0),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
                      child: FadeTransition(opacity: animation, child: child),
                    );
                  },
                  child: const SizedBox.shrink(key: ValueKey('hidden')),
                );
              }

              // If last message is a bot message, check if it has options
              final hasOptions = lastMessage?.options != null && lastMessage!.options!.isNotEmpty;

              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.0, 1.0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                child: hasOptions ? SizedBox(height: 100.h) : _buildInputArea(context, key: const ValueKey('visible')),
              );
            }),
          ],
        ),
      ),
    );
  }

  /// App Bar
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return CommonAppbar(
      centerTitle: false,
      title: 'chat_take_quiz'.tr,
      actionWidget: GestureDetector(child: Assets.icons.icHistory.svg(), onTap: () => Get.to(() => ChatHistoryView())),
    );
  }

  /// Initial centered view
  Widget _buildInitialView(BuildContext context) {
    return Obx(() {
      // Show shimmer while initializing
      if (controller.isInitializing.value) {
        return SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height - 200.h,
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Greeting shimmer
                ShimmerWidget(
                  child: Container(
                    width: 200.w,
                    height: 30.h,
                    decoration: BoxDecoration(color: AppColors.grayE3E3DC, borderRadius: BorderRadius.circular(8.r)),
                  ),
                ),
                SizedBox(height: 8.h),
                // Question shimmer
                ShimmerWidget(
                  child: Container(
                    width: 250.w,
                    height: 30.h,
                    decoration: BoxDecoration(color: AppColors.grayE3E3DC, borderRadius: BorderRadius.circular(8.r)),
                  ),
                ),
                SizedBox(height: 24.h),
                // Suggestion buttons shimmer
                Row(
                  children: List.generate(4, (index) {
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: index < 3 ? 10.w : 0),
                        child: ShimmerWidget(
                          child: Container(
                            height: 50.h,
                            decoration: BoxDecoration(
                              color: AppColors.grayE3E3DC,
                              borderRadius: BorderRadius.circular(30.r),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        );
      }

      // Show actual content when initialization is complete
      return SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height - 200.h,
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildGreeting(context),
              SizedBox(height: 8.h),
              _buildQuestion(context),
              SizedBox(height: 24.h),
              _buildSuggestionButtons(context),
            ],
          ),
        ),
      );
    });
  }

  /// Chat view with messages
  Widget _buildChatView(BuildContext context) {
    return Obx(() {
      // If first item has options, show all messages including first one
      // Otherwise, skip first item (initial question) and show only chat messages
      final firstItemHasOptions =
          controller.chatData.isNotEmpty &&
          controller.chatData.first.options != null &&
          controller.chatData.first.options!.isNotEmpty;

      final chatMessages = firstItemHasOptions
          ? controller.chatData
          : (controller.chatData.length > 1 ? controller.chatData.sublist(1) : <ChatData>[]);

      if (chatMessages.isEmpty) {
        return const SizedBox();
      }

      // Auto-scroll to bottom when new messages arrive (only if user is near bottom)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients && !_isUserScrolling) {
          final maxScroll = _scrollController.position.maxScrollExtent;
          final currentScroll = _scrollController.position.pixels;
          // Only auto-scroll if user is near the bottom (within 150 pixels)
          if ((maxScroll - currentScroll) < 150) {
            _scrollController.animateTo(
              maxScroll,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        }
      });

      // Check if last message is from user (waiting for response) or if retrying
      final lastMessage = chatMessages.isNotEmpty ? chatMessages.last : null;
      final isWaitingForResponse = lastMessage?.reply?.role == 'user';
      final isRetrying = controller.isRetrying.value;
      final itemCount = (isWaitingForResponse || isRetrying) ? chatMessages.length + 1 : chatMessages.length;

      // Auto-scroll when typing indicator appears (only if user is near bottom)
      if ((isWaitingForResponse || isRetrying) && !_isUserScrolling) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            final maxScroll = _scrollController.position.maxScrollExtent;
            final currentScroll = _scrollController.position.pixels;
            // Only auto-scroll if user is near the bottom (within 150 pixels)
            if ((maxScroll - currentScroll) < 150) {
              _scrollController.animateTo(
                maxScroll,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          }
        });
      }

      return Stack(
        children: [
          ListView.builder(
            controller: _scrollController,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
            itemCount: itemCount,
            itemBuilder: (context, index) {
              // Show typing animation as last item if waiting for response or retrying
              if ((isWaitingForResponse || isRetrying) && index == chatMessages.length) {
                return _buildTypingIndicator(context);
              }

              final chatData = chatMessages[index];
              // Use StatefulBuilder to rebuild when typing animation updates
              return StatefulBuilder(
                builder: (context, setState) {
                  return _buildChatDataBubble(chatData, context);
                },
              );
            },
          ),
          // Scroll to bottom button
          Obx(() => _showScrollToBottomButton.value ? _buildScrollToBottomButton(context) : const SizedBox.shrink()),
        ],
      );
    });
  }

  /// Scroll to bottom button (like ChatGPT)
  Widget _buildScrollToBottomButton(BuildContext context) {
    return Positioned(
      bottom: 20.h,
      right: 20.w,
      child: GestureDetector(
        onTap: () {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
            // Hide button after scrolling
            Future.delayed(const Duration(milliseconds: 350), () {
              if (mounted) {
                _showScrollToBottomButton.value = false;
              }
            });
          }
        },
        child: Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            color: AppColors.primaryColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.keyboard_arrow_down,
            color: AppColors.surfaceColor,
            size: 24.sp,
          ),
        ),
      ),
    );
  }

  /// Chat data bubble
  Widget _buildChatDataBubble(ChatData chatData, BuildContext context) {
    final reply = chatData.reply;
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
                      child: Obx(() {
                        // Hide error message and retry button when retrying
                        final isRetrying = controller.isRetrying.value;
                        if (isRetrying && chatData.isError == true) {
                          return const SizedBox.shrink();
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTypingText(reply.content!, chatData.sessionId ?? ''),
                            if (chatData.isError == true && !isRetrying) ...[
                              SizedBox(height: 8.h),
                              _buildRetryButton(context),
                            ],
                          ],
                        );
                      }),
                    ),
                    // Handle options/buttons if available - only show after typing animation completes
                    Obx(() {
                      // Use same uniqueId format as _buildTypingText
                      final uniqueId = '${chatData.sessionId ?? ''}_${reply.content!.hashCode}';
                      final isAnimationComplete = _completedAnimations.contains(uniqueId);

                      if (chatData.options != null && isAnimationComplete) {
                        return _buildOptionsFromChatData(chatData.options, chatData);
                      }
                      // Check if user is logged in (reactive check)
                      final isUserLoggedIn = PrefService.getBool(PrefKeys.isLogin);
                      // Show login button if:
                      // 1. showLoginButton flag is set OR isRegistered is false
                      // 2. Animation is complete
                      final shouldShowLoginButton =
                          (chatData.showLoginButton == true || chatData.isRegistered == false) && isAnimationComplete;
                      if (shouldShowLoginButton) {
                        return _buildLoginButton(context, isDisabled: isUserLoggedIn);
                      }
                      // Show products if available and animation is complete
                      if (chatData.products != null && chatData.products!.isNotEmpty && isAnimationComplete) {
                        return _buildProductsList(chatData.products!);
                      }
                      return const SizedBox.shrink();
                    }),
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

    // Create unique identifier for this ChatData's options
    final optionsMessageId = '${currentChatData.sessionId ?? ''}_${currentChatData.reply?.content?.hashCode ?? 0}';

    // Get the selected option value for this specific ChatData (if any)
    final selectedOptionValue = _getSelectedOptionValue(currentChatData, options);

    // Check if API response has been received for this message (disable options only after API response)
    return Obx(() {
      final isCompleted = controller.completedOptionMessages.contains(optionsMessageId);
      final hasAnyOptionSelected = selectedOptionValue != null;
      // Disable only if API response has been received AND an option was selected
      final isDisabled = isCompleted && hasAnyOptionSelected;

      return Padding(
        padding: EdgeInsets.only(bottom: 12.h),
        child: Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: options.map((option) {
            final isSelected = option.value == selectedOptionValue;

            return GestureDetector(
              onTap: isDisabled
                  ? null // Disable tap only after API response is received
                  : () {
                      // Call sendMessage with option value and label, pass optionsMessageId
                      if (option.value != null && option.value!.isNotEmpty) {
                        controller.onOptionTap(option.value!, label: option.label, optionsMessageId: optionsMessageId);
                      }
                    },
              child: Opacity(
                opacity: (isDisabled && !isSelected)
                    ? 0.5
                    : 1.0, // Dim disabled options, but keep selected option at full opacity
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors
                              .yellowF0EFE4 // Highlight selected option
                        : (isDisabled ? AppColors.grayE3E3DC : AppColors.white),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: isSelected
                          ? AppColors
                                .black1414141 // Darker border for selected
                          : (isDisabled ? AppColors.grayE3E3DC : AppColors.yellowF0EFE4),
                      width: isSelected ? 2 : 1, // Thicker border for selected
                    ),
                  ),
                  child: Text(
                    option.label ?? option.value ?? '',
                    style: TextStyles.regular(
                      12.sp,
                      fontColor: isSelected
                          ? AppColors
                                .black1414141 // Keep dark text for selected
                          : (isDisabled ? AppColors.gray949391 : AppColors.black1414141),
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal, // Bold for selected
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );
    });
  }

  /// Get the selected option value for a specific ChatData's options
  /// Only checks user messages that come AFTER this ChatData message
  String? _getSelectedOptionValue(ChatData currentChatData, List<Option> options) {
    // Get all option labels and values from the list
    // We need to match by label because user messages store the label (not the value)
    final optionLabels = options
        .map((option) => option.label ?? option.value)
        .where((label) => label != null && label.isNotEmpty)
        .cast<String>()
        .toList();

    if (optionLabels.isEmpty) {
      return null;
    }

    // Find the index of currentChatData in chatData list
    final currentIndex = controller.chatData.indexOf(currentChatData);
    if (currentIndex == -1) {
      return null;
    }

    // Check if any user message AFTER this ChatData matches any of the option labels
    // This ensures that if the same options appear again in a new message, they're treated as new
    for (int i = currentIndex + 1; i < controller.chatData.length; i++) {
      final chatData = controller.chatData[i];
      final reply = chatData.reply;
      if (reply?.role == 'user' && reply?.content != null) {
        final userMessageContent = reply!.content!;
        // Check if this user message matches any option label
        if (optionLabels.contains(userMessageContent)) {
          // Find the corresponding option value for this label
          final selectedOption = options.firstWhere(
            (option) => (option.label ?? option.value) == userMessageContent,
            orElse: () => options.first, // Fallback (shouldn't happen)
          );
          return selectedOption.value ?? selectedOption.label; // Return the value
        }
      }
    }

    return null; // No option selected from this specific set
  }

  /// Button options (legacy - kept for compatibility)
  Widget _buildButtonOptions(List<String> options) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Wrap(
        spacing: 8.w,
        runSpacing: 8.h,
        children: options.map((option) {
          return GestureDetector(
            onTap: () => controller.onButtonOptionTap(option),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.yellowF0EFE4, width: 1),
              ),
              child: Text(option, style: TextStyles.regular(12.sp, fontColor: AppColors.black1414141)),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Summary widget
  Widget _buildSummary(String summary) {
    final lines = summary.split('\n');
    return Container(
      margin: EdgeInsets.only(bottom: 12.h, right: 60.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(color: AppColors.offWhite, borderRadius: BorderRadius.circular(12.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: lines.map((line) {
          return Padding(
            padding: EdgeInsets.only(bottom: 4.h),
            child: Text('• $line', style: TextStyles.regular(14.sp, fontColor: AppColors.black1414141)),
          );
        }).toList(),
      ),
    );
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

  /// Retry button shown on error messages
  Widget _buildRetryButton(BuildContext context) {
    return Obx(() {
      final isRetrying = controller.isRetrying.value;
      return Align(
        alignment: Alignment.centerLeft,
        child: ElevatedButton.icon(
          onPressed: isRetrying ? null : () {
            controller.retryLastRequest();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isRetrying 
                ? AppColors.primaryColor.withValues(alpha: 0.5)
                : AppColors.primaryColor,
            foregroundColor: AppColors.surfaceColor,
            elevation: 0,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
            disabledBackgroundColor: AppColors.primaryColor.withValues(alpha: 0.5),
            disabledForegroundColor: AppColors.surfaceColor,
          ),
          icon: isRetrying 
              ? SizedBox(
                  width: 16.sp,
                  height: 16.sp,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.surfaceColor),
                  ),
                )
              : Icon(Icons.refresh, size: 16.sp),
          label: Text(
            isRetrying ? 'Retrying...' : 'Retry',
            style: TextStyles.medium(12.sp, fontColor: AppColors.surfaceColor),
          ),
        ),
      );
    });
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
                          message: result['message'] as String? ?? 'home_item_added_to_cart'.tr,
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

  /// Greeting with gradient text
  Widget _buildGreeting(BuildContext context) {
    // Use GetBuilder since ProfileController uses update() instead of reactive variables
    if (!Get.isRegistered<ProfileController>()) {
      return RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: [
            WidgetSpan(
              child: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      AppColors.primaryColor, // #1BAF9A
                      AppColors.orangeF7A173, // #F7A173
                    ],
                    transform: GradientRotation(1),
                  ).createShader(bounds);
                },
                child: Text('chat_hello'.tr, style: TextStyles.semiBold(24.sp, fontColor: Colors.white)),
              ),
            ),
          ],
        ),
      );
    }

    return GetBuilder<ProfileController>(
      builder: (profileController) {
        // Get user name from ProfileController
        String? userName;
        final firstName = profileController.userData.user?.firstName?.trim();
        final lastName = profileController.userData.user?.lastName?.trim();
        
        // Build full name if available
        if (firstName != null && firstName.isNotEmpty) {
          userName = lastName != null && lastName.isNotEmpty 
              ? '$firstName $lastName' 
              : firstName;
        } else if (lastName != null && lastName.isNotEmpty) {
          userName = lastName;
        }

        // Use name if available, otherwise use default greeting
        final greetingText = userName != null && userName.isNotEmpty 
            ? "Hello, $userName" 
            : "Hello";

        return RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              WidgetSpan(
                child: ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        AppColors.primaryColor, // #1BAF9A
                        AppColors.orangeF7A173, // #F7A173
                      ],
                      transform: GradientRotation(1),
                    ).createShader(bounds);
                  },
                  child: Text(greetingText, style: TextStyles.semiBold(24.sp, fontColor: Colors.white)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Question text
  Widget _buildQuestion(BuildContext context) {
    return Obx(() {
      // Use first chatData item's reply content if available, otherwise show default text
      final questionText = controller.chatData.isNotEmpty && controller.chatData.first.reply?.content != null
          ? controller.chatData.first.reply!.content!
          : 'chat_help_today'.tr;

      return Text(
        questionText,
        textAlign: TextAlign.center,
        style: TextStyles.semiBold(24.sp, fontColor: AppColors.black1414141),
      );
    });
  }

  /// Suggestion buttons
  Widget _buildSuggestionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildSuggestionButton(
            context,
            svgIcon: Assets.icons.icSleep,
            label: 'Sleep',
            onTap: () => controller.onSuggestionTap('sleep'),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _buildSuggestionButton(
            context,
            svgIcon: Assets.icons.icEnergy,
            label: 'Energy',
            onTap: () => controller.onSuggestionTap('energy'),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _buildSuggestionButton(
            context,
            svgIcon: Assets.icons.icStress,
            label: 'Stress',
            onTap: () => controller.onSuggestionTap('stress'),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _buildSuggestionButton(
            context,
            svgIcon: Assets.icons.icImmunity,
            label: 'Immunity',
            onTap: () => controller.onSuggestionTap('immunity'),
          ),
        ),
      ],
    );
  }

  /// Individual suggestion button
  Widget _buildSuggestionButton(
    BuildContext context, {
    required SvgGenImage svgIcon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(30.r),
          border: Border.all(color: AppColors.yellowF0EFE4, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            svgIcon.svg(width: 14.w, height: 14.h),
            SizedBox(width: 2.5.h),
            Expanded(
              child: Text(
                label,
                style: TextStyles.regular(10.sp, fontColor: AppColors.grey6D6D6D),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Typing animation widget for bot messages
  Widget _buildTypingText(String fullText, String messageId) {
    // Use messageId + content hash as unique identifier for each message
    final uniqueId = '${messageId}_${fullText.hashCode}';

    // Initialize displayed text if not exists (defer to post-frame to avoid setState during build)
    if (!_initializedMessages.contains(uniqueId)) {
      _initializedMessages.add(uniqueId);
      // Start animation after build completes to avoid setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          // Initialize with empty string and start animation after build completes
          _displayedTexts[uniqueId] = '';
          _startTypingAnimation(fullText, uniqueId);
        }
      });
    }

    // Always return Obx widget so it can reactively update when _displayedTexts changes
    // Use _initializedMessages (non-reactive Set) to check if we should access RxMap
    return Obx(() {
      // Check if message is initialized using non-reactive Set first
      // This prevents accessing RxMap during build phase
      if (!_initializedMessages.contains(uniqueId)) {
        return Text(
          '',
          style: TextStyles.regular(14.sp, fontColor: AppColors.black1414141),
        );
      }

      // Now safe to access RxMap since initialization is scheduled
      // Get displayed text from RxMap (will be empty initially, then animate)
      // Using null-coalescing operator is safe - if key doesn't exist, returns empty string
      final displayedText = _displayedTexts[uniqueId] ?? '';

      // Auto-scroll when typing animation is ongoing (throttled to avoid excessive scrolling)
      // Only scroll if user is near bottom and not manually scrolling
      if (displayedText.isNotEmpty && _typingTimers[uniqueId] != null && !_isUserScrolling) {
        final now = DateTime.now();
        final lastScroll = _lastScrollTime[uniqueId];
        // Throttle scrolling to once every 200ms during typing
        if (lastScroll == null || now.difference(lastScroll).inMilliseconds > 200) {
          _lastScrollTime[uniqueId] = now;
          // Scroll to bottom after a small delay to ensure text is rendered
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients && mounted && !_isUserScrolling) {
              final maxScroll = _scrollController.position.maxScrollExtent;
              final currentScroll = _scrollController.position.pixels;
              // Only scroll if we're near the bottom (within 150 pixels)
              if ((maxScroll - currentScroll) < 150) {
                _scrollController.animateTo(
                  maxScroll,
                  duration: const Duration(milliseconds: 100),
                  curve: Curves.easeOut,
                );
              }
            }
          });
        }
      }

      // Show displayed text (will be empty initially, then animate character by character)
      return Text(
        displayedText,
        style: TextStyles.regular(14.sp, fontColor: AppColors.black1414141),
      );
    });
  }

  /// Safely get substring up to a certain number of characters, handling UTF-16 properly
  String _safeSubstring(String text, int charCount) {
    if (charCount <= 0) return '';
    if (charCount >= text.length) return text;

    // Use runes to get code points and build string safely
    final runes = text.runes.toList();
    if (charCount >= runes.length) return text;

    // Get the substring up to charCount characters
    final substringRunes = runes.take(charCount);
    return String.fromCharCodes(substringRunes);
  }

  /// Start typing animation for a message
  void _startTypingAnimation(String fullText, String messageId) {
    // Cancel existing timer if any
    _typingTimers[messageId]?.cancel();

    int currentCharCount = 0;
    // Use runes to get actual character count (handles multi-byte UTF-16 characters)
    final totalCharCount = fullText.runes.length;

    // Calculate delay per character (adjust for speed)
    // Faster for long messages, slower for short ones
    final delayPerChar = totalCharCount > 100 ? 15 : (totalCharCount > 50 ? 20 : 30);

    _typingTimers[messageId] = Timer.periodic(Duration(milliseconds: delayPerChar), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (currentCharCount < totalCharCount) {
        // Update displayed text using safe substring method
        _displayedTexts[messageId] = _safeSubstring(fullText, currentCharCount + 1);
        currentCharCount++;
      } else {
        timer.cancel();
        _typingTimers[messageId] = null;
        // Ensure final text is set
        _displayedTexts[messageId] = fullText;
        // Mark animation as complete
        _completedAnimations.add(messageId);
        // Scroll to bottom when animation completes
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients && mounted) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    });
  }

  /// Typing indicator with Lottie animation
  Widget _buildTypingIndicator(BuildContext context) {
    return Row(
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
        Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(16.r)),
          child: Assets.animations.typingAnimation.lottie(width: 60.w, height: 40.h, repeat: true, fit: BoxFit.contain),
        ),
      ],
    );
  }

  /// Login button with animation
  Widget _buildLoginButton(BuildContext context, {bool isDisabled = false}) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: Padding(
              padding: EdgeInsets.only(top: 12.h, bottom: 12.h, right: 12.w),
              child: ElevatedButton(
                onPressed: isDisabled
                    ? null
                    : () {
                        Get.toNamed(
                          AppRoutes.login,
                          arguments: {'isFromAIChat': true, 'sessionID': controller.sessionId.value},
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDisabled ? AppColors.gray949391 : AppColors.primaryColor,
                  foregroundColor: AppColors.surfaceColor,
                  disabledBackgroundColor: AppColors.gray949391,
                  disabledForegroundColor: AppColors.surfaceColor,
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('auth_login'.tr, style: TextStyles.semiBold(16.sp, fontColor: AppColors.surfaceColor)),
                    SizedBox(width: 8.w),
                    Icon(Icons.arrow_forward, size: 18.sp, color: AppColors.surfaceColor),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Input area at bottom
  Widget _buildInputArea(BuildContext context, {Key? key}) {
    return Container(
      key: key,
      margin: EdgeInsets.all(15.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.yellowF0EFE4),
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller.messageController,
              maxLines: 5,
              minLines: 3,
              decoration: InputDecoration(
                hintText: 'chat_question_hint'.tr,
                hintStyle: TextStyles.regular(14.sp, fontColor: AppColors.gray949391),
                border: InputBorder.none,
                isDense: true,
              ),
              style: TextStyles.regular(14.sp, fontColor: AppColors.black1414141),
              onSubmitted: (_) {
                if (!controller.isMessageEmpty.value) {
                  controller.sendMessage();
                }
              },
            ),
          ),

          SizedBox(width: 8.w),

          Obx(
                () => GestureDetector(
              onTap: controller.isMessageEmpty.value
                  ? null
                  : () => controller.sendMessage(),
              child: Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: controller.isMessageEmpty.value
                      ? AppColors.primaryColor.withValues(alpha: 0.3)
                      : null,
                  gradient: controller.isMessageEmpty.value
                      ? null
                      : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryColor.withValues(alpha: 0.8),
                      AppColors.primaryColor,
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_upward,
                  color: AppColors.surfaceColor,
                  size: 25.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget _buildInputArea(BuildContext context, {Key? key}) {
  //   return Container(
  //     key: key,
  //     margin: EdgeInsets.all(15.h),
  //     padding: EdgeInsets.symmetric(horizontal: 16.w),
  //     decoration: BoxDecoration(
  //       border: Border.all(color: AppColors.yellowF0EFE4),
  //       color: AppColors.white,
  //       // boxShadow: [
  //       //   BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -2)),
  //       // ],
  //       borderRadius: BorderRadius.circular(16.r),
  //     ),
  //     child: Column(
  //       mainAxisSize: MainAxisSize.min,
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         SizedBox(height: 8.h),
  //         TextField(
  //           controller: controller.messageController,
  //           maxLines: null,
  //           decoration: InputDecoration(
  //             hintText: 'Ask a your question...',
  //             hintStyle: TextStyles.regular(14.sp, fontColor: AppColors.gray949391),
  //             border: InputBorder.none,
  //             contentPadding: EdgeInsets.zero,
  //             isDense: true,
  //           ),
  //           style: TextStyles.regular(14.sp, fontColor: AppColors.black1414141),
  //           onSubmitted: (_) {
  //             if (!controller.isMessageEmpty.value) {
  //               controller.sendMessage();
  //             }
  //           },
  //         ),
  //         SizedBox(height: 30.h),
  //         Row(
  //           children: [
  //             // Plus button
  //             Container(
  //               width: 38.w,
  //               height: 38.w,
  //               padding: EdgeInsets.all(12.h),
  //               decoration: BoxDecoration(color: AppColors.whiteF8F8F8, borderRadius: BorderRadius.circular(30.r)),
  //               child: Assets.icons.icAdd.svg(),
  //             ),
  //             SizedBox(width: 10.w),
  //             // Tools pill
  //             Container(
  //               padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
  //               decoration: BoxDecoration(color: AppColors.whiteF8F8F8, borderRadius: BorderRadius.circular(18.r)),
  //               child: Row(
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: [
  //                   Assets.icons.icTools.svg(),
  //                   SizedBox(width: 6.w),
  //                   Text('chat_tools'.tr, style: TextStyles.medium(14.sp, fontColor: AppColors.black1414141)),
  //                 ],
  //               ),
  //             ),
  //             const Spacer(),
  //             Obx(
  //                   () => GestureDetector(
  //                 onTap: controller.isMessageEmpty.value ? null : () => controller.sendMessage(),
  //                 child: Container(
  //                   width: 40.w,
  //                   height: 40.w,
  //                   decoration: BoxDecoration(
  //                     color: controller.isMessageEmpty.value ? AppColors.primaryColor.withValues(alpha: 0.3) : null,
  //                     gradient: controller.isMessageEmpty.value
  //                         ? null
  //                         : LinearGradient(
  //                       begin: Alignment.topLeft,
  //                       end: Alignment.bottomRight,
  //                       colors: [AppColors.primaryColor.withValues(alpha: 0.8), AppColors.primaryColor],
  //                     ),
  //                     shape: BoxShape.circle,
  //                   ),
  //                   child: Icon(Icons.arrow_upward, color: AppColors.surfaceColor, size: 25.sp),
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //         SizedBox(height: 8.h),
  //       ],
  //     ),
  //   );
  // }
}

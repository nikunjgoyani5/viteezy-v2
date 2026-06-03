import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:viteezy/core/repositories/ai_chat_repository.dart';
import 'package:viteezy/core/repositories/cart_repository.dart';
import 'package:viteezy/core/services/cart_count_service.dart';

import '../../../../core/models/ai_chat_login.dart';
import '../../../../core/models/ai_chat_response_model.dart';
import '../../../../core/models/session_history_model.dart';
import '../../../../core/models/api_response.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_functions.dart';
import '../../../../core/utils/app_prefrence.dart';
import '../../../../core/utils/dialog_service.dart';
import '../../../../core/routes/app_routes.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../profile/controllers/profile_controller.dart';

/// AI Chat Controller
class AiChatController extends GetxController {
  final _aiChatRepository = AiChatRepository();
  final _cartRepository = CartRepository();
  final TextEditingController messageController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  final RxBool isLoading = false.obs;
  final RxBool isInitializing = false.obs;
  final RxBool isRetrying = false.obs; // Track retry state
  final RxString sessionId = ''.obs;
  final RxString sessionName = ''.obs; // Store session name for history detail view
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxBool hasStartedChat = false.obs;
  final RxBool isMessageEmpty = true.obs;
  final RxBool isSearchMode = false.obs;
  final RxList<ChatData> chatData = <ChatData>[].obs;
  final RxList<ChatData> historyChatData = <ChatData>[].obs;
  final RxString searchQuery = ''.obs;
  // Track which ChatData messages have received API responses (to disable their options)
  final RxSet<String> completedOptionMessages = <String>{}.obs;
  // Track last API request to support retry on failure
  _RetryRequest? _lastRetryRequest;
  final RxList<String> historyItems = <String>[
    'I have trouble sleeping at night and feel tired during the day',
    'Are you a Woman, Man, or Gender Neutral?',
    'I have trouble sleeping at night and feel tired during the day',
  ].obs;

  // Session history
  final RxList<SessionHistory> sessionHistory = <SessionHistory>[].obs;
  final RxBool isLoadingSessionHistory = false.obs;
  final RxBool isLoadingMoreSessionHistory = false.obs;
  int currentPage = 1;
  final int limit = 10;
  bool hasMore = true;
  Pagination? pagination;
  Timer? _searchDebounceTimer;

  // Quiz data
  final RxString selectedGender = ''.obs;
  final RxString selectedAge = ''.obs;
  final RxString selectedHealthConcern = ''.obs;
  final RxString initialConcern = ''.obs;
  final RxInt currentQuestionIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    messageController.addListener(_onMessageChanged);
    searchController.addListener(_onSearchChanged);
  }

  void chatInitialization() {
    // Reset session ID when user comes again
    sessionId.value = '';
    isInitializing.value = true;
    ProfileController profileController = Get.find();
    final userId = profileController.userData.user?.userId;
    _aiChatRepository.createSession(
      body: userId != null || userId != '' ? {"user_id": userId} : null,
      onSuccess: (data) {
        // Extract and store session_id from response
        if (data.data != null && data.data is Map<String, dynamic>) {
          final responseData = data.data as Map<String, dynamic>;
          final extractedSessionId = responseData['session_id'];
          sessionId.value = extractedSessionId != null ? extractedSessionId.toString() : '';
          _aiChatRepository.getFirstQuestion(
            body: {'session_id': sessionId.value},
            onSuccess: (data) {
              if (data.data != null) {
                final chat = ChatData.fromJson(data.data);
                chatData.add(chat);
              }
              isInitializing.value = false;
            },
            onError: (error) {
              isInitializing.value = false;
              AppFunctions().showToast(error.message, bgColor: AppColors.red);
            },
          );
        }
      },
      onError: (error) {
        isInitializing.value = false;
        sessionId.value = '';
        AppFunctions().showToast(error.message, bgColor: AppColors.red);
      },
    );

    // _aiChatRepository.health(
    //   onSuccess: (data) {
    //
    //   },
    //   onError: (error) {
    //     isInitializing.value = false;
    //     AppFunctions().showToast(error.message, bgColor: AppColors.red);
    //   },
    // );
  }

  void sendMessage() {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    // Mark chat as started
    if (!hasStartedChat.value) {
      hasStartedChat.value = true;
    }

    // Store user's message in chatData before API call (for right side display)
    final userMessage = ChatData(
      sessionId: sessionId.value,
      reply: Reply(role: 'user', content: text, createdAt: DateTime.now()),
      timestamp: DateTime.now(),
    );
    chatData.add(userMessage);

    // Clear input after storing message
    messageController.clear();

    // Remember last request for retry
    _lastRetryRequest = _RetryRequest(message: text);

    // Call API to get bot response
    _sendToApi(apiMessage: text);
  }

  void getSessionByUser({bool isLoadMore = false}) {
    ProfileController profileController = Get.find();
    final userId = profileController.userData.user?.userId;
    if (userId == null) {
      isLoadingSessionHistory.value = false;
      isLoadingMoreSessionHistory.value = false;
      return;
    }

    if (isLoadMore) {
      if (!hasMore || isLoadingMoreSessionHistory.value) return;
      isLoadingMoreSessionHistory.value = true;
    } else {
      currentPage = 1;
      hasMore = true;
      isLoadingSessionHistory.value = true;
      sessionHistory.clear();
    }

    _aiChatRepository.getSessionByUser(
      userId: userId,
      page: currentPage,
      limit: limit,
      onSuccess: (data) {
        isLoadingSessionHistory.value = false;
        isLoadingMoreSessionHistory.value = false;
        if (data.data != null) {
          try {
            final sessionHistoryModel = List<SessionHistory>.from(data.data.map((x) => SessionHistory.fromJson(x)));

            if (isLoadMore) {
              sessionHistory.addAll(sessionHistoryModel);
            } else {
              sessionHistory.value = sessionHistoryModel;
            }

            // Update pagination
            pagination = data.pagination;
            if (pagination != null) {
              hasMore = pagination!.hasNext ?? false;
              if (hasMore) {
                currentPage++;
              }
            } else {
              // If no pagination info, assume hasMore based on the number of items received
              hasMore = sessionHistoryModel.length >= limit;
              if (hasMore) {
                currentPage++;
              }
            }
          } catch (e) {
            if (!isLoadMore) {
              sessionHistory.value = [];
            }
            hasMore = false;
          }
        } else {
          if (!isLoadMore) {
            sessionHistory.value = [];
          }
          hasMore = false;
        }
      },
      onError: (error) {
        isLoadingSessionHistory.value = false;
        isLoadingMoreSessionHistory.value = false;
        if (!isLoadMore) {
          sessionHistory.value = [];
        }
        hasMore = false;
        AppFunctions().showToast(error.message, bgColor: AppColors.red);
      },
    );
  }

  void getSearchSessionByUser({String? search}) {
    ProfileController profileController = Get.find();
    final userId = profileController.userData.user?.userId;
    if (userId == null) {
      isLoadingSessionHistory.value = false;
      return;
    }

    // Reset pagination for search
    currentPage = 1;
    hasMore = true;
    isLoadingSessionHistory.value = true;
    _aiChatRepository.getSearchSessionByUser(
      userId: userId,
      search: search,
      onSuccess: (data) {
        isLoadingSessionHistory.value = false;
        if (data.data != null) {
          try {
            final sessionHistoryModel = List<SessionHistory>.from(
              data.data['matches'].map(
                (x) => SessionHistory(
                  sessionId: x['session_id'],
                  sessionName: x['session_name'],
                  createdAt: DateTime.parse(x['date']),
                ),
              ),
            );
            sessionHistory.value = sessionHistoryModel;

            // Update pagination for search
            pagination = data.pagination;
            if (pagination != null) {
              hasMore = pagination!.hasNext ?? false;
            } else {
              hasMore = false;
            }
          } catch (e) {
            sessionHistory.value = [];
            hasMore = false;
          }
        } else {
          sessionHistory.value = [];
          hasMore = false;
        }
      },
      onError: (error) {
        isLoadingSessionHistory.value = false;
        sessionHistory.value = [];
        hasMore = false;
        AppFunctions().showToast(error.message, bgColor: AppColors.red);
      },
    );
  }

  /// Delete a session
  void deleteSession(String sessionId, {Function()? onSuccess, Function()? onError}) {
    // Optimistically remove from local list with animation
    ProfileController profileController = Get.find();
    final userId = profileController.userData.user?.userId;
    if (userId == null) {
      return;
    }

    // Check if the session being deleted is the current active session
    final isCurrentSession = this.sessionId.value == sessionId;

    final sessionToRemove = sessionHistory.firstWhereOrNull((s) => s.sessionId == sessionId);
    if (sessionToRemove != null) {
      sessionHistory.remove(sessionToRemove);
    }

    // Call API to delete from backend
    _aiChatRepository.deleteSession(
      sessionId: sessionId,
      userId: userId,
      onSuccess: (data) {
        // If deleted session is the current active session, initialize a new chat session
        if (isCurrentSession) {
          chatInitialization();
        }
        // Session already removed from list, just call success callback
        if (onSuccess != null) onSuccess();
      },
      onError: (error) {
        // Re-add session if API call failed
        if (sessionToRemove != null && !sessionHistory.contains(sessionToRemove)) {
          sessionHistory.add(sessionToRemove);
          // Re-sort to maintain order
          sessionHistory.sort((a, b) {
            final aDate = a.updatedAt ?? a.createdAt ?? DateTime(1970);
            final bDate = b.updatedAt ?? b.createdAt ?? DateTime(1970);
            return bDate.compareTo(aDate);
          });
        }
        if (onError != null) onError();
        AppFunctions().showToast(error.message, bgColor: AppColors.red);
      },
    );
  }

  /// Load session history when coming from chat history
  void loadSessionHistory({required String sessionId}) {
    ProfileController profileController = Get.find();
    final userId = profileController.userData.user?.userId;
    if (userId == null) {
      return;
    }

    historyChatData.clear();
    isInitializing.value = true;

    // Call getSessionsHistory API
    _aiChatRepository.getSessionsHistory(
      userId: userId,
      sessionId: sessionId,
      onSuccess: (data) {
        isInitializing.value = false;
        if (data.data != null && data.data is Map) {
          try {
            final responseData = data.data as Map<String, dynamic>;
            final sessionIdFromResponse = responseData['session_id'] as String?;
            final sessionNameFromResponse = responseData['session_name'] as String?;
            final messages = responseData['messages'] as List<dynamic>?;

            // Store session name
            sessionName.value = sessionNameFromResponse ?? '';

            if (messages != null && messages.isNotEmpty) {
              // Map each message to ChatData
              final List<ChatData> parsedChats = messages
                  .map((message) {
                    try {
                      final messageMap = message as Map<String, dynamic>;
                      final role = messageMap['role'] as String?;
                      final content = messageMap['content'] as String?;
                      final createdAtStr = messageMap['created_at'] as String?;

                      DateTime? createdAt;
                      if (createdAtStr != null) {
                        try {
                          createdAt = DateTime.parse(createdAtStr);
                        } catch (e) {
                          createdAt = DateTime.now();
                        }
                      } else {
                        createdAt = DateTime.now();
                      }

                      return ChatData(
                        sessionId: sessionIdFromResponse ?? sessionId,
                        reply: Reply(role: role, content: content, createdAt: createdAt),
                        timestamp: createdAt,
                      );
                    } catch (e) {
                      return null;
                    }
                  })
                  .whereType<ChatData>()
                  .toList();

              historyChatData.value = parsedChats;
            } else {
              historyChatData.value = [];
            }
          } catch (e) {
            historyChatData.value = [];
          }
        } else {
          historyChatData.value = [];
        }
      },
      onError: (error) {
        isInitializing.value = false;
        historyChatData.value = [];
        AppFunctions().showToast(error.message, bgColor: AppColors.red);
      },
    );
  }

  getProductRecommendation(String userId, {VoidCallback? onComplete, VoidCallback? onError}) {
    _aiChatRepository.useridLogin(
      body: {"user_id": userId, "session_id": sessionId.value},
      onSuccess: (data) {
        if (data.data != null) {
          try {
            final msg1 = ChatData.fromJson(data.data);
            final msg = ChatData(
              sessionId: sessionId.value,
              products: msg1.products,
              reply: Reply(role: "assistant", content: data.data['message']),
              isRegistered: true,
              showLoginButton: false,
            );
            // Ensure message has at least reply with content, or products, or options
            // This is required for _buildChatDataBubble to display it
            if (msg.reply?.content != null ||
                (msg.products != null && msg.products!.isNotEmpty) ||
                (msg.options != null && msg.options!.isNotEmpty)) {
              // Use assignment to trigger reactive update - this ensures Obx rebuilds
              final updatedList = List<ChatData>.from(chatData);
              updatedList.add(msg);
              chatData.value = updatedList;
              // Force refresh to ensure UI updates
              chatData.refresh();
            }
          } catch (e) {
            // If parsing fails, log error but don't crash
            debugPrint('Error parsing ChatData: $e');
            debugPrint('Data received: ${data.data}');
          }
        } else {
          debugPrint('getProductRecommendation: data.data is null');
        }
        onComplete?.call();
        Get.back();
      },
      onError: (error) {
        debugPrint('getProductRecommendation error: ${error.message}');
        onError?.call();
      },
    );
  }

  void _onMessageChanged() {
    isMessageEmpty.value = messageController.text.trim().isEmpty;
  }

  void _onSearchChanged() {
    if (searchController.text.trim().isEmpty) {
      return;
    }
    final query = searchController.text.trim();
    searchQuery.value = query;

    // Cancel previous timer
    _searchDebounceTimer?.cancel();

    // Debounce search API call
    _searchDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      // Call getSessionByUser with search keyword
      getSearchSessionByUser(search: query.isNotEmpty ? query : null);
    });
  }

  void enterSearchMode() {
    isSearchMode.value = true;
    searchController.clear();
    searchQuery.value = '';
  }

  void exitSearchMode() {
    isSearchMode.value = false;
    searchController.clear();
    getSessionByUser();
    searchQuery.value = '';
  }

  List<String> get filteredHistory {
    final query = searchQuery.value.toLowerCase();
    if (query.isEmpty) return historyItems;
    return historyItems.where((item) => item.toLowerCase().contains(query)).toList();
  }

  /// Send message
  // void sendMessage() {
  //   final text = messageController.text.trim();
  //   if (text.isEmpty) return;
  //
  //   // Mark chat as started
  //   if (!hasStartedChat.value) {
  //     hasStartedChat.value = true;
  //   }
  //
  //   // Add user message
  //   messages.add(ChatMessage(text: text, isUser: true, timestamp: DateTime.now()));
  //
  //   // Clear input
  //   messageController.clear();
  //
  //   // Generate AI response
  //   _generateAiResponse(text);
  // }

  /// Generate AI response based on quiz flow
  void _generateAiResponse(String userMessage) {
    isLoading.value = true;

    // Simulate delay
    Future.delayed(const Duration(milliseconds: 800), () {
      isLoading.value = false;

      if (currentQuestionIndex.value == 0) {
        // Store initial concern
        initialConcern.value = userMessage;
        // Ask gender question
        _askGenderQuestion();
      } else if (currentQuestionIndex.value == 1) {
        // Store gender
        selectedGender.value = userMessage;
        // Ask age question
        _askAgeQuestion();
      } else if (currentQuestionIndex.value == 2) {
        // Store age
        selectedAge.value = userMessage;
        // Ask health concern question
        _askHealthConcernQuestion();
      } else if (currentQuestionIndex.value == 3) {
        // Store health concern
        selectedHealthConcern.value = userMessage;
        // Show profile summary and recommendations
        _showProfileSummary();
      }
    });
  }

  /// Ask gender question
  void _askGenderQuestion() {
    currentQuestionIndex.value = 1;
    messages.add(
      ChatMessage(
        text: 'Are you a Woman, Man, or Gender Neutral?',
        isUser: false,
        timestamp: DateTime.now(),
        hasButtons: true,
        buttonOptions: ['Woman', 'Man', 'Gender Neutral'],
      ),
    );
  }

  /// Ask age question
  void _askAgeQuestion() {
    currentQuestionIndex.value = 2;
    messages.add(ChatMessage(text: 'What is your age?', isUser: false, timestamp: DateTime.now()));
  }

  /// Ask health concern question
  void _askHealthConcernQuestion() {
    currentQuestionIndex.value = 3;
    messages.add(
      ChatMessage(
        text: 'Thank you! Based on your answers, which health concern is most important to you?',
        isUser: false,
        timestamp: DateTime.now(),
        hasButtons: true,
        buttonOptions: ['Question 1', 'Question 2', 'Question 3'],
      ),
    );
  }

  /// Show profile summary
  void _showProfileSummary() {
    messages.add(
      ChatMessage(
        text:
            'Perfect! I have your complete profile. Your main concern is about sleep. I\'ll tailor my recommendations accordingly.',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );

    // Show summary
    final summary = 'Name: ${initialConcern.value}\nSex: ${selectedGender.value}\nAge: ${selectedAge.value}';
    messages.add(ChatMessage(text: summary, isUser: false, timestamp: DateTime.now(), isSummary: true));

    // Show recommended products
    messages.add(
      ChatMessage(text: 'Recommended Products', isUser: false, timestamp: DateTime.now(), isProductHeader: true),
    );

    messages.add(
      ChatMessage(
        text: 'Energy Bundle',
        isUser: false,
        timestamp: DateTime.now(),
        isProduct: true,
        productDescription: 'A good source of protein, ideal for an active lifestyle.',
      ),
    );
  }

  /// Handle suggestion button tap
  void onSuggestionTap(String suggestion) {
    String message = '';
    switch (suggestion) {
      case 'sleep':
        message = "I have trouble sleeping at night and feel tired during the day.";
        break;
      case 'energy':
        message = "I need help with energy";
        break;
      case 'stress':
        message = "I need help with stress";
        break;
      case 'immunity':
        message = "I need help with immunity";
        break;
    }

    if (message.isNotEmpty) {
      hasStartedChat.value = true;
      messageController.text = message;
      sendMessage();
    }
  }

  /// Handle button option selection (legacy)
  void onButtonOptionTap(String option) {
    hasStartedChat.value = true;
    messageController.text = option;
    sendMessage();
  }

  /// Handle option tap with value and label
  void onOptionTap(String value, {String? label, String? optionsMessageId}) {
    hasStartedChat.value = true;
    // Send message with option value
    final text = value.trim();
    if (text.isEmpty) return;

    // Store user's message in chatData before API call (for right side display)
    // Use label for display if available, otherwise fallback to value
    final displayText = label ?? value;
    final userMessage = ChatData(
      sessionId: sessionId.value,
      reply: Reply(
        role: 'user',
        content: displayText, // Use label for display
        createdAt: DateTime.now(),
      ),
      timestamp: DateTime.now(),
    );
    chatData.add(userMessage);

    // Remember last request for retry
    _lastRetryRequest = _RetryRequest(message: value, optionsMessageId: optionsMessageId, label: label);

    // Call API to get bot response (send value to API)
    _sendToApi(apiMessage: value, optionsMessageId: optionsMessageId);
  }

  /// Add product to cart
  Future<Map<String, dynamic>> addToCart(String productId, String quantity) async {
    // Check if user is logged in
    final isLoggedIn = PrefService.getBool(PrefKeys.isLogin) && PrefService.getString(PrefKeys.accessToken).isNotEmpty;
    if (!isLoggedIn) {
      // Show login dialog
      DialogService.showLoginRequiredDialog(
        message: 'Please login to add products to your cart.',
        onLogin: () {
          Get.toNamed(AppRoutes.login);
        },
      );
      return {'success': false, 'message': 'Please login to add products to your cart.'};
    }

    final completer = Completer<Map<String, dynamic>>();

    _cartRepository.addToCartItem(
      body: {"productId": productId, "variantType": quantity},
      onSuccess: (data) {
        final message = data.message;

        // Refresh cart data silently if CartController is registered
        if (Get.isRegistered<CartController>()) {
          final cartController = Get.find<CartController>();
          cartController.refreshCartSilently();
        }

        // Update cart count in preferences on success
        if (Get.isRegistered<CartCountService>()) {
          final cartCountService = CartCountService.to;
          // Increment count by 1 when item is added
          final newCount = cartCountService.cartItemCount.value + 1;
          cartCountService.updateCartCount(newCount);
        }

        completer.complete({
          'success': true,
          'message': message != null && message.isNotEmpty ? message : 'Item added to cart',
        });
      },
      onError: (error) {
        completer.complete({
          'success': false,
          'message': error.message.isNotEmpty ? error.message : 'Failed to add item to cart. Please try again.',
        });
      },
    );

    return completer.future;
  }

  @override
  void onClose() {
    _searchDebounceTimer?.cancel();
    messageController.removeListener(_onMessageChanged);
    messageController.dispose();
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    super.onClose();
  }

  /// Retry the last failed API request (sendMessage or option tap)
  void retryLastRequest() {
    final request = _lastRetryRequest;
    if (request == null || isRetrying.value) return; // Prevent multiple retries

    // Set retry state
    isRetrying.value = true;

    // Remove the last error message from chatData
    if (chatData.isNotEmpty && chatData.last.isError == true) {
      chatData.removeLast();
    }

    // Retry the API call
    _sendToApi(apiMessage: request.message, optionsMessageId: request.optionsMessageId);
  }

  /// Shared API sender for chat requests
  void _sendToApi({required String apiMessage, String? optionsMessageId}) {
    _aiChatRepository.sendMessage(
      body: {"session_id": sessionId.value, "message": apiMessage},
      onSuccess: (data) {
        // Reset retry state on success
        isRetrying.value = false;

        // Mark the options message as completed (disable its options)
        if (optionsMessageId != null && optionsMessageId.isNotEmpty) {
          completedOptionMessages.add(optionsMessageId);
        }

        if (data.data != null) {
          final chat = ChatData.fromJson(data.data);

          if (chat.reply == null) {
            ProfileController profileController = Get.find();
            _aiChatRepository.useridLogin(
              body: {
                if (profileController.userData.user?.userId != null || profileController.userData.user?.userId != '')
                  "user_id": profileController.userData.user?.userId,
                "session_id": sessionId.value,
              },
              onSuccess: (data1) {
                isRetrying.value = false; // Reset retry state
                final loinRes = LoinData.fromJson(data1.data);
                if (loinRes.isLogin == false) {
                  // Display message first, then show login button with animation
                  final msg = ChatData(
                    sessionId: sessionId.value,
                    reply: Reply(role: 'assistant', content: loinRes.message, createdAt: DateTime.now()),
                    timestamp: DateTime.now(),
                    showLoginButton: true, // Flag to show login button
                    products: loinRes.products,
                  );
                  chatData.add(msg);
                } else {
                  final msg = ChatData(
                    sessionId: sessionId.value,
                    reply: Reply(role: 'assistant', content: loinRes.message, createdAt: DateTime.now()),
                    timestamp: DateTime.now(),
                    showLoginButton: false,
                    products: loinRes.products,
                  );
                  chatData.add(msg);
                }
              },
              onError: (error) {
                isRetrying.value = false; // Reset retry state on error
                // On error, keep options disabled and show retry-able error message
                if (optionsMessageId != null && optionsMessageId.isNotEmpty) {
                  completedOptionMessages.add(optionsMessageId);
                }
                final errorMsg = ChatData(
                  sessionId: sessionId.value,
                  reply: Reply(
                    role: 'assistant',
                    content: 'Something went wrong. Please try again.',
                    createdAt: DateTime.now(),
                  ),
                  timestamp: DateTime.now(),
                  showLoginButton: false,
                  isError: true,
                );
                chatData.add(errorMsg);
              },
            );
          } else {
            chatData.add(chat);
          }
        }
      },
      onError: (error) {
        isRetrying.value = false; // Reset retry state on error
        // On error, keep options disabled and show retry-able error message
        if (optionsMessageId != null && optionsMessageId.isNotEmpty) {
          completedOptionMessages.add(optionsMessageId);
        }
        final errorMsg = ChatData(
          sessionId: sessionId.value,
          showLoginButton: false,
          reply: Reply(
            role: 'assistant',
            content: 'Something went wrong. Please try again.',
            createdAt: DateTime.now(),
          ),
          timestamp: DateTime.now(),
          isError: true,
        );
        chatData.add(errorMsg);
      },
    );
  }
}

/// Internal model to keep track of last request for retry
class _RetryRequest {
  final String message;
  final String? optionsMessageId;
  final String? label;

  _RetryRequest({required this.message, this.optionsMessageId, this.label});
}

/// Chat Message Model
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool hasButtons;
  final List<String>? buttonOptions;
  final bool isSummary;
  final bool isProductHeader;
  final bool isProduct;
  final String? productDescription;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.hasButtons = false,
    this.buttonOptions,
    this.isSummary = false,
    this.isProductHeader = false,
    this.isProduct = false,
    this.productDescription,
  });
}

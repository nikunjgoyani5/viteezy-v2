import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Support Controller
class SupportController extends GetxController {
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final TextEditingController messageController = TextEditingController();
  final RxBool isLoading = false.obs;


  /// Send message
  void sendMessage() {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    // Add user message
    messages.add(ChatMessage(
      text: text,
      isBot: false,
      timestamp: DateTime.now(),
    ));

    // Clear input
    messageController.clear();

    // Simulate bot response
    _generateBotResponse(text);
  }

  /// Generate bot response based on user message
  void _generateBotResponse(String userMessage) {
    isLoading.value = true;

    // Simulate delay
    Future.delayed(const Duration(milliseconds: 800), () {
      String response = _getResponseForMessage(userMessage);
      messages.add(ChatMessage(
        text: response,
        isBot: true,
        timestamp: DateTime.now(),
      ));
      isLoading.value = false;
    });
  }

  /// Get response based on message content
  String _getResponseForMessage(String message) {
    final lowerMessage = message.toLowerCase();

    if (lowerMessage.contains('recommendation') || lowerMessage.contains('recommend')) {
      return "I'd be happy to help you find the perfect product! Could you tell me what health goals you're looking to achieve?";
    } else if (lowerMessage.contains('order') || lowerMessage.contains('delivery') || lowerMessage.contains('shipping')) {
      return "I can help you with your order! Please provide your order number or email address, and I'll look up your order details.";
    } else if (lowerMessage.contains('product') || lowerMessage.contains('question') || lowerMessage.contains('about')) {
      return "I'm here to answer any questions about our products! Which product would you like to know more about?";
    } else if (lowerMessage.contains('hello') || lowerMessage.contains('hi') || lowerMessage.contains('hey')) {
      return "Hello! How can I assist you today?";
    } else if (lowerMessage.contains('thank')) {
      return "You're welcome! Is there anything else I can help you with?";
    } else {
      return "I understand. Let me connect you with one of our support specialists who can better assist you with this.";
    }
  }

  /// Handle quick action button tap
  void onQuickActionTap(String action) {
    String message = '';
    switch (action) {
      case 'recommendation':
        message = "I'd like a recommendation";
        break;
      case 'order':
        message = "I need help with my order";
        break;
      case 'product':
        message = "I have a question about a product";
        break;
    }

    if (message.isNotEmpty) {
      messageController.text = message;
      sendMessage();
    }
  }

  @override
  void onClose() {
    messageController.dispose();
    super.onClose();
  }
}

/// Chat Message Model
class ChatMessage {
  final String text;
  final bool isBot;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isBot,
    required this.timestamp,
  });
}


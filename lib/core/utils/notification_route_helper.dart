import 'package:get/get.dart';

import '../models/notification_list_response_model.dart';
import '../routes/app_routes.dart';

/// Shared helper for navigating from notification payload (in-app list or push).
/// Uses [appRoute] and IDs from [data] / [query] per allowed query keys.
class NotificationRouteHelper {
  NotificationRouteHelper._();

  /// Build route arguments from [NotificationData] query.
  static Map<String, dynamic> buildArgumentsFromNotification(NotificationData item) {
    final q = item.query;
    if (q == null) return {};
    return {
      if (_str(q.orderId) != null) 'orderId': _str(q.orderId),
      if (_str(q.productId) != null) 'productId': _str(q.productId),
      if (_str(q.subscriptionId) != null) 'subscriptionId': _str(q.subscriptionId),
      if (_str(q.membershipId) != null) 'membershipId': _str(q.membershipId),
      if (_str(q.ticketId) != null) 'ticketId': _str(q.ticketId),
      if (_str(q.quizSessionId) != null) 'quizSessionId': _str(q.quizSessionId),
      if (_str(q.expertId) != null) 'expertId': _str(q.expertId),
    };
  }

  static String? _str(String? value) {
    if (value == null || value.isEmpty) return null;
    return value;
  }

  /// Navigate by [appRoute] with [arguments]. Use after [buildArgumentsFromNotification].
  static void navigateByAppRoute(String appRoute, Map<String, dynamic> arguments) {
    final route = appRoute.startsWith('/') ? appRoute : '/$appRoute';

    try {
      switch (route) {
        case '/dashboard':
          if (arguments['tab'] != null) {
            Get.toNamed(AppRoutes.dashboard, arguments: {'tab': arguments['tab']});
          } else {
            Get.offAllNamed(AppRoutes.dashboard);
          }
          break;

        case '/product-detail':
          if (arguments['productId'] != null &&
              arguments['productId'].toString().isNotEmpty) {
            Get.toNamed(
              AppRoutes.productDetail,
              arguments: {'productId': arguments['productId']},
            );
          } else {
            Get.offAllNamed(AppRoutes.dashboard);
          }
          break;

        case '/orderDetail':
          if (arguments['orderId'] != null &&
              arguments['orderId'].toString().isNotEmpty) {
            Get.toNamed(
              AppRoutes.orderDetail,
              arguments: {'orderId': arguments['orderId']},
            );
          } else {
            Get.toNamed(AppRoutes.myOrder);
          }
          break;

        case '/subscription':
          if (arguments['subscriptionId'] != null &&
              arguments['subscriptionId'].toString().isNotEmpty) {
            Get.toNamed(
              AppRoutes.subscription,
              arguments: {'subscriptionId': arguments['subscriptionId']},
            );
          } else {
            Get.toNamed(AppRoutes.subscription);
          }
          break;

        case '/membership':
          if (arguments['membershipId'] != null &&
              arguments['membershipId'].toString().isNotEmpty) {
            Get.toNamed(
              AppRoutes.membership,
              arguments: {'membershipId': arguments['membershipId']},
            );
          } else {
            Get.toNamed(AppRoutes.membership);
          }
          break;

        case '/support':
          if (arguments['ticketId'] != null &&
              arguments['ticketId'].toString().isNotEmpty) {
            Get.toNamed(
              AppRoutes.support,
              arguments: {'ticketId': arguments['ticketId']},
            );
          } else {
            Get.toNamed(AppRoutes.support);
          }
          break;

        case '/ai-chat':
          final quizSessionId = arguments['quizSessionId']?.toString();
          final expertId = arguments['expertId']?.toString();
          if ((quizSessionId != null && quizSessionId.isNotEmpty) ||
              (expertId != null && expertId.isNotEmpty)) {
            Get.toNamed(AppRoutes.aiChat, arguments: {
              if (quizSessionId != null && quizSessionId.isNotEmpty)
                'quizSessionId': quizSessionId,
              if (expertId != null && expertId.isNotEmpty) 'expertId': expertId,
            });
          } else {
            Get.toNamed(AppRoutes.aiChat);
          }
          break;

        case '/notification':
          Get.toNamed(AppRoutes.notification);
          break;

        case '/cart':
          Get.toNamed(AppRoutes.dashboard, arguments: {'tab': 2});
          break;

        default:
          Get.offAllNamed(AppRoutes.dashboard);
      }
    } catch (e) {
      Get.offAllNamed(AppRoutes.dashboard);
    }
  }

  /// Build arguments and navigate for a notification item (used from list tap).
  static void onNotificationTap(NotificationData item) {
    final appRoute = item.appRoute ?? '/dashboard';
    final args = buildArgumentsFromNotification(item);
    navigateByAppRoute(appRoute, args);
  }
}

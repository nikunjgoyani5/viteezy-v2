import 'dart:convert';
import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import '../models/notification_list_response_model.dart';
import '../repositories/profile_repository.dart';
import '../routes/app_routes.dart';
import 'package:viteezy/presentation/main/dashboard/controllers/dashboard_controller.dart';
import '../utils/app_constant.dart';
import '../utils/app_prefrence.dart';

/// OneSignal push notification service.
/// Handles notifications in foreground, background, killed, and open states.
/// Performs click redirection using payload [appRoute] and IDs from [data] / [query]
/// according to allowed query keys: orderId, productId, subscriptionId, membershipId,
/// ticketId, quizSessionId, expertId.
class OneSignalNotificationService {
  OneSignalNotificationService._();
  static final OneSignalNotificationService _instance = OneSignalNotificationService._();
  static OneSignalNotificationService get instance => _instance;

  bool _initialized = false;
  bool get isInitialized => _initialized;

  /// Pending notification when app launched from killed state (cold start).
  /// Flow: Splash → Dashboard → then navigate to target screen.
  static NotificationData? _pendingNotification;

  /// Initialize OneSignal. Call once from main.dart after WidgetsFlutterBinding.
  static Future<void> initialize({String? oneSignalAppId}) async {
    final appId = oneSignalAppId ?? oneSignalAppIdConstant;
    if (appId.isEmpty || appId == 'YOUR_ONESIGNAL_APP_ID') {
      log(
        'OneSignalNotificationService: OneSignal App ID not set. Set oneSignalAppId in app_constant.dart or pass it here.',
      );
      return;
    }

    if (_instance._initialized) {
      log('OneSignalNotificationService: Already initialized.');
      return;
    }

    try {
      OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

      OneSignal.initialize(appId);

      _setupForegroundDisplayListener();
      _setupNotificationClickListener();
      _setupOneSignalIdAndSubscription();

      await OneSignal.Notifications.requestPermission(false);

      _instance._initialized = true;
      log('OneSignalNotificationService: Initialized successfully.');
    } catch (e, st) {
      log('OneSignalNotificationService: Initialization error: $e');
      log('Stack trace: $st');
    }
  }

  static String get oneSignalAppIdConstant => oneSignalAppId;

  static void _setupForegroundDisplayListener() {
    OneSignal.Notifications.addForegroundWillDisplayListener((OSNotificationWillDisplayEvent event) {
      event.notification.display();
    });
  }

  static void _setupNotificationClickListener() {
    OneSignal.Notifications.addClickListener((OSNotificationClickEvent event) {
      _handleNotificationClick(event.notification);
    });
  }

  /// Fetches OneSignal ID (UUID), stores in Pref, opts in to push, observes subscription id,
  /// and registers device token with backend only when push subscription is active (so backend
  /// gets a player ID that can receive notifications; avoids "0 recipients" from OneSignal).
  static void _setupOneSignalIdAndSubscription() {
    OneSignal.User.getOnesignalId().then((String? onSignalId) {
      final id = onSignalId ?? '';
      if (id.isNotEmpty) {
        PrefService.setValue(PrefKeys.oneSignalId, id);
        log('One === $id');
      }
    });
    OneSignal.User.pushSubscription.optIn();
    OneSignal.User.pushSubscription.addObserver((state) {
      final subscriptionId = OneSignal.User.pushSubscription.id ?? '';
      final optedIn = OneSignal.User.pushSubscription.optedIn ?? false;
      if (subscriptionId.isNotEmpty) {
        PrefService.setValue(PrefKeys.oneSignalSubscriptionId, subscriptionId);
        log('One sub id : ${OneSignal.User.pushSubscription.id}');
        // Only register with backend when user is subscribed to push (opted in),
        // so the player ID is active and can receive notifications.
        if (optedIn) {
          _registerDeviceTokenIfLoggedIn(subscriptionId);
        }
      }
    });
  }

  static void _registerDeviceTokenIfLoggedIn(String deviceToken) {
    if (PrefService.getString(PrefKeys.accessToken).isEmpty) return;
    ProfileRepository().registerDeviceToken(deviceToken: deviceToken, platform: 'Mobile', onError: (_) {});
  }

  /// OneSignal may send [query] as a JSON string. Convert to Map for model parsing.
  static Map<String, dynamic> _normalizePayload(Map<String, dynamic> raw) {
    final map = Map<String, dynamic>.from(raw);
    final query = map['query'];
    if (query is String && query.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(query);
        if (decoded is Map) {
          map['query'] = Map<String, dynamic>.from(decoded);
        }
      } catch (_) {}
    }
    return map;
  }

  /// Handle notification tap. Parses payload into [NotificationData], then redirects
  /// using [appRoute] and IDs from [query]. When app is killed: stores pending for Splash → Dashboard → target flow.
  static void _handleNotificationClick(OSNotification? notification) {
    if (notification == null) return;

    final additionalData = notification.additionalData;
    if (additionalData == null || additionalData.isEmpty) {
      _scheduleNavigateOrStorePending(NotificationData(appRoute: '/dashboard'));
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final payloadMap = _normalizePayload(Map<String, dynamic>.from(additionalData));
        final notificationData = NotificationData.fromJson(payloadMap);
        _scheduleNavigateOrStorePending(notificationData);
      } catch (_) {
        _scheduleNavigateOrStorePending(NotificationData(appRoute: '/dashboard'));
      }
    });
  }

  /// When app is on splash (cold start from killed state), store pending and let Splash → Dashboard flow complete.
  /// Otherwise navigate immediately.
  static void _scheduleNavigateOrStorePending(NotificationData data) {
    final currentRoute = Get.currentRoute;
    final isOnSplash =
        currentRoute.isEmpty ||
        currentRoute == '/' ||
        currentRoute == AppRoutes.initial ||
        currentRoute.contains('splash');

    if (isOnSplash) {
      _pendingNotification = data;
      log('OneSignalNotificationService: Cold start - stored pending navigation to ${data.appRoute}');
      return;
    }

    _navigateByAppRoute(data);
  }

  /// Call from DashboardController.onReady after splash → dashboard flow.
  /// If a notification launched the app from killed state, navigates to the target screen.
  static void handlePendingNotificationIfAny() {
    final data = _pendingNotification;
    if (data != null) {
      _pendingNotification = null;
      log('OneSignalNotificationService: Handling pending navigation to ${data.appRoute}');
      _navigateByAppRoute(data);
    }
  }

  static String? _str(dynamic value) {
    if (value == null) return null;
    if (value is String) return value.isEmpty ? null : value;
    final s = value.toString();
    return s.isEmpty ? null : s;
  }

  /// Returns true if the target screen with same arguments is already displayed.
  /// Avoids opening duplicate screens when app is already open.
  static bool _isTargetScreenAlreadyOpen(String route, Map<String, dynamic> arguments) {
    try {
      final currentRoute = Get.currentRoute;
      if (currentRoute.isEmpty) return false;

      final targetPath = route.startsWith('/') ? route : '/$route';
      final currentPath = currentRoute.split('?').first;
      final targetName = targetPath.replaceAll('/', '');

      // Match current route to target (handles /orderDetail, orderDetail, dashboard, etc.)
      final isSameRoute =
          currentPath == targetPath || currentPath.endsWith(targetPath) || currentPath.contains(targetName);

      if (!isSameRoute) return false;

      final currentArgs = Get.arguments;
      if (currentArgs == null || currentArgs is! Map) {
        return targetPath == '/dashboard' || targetPath == '/notification' || targetPath == '/cart';
      }

      final currentArgsMap = Map<String, dynamic>.from(Map.from(currentArgs));

      switch (targetPath) {
        case '/dashboard':
        case '/cart':
          final targetTab = arguments['tab'] ?? (targetPath == '/cart' ? 2 : null);
          final currentTab = currentArgsMap['tab'];
          return targetTab == null || currentTab == targetTab;
        case '/product-detail':
          return _strEquals(currentArgsMap['productId'], arguments['productId']);
        case '/orderDetail':
          return _strEquals(currentArgsMap['orderId'], arguments['orderId']);
        case '/subscription':
          return _strEquals(currentArgsMap['subscriptionId'], arguments['subscriptionId']);
        case '/membership':
          return _strEquals(currentArgsMap['membershipId'], arguments['membershipId']);
        case '/support':
          return _strEquals(currentArgsMap['ticketId'], arguments['ticketId']);
        case '/ai-chat':
          final qMatch = _strEquals(currentArgsMap['quizSessionId'], arguments['quizSessionId']);
          final eMatch = _strEquals(currentArgsMap['expertId'], arguments['expertId']);
          final bothEmpty =
              (arguments['quizSessionId']?.toString().trim().isEmpty ?? true) &&
              (arguments['expertId']?.toString().trim().isEmpty ?? true);
          return (bothEmpty && currentPath.contains('ai-chat')) || qMatch || eMatch;
        case '/notification':
          return true;
        default:
          return false;
      }
    } catch (_) {
      return false;
    }
  }

  static bool _strEquals(dynamic a, dynamic b) {
    final sa = a?.toString().trim() ?? '';
    final sb = b?.toString().trim() ?? '';
    if (sa.isEmpty && sb.isEmpty) return true;
    return sa.isNotEmpty && sb.isNotEmpty && sa == sb;
  }

  /// Returns true if the current route is the dashboard (or a child route like Home).
  /// Used to avoid Get.offNamed/Get.offAllNamed when already on dashboard, which
  /// would dispose TabController and cause TabBar paint errors.
  static bool _isCurrentlyOnDashboard() {
    try {
      final r = Get.currentRoute;
      if (r.isEmpty) return false;
      final path = r.split('?').first;
      return path == AppRoutes.dashboard || path.endsWith(AppRoutes.dashboard) || path.contains('dashboard');
    } catch (_) {
      return false;
    }
  }

  /// Switches to a dashboard tab without replacing the route (avoids TabController disposal).
  /// Returns true if the tab was switched; false if we must use Get.offAllNamed.
  static bool _trySwitchDashboardTab(int tab) {
    if (tab < 0 || tab > 4) return false;
    if (!Get.isRegistered<DashboardController>()) return false;
    try {
      if (_isCurrentlyOnDashboard()) {
        Get.find<DashboardController>().changeBottomNav(tab);
        return true;
      }
    } catch (_) {}
    return false;
  }

  /// Extract route arguments map from [NotificationData.query].
  static Map<String, dynamic> _getArgsFromModel(NotificationData data) {
    final q = data.query;
    if (q == null) return {};
    return {
      if (_str(q.orderId) != null) 'orderId': _str(q.orderId)!,
      if (_str(q.productId) != null) 'productId': _str(q.productId)!,
      if (_str(q.subscriptionId) != null) 'subscriptionId': _str(q.subscriptionId)!,
      if (_str(q.membershipId) != null) 'membershipId': _str(q.membershipId)!,
      if (_str(q.ticketId) != null) 'ticketId': _str(q.ticketId)!,
      if (_str(q.quizSessionId) != null) 'quizSessionId': _str(q.quizSessionId)!,
      if (_str(q.expertId) != null) 'expertId': _str(q.expertId)!,
    };
  }

  /// Navigate using [NotificationData] model. Extracts appRoute and query from model.
  static void _navigateByAppRoute(NotificationData data) {
    final rawRoute = data.appRoute?.toString().trim() ?? '';
    final appRoute = rawRoute.isEmpty ? '/dashboard' : (rawRoute.startsWith('/') ? rawRoute : '/$rawRoute');
    final arguments = _getArgsFromModel(data);

    try {
      if (_isTargetScreenAlreadyOpen(appRoute, arguments)) {
        log('OneSignalNotificationService: Target screen already open, skipping navigation.');
        return;
      }

      switch (appRoute) {
        case '/dashboard':
          {
            final tab = arguments['tab'] is int ? arguments['tab'] as int : 0;
            if (_trySwitchDashboardTab(tab)) return;
            if (arguments['tab'] != null) {
              Get.offAllNamed(AppRoutes.dashboard, arguments: {'tab': arguments['tab']});
            } else {
              Get.offAllNamed(AppRoutes.dashboard);
            }
            break;
          }

        case '/product-detail':
          final productId = data.query?.productId ?? arguments['productId'];
          if (productId != null && productId.toString().trim().isNotEmpty) {
            Get.toNamed(AppRoutes.productDetail, arguments: {'productId': productId.toString().trim()});
          } else {
            Get.offAllNamed(AppRoutes.dashboard);
          }
          break;

        case '/orderDetail':
          final orderId = data.query?.orderId ?? arguments['orderId'];
          if (orderId != null && orderId.toString().trim().isNotEmpty) {
            Get.toNamed(AppRoutes.orderDetail, arguments: {'orderId': orderId.toString().trim()});
          } else {
            Get.toNamed(AppRoutes.myOrder);
          }
          break;

        case '/subscription':
          final subscriptionId = data.query?.subscriptionId ?? arguments['subscriptionId'];
          if (subscriptionId != null && subscriptionId.toString().trim().isNotEmpty) {
            Get.toNamed(AppRoutes.subscription, arguments: {'subscriptionId': subscriptionId.toString().trim()});
          } else {
            Get.toNamed(AppRoutes.subscription);
          }
          break;

        case '/membership':
          final membershipId = data.query?.membershipId ?? arguments['membershipId'];
          if (membershipId != null && membershipId.toString().trim().isNotEmpty) {
            Get.toNamed(AppRoutes.membership, arguments: {'membershipId': membershipId.toString().trim()});
          } else {
            Get.toNamed(AppRoutes.membership);
          }
          break;

        case '/support':
          final ticketId = data.query?.ticketId ?? arguments['ticketId'];
          if (ticketId != null && ticketId.toString().trim().isNotEmpty) {
            Get.toNamed(AppRoutes.support, arguments: {'ticketId': ticketId.toString().trim()});
          } else {
            Get.toNamed(AppRoutes.support);
          }
          break;

        case '/ai-chat':
          final quizSessionId = data.query?.quizSessionId ?? arguments['quizSessionId'];
          final expertId = data.query?.expertId ?? arguments['expertId'];
          final q = _str(quizSessionId);
          final e = _str(expertId);
          if ((q != null && q.isNotEmpty) || (e != null && e.isNotEmpty)) {
            Get.toNamed(
              AppRoutes.aiChat,
              arguments: {
                if (q != null && q.isNotEmpty) 'quizSessionId': q,
                if (e != null && e.isNotEmpty) 'expertId': e,
              },
            );
          } else {
            Get.toNamed(AppRoutes.aiChat);
          }
          break;

        case '/notification':
          Get.toNamed(AppRoutes.notification);
          break;

        case '/cart':
          if (_trySwitchDashboardTab(2)) return;
          Get.offAllNamed(AppRoutes.dashboard, arguments: {'tab': 2});
          break;

        default:
          Get.offAllNamed(AppRoutes.dashboard);
      }
    } catch (e) {
      log('OneSignalNotificationService: Navigation error to $appRoute: $e');
      Get.offAllNamed(AppRoutes.dashboard);
    }
  }

  static Future<void> setExternalUserId(String? externalUserId) async {
    if (!_instance._initialized) return;
    try {
      if (externalUserId != null && externalUserId.isNotEmpty) {
        OneSignal.login(externalUserId);
      } else {
        OneSignal.logout();
      }
    } catch (e) {
      log('OneSignalNotificationService: setExternalUserId error: $e');
    }
  }

  static Future<bool> requestPermission({bool fallbackToSettings = false}) async {
    if (!_instance._initialized) return false;
    try {
      return await OneSignal.Notifications.requestPermission(fallbackToSettings);
    } catch (e) {
      log('OneSignalNotificationService: requestPermission error: $e');
      return false;
    }
  }

  /// Returns the OneSignal player ID (UUID) for sending to backend. Uses stored oneSignalId
  /// or oneSignalSubscriptionId to avoid sending FCM token (backend expects UUID).
  static String getDeviceToken() {
    if (!_instance._initialized) return '';
    try {
      final oneSignalId = PrefService.getString(PrefKeys.oneSignalId);
      if (oneSignalId.isNotEmpty) return oneSignalId;
      final subscriptionId = PrefService.getString(PrefKeys.oneSignalSubscriptionId);
      if (subscriptionId.isNotEmpty) return subscriptionId;
      final id = OneSignal.User.pushSubscription.id;
      if (id != null && id.isNotEmpty) return id;
    } catch (e) {
      log('OneSignalNotificationService: getDeviceToken error: $e');
    }
    return '';
  }

  /// Call after login so backend gets the current player ID for the logged-in user.
  /// Only sends if user is subscribed to push (opted in), so backend receives a valid recipient.
  static void registerDeviceTokenWithBackendIfLoggedIn() {
    if (!_instance._initialized) return;
    if (PrefService.getString(PrefKeys.accessToken).isEmpty) return;
    try {
      final optedIn = OneSignal.User.pushSubscription.optedIn ?? false;
      if (!optedIn) return;
      final subscriptionId =
          OneSignal.User.pushSubscription.id ?? PrefService.getString(PrefKeys.oneSignalSubscriptionId);
      if (subscriptionId.isEmpty) return;
      _registerDeviceTokenIfLoggedIn(subscriptionId);
    } catch (e) {
      log('OneSignalNotificationService: registerDeviceTokenWithBackendIfLoggedIn error: $e');
    }
  }
}

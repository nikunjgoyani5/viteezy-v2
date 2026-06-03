import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:viteezy/core/services/global_settings_service.dart';
import 'package:viteezy/core/services/cart_count_service.dart';
import 'package:viteezy/core/services/language_data_refresh_service.dart';
import 'package:viteezy/core/services/pending_action_service.dart';
import 'package:viteezy/core/services/onesignal_notification_service.dart';
import 'package:viteezy/core/services/remote_config_service.dart';
import 'package:viteezy/core/utils/app_prefrence.dart';
import 'package:viteezy/core/widgets/app_root.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await RemoteConfigService.initialize();
  await PrefService.init();
  await OneSignalNotificationService.initialize();
  // Lock orientation to portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  initServices();
  runApp(const AppRoot());
}

void initServices() {
  // Initialize GlobalSettingsService as permanent singleton
  Get.put(GlobalSettingsService(), permanent: true);
  // Initialize CartCountService as permanent singleton
  Get.put(CartCountService(), permanent: true);
  // Initialize PendingActionService as permanent singleton
  Get.put(PendingActionService(), permanent: true);
  // Refresh language-dependent data after locale change
  Get.put(LanguageDataRefreshService(), permanent: true);
}

// Lock orientation when app is disposed (optional, but good practice)
class OrientationLock {
  static Future<void> lockPortrait() async {
    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  }

  static Future<void> unlock() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }
}

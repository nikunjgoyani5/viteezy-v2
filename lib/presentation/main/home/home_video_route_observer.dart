import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controllers/home_controller.dart';

/// Pauses the home video when a new route is pushed (user navigates to another screen).
class HomeVideoRouteObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().pauseVideoWhenLeavingHome();
    }
  }
}

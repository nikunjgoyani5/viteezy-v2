import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:viteezy/core/theme/app_colors.dart';
import 'package:viteezy/gen/assets.gen.dart';

import '../controllers/splash_controller.dart';

class SplashScreen extends GetView<SplashController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Assets.animations.splashAnimation.lottie(
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.fill, // fills screen, may crop
          alignment: Alignment.center,
          repeat: false,
        ),
      ),
    );
  }
}

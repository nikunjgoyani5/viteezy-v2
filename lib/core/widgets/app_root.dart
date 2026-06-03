import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:viteezy/core/l10n/app_translations.dart';
import 'package:viteezy/core/l10n/locale_service.dart';
import 'package:viteezy/core/routes/app_pages.dart';
import 'package:viteezy/core/routes/app_routes.dart';
import 'package:viteezy/core/services/remote_config_service.dart';
import 'package:viteezy/core/theme/app_theme.dart';
import 'package:viteezy/presentation/main/home/home_video_route_observer.dart';
import 'package:viteezy/presentation/onboard/app_locked/app_locked_screen.dart';

/// Root widget that decides which shell to show. Access control is enforced here.
class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    final allowAccess = _resolveAccess();
    return allowAccess ? const _MainShell() : const _LockedShell();
  }

  /// Access only when Remote Config [app_license_key] matches the app's built-in key.
  static bool _resolveAccess() {
    return RemoteConfigService.hasValidLicenseKey;
  }
}

class _LockedShell extends StatelessWidget {
  const _LockedShell();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Viteezy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AppLockedScreen(),
    );
  }
}

class _MainShell extends StatelessWidget {
  const _MainShell();

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: false,
      builder: (context, child) {
        return SafeArea(
          bottom: true,
          top: false,
          child: GetMaterialApp(
            title: 'Viteezy',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.light,
            initialRoute: AppRoutes.initial,
            getPages: AppPages.pages,
            navigatorObservers: [HomeVideoRouteObserver()],
            defaultTransition: Transition.cupertino,
            transitionDuration: const Duration(milliseconds: 300),
            translations: AppTranslations(),
            locale: LocaleService.getInitialLocale(),
            fallbackLocale: LocaleService.fallbackLocale,
          ),
        );
      },
    );
  }
}

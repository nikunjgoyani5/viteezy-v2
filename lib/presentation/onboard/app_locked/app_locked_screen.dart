import 'package:flutter/material.dart';
import 'package:viteezy/core/theme/app_colors.dart';

/// Full-screen lock screen shown when Remote Config flag [app_restricted] is true.
/// No navigation, no back, no way to access the app — restriction is enforced at root.
class AppLockedScreen extends StatelessWidget {
  const AppLockedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock_outline_rounded,
                    size: 80,
                    color: AppColors.primaryColor,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'App temporarily unavailable',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Please try again later.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.grey6A6A6A,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import '../utils/exports.dart';
import 'custom_button.dart';

/// Error Widget - Reusable error display with retry option
class ErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final String? retryText;

  const ErrorWidget({super.key, required this.message, this.onRetry, this.retryText});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: AppColors.errorColor),
            const SizedBox(height: 16),
            Text('error_oops'.tr, style: TextStyles.bold(24.sp), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyles.regular(14.sp, fontColor: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              CustomButton(text: retryText ?? 'Retry', onPressed: onRetry, icon: Icons.refresh),
            ],
          ],
        ),
      ),
    );
  }
}

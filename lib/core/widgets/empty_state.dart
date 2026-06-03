import '../utils/exports.dart';

/// Empty State Widget - Reusable empty state display
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final String? buttonText;
  final VoidCallback? onButtonPressed;
  final Color? iconColor;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.buttonText,
    this.onButtonPressed,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 100, color: iconColor ?? AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(title, style: TextStyles.bold(24.sp), textAlign: TextAlign.center),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                style: TextStyles.regular(14.sp, fontColor: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
            if (buttonText != null && onButtonPressed != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(onPressed: onButtonPressed, child: Text(buttonText!)),
            ],
          ],
        ),
      ),
    );
  }
}

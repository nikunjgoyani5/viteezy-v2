import '../utils/exports.dart';

/// Custom Card Widget - Reusable card with consistent styling
class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? color;
  final double? elevation;
  final BorderRadius? borderRadius;

  const CustomCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.color,
    this.elevation,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final card = Card(
      elevation: elevation ?? 2,
      color: color ?? AppColors.surfaceColor,
      shape: RoundedRectangleBorder(borderRadius: borderRadius ?? BorderRadius.circular(12)),
      margin: margin ?? EdgeInsets.zero,
      child: padding != null ? Padding(padding: padding!, child: child) : child,
    );

    if (onTap != null) {
      return InkWell(onTap: onTap, borderRadius: borderRadius ?? BorderRadius.circular(12), child: card);
    }

    return card;
  }
}

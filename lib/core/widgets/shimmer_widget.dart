import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Common Shimmer Widget
/// Wraps any child widget with shimmer effect
class ShimmerWidget extends StatelessWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration? period;

  const ShimmerWidget({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
    this.period,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: baseColor ?? Colors.grey.shade300,
      highlightColor: highlightColor ?? Colors.grey.shade100,
      period: period ?? const Duration(milliseconds: 1500),
      child: child,
    );
  }
}


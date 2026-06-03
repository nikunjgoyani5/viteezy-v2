import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'dart:math' as math;
import 'package:viteezy/core/theme/app_colors.dart';
import 'package:viteezy/core/theme/text_styles.dart';

/// Discount Progress Bar Widget
/// Shows progress based on product count: 1, 2, or 3+ products
class DiscountProgressBar extends StatelessWidget {
  final dynamic controller; // CartController

  const DiscountProgressBar({super.key, required this.controller});

  int get totalProducts => controller.cartData.value?.cart?.items?.fold(0, (sum, item) => sum + item.effectiveQuantity) ?? 0;

  // Get current status: 0 = start, 1 = 1 product, 2 = 2 products, 3 = 3+ products
  int _getCurrentStatus(int totalProducts) {
    if (totalProducts >= 3) return 3;
    if (totalProducts >= 2) return 2;
    if (totalProducts >= 1) return 1;
    return 0;
  }

  // Calculate progress fill: 0.0 to 1.0
  // Status 1: Line fills to center (0.5)
  // Status 2: Line fills to center (0.5) with center circle half-filled
  // Status 3: Line fills to end (1.0) with all circles filled
  double _getProgressFill(int totalProducts) {
    final currentStatus = _getCurrentStatus(totalProducts);
    if (currentStatus >= 3) return 1.0; // Full fill
    if (currentStatus >= 2) return 0.5; // Half fill to center
    if (currentStatus >= 1) return 0.5; // Half fill to center
    return 0.0; // No fill
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Access the observable directly in the Obx builder
      final totalProducts = controller.totalProducts;
      return _buildProgressBarContent(totalProducts);
    });
  }

  Widget _buildProgressBarContent(int totalProducts) {
    return Container(
      padding: EdgeInsets.only(left: 16.w, right: 16.w, top: 20.h, bottom: 5.h),
      decoration: BoxDecoration(
        color: AppColors.offWhite, // Light beige background
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final trackWidth = constraints.maxWidth;
          final startPosition = 0.0;
          final centerPosition = trackWidth * 0.5; // 50% position (10% off marker)
          final endPosition = trackWidth; // 100% position (50% off marker)
          final currentStatus = _getCurrentStatus(totalProducts);
          final progressFill = _getProgressFill(totalProducts);

          return Column(
            children: [
              // Progress Bar with Handles
              Stack(
                clipBehavior: Clip.none,
                children: [
                  // Background track (white, no border initially)
                  Container(
                    height: 8.h,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4.r)),
                  ),
                  // Progress fill (teal-to-green gradient) - only shows when progress > 0, no border
                  if (progressFill > 0)
                    FractionallySizedBox(
                      widthFactor: progressFill,
                      child: Container(
                        height: 8.h,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primaryColor, // Teal
                              Color(0xFF4CAF50), // Green
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(4.r),
                            bottomLeft: Radius.circular(4.r),
                          ),
                        ),
                      ),
                    ),
                  // Border only on the unfilled portion (right side) - connects with circle border
                  // No border when fully filled (progressFill == 1.0)
                  if (progressFill < 1.0 && currentStatus < 3)
                    CustomPaint(
                      painter: _ProgressLineBorderPainter(
                        borderColor: AppColors.yellowF0EFE4,
                        fillStart: progressFill * trackWidth,
                        lineHeight: 8.h,
                        lineWidth: trackWidth,
                      ),
                      size: Size(trackWidth, 8.h),
                    ),
                  // Start circle (always filled with starting color of gradient - teal)
                  Positioned(
                    left: startPosition - 8.w,
                    top: -4.h,
                    child: Container(
                      width: 16.w,
                      height: 16.w,
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor, // Teal - starting color of gradient
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  // Center circle (half-filled when status is 2, fully filled when status >= 3)
                  Positioned(left: centerPosition - 8.w, top: -4.h, child: _buildCenterCircle(currentStatus)),
                  // End circle (filled when status is 3 with gradient, no border when filled)
                  Positioned(
                    left: endPosition - 8.w,
                    top: -5.h,
                    child: Container(
                      width: 18.w,
                      height: 18.w,
                      decoration: BoxDecoration(
                        gradient: currentStatus >= 3
                            ? LinearGradient(
                                colors: [
                                  AppColors.primaryColor, // Teal
                                  Color(0xFF4CAF50), // Green
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        color: currentStatus >= 3 ? null : Colors.white,
                        shape: BoxShape.circle,
                        border: currentStatus >= 3
                            ? null
                            : Border(
                                right: BorderSide(color: AppColors.yellowF0EFE4, width: 2),
                                top: BorderSide(color: AppColors.yellowF0EFE4, width: 2),
                                bottom: BorderSide(color: AppColors.yellowF0EFE4, width: 2),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
              Gap(8.h),
              // Labels aligned with circles - centered under each circle
              SizedBox(
                height: 40.h, // Define height for the Stack
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Start label - centered under start circle (circle center at startPosition = 0)
                    Positioned(
                      top: 8.h,
                      left: startPosition - 20.w, // Center the text under the circle
                      child: SizedBox(
                        width: 50.w,
                        child: Center(
                          child: Text('discount_start'.tr, style: TextStyles.medium(12.sp, fontColor: AppColors.black1414141)),
                        ),
                      ),
                    ),
                    // 10% off label - centered under center circle (circle center at centerPosition)
                    Positioned(
                      top: 4.h,
                      left: centerPosition - 40.w, // Center the text under the circle
                      child: SizedBox(
                        width: 80.w,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('discount_10_off'.tr, style: TextStyles.medium(12.sp, fontColor: AppColors.black1414141)),
                              Text('discount_2_products'.tr, style: TextStyles.medium(12.sp, fontColor: AppColors.black1414141)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // 50% off label - right-aligned under end circle (circle center at endPosition)
                    Positioned(
                      left: endPosition - 55.w,
                      top: 4.h,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('discount_50_off'.tr, style: TextStyles.medium(12.sp, fontColor: AppColors.black1414141)),
                          Text('discount_3_products'.tr, style: TextStyles.medium(12.sp, fontColor: AppColors.black1414141)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Build center circle with half-fill when status is 2
  Widget _buildCenterCircle(int currentStatus) {
    if (currentStatus >= 3) {
      // Fully filled with gradient
      return Container(
        width: 16.w,
        height: 16.w,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryColor, // Teal
              Color(0xFF4CAF50), // Green
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
        ),
      );
    } else if (currentStatus == 2) {
      // Half-filled - left half with gradient (no border), right half white with border only on curved edge
      // Border connects seamlessly with the progress line border
      return Container(
        width: 16.w,
        height: 16.w,
        decoration: BoxDecoration(shape: BoxShape.circle),
        child: Stack(
          children: [
            // Filled half (left side with gradient) - no border
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 8.w,
              child: ClipRRect(
                borderRadius: BorderRadius.only(topLeft: Radius.circular(8.w), bottomLeft: Radius.circular(8.w)),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryColor, // Teal
                        Color(0xFF4CAF50), // Green
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
              ),
            ),
            // White background (right half - unfilled) with border only on curved edge
            // The border connects seamlessly with the progress line border
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              right: 0,
              child: ClipOval(
                child: Stack(
                  children: [
                    // Full white circle background
                    Container(width: 16.w, height: 16.w, color: Colors.white),
                    // Left half gradient overlay (covers the white on left, no border)
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      width: 8.w,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primaryColor, // Teal
                              Color(0xFF4CAF50), // Green
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                      ),
                    ),
                    // Border only on right half curved edge (top and bottom arcs, and right edge)
                    // This connects seamlessly with the progress line border
                    CustomPaint(
                      painter: _HalfCircleBorderPainter(borderColor: Colors.transparent, circleSize: 16.w),
                      size: Size(16.w, 16.w),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // Not filled (white with yellow border)
      return Container(
        width: 16.w,
        height: 16.w,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.yellowF0EFE4, width: 2),
        ),
      );
    }
  }
}

/// Custom painter to draw border only on the curved edge of the right half circle
/// The border connects seamlessly with the progress line border
class _HalfCircleBorderPainter extends CustomPainter {
  final Color borderColor;
  final double circleSize;

  _HalfCircleBorderPainter({required this.borderColor, required this.circleSize});

  @override
  void paint(Canvas canvas, Size size) {
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Draw border only on the curved edge (arc) - right half of the full circle
    // Draw from top (90 degrees / π/2) to bottom (270 degrees / 3π/2)
    // This creates the border on the right curved edge that connects with the line
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Draw the right half arc (curved edge)
    canvas.drawArc(
      rect,
      math.pi / 2, // Start at top (90 degrees)
      math.pi, // Draw 180 degrees (half circle - right side)
      false,
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom painter to draw border only on the unfilled portion of the progress line
/// The border connects seamlessly with the circle border
class _ProgressLineBorderPainter extends CustomPainter {
  final Color borderColor;
  final double fillStart;
  final double lineHeight;
  final double lineWidth;

  _ProgressLineBorderPainter({
    required this.borderColor,
    required this.fillStart,
    required this.lineHeight,
    required this.lineWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Draw border on the unfilled portion (right side)
    // Top border
    canvas.drawLine(Offset(fillStart, 0), Offset(size.width, 0), borderPaint);

    // Right border
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, size.height), borderPaint);

    // Bottom border
    canvas.drawLine(Offset(fillStart, size.height), Offset(size.width, size.height), borderPaint);

    // Left border (vertical line at the fill start point)
    // This connects with the circle border when at center position
    canvas.drawLine(Offset(fillStart, 0), Offset(fillStart, size.height), borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

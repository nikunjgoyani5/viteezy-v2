import '../utils/exports.dart';

class CommonButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? color;
  final Color? textColor;
  final double? width;
  final double? height;
  final double borderRadius;
  final Color? borderColor;
  final IconData? suffixIcon;
  final double? textSize;
  final double? radius;

  const CommonButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color,
    this.textColor,
    this.width,
    this.height = 50,
    this.borderRadius = 40,
    this.borderColor,
    this.suffixIcon, this.textSize,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: width ?? Get.width,
        height: height,
        decoration: BoxDecoration(
          color: color ?? AppColors.primaryColor,
          borderRadius: BorderRadius.circular(borderRadius),

          border: Border.all(color: borderColor != null ? borderColor! : Colors.transparent),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: TextStyles.medium(textSize ??17.sp, fontColor: textColor ?? AppColors.white),
            ),
            if (suffixIcon != null) ...[Gap(8.w), Icon(suffixIcon, color: textColor ?? AppColors.white, size: 20)],
          ],
        ),
      ),
    );
  }
}

class CommonButtonWidget extends StatelessWidget {
  final Widget child;
  final VoidCallback onPressed;
  final Color? color;
  final Color? textColor;
  final double? width;
  final double? height;
  final double borderRadius;
  final Color? borderColor;
  const CommonButtonWidget({
    super.key,
    required this.child,
    required this.onPressed,
    this.color,
    this.textColor,
    this.width,
    this.height,
    this.borderRadius = 40,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: width ?? Get.width,
        height: height ?? 50.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          color: color ?? AppColors.primaryColor,
          border: Border.all(color: borderColor != null ? borderColor! : Colors.transparent),
        ),

        child: child,
      ),
    );
  }
}

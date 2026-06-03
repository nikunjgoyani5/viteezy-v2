import '../../gen/assets.gen.dart';
import '../utils/exports.dart';

class CommonAppbar extends StatelessWidget implements PreferredSizeWidget {
  const CommonAppbar({
    super.key,
    this.onLeadPress,
    required this.title,
    this.actionWidget,
    this.bgColor,
    this.showBackButton,
    this.centerTitle = false,
  });

  final VoidCallback? onLeadPress;
  final String title;
  final bool? showBackButton;
  final bool? centerTitle;
  final Color? bgColor;
  final Widget? actionWidget;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: bgColor ?? AppColors.white,
      elevation: 0,
      leading: (showBackButton ?? true)
          ? IconButton(
              onPressed: onLeadPress ?? () => Get.back(),
              icon: Image.asset(Assets.icons.icBackArrow.path, scale: 3),
              highlightColor: AppColors.transparent,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            )
          : null,
      leadingWidth: (showBackButton ?? true) ? 56.w : 0,
      foregroundColor: AppColors.black1414141,
      title: Padding(
        padding: EdgeInsets.only(left: (showBackButton ?? true) ? 4.w : 0),
        child: Text(title, style: TextStyles.medium(20.sp)),
      ),
      centerTitle: centerTitle,
      titleSpacing: 0,
      scrolledUnderElevation: 0,
      actions: [
        if (actionWidget != null) ...[
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: Center(child: actionWidget!),
          ),
        ],
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

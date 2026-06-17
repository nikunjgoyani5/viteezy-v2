import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:viteezy/core/services/cart_count_service.dart';
import 'package:viteezy/presentation/main/profile/views/profile_screen.dart';

import 'package:viteezy/core/theme/app_colors.dart';
import 'package:viteezy/core/theme/text_styles.dart';
import 'package:viteezy/core/widgets/app_drawer.dart';
import 'package:viteezy/gen/assets.gen.dart';
import '../../home/views/home_view.dart';

import '../../reminder/views/reminder_view.dart';
import '../../wishlist/views/wishlist_view.dart';
import '../../cart/views/cart_view.dart';
import '../../browse/views/browse_view.dart';
import '../controllers/dashboard_controller.dart';


/// Dashboard View
class DashboardView extends GetView<DashboardController> {
  DashboardView({super.key});

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldExit = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: Text('exit_app'.tr, style: TextStyles.semiBold(18.sp)),
            content: Text(
              'exit_confirm'.tr,
              style: TextStyles.regular(14.sp, fontColor: AppColors.black1414141),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: Text('common_no'.tr, style: TextStyles.medium(14.sp, fontColor: AppColors.primaryColor)),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: Text('common_yes'.tr, style: TextStyles.medium(14.sp, fontColor: AppColors.primaryColor)),
              ),
            ],
          ),
        );
        if (shouldExit == true) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppColors.surfaceColor,
        drawer: const AppDrawer(),
        drawerEdgeDragWidth: 20.0, // Only allow drawer to open from left edge
        body: SafeArea(
          child: Obx(
            () => IndexedStack(
              index: controller.selectedBottomNav.value,
              children: [
                HomeView(scaffoldKey: _scaffoldKey), // Bottom Nav 0: Home
                const BrowseView(), // Bottom Nav 1: Browse
                const CartView(), // Bottom Nav 2: Cart
                ReminderView(), // Bottom Nav 3: Wishlist
                const ProfileScreen(), // Bottom Nav 4: Account
              ],
            ),
          ),
        ),
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  /// Custom Bottom Navigation Bar
  Widget _buildBottomNavigationBar() {
    return Obx(
      () => SafeArea(
        top: false,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 20,
                offset: const Offset(0, -12), // negative Y = top shadow
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Assets.icons.icHome,
                label: 'nav_home'.tr,
                index: 0,
                isActive: controller.selectedBottomNav.value == 0,
              ),
              _buildNavItem(
                icon: Assets.icons.icBrowse,
                label: 'nav_browse'.tr,
                index: 1,
                isActive: controller.selectedBottomNav.value == 1,
              ),
              _buildNavItem(
                icon: Assets.icons.icCart,
                label: 'nav_cart'.tr,
                index: 2,
                isActive: controller.selectedBottomNav.value == 2,
                badgeCount: Get.isRegistered<CartCountService>() ? CartCountService.to.cartItemCount.value : 0,
              ),
              _buildNavItem(
                icon: Assets.icons.icReminder,
                label: 'reminder'.tr,
                index: 3,

                isActive: controller.selectedBottomNav.value == 3,
              ),
              _buildNavItem(
                icon: Assets.icons.icAccount,
                label: 'nav_account'.tr,
                index: 4,
                isActive: controller.selectedBottomNav.value == 4,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required dynamic icon,
    required String label,
    required int index,
    required bool isActive,
    int? badgeCount,
  }) {
    final color = isActive ? AppColors.primaryColor : AppColors.black1414141;
    final textStyle = isActive
        ? TextStyles.semiBold(10.sp, fontWeight: FontWeight.w600, fontColor: AppColors.primaryColor)
        : TextStyles.medium(10.sp, fontColor: AppColors.black1414141);

    return Expanded(
      child: _AnimatedNavItem(
        icon: icon,
        label: label,
        color: color,
        textStyle: textStyle,
        badgeCount: badgeCount,
        onTap: () => controller.changeBottomNav(index),
      ),
    );
  }
}

/// Animated Navigation Item with press animation
class _AnimatedNavItem extends StatefulWidget {
  final dynamic icon;
  final String label;
  final Color color;
  final TextStyle textStyle;
  final int? badgeCount;
  final VoidCallback onTap;

  const _AnimatedNavItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.textStyle,
    this.badgeCount,
    required this.onTap,
  });

  @override
  State<_AnimatedNavItem> createState() => _AnimatedNavItemState();
}

class _AnimatedNavItemState extends State<_AnimatedNavItem> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 150), vsync: this);
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.65,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTap() {
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _handleTap,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(bottom: 6.h, top: 6.h),
                        child: widget.icon.svg(
                          width: 18.w,
                          height: 18.w,
                          colorFilter: ColorFilter.mode(widget.color, BlendMode.srcIn),
                        ),
                      ),
                      if (widget.badgeCount != null && widget.badgeCount! > 0)
                        Positioned(
                          right: -8.w,
                          top: -8.h,
                          child: Container(
                            padding: EdgeInsets.all(4.w),
                            decoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                            constraints: BoxConstraints(minWidth: 18.w, minHeight: 18.w),
                            child: Center(
                              child: Text(
                                widget.badgeCount.toString(),
                                style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
            Text(widget.label, style: widget.textStyle),
          ],
        ),
      ),
    );
  }
}

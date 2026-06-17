import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:viteezy/core/services/global_settings_service.dart';
import 'package:viteezy/core/utils/app_prefrence.dart';
import 'package:viteezy/core/utils/dialog_service.dart';
import 'package:viteezy/core/widgets/common_network_image.dart';
import 'package:viteezy/presentation/main/profile/controllers/profile_controller.dart';

import '../../presentation/main/shop_all_view/controller/shop_all_controller.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';
import '../theme/text_styles.dart';
import '../../gen/assets.gen.dart';

/// App Drawer Widget
class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> with TickerProviderStateMixin {
  late AnimationController _profileController;
  late AnimationController _categoriesController;
  late AnimationController _socialController;

  late Animation<Offset> _profileSlideAnimation;
  late Animation<double> _profileFadeAnimation;
  final shopAllController = Get.find<ShopAllController>();

  @override
  void initState() {
    super.initState();

    // Profile animation
    _profileController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _profileSlideAnimation =
        Tween<Offset>(begin: const Offset(-0.3, 0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _profileController,
            curve: Curves.easeOutCubic,
          ),
        );
    _profileFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _profileController, curve: Curves.easeOut),
    );

    // Categories animation
    _categoriesController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Social section animation
    _socialController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Start animations with stagger
    _profileController.forward();
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _categoriesController.forward();
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _socialController.forward();
    });
  }

  @override
  void dispose() {
    _profileController.dispose();
    _categoriesController.dispose();
    _socialController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.8,
      shape: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: Colors.transparent),
      ),
      child: Container(
        decoration: BoxDecoration(color: AppColors.surfaceColor),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Section (fixed)
              _buildProfileSection(context),
              Divider(height: 2, thickness: 3, color: AppColors.offWhite),
              // Categories Section (scrollable)
              Expanded(child: _buildCategoriesSection(context)),
              Divider(height: 2, thickness: 3, color: AppColors.offWhite),
              // Social Media and Legal Section (fixed at bottom)
              _buildSocialAndLegalSection(context),
            ],
          ),
        ),
      ),
    );
  }

  /// Profile Section
  Widget _buildProfileSection(BuildContext context) {
    // Check if user is logged in
    final isLoggedIn =
        PrefService.getBool(PrefKeys.isLogin) &&
        PrefService.getString(PrefKeys.accessToken).isNotEmpty;

    ProfileController? profileController;
    if (isLoggedIn && Get.isRegistered<ProfileController>()) {
      profileController = Get.find<ProfileController>();
    }

    return SlideTransition(
      position: _profileSlideAnimation,
      child: FadeTransition(
        opacity: _profileFadeAnimation,
        child: InkWell(
          onTap: () {
            Get.back(); // Close drawer
            if (isLoggedIn) {
              Get.toNamed(AppRoutes.editProfile);
            } else {
              // Show login dialog if not logged in
              DialogService.showLoginRequiredDialog(
                message: 'drawer_please_login_profile'.tr,
                onLogin: () {
                  Get.toNamed(AppRoutes.login);
                },
              );
            }
          },
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Image or Default Icon
                isLoggedIn &&
                        profileController != null &&
                        profileController.userData.user?.profileImage != null
                    ? Container(
                        width: 60.w,
                        height: 60.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.backgroundColor,
                          border: Border.all(color: AppColors.white, width: 2),
                        ),
                        child: ClipOval(
                          child: CommonNetworkImage(
                            imageUrl:
                                profileController.userData.user?.profileImage,
                          ),
                        ),
                      )
                    : Container(
                        width: 60.w,
                        height: 60.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.backgroundColor,
                          border: Border.all(color: AppColors.white, width: 2),
                        ),
                        child: Center(
                          child: isLoggedIn && profileController != null
                              ? Text(
                                  profileController.getInitials(
                                    profileController
                                            .userData
                                            .user
                                            ?.firstName ??
                                        '',
                                    profileController.userData.user?.lastName ??
                                        "",
                                  ),
                                  style: TextStyles.bold(24.sp),
                                )
                              : Icon(
                                  Icons.person_outline,
                                  size: 30.sp,
                                  color: AppColors.textSecondary,
                                ),
                        ),
                      ),
                SizedBox(height: 10.h),
                // Name and Username
                Text(
                  isLoggedIn && profileController != null
                      ? "${profileController.userData.user?.firstName ?? ''} ${profileController.userData.user?.lastName ?? ''}"
                            .trim()
                      : 'profile_guest_user'.tr,
                  style: TextStyles.bold(
                    18.sp,
                    fontColor: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  isLoggedIn && profileController != null
                      ? profileController.userData.user?.email ?? ''
                      : 'drawer_login_to_access'.tr,
                  style: TextStyles.regular(
                    14.sp,
                    fontColor: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Categories Section
  Widget _buildCategoriesSection(BuildContext context) {
    // final categories = [
    //   {'name': 'All Products', 'image': Assets.images.imgDrawerCat1.path},
    //   {'name': 'Spices', 'image': Assets.images.imgDrawerCat2.path},
    //   {'name': 'Minerals', 'image': Assets.images.imgDrawerCat3.path},
    //   {'name': 'Specialties', 'image': Assets.images.imgDrawerCat1.path},
    //   {'name': 'Vitamins', 'image': Assets.images.imgDrawerCat2.path},
    //   // {'name': 'Vitamins', 'image': Assets.images.imgDrawerCat2.path},
    // ];
    final categories = shopAllController.categories;

    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _categoriesController,
          curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
        ),
      ),
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0.2, 0), end: Offset.zero)
            .animate(
              CurvedAnimation(
                parent: _categoriesController,
                curve: const Interval(0.0, 0.3, curve: Curves.easeOutCubic),
              ),
            ),
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 20.w,
            right: 20.w,
            top: 16.h,
            bottom: 16.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'drawer_categories'.tr,
                style: TextStyles.bold(18.sp, fontColor: AppColors.textPrimary),
              ),
              SizedBox(height: 16.h),
              ...categories?.asMap().entries.map(
                    (entry) => _buildCategoryItem(
                      context,
                      entry.value.name ?? "",
                      entry.value.icon ?? "",
                      entry.key,
                    ),
                  ) ??
                  [],
            ],
          ),
        ),
      ),
    );
  }

  /// Category Item
  Widget _buildCategoryItem(
    BuildContext context,
    String name,
    String imagePath,
    int index,
  ) {
    final delay = 0.3 + (index * 0.1);
    final itemAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _categoriesController,
        curve: Interval(
          delay.clamp(0.0, 1.0),
          (delay + 0.2).clamp(0.0, 1.0),
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    return FadeTransition(
      opacity: itemAnimation,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0.2, 0), end: Offset.zero)
            .animate(
              CurvedAnimation(
                parent: _categoriesController,
                curve: Interval(
                  delay.clamp(0.0, 1.0),
                  (delay + 0.2).clamp(0.0, 1.0),
                  curve: Curves.easeOutCubic,
                ),
              ),
            ),
        child: Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: InkWell(
            onTap: () {
              Get.back(); // Close drawer
              // TODO: Navigate to category page
              Get.toNamed(
                AppRoutes.categoryProductView,
                arguments: {"cate": name},
              );
              // Get.snackbar('Category', '$name feature coming soon!');
            },
            child: Container(
              // padding: EdgeInsets.all(12.w),
              height: 65.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x1A000000), // #0000001A
                    offset: const Offset(0, 3),
                    blurRadius: 4.5,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Category Image
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(8.r),
                      topLeft: Radius.circular(8.r),
                    ),
                    child: SizedBox(
                      width: 80.w,
                      // height: 65.h,
                      child: CommonNetworkImage(
                        imageUrl: imagePath,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  // Category Name
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5.w),
                        child: Text(
                          name,
                          textAlign: TextAlign.center,
                          style: TextStyles.medium(
                            14.sp,
                            fontColor: AppColors.textPrimary,
                          ),
                        ),
                      ),
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

  /// Social Media and Legal Section
  Widget _buildSocialAndLegalSection(BuildContext context) {
    final socialSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _socialController,
            curve: Curves.easeOutCubic,
          ),
        );
    final socialFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _socialController, curve: Curves.easeOut),
    );

    return SlideTransition(
      position: socialSlideAnimation,
      child: FadeTransition(
        opacity: socialFadeAnimation,
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Social Media Icons
              Obx(() {
                final socialMedia = GlobalSettingsService.to.socialMedia;
                final List<Widget> socialIcons = [];
                int iconIndex = 0;

                if (socialMedia?.instagram != null &&
                    socialMedia!.instagram!.isNotEmpty) {
                  if (socialIcons.isNotEmpty)
                    socialIcons.add(SizedBox(width: 15.w));
                  socialIcons.add(
                    _buildSocialIcon(
                      Assets.icons.icInstagram,
                      iconIndex++,
                      socialMedia.instagram!,
                    ),
                  );
                }
                if (socialMedia?.facebook != null &&
                    socialMedia!.facebook!.isNotEmpty) {
                  if (socialIcons.isNotEmpty)
                    socialIcons.add(SizedBox(width: 15.w));
                  socialIcons.add(
                    _buildSocialIcon(
                      Assets.icons.icFacebook,
                      iconIndex++,
                      socialMedia.facebook!,
                    ),
                  );
                }
                if (socialMedia?.linkedin != null &&
                    socialMedia!.linkedin!.isNotEmpty) {
                  if (socialIcons.isNotEmpty)
                    socialIcons.add(SizedBox(width: 15.w));
                  socialIcons.add(
                    _buildSocialIcon(
                      Assets.icons.icLinkedin,
                      iconIndex++,
                      socialMedia.linkedin!,
                    ),
                  );
                }
                if (socialMedia?.youtube != null &&
                    socialMedia!.youtube!.isNotEmpty) {
                  if (socialIcons.isNotEmpty)
                    socialIcons.add(SizedBox(width: 15.w));
                  socialIcons.add(
                    _buildSocialIcon(
                      Assets.icons.icYoutube,
                      iconIndex++,
                      socialMedia.youtube!,
                    ),
                  );
                }
                // if (socialMedia?.tiktok != null && socialMedia!.tiktok!.isNotEmpty) {
                //   if (socialIcons.isNotEmpty) socialIcons.add(SizedBox(width: 15.w));
                //   socialIcons.add(_buildSocialIcon(Assets.icons.icInstagram, iconIndex++, socialMedia.tiktok!)); // TikTok (using Instagram icon as placeholder)
                // }

                return Row(children: socialIcons);
              }),
              SizedBox(height: 20.h),
              // Terms and Privacy Policy
              InkWell(
                onTap: () {
                  Get.back();
                  Get.toNamed(
                    AppRoutes.webview,
                    arguments: {
                      'title': 'profile_terms_of_service'.tr,
                      'url':
                          'https://staging-v2.viteezy.com/static-pages/terms-conditions',
                    },
                  );
                },
                child: Text(
                  'drawer_terms_privacy'.tr,
                  style: TextStyles.bold(
                    14.sp,
                    fontColor: AppColors.textPrimary,
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              // Version
              Text(
                '${'drawer_version'.tr} 4.6.7',
                style: TextStyles.regular(
                  12.sp,
                  fontColor: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Social Icon
  Widget _buildSocialIcon(dynamic svgIcon, int index, String url) {
    final iconDelay = 0.2 + (index * 0.1);
    final iconAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _socialController,
        curve: Interval(
          iconDelay.clamp(0.0, 1.0),
          (iconDelay + 0.2).clamp(0.0, 1.0),
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    return FadeTransition(
      opacity: iconAnimation,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.5, end: 1.0).animate(
          CurvedAnimation(
            parent: _socialController,
            curve: Interval(
              iconDelay.clamp(0.0, 1.0),
              (iconDelay + 0.2).clamp(0.0, 1.0),
              curve: Curves.easeOutBack,
            ),
          ),
        ),
        child: GestureDetector(
          onTap: () async {
            Get.back();
            await _launchSocialMediaUrl(url);
          },
          child: Container(
            width: 50.w,
            height: 50.w,
            decoration: BoxDecoration(
              color: AppColors.surfaceColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.textSecondary.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Center(
              child: svgIcon.svg(
                width: 20.w,
                height: 20.h,
                colorFilter: ColorFilter.mode(
                  AppColors.textPrimary,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Launch social media URL
  Future<void> _launchSocialMediaUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      // if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      // } else {
      //   Get.snackbar('Error', 'Could not open the link');
      // }
    } catch (e) {
      Get.snackbar('common_error'.tr, 'drawer_social_link_failed'.tr);
    }
  }
}

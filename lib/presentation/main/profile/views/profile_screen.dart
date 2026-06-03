import 'package:viteezy/core/routes/app_routes.dart';
import 'package:viteezy/core/utils/app_prefrence.dart';
import 'package:viteezy/core/widgets/common_appbar.dart';
import 'package:viteezy/core/widgets/common_loader.dart';
import 'package:viteezy/core/widgets/common_network_image.dart';
import 'package:viteezy/core/widgets/language_selection_bottom_sheet.dart';
import 'package:viteezy/gen/assets.gen.dart';
import 'package:viteezy/presentation/main/membership/views/membership_view.dart';
import 'package:viteezy/presentation/main/profile/controllers/profile_controller.dart';
import 'package:viteezy/presentation/main/profile/views/edit_profile_screen.dart';
import 'package:viteezy/presentation/main/wishlist/views/wishlist_view.dart';
import 'package:viteezy/core/utils/app_functions.dart';
import 'package:viteezy/core/utils/exports.dart';
import 'package:viteezy/core/widgets/common_button.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<ProfileController>()) {
      Get.put(ProfileController());
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CommonAppbar(
        title: 'profile_my_profile'.tr,
        showBackButton: false,
        centerTitle: true,
        actionWidget: InkWell(
          onTap: () {
            Get.toNamed(AppRoutes.notification);
          },
          child: Assets.icons.icNotification.svg(width: 20.w),
        ),
      ),
      body: GetBuilder<ProfileController>(
        builder: (controller) {
          // Check if user is logged in - this will be re-evaluated when controller updates
          final isLoggedIn =
              PrefService.getBool(PrefKeys.isLogin) &&
              PrefService.getString(PrefKeys.accessToken).isNotEmpty;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      children: [
                        Gap(30.h),

                        // Profile Avatar - Show guest icon if not logged in
                        isLoggedIn &&
                                controller.userData.user?.profileImage != null
                            ? Container(
                                width: 100.w,
                                height: 100.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.backgroundColor,
                                  border: Border.all(
                                    color: AppColors.white,
                                    width: 2,
                                  ),
                                ),
                                child: ClipOval(
                                  child: CommonNetworkImage(
                                    imageUrl:
                                        controller.userData.user?.profileImage,
                                  ),
                                ),
                              )
                            : Container(
                                width: 100.w,
                                height: 100.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.backgroundColor,
                                  border: Border.all(
                                    color: AppColors.white,
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: isLoggedIn
                                      ? Text(
                                          controller.getInitials(
                                            controller
                                                    .userData
                                                    .user
                                                    ?.firstName ??
                                                '',
                                            controller
                                                    .userData
                                                    .user
                                                    ?.lastName ??
                                                '',
                                          ),
                                          style: TextStyles.bold(24.sp),
                                        )
                                      : Icon(
                                          Icons.person_outline,
                                          size: 50.sp,
                                          color: AppColors.textSecondary,
                                        ),
                                ),
                              ),
                        Gap(10.h),
                        // User Name - Show "Guest User" if not logged in
                        Text(
                          isLoggedIn
                              ? "${controller.userData.user?.firstName ?? ''} ${controller.userData.user?.lastName ?? ''}"
                                    .trim()
                              : 'profile_guest_user'.tr,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyles.medium(20.sp),
                        ),
                        Gap(10.h),

                        // Edit Profile Button - Only show when logged in
                        if (isLoggedIn)
                          GestureDetector(
                            onTap: () {
                              Get.to(() => EditProfileScreen());
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(40),
                              ),
                              child: Text(
                                'profile_edit_info'.tr,
                                style: TextStyles.medium(14.sp),
                              ),
                            ),
                          ),
                        // Login Button - Only show when not logged in
                        if (!isLoggedIn)
                          Padding(
                            padding: EdgeInsets.only(top: 10.h),
                            child: CommonButtonWidget(
                              width: 140.w,
                              height: 44.h,
                              color: AppColors.primaryColor,
                              borderRadius: 40,
                              onPressed: () {
                                Get.toNamed(AppRoutes.login);
                              },
                              child: Center(
                                child: Text(
                                  'profile_login'.tr,
                                  style: TextStyles.semiBold(
                                    15.sp,
                                    fontColor: AppColors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        Gap(30.h),
                        // Membership Card
                        if (controller.userData.user?.isMember == false)
                          GestureDetector(
                            onTap: () {
                              Get.to(() => MembershipView(product: null));
                            },
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(16.w),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primaryColor.withValues(
                                      alpha: 0.4,
                                    ),
                                    AppColors.orangeF7A173.withValues(
                                      alpha: 0.6,
                                    ),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'profile_membership'.tr,
                                        style: TextStyles.semiBold(20.sp),
                                      ),
                                      Gap(10.w),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 12.w,
                                          vertical: 4.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.yellowEDDFA5,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          'profile_pro'.tr,
                                          style: TextStyles.semiBold(
                                            12.sp,
                                            fontColor: AppColors.brown995824,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Gap(5.h),
                                  Text(
                                    'profile_unlock_membership'.tr,
                                    style: TextStyles.regular(
                                      15.sp,
                                      fontColor: AppColors.black1414141,
                                    ),
                                  ),
                                  Gap(10.h),
                                  CommonButtonWidget(
                                    width: 120.w,
                                    height: 35.h,
                                    color: AppColors.black1414141,
                                    borderRadius: 10,
                                    onPressed: () {
                                      Get.to(
                                        () => MembershipView(product: null),
                                      );
                                    },
                                    child: Center(
                                      child: Text(
                                        'profile_upgrade_now'.tr,
                                        style: TextStyles.semiBold(
                                          13.sp,
                                          fontColor: AppColors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        if (isLoggedIn &&
                            controller.userData.user?.isMember == false) ...[
                          Gap(8.h),
                          _buildMemberIdReferralCard(context, controller),
                        ],
                        Gap(20.h),
                        // General Section
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'profile_general'.tr,
                            style: TextStyles.regular(
                              15.sp,
                              fontColor: AppColors.grey898989,
                            ),
                          ),
                        ),
                        Gap(15.h),
                        // Orders - Only show when logged in
                        if (isLoggedIn) ...[
                          _buildMenuItem(
                            context: context,
                            icon: Image.asset(
                              Assets.icons.icOrder.path,
                              height: 18,
                              width: 18,
                            ),
                            title: 'profile_orders'.tr,
                            subtitle: 'profile_orders_subtitle'.tr,
                            onTap: () {
                              Get.toNamed(AppRoutes.myOrder);
                            },
                          ),
                          Gap(10.h),
                        ],
                        // Addresses - Only show when logged in
                        if (isLoggedIn) ...[
                          _buildMenuItem(
                            context: context,
                            icon: Image.asset(
                              Assets.icons.icHone.path,
                              height: 18,
                              width: 18,
                            ),
                            title: 'profile_addresses'.tr,
                            subtitle: 'profile_addresses_subtitle'.tr,
                            onTap: () {
                              Get.toNamed(AppRoutes.addresses);
                            },
                          ),
                          Gap(10.h),
                        ],
                        // Family member
                        if (isLoggedIn) ...[
                          _buildMenuItem(
                            context: context,
                            icon: Image.asset(
                              'assets/icons/ic_family.png',
                              height: 18,
                              width: 18,
                            ),
                            title: 'Family Member'.tr,
                            subtitle: 'Manage all your connected members'.tr,
                            onTap: () {
                              Get.toNamed(AppRoutes.familyscreen);
                            },
                          ),
                          Gap(10.h),
                        ],
                        if (isLoggedIn &&
                            controller.userData.user?.isMember == true) ...[
                          _buildMemberIdReferralCard(context, controller),
                          Gap(10.h),
                        ],

                        // Membership
                        if (isLoggedIn) ...[
                          _buildMenuItem(
                            context: context,
                            icon: Assets.icons.icMember.svg(),
                            title: 'Membership'.tr,
                            subtitle: 'Manage your membership & benefits'.tr,
                            onTap: () {
                              Get.toNamed(AppRoutes.memberScreen);
                            },
                          ),
                          Gap(10.h),
                        ],
                        // Wishlist - Only show when logged in
                        if (isLoggedIn) ...[
                          _buildMenuItem(
                            context: context,
                            icon: Image.asset(
                              Assets.icons.icFav.path,
                              height: 18,
                              width: 18,
                            ),
                            title: 'profile_wishlist'.tr,
                            subtitle: 'profile_wishlist_subtitle'.tr,
                            onTap: () {
                              Get.to(() => WishlistView());
                            },
                          ),
                          Gap(10.h),
                        ],
                        // Change Password - Only show when logged in
                        if (isLoggedIn) ...[
                          _buildMenuItem(
                            context: context,
                            icon: Image.asset(
                              Assets.icons.icLock.path,
                              height: 18,
                              width: 18,
                            ),
                            title: 'profile_change_password'.tr,
                            subtitle: 'profile_change_password_subtitle'.tr,
                            onTap: () {
                              Get.toNamed(AppRoutes.changePass);
                            },
                          ),
                          Gap(10.h),
                        ],
                        if (isLoggedIn) ...[
                          _buildMenuItem(
                            context: context,
                            icon: Image.asset(
                              Assets.icons.icSubscription.path,
                              height: 18,
                              width: 18,
                            ),
                            title: 'profile_subscription'.tr,
                            subtitle: 'profile_subscription_subtitle'.tr,
                            onTap: () {
                              Get.toNamed(AppRoutes.subscription);
                            },
                          ),
                          Gap(10.h),
                        ],
                        _buildMenuItem(
                          context: context,
                          icon: Image.asset(
                            Assets.icons.icChat.path,
                            height: 18,
                            width: 18,
                          ),
                          title: 'profile_help_support'.tr,
                          subtitle: 'profile_help_support_subtitle'.tr,
                          onTap: () {
                            Get.toNamed(AppRoutes.helpCenter);
                          },
                        ),
                        Gap(10.h),
                        _buildMenuItem(
                          context: context,
                          icon: Image.asset(
                            Assets.icons.icLanguageLogo.path,
                            height: 18,
                            width: 18,
                          ),
                          title: 'profile_language'.tr,
                          subtitle: controller.localeCodeToNameFromCode(
                            controller.selectedLanguage,
                          ),
                          onTap: () {
                            _showLanguageBottomSheet(context, controller);
                          },
                        ),
                        Gap(30.h),
                        // Help & Info Section
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'profile_help_info'.tr,
                            style: TextStyles.regular(
                              15.sp,
                              fontColor: AppColors.grey898989,
                            ),
                          ),
                        ),
                        Gap(15.h),

                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildWebViewMenuItem(
                                title: 'profile_faqs'.tr,
                                onTap: () {
                                  Get.toNamed(
                                    AppRoutes.webview,
                                    arguments: {
                                      'title': 'profile_faqs'.tr,
                                      'url':
                                          'https://staging-v2.viteezy.com/faq',
                                    },
                                  );
                                },
                              ),
                              Gap(10.h),
                              Container(
                                height: 1,
                                width: Get.width,
                                color: AppColors.yellowF0EFE4,
                              ),
                              Gap(10.h),
                              _buildWebViewMenuItem(
                                title: 'profile_about_us'.tr,
                                onTap: () {
                                  Get.toNamed(
                                    AppRoutes.webview,
                                    arguments: {
                                      'title': 'profile_about_us'.tr,
                                      'url':
                                          'https://staging-v2.viteezy.com/aboutUs',
                                    },
                                  );
                                },
                              ),
                              Gap(10.h),
                              Container(
                                height: 1,
                                width: Get.width,
                                color: AppColors.yellowF0EFE4,
                              ),
                              Gap(10.h),
                              _buildWebViewMenuItem(
                                title: 'profile_contact_us'.tr,
                                onTap: () {
                                  Get.toNamed(
                                    AppRoutes.webview,
                                    arguments: {
                                      'title': 'profile_contact_us'.tr,
                                      'url':
                                          'https://staging-v2.viteezy.com/contactUs',
                                    },
                                  );
                                },
                              ),
                              Gap(10.h),
                              Container(
                                height: 1,
                                width: Get.width,
                                color: AppColors.yellowF0EFE4,
                              ),
                              Gap(10.h),
                              _buildWebViewMenuItem(
                                title: 'profile_privacy_policy'.tr,
                                onTap: () {
                                  Get.toNamed(
                                    AppRoutes.webview,
                                    arguments: {
                                      'title': 'profile_privacy_policy'.tr,
                                      'url':
                                          'https://staging-v2.viteezy.com/static-pages/privacy-policy',
                                    },
                                  );
                                },
                              ),
                              Gap(10.h),
                              Container(
                                height: 1,
                                width: Get.width,
                                color: AppColors.yellowF0EFE4,
                              ),
                              Gap(10.h),
                              _buildWebViewMenuItem(
                                title: 'profile_terms_of_service'.tr,
                                onTap: () {
                                  Get.toNamed(
                                    AppRoutes.webview,
                                    arguments: {
                                      'title': 'profile_terms_of_service'.tr,
                                      'url':
                                          'https://staging-v2.viteezy.com/static-pages/terms-conditions',
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),

                        Gap(15.h),
                        // Log Out Button - Only show when logged in
                        if (isLoggedIn)
                          InkWell(
                            onTap: () {
                              showLogoutDialog(context);
                            },
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                horizontal: 20.w,
                                vertical: 15.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.yellowF0EFE4,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    Assets.icons.icLogout.path,
                                    scale: 3.5,
                                  ),
                                  Gap(10.w),
                                  Text(
                                    'profile_log_out'.tr,
                                    style: TextStyles.medium(
                                      14.sp,
                                      fontColor: AppColors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        Gap(40.h),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildWebViewMenuItem({
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Text(title, style: TextStyles.medium(14.sp)),
    );
  }

  Widget _buildMemberIdReferralCard(
    BuildContext context,
    ProfileController controller,
  ) {
    final user = controller.userData.user;
    final memberId = user?.memberId?.trim();
    final referral = user?.refrelCode?.trim();
    final hasMemberId = memberId != null && memberId.isNotEmpty;
    final hasReferral = referral != null && referral.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.black1414141.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMemberReferralRow(
            label: 'profile_member_id'.tr,
            value: hasMemberId ? memberId : '—',
            onCopy: hasMemberId
                ? () => _copyMemberReferralToClipboard(context, memberId)
                : null,
          ),
          SizedBox(height: 4.h),
          Divider(height: 1, thickness: 1, color: AppColors.yellowF0EFE4),
          SizedBox(height: 4.h),
          _buildMemberReferralRow(
            label: 'profile_referral_code'.tr,
            value: hasReferral ? referral : '—',
            onCopy: hasReferral
                ? () => _copyMemberReferralToClipboard(context, referral)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildMemberReferralRow({
    required String label,
    required String value,
    VoidCallback? onCopy,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyles.regular(
                    14.sp,
                    fontColor: AppColors.grey898989,
                  ),
                ),
                Gap(4.h),
                Text(
                  value,
                  style: TextStyles.semiBold(
                    15.sp,
                    fontColor: AppColors.black1414141,
                  ),
                ),
              ],
            ),
          ),
          Gap(8.w),
          Material(
            color: AppColors.yellowF0EFE4.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: onCopy,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: EdgeInsets.all(10.w),
                child: Icon(
                  Icons.copy_rounded,
                  size: 18.sp,
                  color: onCopy != null
                      ? AppColors.black1414141
                      : AppColors.grey898989,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _copyMemberReferralToClipboard(
    BuildContext context,
    String text,
  ) async {
    await Clipboard.setData(ClipboardData(text: text));
    AppFunctions().showToast(
      'profile_copied_to_clipboard'.tr,
      bgColor: AppColors.green,
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required Widget icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 18),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.yellowF0EFE4),
        ),
        child: Row(
          children: [
            icon,
            Gap(15.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyles.medium(14.sp)),

                  Text(
                    subtitle,
                    style: TextStyles.regular(
                      12.sp,
                      fontColor: AppColors.grey898989,
                    ),
                  ),
                ],
              ),
            ),
            Gap(10),
            Assets.icons.icArrowNext.svg(
              height: 17,
              width: 20,
              fit: BoxFit.cover,
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageBottomSheet(
    BuildContext context,
    ProfileController controller,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => LanguageSelectionBottomSheet(
        selectedLanguage: controller.selectedLanguage,
        onLanguageSelected: (language) {
          controller.updateLanguage(language);
        },
        onOkPressed: () {
          Get.back();
        },
      ),
    );
  }

  void showLogoutDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: AlignmentGeometry.center,

                child: Text(
                  'profile_logout'.tr,
                  style: TextStyles.medium(21.sp),
                ),
              ),
              Gap(6.h),
              Align(
                alignment: AlignmentGeometry.center,
                child: Text(
                  'profile_logout_confirm'.tr,
                  style: TextStyles.regular(16.sp),
                ),
              ),
              Gap(18.h),
              Row(
                children: [
                  Expanded(
                    child: CommonButtonWidget(
                      height: 44.h,
                      color: AppColors.red,
                      borderRadius: 40,
                      onPressed: () {
                        Get.back();
                      },
                      child: Center(
                        child: Text(
                          'common_cancel'.tr,
                          style: TextStyles.medium(
                            16.sp,
                            fontColor: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Gap(10.w),
                  Expanded(
                    child: Obx(() {
                      return CommonButtonWidget(
                        height: 44.h,
                        color: AppColors.black1414141,
                        borderRadius: 40,
                        onPressed: () async {
                          Get.back();
                          await controller.logout(context);
                        },
                        child: controller.loader.value
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,

                                children: [
                                  CommonLoader(
                                    color: AppColors.white,
                                    size: 15,
                                  ),
                                ],
                              )
                            : Center(
                                child: Text(
                                  'common_yes'.tr,
                                  style: TextStyles.medium(
                                    16.sp,
                                    fontColor: AppColors.white,
                                  ),
                                ),
                              ),
                      );
                    }),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}

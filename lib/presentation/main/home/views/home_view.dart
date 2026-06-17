import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:viteezy/core/routes/app_routes.dart';

import 'package:viteezy/core/theme/app_colors.dart';
import 'package:viteezy/core/theme/text_styles.dart';
import 'package:viteezy/core/widgets/common_network_image.dart';
import 'package:viteezy/core/widgets/custom_toast.dart';
import 'package:viteezy/core/widgets/shimmer_widget.dart';
import 'package:viteezy/gen/assets.gen.dart';
import '../../../../core/models/home_data_model.dart';
import '../../../../core/models/product_response_model.dart';
import '../../../../core/services/global_settings_service.dart';
import '../../shop_all_view/views/shop_all_view.dart';
import '../../shop_all_view/controller/shop_all_controller.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../controllers/home_controller.dart';
import 'rotating_playing_button_widget.dart';

/// Home View
class HomeView extends GetView<HomeController> {
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const HomeView({super.key, this.scaffoldKey});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceColor,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: TabBarView(
          controller: controller.tabController,
          children: [
            // Tab 0: Home Content
            Obx(() {
              return RefreshIndicator(
                onRefresh: () async {
                  await GlobalSettingsService.to.refreshLandingPage();
                },
                child: controller.isLoadingHomeData
                    ? _buildHomeShimmer()
                    : SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          children: [
                            SlideTransition(
                              position: controller.heroSectionSlideAnimation,
                              child: _buildHeroSection(context),
                            ),
                            Gap(5),
                            SlideTransition(
                              position: controller.bottomSectionsSlideAnimation,
                              child: _buildBottomSections(context),
                            ),
                            Gap(8),
                            _DiscoverSectionWidget(controller: controller),
                            _WhyChooseSectionWidget(controller),
                            _RealCustomersSectionWidget(controller),
                          ],
                        ),
                      ),
              );
            }),
            // Tab 1: Shop All Content
            ShopAllView(),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  /// AppBar with Custom AppBar, Navigation Tabs, and Promotional Banner
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return _ReactiveAppBar(
      buildCustomAppBar: (ctx) => _buildCustomAppBar(ctx),
      buildNavigationTabs: (ctx) => _buildNavigationTabs(ctx),
      // Promotional banner temporarily removed
      buildPromotionalBanner: (ctx) => _buildPromotionalBanner(ctx),
    );
  }

  Widget _buildPromotionalBanner(BuildContext context) {
    return _ShimmerBanner(
      shimmerColor: AppColors.white,
      child: GestureDetector(
        onTap: () {
          Get.toNamed(AppRoutes.membership);
        },
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            gradient: LinearGradient(
              colors: [
                Color(0xFFECD2BC),
                Color(0xFFB8E2D0),
                Color(0xFFC6E2F1),
                Color(0xFFB5E5AD),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: EdgeInsets.symmetric(vertical: 2.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  'profile_unlock_membership'.tr,
                  textAlign: TextAlign.center,
                  style: TextStyles.medium(
                    14.sp,
                    fontColor: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 10.w),
              Icon(
                Icons.arrow_forward,
                size: 16.sp,
                color: AppColors.textPrimary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Custom AppBar with menu, logo, and notification
  Widget _buildCustomAppBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(Icons.menu, size: 24.sp, color: AppColors.textPrimary),
          onPressed: () {
            // Open drawer using the scaffold key from DashboardView
            if (scaffoldKey?.currentState != null) {
              scaffoldKey!.currentState!.openDrawer();
            } else {
              // Fallback: try to find the Scaffold ancestor
              Scaffold.of(context).openDrawer();
            }
          },
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Obx(
              () => controller.showAppIcon.value
                  ? Assets.animations.appIcon.lottie(width: 180, repeat: false)
                  : const SizedBox.shrink(),
            ),
          ],
        ),
        IconButton(
          icon: Assets.icons.icNotification.svg(width: 20.w),
          onPressed: () {
            Get.toNamed(AppRoutes.notification);
          },
        ),
        IconButton(
          icon: Assets.icons.icAdd.svg(width: 20.w),
          onPressed: () {
            Get.toNamed(AppRoutes.quizFlow);
          },
        ),      IconButton(
          icon: Assets.icons.icAdd.svg(width: 20.w),
          onPressed: () {
            Get.toNamed(AppRoutes.recommendation);
          },
        ),
      ],
    );
  }

  /// Navigation Tabs (Home, Shop All)
  Widget _buildNavigationTabs(BuildContext context) {
    return TabBar(
      controller: controller.tabController,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: AppColors.textPrimary, width: 2.h),
        insets: EdgeInsets.zero,
      ),
      indicatorSize: TabBarIndicatorSize.tab,
      dividerColor: Colors.transparent,
      labelColor: AppColors.textPrimary,
      unselectedLabelColor: AppColors.textSecondary,
      labelStyle: TextStyles.semiBold(16.sp, fontColor: AppColors.textPrimary),
      unselectedLabelStyle: TextStyles.regular(
        16.sp,
        fontColor: AppColors.textSecondary,
      ),
      indicatorAnimation: TabIndicatorAnimation.elastic,
      tabs: [
        Tab(text: 'home_tab'.tr),
        Tab(text: 'home_shop_all'.tr),
      ],
    );
  }

  /* /// Promotional Banner (temporarily disabled)
  Widget _buildPromotionalBanner(BuildContext context) {
    return Container(
      key: const ValueKey('banner'),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        gradient: LinearGradient(
          colors: [Color(0xFFECD2BC), Color(0xFFB8E2D0), Color(0xFFC6E2F1), Color(0xFFB5E5AD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              'profile_unlock_membership'.tr,
              textAlign: TextAlign.center,
              style: TextStyles.medium(14.sp, fontColor: AppColors.textPrimary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 10.w),
          Icon(Icons.arrow_forward, size: 16.sp, color: AppColors.textPrimary),
        ],
      ),
    );
  } */

  /// Hero Section with Video/Image and Quiz
  Widget _buildHeroSection(BuildContext context) {
    final heroSection = controller.homeData?.landingPage?.heroSection;
    return Container(
      height: 350.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(0.r),
        color: AppColors.backgroundColor,
      ),
      child: Stack(
        children: [
          // Tappable area for the entire video section
          GestureDetector(
            onTap: controller.onVideoAreaTap,
            child: Stack(
              children: [
                // Placeholder Image (shown while loading)
                Obx(
                  () => AnimatedOpacity(
                    opacity: controller.isVideoLoading.value ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(0.r),
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        color: AppColors.primaryColor.withValues(alpha: 0.3),
                        child: Assets.images.imgHomePlace.image(
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                // Video Player (shown when initialized)
                Obx(
                  () => AnimatedOpacity(
                    opacity: controller.isVideoInitialized.value ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(0.r),
                      child: SizedBox(
                        width: double.infinity,
                        height: double.infinity,
                        child:
                            controller.videoPlayerController != null &&
                                controller.isVideoInitialized.value
                            ? FittedBox(
                                fit: BoxFit.cover,
                                child: SizedBox(
                                  width: controller
                                      .videoPlayerController!
                                      .value
                                      .size
                                      .width,
                                  height: controller
                                      .videoPlayerController!
                                      .value
                                      .size
                                      .height,
                                  child: VideoPlayer(
                                    controller.videoPlayerController!,
                                  ),
                                ),
                              )
                            : const SizedBox(),
                      ),
                    ),
                  ),
                ),
                // Dark overlay when paused (like video player)
                Obx(
                  () => AnimatedOpacity(
                    opacity: controller.showPlayButton.value ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: Colors.black.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Play Button Overlay (shown when paused)
          Obx(
            () => AnimatedOpacity(
              opacity: controller.showPlayButton.value ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: IgnorePointer(
                ignoring: !controller.showPlayButton.value,
                child: Center(
                  child: RotatingPlayButton(
                    size: 150,
                    onTap: controller.onPlayButtonTap,
                  ),
                ),
              ),
            ),
          ),
          // Mute / Unmute button (circle with white opacity)
          Obx(
            () => controller.isVideoInitialized.value
                ? Positioned(
                    top: 12.h,
                    right: 12.w,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: controller.toggleVideoMute,
                        borderRadius: BorderRadius.circular(24.r),
                        child: Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.4),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            controller.isVideoMuted.value
                                ? Icons.volume_off
                                : Icons.volume_up,
                            color: Colors.white,
                            size: 24.sp,
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          // Bottom Content
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.4),
                    Colors.black.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(0.r),
                  bottomRight: Radius.circular(0.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      heroSection?.title ??
                          'home_start_quiz'.tr,
                      style: TextStyles.medium(18.sp, fontColor: Colors.white),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  ElevatedButton(
                    onPressed: () {
                      Get.toNamed(AppRoutes.aiChat);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.textPrimary,
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50.r),
                      ),
                    ),
                    child: Text(
                      heroSection?.primaryCta?.first.label ?? 'home_take_quiz'.tr,
                      style: TextStyles.medium(
                        14.sp,
                        fontColor: AppColors.black1414141,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Floating Action Button
  Widget _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      heroTag: "Hello",
      onPressed: () {
        Get.toNamed(AppRoutes.support);
      },
      backgroundColor: AppColors.primaryColor,
      shape: const CircleBorder(),
      child: Assets.icons.icFloatingChat.svg(width: 24.w, height: 24.h),
    );
  }

  /// Bottom Sections (Shop Products & Talk to Expert)
  Widget _buildBottomSections(BuildContext context) {
    final heroSection = controller.homeData?.landingPage?.heroSection;
    final primaryCta = heroSection?.primaryCta ?? [];

    // Check if we have enough CTA items
    final hasFirstCta = primaryCta.length > 1;
    final hasSecondCta = primaryCta.length > 2;

    // If no CTAs available, show default sections
    if (!hasFirstCta && !hasSecondCta) {
      return Row(
        children: [
          Expanded(
            child: _buildSectionCard(
              context: context,
              title: 'home_shop_products'.tr,
              child: _AnimatedImageContainer(
                imagePath: Assets.images.productOne.path,
                height: 180.h,
              ),
              onTap: () {
                controller.tabController.animateTo(
                  1,
                ); // Navigate to Shop All tab
                // Get.snackbar('Shop', 'Shop products feature coming soon!');
              },
            ),
          ),
          SizedBox(width: 6.w),
          Expanded(
            child: _buildSectionCard(
              context: context,
              title: 'home_talk_to_expert'.tr,
              child: _AnimatedImageContainer(
                imagePath: Assets.images.imgDoctor.path,
                height: 180.h,
              ),
              onTap: () {
                controller.tabController.animateTo(
                  1,
                ); // Navigate to Shop All tab
                // Get.snackbar('Expert', 'Talk to expert feature coming soon!');
              },
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        // First CTA (index 1) - Shop Products
        if (hasFirstCta)
          Expanded(
            child: _buildSectionCard(
              context: context,
              title: primaryCta[1].label ?? 'home_shop_products'.tr,
              child: _AnimatedImageContainer(
                imagePath: primaryCta[1].image?.isNotEmpty == true
                    ? primaryCta[1].image!
                    : Assets.images.productOne.path,
                height: 180.h,
              ),
              onTap: () {
                controller.tabController.animateTo(
                  1,
                ); // Navigate to Shop All tab
                // Get.snackbar('Shop', 'Shop products feature coming soon!');
              },
            ),
          ),
        if (hasFirstCta && hasSecondCta) SizedBox(width: 6.w),
        // Second CTA (index 2) - Talk to an Expert
        if (hasSecondCta)
          Expanded(
            child: _buildSectionCard(
              context: context,
              title: primaryCta[2].label ?? 'home_talk_to_expert'.tr,
              child: _AnimatedImageContainer(
                imagePath: primaryCta[2].image?.isNotEmpty == true
                    ? primaryCta[2].image!
                    : Assets.images.imgDoctor.path,
                height: 180.h,
              ),
              onTap: () {
                controller.tabController.animateTo(
                  1,
                ); // Navigate to Shop All tab
                // Get.snackbar('Expert', 'Talk to expert feature coming soon!');
              },
            ),
          ),
        // If only one CTA is available, show default second section
        if (hasFirstCta && !hasSecondCta)
          Expanded(
            child: _buildSectionCard(
              context: context,
              title: 'home_talk_to_expert'.tr,
              child: _AnimatedImageContainer(
                imagePath: Assets.images.imgDoctor.path,
                height: 180.h,
              ),
              onTap: () {
                controller.tabController.animateTo(
                  1,
                ); // Navigate to Shop All tab
                // Get.snackbar('Expert', 'Talk to expert feature coming soon!');
              },
            ),
          ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required Widget child,
    required VoidCallback onTap,
    required BuildContext context,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          child,
          Padding(
            padding: EdgeInsets.only(left: 10.h, top: 10.h, bottom: 10.h),
            child: Text(
              title,
              style: TextStyles.semiBold(
                16.sp,
                fontColor: AppColors.blackColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build shimmer loading for home screen
  Widget _buildHomeShimmer() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          // Hero Section Shimmer
          ShimmerWidget(
            child: Container(
              height: 350.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.grayE3E3DC,
                borderRadius: BorderRadius.circular(0.r),
              ),
            ),
          ),
          Gap(5),
          // Bottom Sections Shimmer
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              children: [
                Expanded(
                  child: ShimmerWidget(
                    child: Container(
                      height: 180.h,
                      decoration: BoxDecoration(
                        color: AppColors.grayE3E3DC,
                        borderRadius: BorderRadius.circular(0.r),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 6.w),
                Expanded(
                  child: ShimmerWidget(
                    child: Container(
                      height: 180.h,
                      decoration: BoxDecoration(
                        color: AppColors.grayE3E3DC,
                        borderRadius: BorderRadius.circular(0.r),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Gap(8),
          // Discover Section Shimmer
          Container(
            color: AppColors.warningColor,
            padding: EdgeInsets.symmetric(vertical: 20.h),
            child: Column(
              children: [
                // Title shimmer
                ShimmerWidget(
                  child: Container(
                    width: 200.w,
                    height: 24.h,
                    margin: EdgeInsets.symmetric(horizontal: 20.w),
                    decoration: BoxDecoration(
                      color: AppColors.grayE3E3DC,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
                Gap(20.h),
                // Horizontal scroll shimmer
                SizedBox(
                  height: 420.h,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      return Container(
                        width: 280.w,
                        margin: EdgeInsets.only(right: 16.w),
                        child: ShimmerWidget(
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.grayE3E3DC,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            height: 420.h,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Why Choose Section Shimmer
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.backgroundColor, AppColors.surfaceColor],
              ),
            ),
            padding: EdgeInsets.symmetric(vertical: 25.h),
            child: Column(
              children: [
                // Title shimmer
                ShimmerWidget(
                  child: Container(
                    width: 180.w,
                    height: 24.h,
                    margin: EdgeInsets.symmetric(horizontal: 20.w),
                    decoration: BoxDecoration(
                      color: AppColors.grayE3E3DC,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
                Gap(20.h),
                // Horizontal scroll shimmer
                SizedBox(
                  height: 265.h,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      return Container(
                        width: 280.w,
                        margin: EdgeInsets.only(right: 16.w),
                        child: ShimmerWidget(
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.grayE3E3DC,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            height: 265.h,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Real Customers Section Shimmer
          Container(
            color: AppColors.backgroundColor,
            padding: EdgeInsets.symmetric(vertical: 20.h),
            child: Column(
              children: [
                // Title shimmer
                ShimmerWidget(
                  child: Container(
                    width: 220.w,
                    height: 24.h,
                    margin: EdgeInsets.symmetric(horizontal: 20.w),
                    decoration: BoxDecoration(
                      color: AppColors.grayE3E3DC,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
                Gap(20.h),
                // Horizontal scroll shimmer
                SizedBox(
                  height: 375.h,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      return Container(
                        width: 200.w,
                        margin: EdgeInsets.only(right: 16.w),
                        child: ShimmerWidget(
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.grayE3E3DC,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            height: 375.h,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // FAQ Section Shimmer
          Container(
            color: AppColors.primaryColor,
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
            child: Column(
              children: List.generate(
                3,
                (index) => Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: ShimmerWidget(
                    child: Container(
                      height: 40.h,
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Discover Section Widget with ScrollController management
class _DiscoverSectionWidget extends StatefulWidget {
  final HomeController controller;

  const _DiscoverSectionWidget({required this.controller});

  @override
  State<_DiscoverSectionWidget> createState() => _DiscoverSectionWidgetState();
}

class _DiscoverSectionWidgetState extends State<_DiscoverSectionWidget> {
  late ScrollController _scrollController;
  double _scrollPosition = 0.0;
  double _maxScrollExtent = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_updateScrollPosition);
    // Get initial scroll extent after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        setState(() {
          _maxScrollExtent = _scrollController.position.maxScrollExtent;
        });
      }
    });
  }

  void _updateScrollPosition() {
    if (_scrollController.hasClients) {
      setState(() {
        _scrollPosition = _scrollController.offset;
        _maxScrollExtent = _scrollController.position.maxScrollExtent;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.warningColor,
      child: Column(
        children: [
          Gap(20.h),
          // Title with Navigation Arrows
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Left Arrow
                SizedBox(width: 16.w),
                // Title
                Expanded(
                  child: Text(
                    'home_discover_health'.tr,
                    textAlign: TextAlign.center,
                    style: TextStyles.bold(18.sp),
                  ),
                ),
                SizedBox(width: 16.w),

                // Right Arrow
              ],
            ),
          ),
          Gap(12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(
                      (_scrollController.offset - 300).clamp(
                        0.0,
                        _scrollController.position.maxScrollExtent,
                      ),
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.chevron_left,
                      size: 25.sp,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              Gap(20),
              GestureDetector(
                onTap: () {
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(
                      (_scrollController.offset + 300).clamp(
                        0.0,
                        _scrollController.position.maxScrollExtent,
                      ),
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.chevron_right,
                      size: 25.sp,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),

          Gap(16.h),
          // Horizontal Scrollable Product Cards
          SizedBox(
            height: 420.h,
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                // Prevent drawer from opening when scrolling horizontally
                return true;
              },
              child: ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                physics: const ClampingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                itemCount: widget
                    .controller
                    .homeData
                    ?.landingPage
                    ?.productCategorySection
                    ?.productCategories
                    ?.length,
                itemBuilder: (context, index) {
                  final category = widget
                      .controller
                      .homeData
                      ?.landingPage
                      ?.productCategorySection
                      ?.productCategories?[index];
                  return _buildDiscoverProductCard(context, index, category);
                },
              ),
            ),
          ),
          Gap(20.h),
          // Show all Products Button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: SizedBox(
              child: ElevatedButton(
                onPressed: () {
                  widget.controller.tabController.animateTo(
                    1,
                  ); // Navigate to Shop All tab
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surfaceColor,
                  foregroundColor: AppColors.textPrimary,
                  padding: EdgeInsets.symmetric(
                    vertical: 10.h,
                    horizontal: 15.w,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'home_show_all_products'.tr,
                  style: TextStyles.semiBold(
                    13.sp,
                    fontColor: AppColors.black1414141,
                  ),
                ),
              ),
            ),
          ),
          Gap(20.h),
          // Custom Scrollbar at the end
          LayoutBuilder(
            builder: (context, constraints) {
              final trackWidth = constraints.maxWidth;
              if (_maxScrollExtent <= 0) {
                return SizedBox(height: 4.0);
              }

              // Calculate viewport width (screen width minus padding)
              final viewportWidth = MediaQuery.of(context).size.width - 40.w;
              // Thumb width is proportional to viewport vs total scrollable width
              final thumbWidth =
                  (viewportWidth / (_maxScrollExtent + viewportWidth)) *
                  trackWidth;
              // Thumb position based on scroll offset
              final thumbPosition =
                  (_scrollPosition / _maxScrollExtent) *
                  (trackWidth - thumbWidth);

              return Container(
                height: 4.0,
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor,
                  borderRadius: BorderRadius.zero,
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left: thumbPosition.clamp(0.0, trackWidth - thumbWidth),
                      child: Container(
                        width: thumbWidth,
                        height: 4.0,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDiscoverProductCard(
    BuildContext context,
    int index,
    ProductCategory? category,
  ) {
    // Main VITEEZY+ card (index 0)
    return Container(
      width: 280.w,
      margin: EdgeInsets.only(right: 16.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        children: [
          // Product Image Section
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              height: 250.h,
              decoration: BoxDecoration(
                color: AppColors.backgroundColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10.r),
                  topRight: Radius.circular(10.r),
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10.r),
                    topRight: Radius.circular(10.r),
                  ),
                ),
                child: CommonNetworkImage(imageUrl: category?.icon ?? ""),
                // child: CommonNetworkImage(imageUrl: category!.image!.url ?? ""),
              ),
            ),
          ),
          // Product Info Section
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: AppColors.surfaceColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16.r),
                bottomRight: Radius.circular(16.r),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Gap(20.h),
                Text(
                  category?.name ?? "Nature’s Healing Spices",
                  textAlign: TextAlign.center,
                  style: TextStyles.semiBold(
                    16.sp,
                    fontColor: AppColors.black1414141,
                  ),
                ),
                Gap(8.h),
                Text(
                  category?.description ??
                      'home_natural_spices'.tr,
                  textAlign: TextAlign.center,
                  style: TextStyles.regular(
                    12.sp,
                    fontColor: AppColors.black1414141,
                  ),
                ),
                Gap(12.h),
                GestureDetector(
                  onTap: () {
                    Get.toNamed(
                      AppRoutes.categoryProductView,
                      arguments: {"cate": category?.name},
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.black1414141,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      'home_shop_specialties'.tr,
                      style: TextStyles.medium(
                        14.sp,
                        fontColor: AppColors.surfaceColor,
                      ),
                    ),
                  ),
                ),
                Gap(15.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Why Choose Viteezy Section Widget
class _WhyChooseSectionWidget extends StatefulWidget {
  const _WhyChooseSectionWidget(this.controller);
  final HomeController controller;
  @override
  State<_WhyChooseSectionWidget> createState() =>
      _WhyChooseSectionWidgetState();
}

class _WhyChooseSectionWidgetState extends State<_WhyChooseSectionWidget> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.backgroundColor, AppColors.surfaceColor],
        ),
      ),
      child: Column(
        children: [
          Gap(25.h),
          // Title
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Text(
              widget.controller.homeData?.landingPage?.featuresSection?.title ??
                  ""
                      'home_why_choose'.tr,
              textAlign: TextAlign.center,
              style: TextStyles.bold(18.sp, fontColor: AppColors.textPrimary),
            ),
          ),
          Gap(12.h),
          // Navigation Arrows
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(
                      (_scrollController.offset - 300).clamp(
                        0.0,
                        _scrollController.position.maxScrollExtent,
                      ),
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                child: Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.chevron_left,
                    size: 24.sp,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Gap(20.w),
              GestureDetector(
                onTap: () {
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(
                      (_scrollController.offset + 300).clamp(
                        0.0,
                        _scrollController.position.maxScrollExtent,
                      ),
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                child: Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.chevron_right,
                    size: 24.sp,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          Gap(20.h),
          // Horizontal Scrollable Cards
          SizedBox(
            height: 265.h,
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                // Prevent drawer from opening when scrolling horizontally
                return true;
              },
              child: ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                physics: const ClampingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                itemCount: widget
                    .controller
                    .homeData
                    ?.landingPage
                    ?.featuresSection
                    ?.features
                    ?.length,
                itemBuilder: (context, index) {
                  final features = widget
                      .controller
                      .homeData
                      ?.landingPage
                      ?.featuresSection
                      ?.features?[index];
                  return _buildWhyChooseCard(context, index, features);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWhyChooseCard(
    BuildContext context,
    int index,
    Feature? feature,
  ) {
    return Container(
      width: 280.w,
      margin: EdgeInsets.only(right: 16.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(10.r),
      ),
      padding: EdgeInsets.all(24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon with circular background
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              color: AppColors.backgroundColor,
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 20.h,
                    horizontal: 20.w,
                  ),
                  child: CommonNetworkImage(imageUrl: feature?.icon ?? ""),
                ),
              ),
            ),
          ),
          Gap(20.h),
          // Title
          Text(
            feature?.title ?? "",
            textAlign: TextAlign.center,
            style: TextStyles.semiBold(
              16.sp,
              fontColor: AppColors.black1414141,
            ),
          ),
          Gap(12.h),
          // Description
          Text(
            feature?.description ?? "",
            textAlign: TextAlign.center,
            style: TextStyles.regular(12.sp, fontColor: AppColors.black1414141),
          ),
        ],
      ),
    );
  }
}

/// Real Customers, Real Results Section Widget
class _RealCustomersSectionWidget extends StatefulWidget {
  const _RealCustomersSectionWidget(this.controller);
  final HomeController controller;
  @override
  State<_RealCustomersSectionWidget> createState() =>
      _RealCustomersSectionWidgetState();
}

class _RealCustomersSectionWidgetState
    extends State<_RealCustomersSectionWidget> {
  late ScrollController _scrollController;
  double _scrollPosition = 0.0;
  double _maxScrollExtent = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_updateScrollPosition);
    // Get initial scroll extent after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        setState(() {
          _maxScrollExtent = _scrollController.position.maxScrollExtent;
        });
      }
    });
  }

  void _updateScrollPosition() {
    if (_scrollController.hasClients) {
      setState(() {
        _scrollPosition = _scrollController.offset;
        _maxScrollExtent = _scrollController.position.maxScrollExtent;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backgroundColor,
      child: Column(
        children: [
          Gap(20.h),
          // Title with Navigation Arrows
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Title
                Expanded(
                  child: Text(
                    'home_real_customers'.tr,
                    textAlign: TextAlign.center,
                    style: TextStyles.bold(
                      18.sp,
                      fontColor: AppColors.black1414141,
                    ),
                  ),
                ),
                // Navigation Arrows
              ],
            ),
          ),
          Gap(15.h),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(
                      (_scrollController.offset - 300).clamp(
                        0.0,
                        _scrollController.position.maxScrollExtent,
                      ),
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                child: Container(
                  height: 40.h,
                  width: 40.w,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.chevron_left,
                      size: 25.sp,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              Gap(15),
              GestureDetector(
                onTap: () {
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(
                      (_scrollController.offset + 300).clamp(
                        0.0,
                        _scrollController.position.maxScrollExtent,
                      ),
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
                child: Container(
                  height: 40.h,
                  width: 40.w,

                  decoration: BoxDecoration(
                    color: AppColors.surfaceColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.chevron_right,
                      size: 25.sp,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Gap(20),
          // Horizontal Scrollable Review Cards
          SizedBox(
            height: 375.h,
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                // Prevent drawer from opening when scrolling horizontally
                return true;
              },
              child: Obx(() {
                // Make the list reactive to changes in landingPageData
                // Observe GlobalSettingsService.landingPageData directly to ensure reactivity
                GlobalSettingsService.to.landingPageData.value;
                return ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const ClampingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  itemCount: GlobalSettingsService
                      .to
                      .landingPageData
                      .value
                      ?.landingPage
                      ?.testimonialsSection
                      ?.testimonials
                      ?.length,
                  itemBuilder: (context, index) {
                    final review = GlobalSettingsService
                        .to
                        .landingPageData
                        .value
                        ?.landingPage
                        ?.testimonialsSection
                        ?.testimonials?[index];
                    return _buildCustomerReviewCard(context, review);
                  },
                );
              }),
            ),
          ),
          Gap(20.h),
          // Custom Scrollbar at the end
          LayoutBuilder(
            builder: (context, constraints) {
              final trackWidth = constraints.maxWidth;
              if (_maxScrollExtent <= 0) {
                return SizedBox(height: 4.0);
              }
              // Calculate viewport width (screen width minus padding)
              final viewportWidth = MediaQuery.of(context).size.width - 40.w;
              // Thumb width is proportional to viewport vs total scrollable width
              final thumbWidth =
                  (viewportWidth / (_maxScrollExtent + viewportWidth)) *
                  trackWidth;
              // Thumb position based on scroll offset
              final thumbPosition =
                  (_scrollPosition / _maxScrollExtent) *
                  (trackWidth - thumbWidth);

              return Container(
                height: 4.0,
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor,
                  borderRadius: BorderRadius.zero,
                ),
                child: Stack(
                  children: [
                    Positioned(
                      left: thumbPosition.clamp(0.0, trackWidth - thumbWidth),
                      child: Container(
                        width: thumbWidth,
                        height: 4.0,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerReviewCard(BuildContext context, Testimonial? review) {
    final product = (review != null && (review.products?.isNotEmpty ?? false))
        ? review.products!.first
        : null;
    if (product == null) {
      return SizedBox(width: 200.w, height: 280.h);
    }
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        if (product.id != null && product.id!.isNotEmpty) {
          Get.toNamed(
            AppRoutes.productDetail,
            arguments: {'productId': product.id},
          );
        }
      },
      child: Container(
        width: 200.w,
        height: 375.h,
        margin: EdgeInsets.only(right: 16.w),
        decoration: BoxDecoration(
          color: AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border(
            left: BorderSide(width: 1.1, color: AppColors.grayE3E3DC),
            right: BorderSide(width: 1.1, color: AppColors.grayE3E3DC),
            top: BorderSide(width: 1.1, color: AppColors.grayE3E3DC),
          ),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Half - Customer Image with Product Overlay
                Expanded(
                  flex: 2,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12.r),
                        topRight: Radius.circular(12.r),
                      ),
                      image: DecorationImage(
                        image: CachedNetworkImageProvider(
                          product.productImage ?? "",
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Product Overlay - Bottom Lef
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    width: Get.width,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceColor,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(12.r),
                        bottomRight: Radius.circular(12.r),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: 40.h),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: Text(
                                product.shortDescription ?? '',
                                textAlign: TextAlign.center,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyles.regular(
                                  12.sp,
                                  fontColor: AppColors.black1414141,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Gap(8.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${product.sachetPrices?.thirtyDays?.currency} '
                                '${product.sachetPrices?.thirtyDays?.totalAmount}',
                                style: TextStyles.semiBold(
                                  18.sp,
                                  fontColor: AppColors.primaryColor,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                '${product.sachetPrices?.thirtyDays?.amount}',
                                style: TextStyles.medium(
                                  14.sp,
                                  fontColor: AppColors.gray919191,
                                  textDecoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          ),
                        ),
                        AnimatedReviewAddButton(
                          key: ValueKey('${review?.id}_${product.isInCart}'),
                          product: product,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              // bottom: 120.h,
              // left: 120.w,
              child: Padding(
                padding: EdgeInsets.only(top: 0.h),
                child: Center(
                  child: Container(
                    width: 55.w,
                    height: 60.h,
                    decoration: BoxDecoration(
                      // color: AppColors.surfaceColor,
                      borderRadius: BorderRadius.circular(8.r),
                      // image: DecorationImage(
                      //   image: CachedNetworkImageProvider(review?.videoThumbnail ?? ""),
                      //   fit: BoxFit.cover,
                      // ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: CommonNetworkImage(
                        imageUrl: review?.videoThumbnail ?? "",
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// FAQ Section Widget with iOS-style notification animation
class _FAQSectionWidget extends StatefulWidget {
  const _FAQSectionWidget();

  @override
  State<_FAQSectionWidget> createState() => _FAQSectionWidgetState();
}

class _FAQSectionWidgetState extends State<_FAQSectionWidget>
    with TickerProviderStateMixin {
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _fadeAnimations;
  final List<bool> _isExpanded = List.generate(3, (_) => false);

  List<String> get _menuItems => ['home_faq'.tr, 'home_about_us'.tr, 'home_login'.tr];

  @override
  void initState() {
    super.initState();
    // Animation controllers for menu items (3) + social icons (4) = 7 total
    _animationControllers = List.generate(
      7,
      (index) => AnimationController(
        duration: Duration(milliseconds: 600 + (index * 80)),
        vsync: this,
      ),
    );

    _fadeAnimations = _animationControllers.map((controller) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));
    }).toList();

    // Start staggered animations
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (int i = 0; i < _animationControllers.length; i++) {
        Future.delayed(Duration(milliseconds: i * 80), () {
          if (mounted) {
            _animationControllers[i].forward();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _toggleExpansion(int index) {
    setState(() {
      _isExpanded[index] = !_isExpanded[index];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryColor,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Menu Items with staggered animations
          ...List.generate(_menuItems.length, (index) {
            return _buildMenuItem(_menuItems[index], index);
          }),
          Gap(12.h),
          // Social Media Icons with staggered animations
          Wrap(
            spacing: 15.w,
            children: List.generate(4, (index) {
              return FadeTransition(
                opacity: _fadeAnimations[_menuItems.length + index],
                child: _buildSocialIcon(index),
              );
            }),
          ),
          Gap(15.h),
        ],
      ),
    );
  }

  Widget _buildMenuItem(String title, int index) {
    final isExpanded = _isExpanded[index];

    return InkWell(
      onTap: () => _toggleExpansion(index),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 5.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyles.medium(
                15.sp,
                fontColor: AppColors.surfaceColor,
              ),
            ),
            AnimatedRotation(
              turns: isExpanded ? 0.5 : 0.0,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: Icon(
                Icons.add,
                color: AppColors.surfaceColor,
                size: 24.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialIcon(int index) {
    final socialIcons = [
      Assets.icons.icInstagram,
      Assets.icons.icFacebook,
      Assets.icons.icLinkedin,
      Assets.icons.icYoutube,
    ];

    return socialIcons[index].svg(
      width: 18.w,
      height: 18.w,
      colorFilter: ColorFilter.mode(
        AppColors.surfaceColor.withValues(alpha: 0.5),
        BlendMode.srcIn,
      ),
    );
  }
}

/// Animated Add Button for Review Cards (same as ProductCardWidget but with review card colors)
class AnimatedReviewAddButton extends StatefulWidget {
  final Product? product;

  const AnimatedReviewAddButton({super.key, required this.product});

  @override
  State<AnimatedReviewAddButton> createState() =>
      _AnimatedReviewAddButtonState();
}

enum _ReviewButtonState {
  initial,
  adding,
  grayWithCheck,
  blackFilling,
  success,
}

class _AnimatedReviewAddButtonState extends State<AnimatedReviewAddButton>
    with TickerProviderStateMixin {
  late AnimationController _grayFillAnimationController;
  late AnimationController _blackFillAnimationController;
  late AnimationController _scaleAnimationController;
  late Animation<double> _grayFillAnimation;
  late Animation<double> _blackFillAnimation;
  late Animation<double> _scaleAnimation;
  _ReviewButtonState _buttonState = _ReviewButtonState.initial;

  @override
  void initState() {
    super.initState();
    // Animation controller for gray fill animation
    _grayFillAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _grayFillAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _grayFillAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Animation controller for black fill animation (faster than gray)
    _blackFillAnimationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _blackFillAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _blackFillAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Animation controller for checkmark scale
    _scaleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _grayFillAnimationController.dispose();
    _blackFillAnimationController.dispose();
    _scaleAnimationController.dispose();
    super.dispose();
  }

  void _onButtonPressed() async {
    // Don't allow adding if already in cart
    if (widget.product?.isInCart == true) return;
    if (_buttonState != _ReviewButtonState.initial) return;
    if (widget.product?.id == null || widget.product!.id!.isEmpty) {
      CustomToast.show(context: context, message: 'home_product_id_missing'.tr);
      return;
    }

    setState(() {
      _buttonState = _ReviewButtonState.adding;
    });

    // Start gray fill animation
    _grayFillAnimationController.forward(from: 0.0);

    try {
      // Get ShopAllController for add to cart
      if (Get.isRegistered<ShopAllController>()) {
        final shopAllController = Get.find<ShopAllController>();
        // Call add to cart API
        final result = await shopAllController.addToCart(
          widget.product!.id!,
          "SACHETS",
        );
        final success = result['success'] as bool;
        final message = result['message'] as String? ?? '';

        if (!mounted) return;

        if (success) {
          // Update product's isInCart flag
          widget.product!.isInCart = true;
          // Update the product in the products list if it exists
          final index = shopAllController.products.indexWhere(
            (p) => p.id == widget.product!.id,
          );
          if (index != -1) {
            shopAllController.products[index].isInCart = true;
            shopAllController.products.refresh();
          }
          // Update categoryProducts if it exists
          final categoryIndex = shopAllController.categoryProducts.indexWhere(
            (p) => p.id == widget.product!.id,
          );
          if (categoryIndex != -1) {
            shopAllController.categoryProducts[categoryIndex].isInCart = true;
            shopAllController.categoryProducts.refresh();
          }

          // API call succeeded - ensure gray fill is complete before proceeding
          // Wait for gray fill animation to complete (minimum 400ms for visual feedback)
          await Future.wait([
            _grayFillAnimationController.forward(),
            Future.delayed(const Duration(milliseconds: 400)),
          ]);

          if (!mounted) return;

          setState(() {
            _buttonState = _ReviewButtonState.grayWithCheck;
          });

          // Start checkmark scale animation
          _scaleAnimationController.forward(from: 0.0);

          // Hold gray with checkmark for a moment, then start black fill
          await Future.delayed(const Duration(milliseconds: 500));
          if (!mounted) return;

          setState(() {
            _buttonState = _ReviewButtonState.blackFilling;
          });

          // Start black fill animation (gray stays visible underneath)
          await _blackFillAnimationController.forward();
          if (!mounted) return;

          // Show snackbar with API message
          CustomToast.showItemAddedToCart(
            context: context,
            message: message.isNotEmpty ? message : 'home_item_added_to_cart'.tr,
            onGoToCart: () {
              Get.find<DashboardController>().changeBottomNav(2);
            },
          );

          // After animation completes, show "Added" state
          await Future.delayed(const Duration(milliseconds: 400));
          if (!mounted) return;

          _grayFillAnimationController.reset();
          _blackFillAnimationController.reset();
          _scaleAnimationController.reset();

          setState(() {
            _buttonState = _ReviewButtonState.success;
          });
        } else {
          // API call failed - stop animations and reset to initial state
          _grayFillAnimationController.stop();
          _grayFillAnimationController.reset();
          _blackFillAnimationController.reset();
          _scaleAnimationController.reset();

          setState(() {
            _buttonState = _ReviewButtonState.initial;
          });

          // Show error message from API
          CustomToast.show(
            context: context,
            message: message.isNotEmpty
                ? message
                : 'home_failed_to_add_cart'.tr,
          );
        }
      } else {
        // ShopAllController not registered - reset animations
        _grayFillAnimationController.stop();
        _grayFillAnimationController.reset();
        _blackFillAnimationController.reset();
        _scaleAnimationController.reset();

        setState(() {
          _buttonState = _ReviewButtonState.initial;
        });

        CustomToast.show(context: context, message: 'home_failed_to_add_cart_short'.tr);
      }
    } catch (e) {
      // Handle any errors
      if (!mounted) return;

      _grayFillAnimationController.stop();
      _grayFillAnimationController.reset();
      _blackFillAnimationController.reset();
      _scaleAnimationController.reset();

      setState(() {
        _buttonState = _ReviewButtonState.initial;
      });

      // Show error message
      CustomToast.show(
        context: context,
        message: 'home_error_occurred'.tr,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Wrap in Obx to make it reactive to changes in landingPageData
    return Obx(() {
      // Observe landingPageData to trigger rebuilds when products are updated
      GlobalSettingsService.to.landingPageData.value;
      // Check if product is already in cart (re-evaluate on each build)
      final isInCart = widget.product?.isInCart == true;

      // Reset button state if product was removed from cart
      if (!isInCart && _buttonState == _ReviewButtonState.success) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _buttonState = _ReviewButtonState.initial;
            });
          }
        });
      }

      // Determine background color based on state
      final backgroundColor =
          (isInCart ||
              _buttonState == _ReviewButtonState.success ||
              _buttonState == _ReviewButtonState.grayWithCheck ||
              _buttonState == _ReviewButtonState.blackFilling)
          ? AppColors.gray949391
          : AppColors.whiteFAF6E4;

      return Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border(
            bottom: BorderSide(color: AppColors.grayE3E3DC, width: 1),
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(12.r),
            bottomRight: Radius.circular(12.r),
          ),
        ),
        child: ClipRRect(
          clipBehavior: Clip.antiAlias,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(12.r),
            bottomRight: Radius.circular(12.r),
          ),
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              // Base button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isInCart ? null : _onButtonPressed,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: backgroundColor,
                    foregroundColor: AppColors.textPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(12.r),
                        bottomRight: Radius.circular(12.r),
                      ),
                    ),
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    side: BorderSide.none,
                    surfaceTintColor: Colors.transparent,
                  ),
                  child: _buildButtonContent(isInCart),
                ),
              ),
              // Gray color fill animation overlay (during adding state)
              if (_buttonState == _ReviewButtonState.adding)
                AnimatedBuilder(
                  animation: _grayFillAnimation,
                  builder: (context, child) {
                    return Positioned.fill(
                      child: IgnorePointer(
                        child: Stack(
                          children: [
                            // Gray fill animation
                            ClipRect(
                              child: FractionallySizedBox(
                                widthFactor: _grayFillAnimation.value,
                                alignment: Alignment.centerLeft,
                                child: SizedBox.expand(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.gray949391,
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(12.r),
                                        bottomRight: Radius.circular(12.r),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // "Adding" text on top of gray fill
                            Center(
                              child: Text(
                                'home_adding'.tr,
                                style: TextStyles.semiBold(
                                  15.sp,
                                  fontColor: AppColors.surfaceColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              // Gray background with checkmark (after gray fill completes) - only during animation states
              // Note: success state and isInCart don't need overlay, button content will show through
              if (_buttonState == _ReviewButtonState.grayWithCheck ||
                  _buttonState == _ReviewButtonState.blackFilling)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.gray949391,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(12.r),
                          bottomRight: Radius.circular(12.r),
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Black fill animation (only during blackFilling state)
                          if (_buttonState == _ReviewButtonState.blackFilling)
                            AnimatedBuilder(
                              animation: _blackFillAnimation,
                              builder: (context, child) {
                                return ClipRect(
                                  child: FractionallySizedBox(
                                    widthFactor: _blackFillAnimation.value,
                                    alignment: Alignment.centerLeft,
                                    child: SizedBox.expand(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.secondaryColor,
                                          borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(12.r),
                                            bottomRight: Radius.circular(12.r),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          // Checkmark icon on top of gray/black background (only show during animation states)
                          if (_buttonState ==
                                  _ReviewButtonState.grayWithCheck ||
                              _buttonState == _ReviewButtonState.blackFilling)
                            Center(
                              child: AnimatedBuilder(
                                animation: _scaleAnimation,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: _scaleAnimation.value,
                                    child: Assets.icons.icCheck.svg(
                                      colorFilter: ColorFilter.mode(
                                        AppColors.whiteFAF6E4,
                                        BlendMode.srcIn,
                                      ),
                                      width: 15.w,
                                    ),
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildButtonContent(bool isInCart) {
    // If product is already in cart, show "Added" state
    if (isInCart) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check, size: 16.sp, color: AppColors.whiteFAF6E4),
          Gap(6.w),
          Text(
            'home_added'.tr,
            style: TextStyles.bold(15.sp, fontColor: AppColors.whiteFAF6E4),
          ),
        ],
      );
    }

    switch (_buttonState) {
      case _ReviewButtonState.initial:
        return Text(
          'ADD+',
          style: TextStyles.bold(15.sp, fontColor: AppColors.secondaryColor),
        );
      case _ReviewButtonState.adding:
        return Text(
          'home_adding'.tr,
          style: TextStyles.bold(15.sp, fontColor: AppColors.secondaryColor),
        );
      case _ReviewButtonState.grayWithCheck:
      case _ReviewButtonState.blackFilling:
        // Icon is shown in overlay, so return empty widget
        return const SizedBox.shrink();
      case _ReviewButtonState.success:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check, size: 16.sp, color: AppColors.whiteFAF6E4),
            Gap(6.w),
            Text(
              'home_added'.tr,
              style: TextStyles.bold(15.sp, fontColor: AppColors.whiteFAF6E4),
            ),
          ],
        );
    }
  }
}

/// Shimmer Banner Widget with animated gradient effect on entire container
class _ShimmerBanner extends StatefulWidget {
  final Widget child;
  final Color shimmerColor;

  const _ShimmerBanner({required this.child, this.shimmerColor = Colors.white});

  @override
  State<_ShimmerBanner> createState() => _ShimmerBannerState();
}

class _ShimmerBannerState extends State<_ShimmerBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // Shimmer animation duration - sweeps across in 1.5 seconds
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Animation value from -1.0 to 2.0 to ensure full coverage
    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Start the shimmer animation immediately, then every 5 seconds
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startShimmerCycle(initialDelay: 0);
    });
  }

  void _startShimmerCycle({int initialDelay = 5}) {
    // Wait specified seconds, then animate shimmer
    Future.delayed(Duration(seconds: initialDelay), () {
      if (mounted) {
        _controller.forward(from: 0.0).then((_) {
          if (mounted) {
            _controller.reset();
            // Repeat the cycle with 5 second delay
            _startShimmerCycle(initialDelay: 5);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        // Only show shimmer when animation is running (not at 0.0)
        final isAnimating = _controller.value > 0.0 && _controller.value < 1.0;

        if (!isAnimating) {
          // Default state when not shimmering
          return widget.child;
        }

        // Calculate shimmer position (0.0 to 1.0)
        final shimmerPosition = (_animation.value + 1.0) / 3.0;
        final shimmerWidth = 0.4; // Width of the shimmer highlight

        return Stack(
          children: [
            // Original child
            widget.child,
            // Shimmer overlay with visible highlight
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final containerWidth = constraints.maxWidth;
                  final shimmerLeft =
                      (shimmerPosition - shimmerWidth / 2) * containerWidth;

                  return Stack(
                    children: [
                      Positioned(
                        left: shimmerLeft.clamp(0.0, containerWidth),
                        width: (shimmerWidth * containerWidth).clamp(
                          0.0,
                          containerWidth,
                        ),
                        top: 0,
                        bottom: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Colors.transparent,
                                widget.shimmerColor.withValues(alpha: 0.3),
                                widget.shimmerColor.withValues(alpha: 0.6),
                                widget.shimmerColor.withValues(alpha: 0.3),
                                Colors.transparent,
                              ],
                              stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Animated Image Container with zoom-out animation
class _AnimatedImageContainer extends StatefulWidget {
  final String imagePath;
  final double height;

  const _AnimatedImageContainer({
    required this.imagePath,
    required this.height,
  });

  @override
  State<_AnimatedImageContainer> createState() =>
      _AnimatedImageContainerState();
}

class _AnimatedImageContainerState extends State<_AnimatedImageContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _scaleAnimation =
        Tween<double>(
          begin: 1.3, // Start zoomed in
          end: 1.0, // End at normal size
        ).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );
    // Start animation after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(0.r),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              height: widget.height,
              decoration: BoxDecoration(
                color: AppColors.backgroundColor,
                borderRadius: BorderRadius.circular(0.r),
                image: DecorationImage(
                  image: CachedNetworkImageProvider(widget.imagePath),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Reactive AppBar that adjusts height based on selected tab
class _ReactiveAppBar extends GetView<HomeController>
    implements PreferredSizeWidget {
  final Widget Function(BuildContext) buildCustomAppBar;
  final Widget Function(BuildContext) buildNavigationTabs;
  final Widget Function(BuildContext) buildPromotionalBanner;

  const _ReactiveAppBar({
    required this.buildCustomAppBar,
    required this.buildNavigationTabs,
    required this.buildPromotionalBanner,
  });

  @override
  Size get preferredSize {
    return Size.fromHeight(135.h);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Observe currentTabIndex to trigger rebuild when tab changes
      final _ = controller.currentTabIndex.value;
      return PreferredSize(
        preferredSize: Size.fromHeight(135.h),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SafeArea(
              bottom: false,
              child: Builder(
                builder: (context) {
                  final appBarContent = Container(
                    key: const ValueKey('appbar_content'),
                    constraints: BoxConstraints(
                      maxHeight: constraints.maxHeight.isFinite
                          ? constraints.maxHeight
                          : double.infinity,
                      minHeight: 0,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Custom AppBar
                        buildCustomAppBar(context),
                        SizedBox(height: 6.h),
                        // Navigation Tabs
                        Row(
                          children: [
                            Expanded(child: buildNavigationTabs(context)),
                            Expanded(child: SizedBox()),
                          ],
                        ),
                        // Promotional banner temporarily disabled
                        Obx(() {
                          final isHomeTab =
                              controller.currentTabIndex.value == 0;
                          if (!isHomeTab) {
                            return const SizedBox.shrink();
                          }
                          final bannerContent = buildPromotionalBanner(context);
                          if (controller
                              .bannerAnimationController
                              .isCompleted) {
                            return ClipRect(child: bannerContent);
                          }
                          return ClipRect(
                            child: AnimatedBuilder(
                              animation: controller.bannerSlideAnimation,
                              builder: (context, child) {
                                return SlideTransition(
                                  position: controller.bannerSlideAnimation,
                                  child: bannerContent,
                                );
                              },
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                  // Don't wrap appbar in animation - let individual widgets animate
                  return appBarContent;
                },
              ),
            );
          },
        ),
      );
    });
  }
}

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:viteezy/core/models/home_data_model.dart';
import 'package:viteezy/core/services/global_settings_service.dart';
import 'package:viteezy/core/utils/dialog_service.dart';

import '../../shop_all_view/controller/shop_all_controller.dart';

/// Home Controller
class HomeController extends GetxController
    with GetTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController tabController;
  final RxInt currentTabIndex = 0.obs;
  final RxBool showAppIcon = false.obs;
  late AnimationController bannerAnimationController;
  late Animation<Offset> bannerSlideAnimation;
  bool _isDisposed = false; // Flag to track if controller is disposed
  
  /// Check if controller is still active (not disposed)
  bool get isActive => !_isDisposed;

  // Home data - directly use GlobalSettingsService
  // Getter to access landing page data from GlobalSettingsService
  HomeData? get homeData => GlobalSettingsService.to.landingPageData.value;
  
  // Loading state - observe GlobalSettingsService loading state
  bool get isLoadingHomeData => !GlobalSettingsService.to.isLandingPageLoaded.value;

  // Animation controllers for home view animations
  late AnimationController heroSectionAnimationController;
  late Animation<Offset> heroSectionSlideAnimation;
  late AnimationController bottomSectionsAnimationController;
  late Animation<Offset> bottomSectionsSlideAnimation;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    // Initialize video when landing page data is available
    _initializeVideoWhenReady();

    tabController = TabController(length: 2, vsync: this);
    // Initialize banner animation
    bannerAnimationController = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    bannerSlideAnimation =
        Tween<Offset>(
          begin: const Offset(0.0, -1.0), // Start from behind app bar (completely hidden above)
          end: Offset.zero, // End at normal position
        ).animate(
          CurvedAnimation(
            parent: bannerAnimationController,
            curve: Curves.easeOutCubic, // Smooth easing for appearance
          ),
        );

    // Initialize Hero Section animation (right to left)
    heroSectionAnimationController = AnimationController(duration: const Duration(milliseconds: 700), vsync: this);
    heroSectionSlideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0), // Start from right
      end: Offset.zero, // End at normal position
    ).animate(CurvedAnimation(parent: heroSectionAnimationController, curve: Curves.easeOutCubic));

    // Initialize Bottom Sections animation (left to right)
    bottomSectionsAnimationController = AnimationController(duration: const Duration(milliseconds: 700), vsync: this);
    bottomSectionsSlideAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0), // Start from left
      end: Offset.zero, // End at normal position
    ).animate(CurvedAnimation(parent: bottomSectionsAnimationController, curve: Curves.easeOutCubic));

    tabController.addListener(() {
      if (_isDisposed) return; // Don't process if disposed
      
      if (tabController.indexIsChanging || tabController.index != currentTabIndex.value) {
        currentTabIndex.value = tabController.index;
        // Animate banner when switching to home tab
        if (tabController.index == 0) {
          // Initialize video if data is available
          if (homeData != null && !isVideoInitialized.value) {
            _initializeVideo();
          }
          // Slide down from behind app bar (top to bottom)
          if (!_isDisposed && bannerAnimationController.isAnimating == false) {
            bannerAnimationController.forward();
          }

          // Start home animations
          if (!_isDisposed && !heroSectionAnimationController.isCompleted) {
            heroSectionAnimationController.forward();
          }
          if (!_isDisposed && !bottomSectionsAnimationController.isCompleted) {
            bottomSectionsAnimationController.forward();
          }

          // Show lottie immediately without animation
          showAppIcon.value = true;
        } else {
          // Slide up behind app bar (bottom to top)
          Get.find<ShopAllController>().getProductAll(isRefresh: true);
          // Get.find<ShopAllController>().getProductCategories();
          Get.find<ShopAllController>().getProductFilters();
          if (!_isDisposed && bannerAnimationController.isAnimating == false) {
            bannerAnimationController.reverse();
          }
          // Don't reset appbar animations - keep them in place
          // Always show lottie on Shop All tab (it will be visible but not animated)
          showAppIcon.value = true;
        }
      }
    });

    Future.delayed(const Duration(milliseconds: 2200), () {
      if (!_isDisposed) {
        showAppIcon.value = true;
      }
    });

    // Start animations when home tab is initially selected
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isDisposed) return; // Don't process if disposed
      
      if (currentTabIndex.value == 0) {
        // Show lottie immediately without animation
        showAppIcon.value = true;

        // Start banner animation
        if (!_isDisposed && bannerAnimationController.isAnimating == false) {
          bannerAnimationController.forward();
        }

        // Start Hero Section and Bottom Sections animations
        Future.delayed(const Duration(milliseconds: 400), () {
          if (!_isDisposed) {
            if (heroSectionAnimationController.isAnimating == false) {
              heroSectionAnimationController.forward();
            }
            if (bottomSectionsAnimationController.isAnimating == false) {
              bottomSectionsAnimationController.forward();
            }
          }
        });
      } else {
        // Keep it hidden when not on home tab
        if (!_isDisposed) {
          bannerAnimationController.value = 0.0;
        }
        // Don't reset appbar animations - keep them in place
        // Keep showAppIcon as is - lottie will be visible but not animated on Shop All tab
      }
    });
  }

  /// Initialize video when landing page data is ready
  Future<void> _initializeVideoWhenReady() async {
    // Check if data is already available
    if (homeData != null) {
      await _initializeVideo();
    } else {
      // Listen for when data becomes available
      ever(GlobalSettingsService.to.landingPageData, (data) {
        if (data != null && !isVideoInitialized.value) {
          _initializeVideo();
        }
      });
    }
  }

  // Video player state
  VideoPlayerController? videoPlayerController;
  final RxBool isVideoInitialized = false.obs;
  final RxBool isVideoPlaying = false.obs;
  final RxBool showPlayButton = false.obs;
  final RxBool isVideoLoading = true.obs;
  final RxBool isVideoMuted = false.obs;

  /// Initialize video player
  Future<void> _initializeVideo() async {
    try {
      isVideoLoading.value = true;
      final videoUrl = homeData?.landingPage?.heroSection?.videoUrl ?? "";
      if (videoUrl.isEmpty) {
        isVideoLoading.value = false;
        isVideoInitialized.value = false;
        return;
      }
      videoPlayerController = VideoPlayerController.networkUrl(
        Uri.parse(videoUrl),
      );
      await videoPlayerController!.initialize();

      // Set video to loop
      videoPlayerController!.setLooping(true);

      // Set up listener for video state changes
      videoPlayerController!.addListener(_videoListener);

      isVideoInitialized.value = true;
      isVideoLoading.value = false;

      // Auto-play video (start unmuted)
      await videoPlayerController!.setVolume(1);
      await videoPlayerController!.play();
      isVideoPlaying.value = true;
      showPlayButton.value = false;
    } catch (e) {
      log('Error initializing video: $e');
      isVideoLoading.value = false;
      isVideoInitialized.value = false;
    }
  }

  /// Video state listener
  void _videoListener() {
    if (videoPlayerController != null) {
      if (videoPlayerController!.value.isPlaying) {
        isVideoPlaying.value = true;
        showPlayButton.value = false;
      } else {
        isVideoPlaying.value = false;
        // Only show play button if video is initialized and not loading
        if (isVideoInitialized.value && !isVideoLoading.value) {
          showPlayButton.value = true;
        }
      }
    }
  }

  /// Toggle play/pause on video area tap
  Future<void> onVideoAreaTap() async {
    if (videoPlayerController == null || !isVideoInitialized.value) return;

    if (isVideoPlaying.value) {
      // Pause video
      await videoPlayerController!.pause();
      isVideoPlaying.value = false;
      showPlayButton.value = true;
    } else {
      // Play video
      await videoPlayerController!.play();
      isVideoPlaying.value = true;
      showPlayButton.value = false;
    }
  }

  /// Play button tap handler
  Future<void> onPlayButtonTap() async {
    await onVideoAreaTap();
  }

  /// Toggle video mute/unmute
  Future<void> toggleVideoMute() async {
    if (videoPlayerController == null || !isVideoInitialized.value) return;
    isVideoMuted.value = !isVideoMuted.value;
    await videoPlayerController!.setVolume(isVideoMuted.value ? 0 : 1);
  }

  /// Pause video when leaving home (tab change, app background, or screen push).
  /// Call from DashboardController when switching tab or from NavigatorObserver when route is pushed.
  Future<void> pauseVideoWhenLeavingHome() async {
    if (videoPlayerController == null || !isVideoInitialized.value) return;
    if (!isVideoPlaying.value) return;
    try {
      await videoPlayerController!.pause();
      isVideoPlaying.value = false;
      showPlayButton.value = true;
    } catch (_) {}
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      pauseVideoWhenLeavingHome();
    }
  }

  /// Show discount dialog
  void showDiscountDialog() {
    DialogService.showDiscountDialog(
      onClaimDiscount: (email) {
        // Handle discount claim
        log('Discount claimed for email: $email');
        // TODO: Implement API call to claim discount
        Get.snackbar('Success', 'Discount code sent to $email', snackPosition: SnackPosition.BOTTOM);
      },
      onClose: () {
        log('Discount dialog closed');
      },
    );
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _isDisposed = true; // Mark as disposed before disposing controllers
    bannerAnimationController.dispose();
    heroSectionAnimationController.dispose();
    bottomSectionsAnimationController.dispose();
    tabController.dispose();
    videoPlayerController?.removeListener(_videoListener);
    videoPlayerController?.dispose();
    super.onClose();
  }
}

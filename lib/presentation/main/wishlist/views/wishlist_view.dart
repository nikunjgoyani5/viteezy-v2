import 'package:viteezy/core/models/product_response_model.dart';
import 'package:viteezy/core/routes/app_routes.dart';
import 'package:viteezy/core/utils/app_functions.dart';
import 'package:viteezy/core/utils/app_prefrence.dart';
import 'package:viteezy/core/utils/dialog_service.dart';
import 'package:viteezy/core/utils/exports.dart';
import 'package:viteezy/core/widgets/common_product_card_shimmer.dart';
import 'package:viteezy/core/widgets/product_card_widget.dart';

import 'package:viteezy/gen/assets.gen.dart';
import '../../../../core/widgets/common_appbar.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../../shop_all_view/controller/shop_all_controller.dart';
import '../controllers/wishlist_controller.dart';

class WishlistView extends StatefulWidget {
  const WishlistView({super.key});

  @override
  State<WishlistView> createState() => _WishlistViewState();
}

class _WishlistViewState extends State<WishlistView> {
  late WishlistController controller;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<WishlistController>()) {
      Get.put(WishlistController());
    }
    controller = Get.find<WishlistController>();
    final isLoggedIn =
        PrefService.getBool(PrefKeys.isLogin) && PrefService.getString(PrefKeys.accessToken).isNotEmpty;
    if (isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) controller.getProductWishlist(isRefresh: true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool canPop = Navigator.canPop(context);

    // Check login only when accessed directly (not from IndexedStack in dashboard)
    // When accessed via bottom nav, dashboard controller handles the check
    if (canPop) {
      final isLoggedIn =
          PrefService.getBool(PrefKeys.isLogin) && PrefService.getString(PrefKeys.accessToken).isNotEmpty;
      if (!isLoggedIn) {
        // Show login dialog for direct navigation
        WidgetsBinding.instance.addPostFrameCallback((_) {
          DialogService.showLoginRequiredDialog(
            message: 'wishlist_login_required'.tr,
            onLogin: () {
              Get.toNamed(AppRoutes.login);
            },
          );
        });
        return Scaffold(
          appBar: CommonAppbar(title: 'wishlist_title'.tr, showBackButton: canPop, centerTitle: !canPop),
          backgroundColor: AppColors.backgroundColor,
          body: const SizedBox.shrink(),
        );
      }
    }

    return Scaffold(
      appBar: CommonAppbar(title: 'wishlist_title'.tr, showBackButton: canPop, centerTitle: !canPop),
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Products Grid
            Expanded(child: _buildProductsGrid()),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsGrid() {
    return GetBuilder<WishlistController>(
      builder: (controller) {
        return Obx(() {
          if (controller.loader.value) {
            return CommonProductCardShimmer();
          } else if (controller.wishlistProductList.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.h),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Assets.icons.icEmptyWhishlist.svg(),
                    Gap(16.h),
                    Text('wishlist_empty'.tr, style: TextStyles.bold(18.sp, fontColor: AppColors.black1414141)),
                    Gap(8.h),
                    Text(
                      'wishlist_empty_subtitle'.tr,
                      style: TextStyles.regular(15.sp, fontColor: AppColors.grey6D6D6D),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }
          return Stack(
            children: [
              RefreshIndicator(
                onRefresh: () async {
                  // Refresh wishlist data when user pulls down
                  await controller.refreshWishlist();
                },
                child: NotificationListener(
                  onNotification: (notification) {
                    if (notification is ScrollEndNotification && notification.metrics.extentAfter == 0) {
                      if ((controller.wishlistModel.pagination?.page ?? 0) <
                          (controller.wishlistModel.pagination?.pages ?? 0)) {
                        controller.loadMoreWishlistData();
                      }
                    }
                    return false;
                  },
                  child: GridView.builder(
                    physics:
                        const AlwaysScrollableScrollPhysics(), // Enable pull-to-refresh even when content doesn't scroll
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.55,
                    ),
                    itemCount: controller.wishlistProductList.length,
                    itemBuilder: (context, index) {
                      Product product = controller.wishlistProductList[index];
                      return _AnimatedWishlistItem(
                        key: ValueKey(product.id ?? index),
                        product: product,
                        index: index,
                        onRemove: () {
                          controller.wishlistProductList.removeAt(index);
                          controller.update();
                          AppFunctions().showToast('wishlist_item_removed'.tr);
                          controller.toggleLikeDislike(productId: product.id ?? '', index: index);
                        },
                      );
                    },
                  ),
                ),
              ),
              controller.isMoreLoading.value
                  ? const Align(alignment: Alignment.bottomCenter, child: LinearProgressIndicator())
                  : const SizedBox.shrink(),
            ],
          );
        });
      },
    );
  }
}

/// Animated wishlist item with fade and scale animation on delete
class _AnimatedWishlistItem extends StatefulWidget {
  final Product product;
  final int index;
  final VoidCallback onRemove;

  const _AnimatedWishlistItem({required super.key, required this.product, required this.index, required this.onRemove});

  @override
  State<_AnimatedWishlistItem> createState() => _AnimatedWishlistItemState();
}

class _AnimatedWishlistItemState extends State<_AnimatedWishlistItem> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  bool _isRemoving = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onRemove();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleRemove() {
    if (_isRemoving) return;
    setState(() => _isRemoving = true);
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: ProductCardWidget(
          product: widget.product,
          // screenName: 'wishlist',
          onTap: () {
            if (widget.product.id != null && widget.product.id!.isNotEmpty) {
              Get.toNamed(
                AppRoutes.productDetail,
                arguments: {'productId': widget.product.id, 'heroTag': 'wishlist_product_image_${widget.product.id}'},
              );
            }
          },
          onFavoriteTap: _handleRemove,
          onAddToCart: () async {
            if (widget.product.id == null || widget.product.id!.isEmpty) {
              return {'success': false, 'message': 'Product ID is missing'};
            }

            try {
              // Get ShopAllController for add to cart
              if (Get.isRegistered<ShopAllController>()) {
                final shopAllController = Get.find<ShopAllController>();
                // Call add to cart API with default SACHETS variant
                final result = await shopAllController.addToCart(widget.product.id!, "SACHETS");

                if (result['success'] == true) {
                  // Update product's isInCart flag
                  widget.product.isInCart = true;
                  // Update selectedProduct if it matches
                  if (shopAllController.selectedProduct.value?.id == widget.product.id) {
                    shopAllController.selectedProduct.value?.isInCart = true;
                    shopAllController.selectedProduct.refresh();
                  }
                  // Update the product in the products list if it exists
                  final index = shopAllController.products.indexWhere((p) => p.id == widget.product.id);
                  if (index != -1) {
                    shopAllController.products[index].isInCart = true;
                    shopAllController.products.refresh();
                  }
                  // Update categoryProducts if it exists
                  final categoryIndex = shopAllController.categoryProducts.indexWhere((p) => p.id == widget.product.id);
                  if (categoryIndex != -1) {
                    shopAllController.categoryProducts[categoryIndex].isInCart = true;
                    shopAllController.categoryProducts.refresh();
                  }
                }

                return result;
              }
              return {'success': false, 'message': 'Failed to add to cart'};
            } catch (e) {
              return {'success': false, 'message': 'An error occurred. Please try again.'};
            }
          },
          onGoToCart: () {
            Navigator.pop(context);
            Get.find<DashboardController>().changeBottomNav(2);
          },
        ),
      ),
    );
  }
}

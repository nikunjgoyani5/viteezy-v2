import 'package:viteezy/core/routes/app_routes.dart';
import 'package:viteezy/core/utils/app_prefrence.dart';
import 'package:viteezy/core/utils/exports.dart';
import 'package:viteezy/core/widgets/product_card_widget.dart';
import 'package:viteezy/core/widgets/common_network_image.dart';
import 'package:viteezy/core/widgets/shimmer_widget.dart';
import 'package:viteezy/presentation/main/dashboard/controllers/dashboard_controller.dart';

import '../controller/shop_all_controller.dart';

class ShopAllView extends GetView<ShopAllController> {
  const ShopAllView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<ShopAllController>()) {
      Get.put(ShopAllController());
    }
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top Filter Bar
            _buildTopFilterBar(context: context),

            // Scrollable Content (Category Section + Products Grid)
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  // Refresh all related APIs when user pulls down
                  await controller.refreshAllData();
                },
                child: NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification scrollInfo) {
                    if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 200) {
                      // User is near the bottom, load more products
                      if (!controller.isLoadingMore.value && controller.hasMore) {
                        controller.loadMoreProducts();
                      }
                    }
                    return false;
                  },
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(), // Enable pull-to-refresh even when content doesn't scroll
                    slivers: [
                      // Category Section
                      SliverToBoxAdapter(child: _buildCategorySection()),

                      // Products Grid
                      _buildProductsGridSliver(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopFilterBar({required BuildContext context}) {
    return Obx(() {
      final selectedIngredients = controller.selectedIngredients;
      final selectedHealthGoals = controller.selectedHealthGoals;
      final selectedProductTypes = controller.selectedProductTypes;

      // Build list of active filters
      final activeFilters = <Widget>[];

      if (selectedIngredients.isNotEmpty) {
        activeFilters.add(
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(color: AppColors.primaryColor, borderRadius: BorderRadius.circular(30)),
            child: Text(
              "Ingredient (${selectedIngredients.length})",
              style: TextStyles.regular(12.sp, fontColor: AppColors.surfaceColor),
            ),
          ),
        );
      }

      if (selectedHealthGoals.isNotEmpty) {
        activeFilters.add(
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(color: AppColors.primaryColor, borderRadius: BorderRadius.circular(30)),
            child: Text(
              "Health Goal (${selectedHealthGoals.length})",
              style: TextStyles.regular(12.sp, fontColor: AppColors.surfaceColor),
            ),
          ),
        );
      }

      if (selectedProductTypes.isNotEmpty) {
        activeFilters.add(
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(color: AppColors.primaryColor, borderRadius: BorderRadius.circular(30)),
            child: Text(
              "Product Type (${selectedProductTypes.length})",
              style: TextStyles.regular(12.sp, fontColor: AppColors.surfaceColor),
            ),
          ),
        );
      }

      return Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        color: AppColors.surfaceColor,
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              SizedBox(width: 11.w),
              GestureDetector(
                onTap: () => controller.showSortAndFilters(false),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                  decoration: BoxDecoration(color: AppColors.backgroundColor, borderRadius: BorderRadius.circular(30)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('shop_sort_filters'.tr, style: TextStyles.medium(12.sp, fontColor: AppColors.black1414141)),
                      Gap(4.w),
                      Icon(Icons.keyboard_arrow_down, size: 18.sp),
                    ],
                  ),
                ),
              ),
              if (activeFilters.isNotEmpty) Gap(10.w),
              ..._buildFilterChipsWithSpacing(activeFilters),
              SizedBox(width: 11.w),
            ],
          ),
        ),
      );
    });
  }

  List<Widget> _buildFilterChipsWithSpacing(List<Widget> filters) {
    if (filters.isEmpty) return [];
    if (filters.length == 1) return filters;

    final result = <Widget>[];
    for (int i = 0; i < filters.length; i++) {
      result.add(filters[i]);
      if (i < filters.length - 1) {
        result.add(Gap(10.w));
      }
    }
    return result;
  }

  Widget _buildCategorySection() {
    return Obx(
      () => Container(
        height: 133.h,
        padding: EdgeInsets.only(top: 10.h),
        child: (controller.categories?.isEmpty ?? true)
            // Show shimmer only when list is empty (first load)
            ? _buildCategoryShimmer()
            // When we already have data, always show list (even while refreshing)
            : ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: controller.categories?.length ?? 0,
                itemBuilder: (context, index) {
                  final category = controller.categories?[index];
                  // Use only the icon from API (assumed to be a full image URL)
                  final iconUrl = category?.icon ?? '';
                  return Obx(
                    () => _buildCategoryItem(
                      category?.name ?? "",
                      iconUrl,
                      index,
                      controller.selectedCategory.value == index,
                      context,
                    ),
                  );
                },
              ),
      ),
    );
  }

  /// Simple shimmer-style placeholder list for categories
  Widget _buildCategoryShimmer() {
    return ShimmerWidget(
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: 6,
        separatorBuilder: (_, __) => SizedBox(width: 16.w),
        itemBuilder: (_, __) {
          return SizedBox(
            width: 105,
            child: Column(
              children: [
                // Circle placeholder for icon
                Container(
                  width: 90.w,
                  height: 90.w,
                  decoration: BoxDecoration(color: AppColors.grayE3E3DC, shape: BoxShape.circle),
                ),
                SizedBox(height: 8.h),
                // Rectangle placeholder for text
                Container(
                  width: 80.w,
                  height: 12.h,
                  decoration: BoxDecoration(color: AppColors.grayE3E3DC, borderRadius: BorderRadius.circular(6)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryItem(String name, String icon, int index, bool isSelected, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(AppRoutes.categoryProductView, arguments: {"cate": name});
      },
      child: SizedBox(
        width: 105,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipOval(
              child: CommonNetworkImage(imageUrl: icon, width: 70.w, height: 70.w, fit: BoxFit.cover),
            ),
            SizedBox(height: 4.h),
            Flexible(
              child: Text(
                name,
                style: TextStyles.medium(13.sp, fontColor: AppColors.black1414141),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsGridSliver() {
    return Obx(() {
      // Show shimmer only on first load when products are empty
      // On refresh, we keep showing existing products (no shimmer)
      final shouldShowShimmer = controller.isLoading.value && controller.products.isEmpty;

      if (shouldShowShimmer) {
        return SliverPadding(
          padding: EdgeInsets.only(bottom: 10.h,left: 16.w,right: 16.w),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.6,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              return ShimmerWidget(
                child: Container(
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Image Section (takes most space)
                      Expanded(
                        flex: 1,
                        child: Stack(
                          children: [
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppColors.grayE3E3DC,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                ),
                              ),
                            ),
                            // Favorite button placeholder
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                width: 30.w,
                                height: 30.w,
                                decoration: BoxDecoration(color: AppColors.grayE3E3DC, shape: BoxShape.circle),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Product Info Section
                      Padding(
                        padding: EdgeInsets.all(8.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product Name and Discount Tag
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 14.h,
                                    decoration: BoxDecoration(
                                      color: AppColors.grayE3E3DC,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                                Gap(4.w),
                                // Discount tag with rounded right corners
                                Container(
                                  width: 60.w,
                                  height: 18.h,
                                  decoration: BoxDecoration(
                                    color: AppColors.grayE3E3DC,
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(50),
                                      bottomRight: Radius.circular(50),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Gap(4.h),
                            // Product Description (2 lines)
                            Container(
                              width: double.infinity,
                              height: 10.h,
                              decoration: BoxDecoration(
                                color: AppColors.grayE3E3DC,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            Gap(4.h),
                            Container(
                              width: 100.w,
                              height: 10.h,
                              decoration: BoxDecoration(
                                color: AppColors.grayE3E3DC,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            Gap(10.h),
                            // Price and Rating Row
                            Row(
                              children: [
                                Container(
                                  width: 45.w,
                                  height: 14.h,
                                  decoration: BoxDecoration(
                                    color: AppColors.grayE3E3DC,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                Gap(4.w),
                                Container(
                                  width: 40.w,
                                  height: 14.h,
                                  decoration: BoxDecoration(
                                    color: AppColors.grayE3E3DC,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                Spacer(),
                                // Star icon placeholder
                                Container(
                                  width: 12.w,
                                  height: 12.w,
                                  decoration: BoxDecoration(color: AppColors.grayE3E3DC, shape: BoxShape.circle),
                                ),
                                Gap(2.w),
                                Container(
                                  width: 25.w,
                                  height: 14.h,
                                  decoration: BoxDecoration(
                                    color: AppColors.grayE3E3DC,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Add to Cart Button
                      Container(
                        width: double.infinity,
                        height: 40.h,
                        decoration: BoxDecoration(
                          color: AppColors.grayE3E3DC,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(10),
                            bottomRight: Radius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }, childCount: 6),
          ),
        );
      }

      // Show empty state only if not loading and no products
      if (controller.products.isEmpty && !controller.isLoading.value) {
        return SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Text('browse_no_products_found'.tr, style: TextStyles.regular(16.sp, fontColor: AppColors.textSecondary)),
          ),
        );
      }

      return SliverPadding(
        padding: EdgeInsets.only(bottom: 10.h,left: 16.w,right: 16.w),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.55,
          ),
          delegate: SliverChildBuilderDelegate((context, index) {
            final product = controller.products[index];
            return ProductCardWidget(
              product: product,
              screenName: 'shop_all',
              onFavoriteTap: () {
                // Check login before updating UI
                final isLoggedIn = PrefService.getBool(PrefKeys.isLogin) && 
                                  PrefService.getString(PrefKeys.accessToken).isNotEmpty;
                if (!isLoggedIn) {
                  // Show login dialog - don't update UI
                  DialogService.showLoginRequiredDialog(
                    message: 'product_detail_login_wishlist'.tr,
                    onLogin: () {
                      Get.toNamed(AppRoutes.login);
                    },
                  );
                  return;
                }
                // Optimistically update the UI only if logged in
                product.isLiked = !(product.isLiked ?? false);
                // Trigger update by reassigning the list to notify GetX observers
                controller.products.value = List.from(controller.products);
                controller.toggleLikeDislike(product);
              },
              onTap: () {
                if (product.id != null && product.id!.isNotEmpty) {
                  Get.toNamed(AppRoutes.productDetail, arguments: {
                    'productId': product.id,
                    'heroTag': 'shop_all_product_image_${product.id}',
                  });
                }
              },
              onAddToCart: () async {
                final result = await controller.addToCart(product.id ?? '', "SACHETS");
                // Refresh the products list to update UI
                if (result['success'] == true) {
                  controller.products.refresh();
                }
                return result;
              },
              onGoToCart: () {
                Get.find<DashboardController>().changeBottomNav(2);
              },
            );
          }, childCount: controller.products.length),
        ),
      );
    });
  }
}

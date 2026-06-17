import 'package:flutter/material.dart';
import 'package:viteezy/core/routes/app_routes.dart';
import 'package:viteezy/core/utils/app_prefrence.dart';
import 'package:viteezy/core/utils/exports.dart';

import '../../../../core/widgets/common_appbar.dart';
import '../../../../core/widgets/product_card_widget.dart';
import '../../../../core/widgets/shimmer_widget.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../controller/shop_all_controller.dart';

class CategoryProductView extends StatefulWidget {
  const CategoryProductView({super.key});

  @override
  State<CategoryProductView> createState() => _CategoryProductViewState();
}

class _CategoryProductViewState extends State<CategoryProductView> {
  final ShopAllController controller = Get.find<ShopAllController>();
  String? category;

  /// Get.arguments may be cleared on rebuild (e.g. after global updates); never index it directly.
  String _categorySlugFromRoute() {
    final args = Get.arguments;
    if (args is Map) {
      return args['cate']?.toString() ?? '';
    }
    return '';
  }

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<ShopAllController>()) {
      Get.put(ShopAllController());
    }

    // Defer all state changes until after build phase completes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getProductFilters();
      // Save current filter state before clearing
      controller.saveFilterState();
      // Clear filters for category product view
      controller.clearFiltersForCategoryView();

      // Clear category products to show shimmer every time user comes to this screen
      controller.categoryProducts.clear();
      controller.categoryCurrentPage = 1;
      controller.categoryHasMore = true;

      final category = Get.arguments['cate']?.toString() ?? '';

      if (category.isNotEmpty) {
        controller.getCategoryProduct(category: category, isRefresh: true, isCategory: true);
      }

      setState(() {
        this.category = category;
      });
    });
  }

  @override
  void dispose() {
    // Defer filter state restoration until after widget tree is disposed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.restoreFilterState();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoryName = Get.arguments['cate']?.toString() ?? "";
    return Scaffold(
      appBar: CommonAppbar(title: categoryName, bgColor: AppColors.white),
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top Filter Bar
            _buildTopFilterBar(context: context),

            // Products Grid
            Expanded(child: _buildProductsGrid()),
          ],
        ),
      ),
    );
  }

  /*  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      color: AppColors.surfaceColor,
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Icon(Icons.arrow_back, size: 24.sp, color: AppColors.black1414141),
          ),
          Gap(16.w),
          Text(
            "All Product",
            style: TextStyles.semiBold(24.sp, fontColor: AppColors.black1414141),
          ),
        ],
      ),
    );
  }*/

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
                onTap: () => controller.showSortAndFilters(true, category: category),
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

  Widget _buildProductsGrid() {
    return Obx(() {
      // Show shimmer only on first load when categoryProducts are empty
      // On refresh, we keep showing existing products (no shimmer)
      final shouldShowShimmer = controller.isLoading.value && controller.categoryProducts.isEmpty;

      if (shouldShowShimmer) {
        return _buildProductsShimmer();
      }

      // Show empty state only if not loading and no products
      if (controller.categoryProducts.isEmpty && !controller.isLoading.value) {
        return Center(
          child: Text('browse_no_products_found'.tr, style: TextStyles.regular(16.sp, fontColor: AppColors.textSecondary)),
        );
      }

      return NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            // User reached the bottom, load more products
            final category = Get.arguments['cate']?.toString() ?? '';
            if (category.isNotEmpty && !controller.isLoadingMore.value && controller.categoryHasMore) {
              controller.getCategoryProduct(category: category, isCategory: true);
            }
          }
          return false;
        },
        child: GridView.builder(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.55,
          ),
          itemCount: controller.categoryProducts.length + (controller.isLoadingMore.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= controller.categoryProducts.length) {
              // Show loading indicator at the bottom
              return const Center(child: CircularProgressIndicator());
            }
            final product = controller.categoryProducts[index];
            return ProductCardWidget(
              product: product,
              screenName: 'category_product',
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
                controller.categoryProducts.value = List.from(controller.categoryProducts);
                // Call API to update like status
                controller.toggleLikeDislike(product);
              },
              onTap: () {
                if (product.id != null && product.id!.isNotEmpty) {
                  Get.toNamed(AppRoutes.productDetail, arguments: {
                    'productId': product.id,
                    'heroTag': 'category_product_product_image_${product.id}',
                  });
                }
              },
              onAddToCart: () async {
                final result = await controller.addToCart(product.id ?? '', "SACHETS");
                // Refresh the categoryProducts list to update UI
                if (result['success'] == true) {
                  controller.categoryProducts.refresh();
                }
                return result;
              },
              onGoToCart: () {
                Get.toNamed(AppRoutes.cart);
              },
            );
          },
        ),
      );
    });
  }

  Widget _buildProductsShimmer() {
    return ShimmerWidget(
      child: GridView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.55,
        ),
        itemCount: 6, // Show 6 shimmer items
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Product Image Section (takes most space)
                SizedBox(
                  height: 180.h,
                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.grayE3E3DC,
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
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
                        decoration: BoxDecoration(color: AppColors.grayE3E3DC, borderRadius: BorderRadius.circular(4)),
                      ),
                      Gap(4.h),
                      Container(
                        width: 100.w,
                        height: 10.h,
                        decoration: BoxDecoration(color: AppColors.grayE3E3DC, borderRadius: BorderRadius.circular(4)),
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
                          Gap(8.w),
                          Container(
                            width: 50.w,
                            height: 12.h,
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
              ],
            ),
          );
        },
      ),
    );
  }
}

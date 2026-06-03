import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gap/gap.dart';
import 'package:viteezy/core/routes/app_routes.dart';
import 'package:viteezy/core/utils/app_prefrence.dart';
import 'package:viteezy/core/utils/exports.dart';
import 'package:viteezy/core/widgets/product_card_widget.dart';
import 'package:viteezy/core/widgets/shimmer_widget.dart';
import 'package:viteezy/gen/assets.gen.dart';
import '../controllers/browse_controller.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../../shop_all_view/controller/shop_all_controller.dart';

class BrowseView extends StatefulWidget {
  const BrowseView({super.key});

  @override
  State<BrowseView> createState() => _BrowseViewState();
}

class _BrowseViewState extends State<BrowseView> {
  late BrowseController controller;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<BrowseController>()) {
      controller = Get.put(BrowseController());
    } else {
      controller = Get.find<BrowseController>();
    }
  }

  /// Sync liked (and cart) state from product detail back into the browse list when user returns.
  void _syncProductStateFromDetail() {
    if (!Get.isRegistered<ShopAllController>()) return;
    final selectedProduct = Get.find<ShopAllController>().selectedProduct.value;
    if (selectedProduct?.id == null) return;
    final index = controller.products.indexWhere((p) => p.id == selectedProduct!.id);
    if (index == -1) return;
    final detailProduct = selectedProduct!;
    controller.products[index].isLiked = detailProduct.isLiked;
    controller.products[index].isInCart = detailProduct.isInCart;
    controller.products.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.h),
        child: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          scrolledUnderElevation: 0,
          titleSpacing: 0,
          flexibleSpace: SafeArea(
            child: Padding(
              padding: EdgeInsets.only(right: 8.w, top: 8.h),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.only(left: 12.w),
                      height: 42.h,
                      decoration: BoxDecoration(
                        color: AppColors.black1414141.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      alignment: Alignment.center,
                      child: Row(
                        children: [
                          SizedBox(width: 15.w, height: 15.w, child: Assets.icons.icSearch.svg()),
                          SizedBox(width: 8.w),
                          Expanded(child: _buildSearchField()),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  InkWell(
                    onTap: () {
                      // If search field has text, clear it first
                      if (controller.searchController.text.isNotEmpty) {
                        controller.searchController.clear();
                        // Close keyboard
                        FocusScope.of(context).unfocus();
                      } else {
                        // If search field is already empty, navigate to Home
                        FocusScope.of(context).unfocus();
                        if (Get.isRegistered<DashboardController>()) {
                          Get.find<DashboardController>().changeBottomNav(0);
                        }
                      }
                    },
                    overlayColor: WidgetStateColor.resolveWith((states) => Colors.transparent),
                    child: Text('common_cancel'.tr, style: TextStyles.medium(14.sp, fontColor: AppColors.black1414141)),
                  ),
                  SizedBox(width: 8.w),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Obx(() {
        final isSearching = controller.isSearching.value;
        final selectedCategory = controller.selectedCategory.value;
        // Show vertical grid if searching or category is selected (not empty string)
        // Empty string means initial state - show horizontal ListView with featured products
        final showVerticalGrid = isSearching || (selectedCategory.isNotEmpty);

        return Column(
          children: [
            // Fixed Category Filters with white background
            Container(
              color: AppColors.white,
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
              child: _buildCategoryFilters(),
            ),
            // Scrollable content
            Expanded(
              child: showVerticalGrid
                  ? _buildSearchResultsView()
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Gap(12.h),
                          // Most Likes Section
                          _buildMostLikesSection(),
                          Gap(12.h),
                          // Products Grid (Horizontal) - Featured Products
                          _buildProductsSection(),
                          Gap(12.h),
                        ],
                      ),
                    ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: controller.searchController,
      autofocus: true,
      decoration: InputDecoration(
        hintText: 'Search for products...',
        hintStyle: TextStyles.regular(14.sp, fontColor: AppColors.black1414141),
        border: InputBorder.none,
        isDense: true,
      ),
      style: TextStyles.regular(14.sp, fontColor: AppColors.black1414141),
    );
  }

  Widget _buildCategoryFilters() {
    return Obx(() {
      // Get ShopAllController for dynamic categories
      ShopAllController? shopAllController;
      if (Get.isRegistered<ShopAllController>()) {
        shopAllController = Get.find<ShopAllController>();
      }

      // Build categories list: "Trending" first, then dynamic categories from ShopAllController
      final List<String> categoriesList = ['Trending'];

      // Add dynamic categories from ShopAllController
      if (shopAllController != null && shopAllController.categories != null) {
        final dynamicCategories = shopAllController.categories!
            .where((category) => category.name != null && category.name!.isNotEmpty)
            .map((category) => category.name!)
            .toList();
        categoriesList.addAll(dynamicCategories);
      }

      // 2 lines of chips, horizontal scrolling
      const double chipHeight = 36;
      const double runSpacing = 8;
      final double twoLineHeight = (chipHeight * 2) + runSpacing;
      final int half = (categoriesList.length / 2).ceil();
      final firstRow = categoriesList.sublist(0, half);
      final secondRow = categoriesList.sublist(half);

      Widget buildChip(String category) {
        final isSelected = controller.selectedCategory.value == category;
        return GestureDetector(
          onTap: () => controller.selectCategory(category),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.yellowF0EFE4 : AppColors.backgroundColor,
              borderRadius: BorderRadius.circular(6.r),
              border: Border.all(color: isSelected ? AppColors.black1414141 : Colors.transparent, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.only(right: 6.w),
                  child: Icon(Icons.trending_up, size: 16.sp, color: AppColors.black1414141),
                ),
                Text(category, style: TextStyles.regular(14.sp, fontColor: AppColors.black1414141)),
              ],
            ),
          ),
        );
      }

      return SizedBox(
        height: twoLineHeight.h,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.zero,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int i = 0; i < firstRow.length; i++) ...[
                    if (i > 0) SizedBox(width: 8.w),
                    buildChip(firstRow[i]),
                  ],
                ],
              ),
              Gap(8.h),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int i = 0; i < secondRow.length; i++) ...[
                    if (i > 0) SizedBox(width: 8.w),
                    buildChip(secondRow[i]),
                  ],
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildMostLikesSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('browse_featured_products'.tr, style: TextStyles.bold(20.sp, fontColor: AppColors.black1414141)),
          // Gap(2.h),
          // Text('Our top seller', style: TextStyles.regular(14.sp, fontColor: AppColors.gray919191)),
        ],
      ),
    );
  }

  Widget _buildProductsSection() {
    return Obx(() {
      // Show shimmer only on first load when products are empty
      final shouldShowShimmer = controller.isLoading.value && controller.products.isEmpty;

      if (shouldShowShimmer) {
        return AspectRatio(
          aspectRatio: 1.3,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: 6,
            itemBuilder: (context, index) {
              return Container(
                width: 180.w,
                margin: EdgeInsets.only(right: index == 5 ? 0 : 12.w),
                child: ShimmerWidget(
                  child: Container(
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.r)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product Image
                        Expanded(
                          flex: 1,
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.grayE3E3DC,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10.r),
                                topRight: Radius.circular(10.r),
                              ),
                            ),
                          ),
                        ),
                        // Product Info
                        Padding(
                          padding: EdgeInsets.all(8.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 14.h,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: AppColors.grayE3E3DC,
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                              ),
                              Gap(4.h),
                              Container(
                                height: 10.h,
                                width: 100.w,
                                decoration: BoxDecoration(
                                  color: AppColors.grayE3E3DC,
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                              ),
                              Gap(10.h),
                              Row(
                                children: [
                                  Container(
                                    width: 45.w,
                                    height: 14.h,
                                    decoration: BoxDecoration(
                                      color: AppColors.grayE3E3DC,
                                      borderRadius: BorderRadius.circular(4.r),
                                    ),
                                  ),
                                  Spacer(),
                                  Container(
                                    width: 25.w,
                                    height: 14.h,
                                    decoration: BoxDecoration(
                                      color: AppColors.grayE3E3DC,
                                      borderRadius: BorderRadius.circular(4.r),
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
                              bottomLeft: Radius.circular(10.r),
                              bottomRight: Radius.circular(10.r),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }

      // Show empty state if no products and not loading
      if (controller.products.isEmpty && !controller.isLoading.value) {
        return AspectRatio(
          aspectRatio: 1.3,
          child: Center(
            child: Text('browse_no_products_found'.tr, style: TextStyles.regular(16.sp, fontColor: AppColors.textSecondary)),
          ),
        );
      }

      // Show products
      return AspectRatio(
        aspectRatio: 1.3,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          itemCount: controller.products.length,
          itemBuilder: (context, index) {
            final product = controller.products[index];
            return Container(
              width: 180.w,
              margin: EdgeInsets.only(right: index == controller.products.length - 1 ? 0 : 12.w),
              child: ProductCardWidget(
                product: product,
                screenName: 'browse',
                onFavoriteTap: () {
                  // Check login before updating UI
                  final isLoggedIn = PrefService.getBool(PrefKeys.isLogin) && 
                                    PrefService.getString(PrefKeys.accessToken).isNotEmpty;
                  if (!isLoggedIn) {
                    // Show login dialog - don't update UI
                    DialogService.showLoginRequiredDialog(
                      message: 'Please login to add products to your wishlist.',
                      onLogin: () {
                        Get.toNamed(AppRoutes.login);
                      },
                    );
                    return;
                  }
                  // Optimistically update the UI only if logged in
                  product.isLiked = !(product.isLiked ?? false);
                  controller.products.refresh();
                  // Call API to toggle like/dislike
                  if (Get.isRegistered<ShopAllController>()) {
                    final shopAllController = Get.find<ShopAllController>();
                    shopAllController.toggleLikeDislike(product);
                  }
                },
                onTap: () {
                  if (product.id != null && product.id!.isNotEmpty) {
                    Get.toNamed(AppRoutes.productDetail, arguments: {
                      'productId': product.id,
                      'heroTag': 'browse_product_image_${product.id}',
                    })?.then((_) => _syncProductStateFromDetail());
                  }
                },
                onAddToCart: () async {
                  // Get ShopAllController for add to cart
                  if (Get.isRegistered<ShopAllController>()) {
                    final shopAllController = Get.find<ShopAllController>();
                    final result = await shopAllController.addToCart(product.id ?? '', "SACHETS");
                    if (result['success'] == true) {
                      product.isInCart = true;
                      controller.products.refresh();
                    }
                    return result;
                  }
                  return {'success': false, 'message': 'Failed to add to cart'};
                },
                onGoToCart: () {
                  Get.find<DashboardController>().changeBottomNav(2);
                },
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildSearchResultsView() {
    return Obx(() {
      // Show shimmer only on first load when products are empty
      final shouldShowShimmer = controller.isLoading.value && controller.products.isEmpty;

      if (shouldShowShimmer) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.55,
            ),
            itemCount: 6,
            itemBuilder: (context, index) {
              return ShimmerWidget(
                child: Container(
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.r)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Image
                      Expanded(
                        flex: 1,
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.grayE3E3DC,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10.r),
                              topRight: Radius.circular(10.r),
                            ),
                          ),
                        ),
                      ),
                      // Product Info
                      Padding(
                        padding: EdgeInsets.all(8.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 14.h,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: AppColors.grayE3E3DC,
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                            ),
                            Gap(4.h),
                            Container(
                              height: 10.h,
                              width: 100.w,
                              decoration: BoxDecoration(
                                color: AppColors.grayE3E3DC,
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                            ),
                            Gap(10.h),
                            Row(
                              children: [
                                Container(
                                  width: 45.w,
                                  height: 14.h,
                                  decoration: BoxDecoration(
                                    color: AppColors.grayE3E3DC,
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                ),
                                Spacer(),
                                Container(
                                  width: 25.w,
                                  height: 14.h,
                                  decoration: BoxDecoration(
                                    color: AppColors.grayE3E3DC,
                                    borderRadius: BorderRadius.circular(4.r),
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
                            bottomLeft: Radius.circular(10.r),
                            bottomRight: Radius.circular(10.r),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }

      // Show empty state if no products and not loading
      if (controller.products.isEmpty && !controller.isLoading.value) {
        return Center(
          child: Padding(
            padding: EdgeInsets.all(32.w),
            child: Text('browse_no_products_found'.tr, style: TextStyles.regular(16.sp, fontColor: AppColors.textSecondary)),
          ),
        );
      }

      // Show products in vertical grid
      return GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.55,
        ),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        itemCount: controller.products.length,
        itemBuilder: (context, index) {
          final product = controller.products[index];
          return ProductCardWidget(
            product: product,
            screenName: 'browse',
            onFavoriteTap: () {
              // Check login before updating UI
              final isLoggedIn = PrefService.getBool(PrefKeys.isLogin) && 
                                PrefService.getString(PrefKeys.accessToken).isNotEmpty;
              if (!isLoggedIn) {
                // Show login dialog - don't update UI
                DialogService.showLoginRequiredDialog(
                  message: 'Please login to add products to your wishlist.',
                  onLogin: () {
                    Get.toNamed(AppRoutes.login);
                  },
                );
                return;
              }
              // Optimistically update the UI only if logged in
              product.isLiked = !(product.isLiked ?? false);
              controller.products.refresh();
              // Call API to toggle like/dislike
              if (Get.isRegistered<ShopAllController>()) {
                final shopAllController = Get.find<ShopAllController>();
                shopAllController.toggleLikeDislike(product);
              }
            },
            onTap: () {
              if (product.id != null && product.id!.isNotEmpty) {
                Get.toNamed(AppRoutes.productDetail, arguments: {
                  'productId': product.id,
                  'heroTag': 'browse_product_image_${product.id}',
                })?.then((_) => _syncProductStateFromDetail());
              }
            },
            onAddToCart: () async {
              // Get ShopAllController for add to cart
              if (Get.isRegistered<ShopAllController>()) {
                final shopAllController = Get.find<ShopAllController>();
                final result = await shopAllController.addToCart(product.id ?? '', "SACHETS");
                if (result['success'] == true) {
                  product.isInCart = true;
                  controller.products.refresh();
                }
                return result;
              }
              return {'success': false, 'message': 'Failed to add to cart'};
            },
            onGoToCart: () {
              Get.find<DashboardController>().changeBottomNav(2);
            },
          );
        },
      );
    });
  }
}

import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:viteezy/core/routes/app_routes.dart';
import 'package:viteezy/core/utils/app_prefrence.dart';
import 'package:viteezy/core/utils/exports.dart';
import 'package:viteezy/core/widgets/common_network_image.dart';
import 'package:viteezy/core/widgets/customer_review_card.dart';
import 'package:viteezy/core/widgets/custom_toast.dart';
import 'package:viteezy/core/widgets/product_card_widget.dart';
import 'package:viteezy/core/widgets/share_product_bottom_sheet.dart';
import 'package:viteezy/core/widgets/shimmer_widget.dart';
import 'package:viteezy/gen/assets.gen.dart';
import 'package:viteezy/presentation/main/membership/views/membership_view.dart';
import 'package:viteezy/presentation/main/shop_all_view/controller/shop_all_controller.dart';
import '../../../../core/models/product_response_model.dart';
import '../controllers/products_controller.dart';

class ProductDetailView extends StatefulWidget {
  const ProductDetailView({super.key});

  @override
  State<ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<ProductDetailView> {
  final ProductsController controller = Get.find<ProductsController>();
  final ShopAllController shopAllController = Get.find<ShopAllController>();
  int _selectedImageIndex = 0;
  String _selectedPreference = 'sachets';
  NinetyDays? _selectedPrice;
  String? _lastProductId; // Track which product we initialized price for
  final Map<String, bool> _expandedSections = {
    'Description': false,
    'Ingredients': false,
    'Nutrition Info': false,
    'How To Use': false,
  };
  // Cache the initial productImage URL to avoid reloading
  String? _cachedProductImageUrl;
  // Loading state for add to cart button
  bool _isAddingToCart = false;
  // Loading state for buy now button
  bool _isBuyingNow = false;
  // Stand-up pouch one-time purchase: quantity (default 1) and selected capsule count (30 or 60)
  int _pouchQuantity = 1;
  int _selectedCapsuleCount = 60;
  // Tracks the last variant (preference + quantities) this screen successfully added to cart.
  // This lets the UI reset from "Added" back to "Add to cart" when the user changes preference/quantity.
  String? _lastAddedCartSelectionKey;
  String get _currentCartSelectionKey {
    if (_selectedPreference == 'sachets') return 'sachets';
    return 'pouch:$_selectedCapsuleCount:$_pouchQuantity';
  }

  static const int _minPouchQuantity = 1;
  static const int _maxPouchQuantity = 99;
  final TextEditingController _quantityController = TextEditingController(
    text: '1',
  );
  final FocusNode _quantityFocusNode = FocusNode();

  /// Similar products for this screen only; avoids mutating [ShopAllController.categoryProducts].
  List<Product> _similarProducts = [];

  @override
  void initState() {
    super.initState();
    final arguments = Get.arguments;
    final String? productId = arguments?['productId'];

    // Cache the productImage from the list if available
    if (productId != null && productId.isNotEmpty) {
      try {
        final productFromList = shopAllController.products.firstWhere(
          (p) => p.id == productId,
        );
        _cachedProductImageUrl = productFromList.productImage;
      } catch (e) {
        // Product not found in list
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          shopAllController.getProductById(productId);
          shopAllController.getProductTestimonials(productId);
          if (shopAllController.products.isNotEmpty) {
            final productFromList = shopAllController.products.firstWhere(
              (p) => p.id == productId,
            );
            shopAllController.fetchSimilarProductsForProductDetail(
              category: productFromList.categories?.first.name,
              onSuccess: (products) {
                if (!mounted) return;
                setState(() {
                  _similarProducts = products;
                });
              },
            );
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _quantityFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLoading = shopAllController.isLoadingProductDetail.value;
      final Product? product = shopAllController.selectedProduct.value;
      // Get product from list to show productImage immediately
      final arguments = Get.arguments;
      final String? productId = arguments?['productId'];
      Product? productFromList;
      if (productId != null && productId.isNotEmpty) {
        try {
          productFromList = shopAllController.products.firstWhere(
            (p) => p.id == productId,
          );
        } catch (e) {
          // Product not found in list, productFromList remains null
          productFromList = null;
        }
      }

      // Initialize _selectedPrice only when product first loads or product changes
      final displayProductForInit = product ?? productFromList;
      if (displayProductForInit != null &&
          displayProductForInit.id != _lastProductId) {
        _lastProductId = displayProductForInit.id;
        _selectedPrice = displayProductForInit.sachetPrices?.thirtyDays;
        _selectedPreference = 'sachets';
        _pouchQuantity = 1;
        _selectedCapsuleCount = 60;
        _quantityController.text = '1';
        _lastAddedCartSelectionKey = displayProductForInit.isInCart == true
            ? _currentCartSelectionKey
            : null;
      }

      // Get display product (from API or from list)
      final displayProduct = product ?? productFromList;

      // Priority 1: Show error UI if product is not found (not loading and no product available)
      if (!isLoading &&
          displayProduct == null &&
          productId != null &&
          productId.isNotEmpty) {
        return Scaffold(
          backgroundColor: AppColors.surfaceColor,
          appBar: AppBar(
            backgroundColor: AppColors.surfaceColor,
            elevation: 0,
            leading: Container(
              margin: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppColors.surfaceColor.withValues(alpha: 0.9),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Image.asset(Assets.icons.icBackArrow.path, scale: 3),
                onPressed: () => Get.back(),
              ),
            ),
          ),
          body: _buildProductNotFoundError(),
        );
      }

      // Priority 2: Show shimmer while loading (only if no product from list to show)
      if (isLoading && displayProduct == null) {
        return Scaffold(
          backgroundColor: AppColors.surfaceColor,
          body: _buildProductDetailShimmer(null),
        );
      }

      // Priority 3: If still no product (shouldn't happen, but show shimmer as fallback)
      if (displayProduct == null) {
        return Scaffold(
          backgroundColor: AppColors.surfaceColor,
          body: _buildProductDetailShimmer(null),
        );
      }

      // Show actual product detail when loaded, or partial with productImage from list
      return Scaffold(
        // backgroundColor: AppColors.offWhite,
        body: CustomScrollView(
          slivers: [
            // Sliver AppBar that changes color on scroll
            SliverAppBar(
              expandedHeight: 360.h,
              floating: false,
              pinned: true,
              backgroundColor: AppColors.surfaceColor,
              elevation: 0,
              leading: Container(
                margin: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.surfaceColor.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Image.asset(Assets.icons.icBackArrow.path, scale: 3),
                  onPressed: () => Get.back(),
                ),
              ),
              actions: [
                Container(
                  margin: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceColor.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Assets.icons.icCart.svg(width: 20.w, height: 20.h),
                    onPressed: () {
                      final isLoggedIn =
                          PrefService.getBool(PrefKeys.isLogin) &&
                          PrefService.getString(
                            PrefKeys.accessToken,
                          ).isNotEmpty;
                      if (!isLoggedIn) {
                        DialogService.showLoginRequiredDialog(
                          message: 'product_detail_login_cart'.tr,
                          onLogin: () {
                            Get.toNamed(AppRoutes.login);
                          },
                        );
                        return;
                      }
                      Get.toNamed(AppRoutes.cart);
                    },
                  ),
                ),
                Obx(() {
                  // Observe selectedProduct to track isLiked changes
                  final currentProduct =
                      shopAllController.selectedProduct.value ?? displayProduct;
                  final isLiked = currentProduct.isLiked ?? false;
                  return Container(
                    margin: EdgeInsets.only(right: 8.w, top: 8.w, bottom: 8.w),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceColor.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: AppColors.black1414141,
                        size: 20.sp,
                      ),
                      onPressed: () {
                        if (displayProduct.id == null ||
                            displayProduct.id!.isEmpty)
                          return;
                        // Check login before updating UI
                        final isLoggedIn =
                            PrefService.getBool(PrefKeys.isLogin) &&
                            PrefService.getString(
                              PrefKeys.accessToken,
                            ).isNotEmpty;
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
                        displayProduct.isLiked = !isLiked;
                        // Update selectedProduct to trigger UI refresh
                        shopAllController.selectedProduct.value =
                            displayProduct;
                        final index = shopAllController.products.indexWhere(
                          (p) => p.id == displayProduct.id,
                        );
                        if (index != -1) {
                          shopAllController.products[index].isLiked =
                              displayProduct.isLiked;
                          shopAllController.products.refresh();
                        }
                        setState(() {});
                        // Call API to toggle like/dislike
                        shopAllController.toggleLikeDislike(displayProduct);
                      },
                    ),
                  );
                }),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: _buildProductImageCarousel(
                  displayProduct,
                  isLoading,
                  Get.arguments?['heroTag'] ??
                      'product_image_${productId ?? ''}',
                ),
              ),
            ),
            // Rest of the content
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Carousel indicators outside the image
                  Gap(12.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _getTotalImageCount(displayProduct),
                      (index) => Container(
                        width: 8.w,
                        height: 8.w,
                        margin: EdgeInsets.symmetric(horizontal: 4.w),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _selectedImageIndex == index
                              ? AppColors.black1414141
                              : AppColors.grayE3E3DC,
                        ),
                      ),
                    ),
                  ),
                  Gap(4.h),
                  // Product Info - Show shimmer if loading, otherwise show actual data
                  isLoading && product == null
                      ? _buildProductInfoShimmer()
                      : Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Product Name and Tagline
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      displayProduct.title ?? "",
                                      style: TextStyles.bold(
                                        22.sp,
                                        fontColor: AppColors.black1414141,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => _showShareBottomSheet(
                                      context,
                                      displayProduct,
                                    ),
                                    child: Assets.icons.icShare.svg(),
                                  ),
                                ],
                              ),
                              Gap(2.h),
                              HtmlWidget(displayProduct.shortDescription ?? ""),
                              // Text(
                              //
                              //   style: TextStyles.regular(14.sp, fontColor: AppColors.black1414141),
                              // ),
                              Gap(12.h),
                              // Pricing
                              Row(
                                children: [
                                  Text(
                                    // '\$${_selectedPrice?.totalAmount}',
                                    '${_selectedPrice?.currency} '
                                    '${_selectedPrice?.totalAmount}',
                                    style: TextStyles.bold(
                                      20.sp,
                                      fontColor: AppColors.primaryColor,
                                    ),
                                  ),
                                  if (displayProduct.title != null) ...[
                                    Gap(4.w),
                                    Text(
                                      // '\$${_selectedPrice?.amount}',
                                      '${_selectedPrice?.currency} '
                                      '${_selectedPrice?.amount}',
                                      style:
                                          TextStyles.semiBold(
                                            16.sp,
                                            fontColor: AppColors.gray949391,
                                            textDecoration:
                                                TextDecoration.lineThrough,
                                          ).copyWith(
                                            decorationColor:
                                                AppColors.gray949391,
                                          ),
                                    ),
                                    Gap(8.w),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8.w,
                                        vertical: 4.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.black1414141,
                                        borderRadius: BorderRadius.only(
                                          bottomRight: Radius.circular(20.h),
                                          topRight: Radius.circular(20.h),
                                        ),
                                      ),
                                      child: Text(
                                        '${'product_detail_save'.tr} ${_selectedPrice?.savingsPercentage}%',
                                        style: TextStyles.medium(
                                          12.sp,
                                          fontColor: AppColors.surfaceColor,
                                        ),
                                      ),
                                    ),
                                    Gap(4.h),
                                    Expanded(
                                      child: Text(
                                        'product_detail_mrp_taxes'.tr,
                                        style: TextStyles.regular(
                                          10.sp,
                                          fontColor: AppColors.black1414141,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),

                              Gap(18.h),
                              _buildPromotionalBanner(context, displayProduct),
                              Gap(24.h),
                              // Product Preference Selection
                              Text(
                                'product_detail_choose_preference'.tr,
                                style: TextStyles.semiBold(
                                  18.sp,
                                  fontColor: AppColors.black1414141,
                                ),
                              ),
                              Gap(12.h),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: _buildPreferenceOption(
                                            'product_detail_viteezy_sachets'.tr,
                                            Assets.images.productOne.path,
                                            'sachets',
                                            displayProduct,
                                          ),
                                        ),
                                        if (displayProduct.hasStandupPouch ??
                                            false) ...[
                                          Gap(12.w),
                                          Expanded(
                                            child: _buildPreferenceOption(
                                              'product_detail_stand_up_pouch'
                                                  .tr,
                                              Assets.images.productTwo.path,
                                              'pouch',
                                              displayProduct,
                                            ),
                                          ),
                                        ],
                                        if (displayProduct.hasStandupPouch ==
                                            false) ...[
                                          Gap(12.w),
                                          Expanded(child: SizedBox()),
                                        ],
                                      ],
                                    ),
                                  ),
                                  Expanded(child: SizedBox()),
                                ],
                              ),
                              Gap(24.h),
                              // One-time purchase widget when Stand-up pouch is selected
                              if (_selectedPreference == 'pouch' &&
                                  (displayProduct.standupPouchPrice != null))
                                _buildStandUpPouchOneTimeWidget(displayProduct),
                              if (_selectedPreference == 'pouch' &&
                                  (displayProduct.standupPouchPrice != null))
                                Gap(24.h),
                              // Expandable Sections
                              _buildExpandableSection(
                                'Description',
                                displayProduct.description ?? "",
                              ),
                              _buildDivider(),
                              if (displayProduct
                                  .ingredientsForDisplay
                                  .isNotEmpty) ...[
                                Gap(12.h),
                                _buildExpandableSectionIngredients(
                                  'Ingredients',
                                  displayProduct.ingredientsForDisplay,
                                ),
                                _buildDivider(),
                              ],

                              Gap(12.h),
                              _buildExpandableSection(
                                'Nutrition Info',
                                displayProduct.nutritionInfo ?? "",
                              ),
                              _buildDivider(),
                              Gap(12.h),
                              _buildExpandableSection(
                                'How To Use',
                                displayProduct.howToUse ?? "",
                              ),
                              Gap(24.h),
                            ],
                          ),
                        ),
                  // Key Benefits Section - Show shimmer if loading
                  isLoading && product == null
                      ? _buildSectionsShimmer()
                      : Column(
                          children: [
                            // Key Benefits Section
                            _buildKeyBenefitsSection(
                              displayProduct.specification,
                            ),
                            Gap(24.h),
                            // Real Customers, Real Results
                            if (shopAllController.productReviews?.isNotEmpty ??
                                false)
                              _buildRealCustomersSection(),
                            Gap(30.h),
                            // Product Comparison Table
                            _buildComparisonTable(
                              displayProduct.comparisonSection,
                            ),
                            Gap(24.h),
                            // Recently Viewed
                            _buildRecentlyViewedSection(displayProduct),
                            Gap(20.h), // Space for bottom navigation
                            // Gap(40.h), // Space for bottom navigation
                            // _FAQSectionWidget(),
                          ],
                        ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: isLoading && product == null
            ? null
            : _buildBottomNavigationBar(displayProduct),
      );
    });
  }

  /// Shimmer UI for Product Detail
  Widget _buildProductDetailShimmer(Product? productFromList) {
    // Use cached productImage if available, otherwise use from productFromList
    final String? productImageUrl =
        _cachedProductImageUrl ?? productFromList?.productImage;
    final String? productId = productFromList?.id;
    final String heroTag =
        Get.arguments?['heroTag'] ?? 'product_image_${productId ?? ''}';

    return ShimmerWidget(
      child: CustomScrollView(
        slivers: [
          // Shimmer AppBar
          SliverAppBar(
            expandedHeight: 360.h,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.surfaceColor,
            elevation: 0,
            leading: Container(
              margin: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppColors.surfaceColor.withValues(alpha: 0.9),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back_outlined,
                  color: AppColors.black1414141,
                  size: 20.sp,
                ),
                onPressed: () => Get.back(),
              ),
            ),
            actions: [
              Container(
                margin: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.surfaceColor.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Assets.icons.icCart.svg(width: 20.w, height: 20.h),
                  onPressed: () {},
                ),
              ),
              Container(
                margin: EdgeInsets.only(right: 8.w, top: 8.w, bottom: 8.w),
                decoration: BoxDecoration(
                  color: AppColors.surfaceColor.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.favorite_border,
                    color: AppColors.black1414141,
                    size: 20.sp,
                  ),
                  onPressed: () {},
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background:
                  productImageUrl != null &&
                      productImageUrl.isNotEmpty &&
                      productId != null
                  ? Hero(
                      tag: heroTag,
                      child: CommonNetworkImage(
                        key: ValueKey(productImageUrl),
                        imageUrl: productImageUrl,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Container(color: AppColors.grayE3E3DC),
            ),
          ),
          // Shimmer Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Gap(12.h),
                // Carousel indicators shimmer
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    3,
                    (index) => Container(
                      width: 8.w,
                      height: 8.w,
                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.grayE3E3DC,
                      ),
                    ),
                  ),
                ),
                Gap(4.h),
                // Product Info Shimmer
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Name and Share shimmer
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Container(
                              height: 28.h,
                              decoration: BoxDecoration(
                                color: AppColors.grayE3E3DC,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          Gap(12.w),
                          Container(
                            width: 24.w,
                            height: 24.w,
                            decoration: BoxDecoration(
                              color: AppColors.grayE3E3DC,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                      Gap(2.h),
                      // Tagline shimmer
                      Container(
                        width: 200.w,
                        height: 16.h,
                        decoration: BoxDecoration(
                          color: AppColors.grayE3E3DC,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      Gap(12.h),
                      // Pricing shimmer
                      Row(
                        children: [
                          Container(
                            width: 80.w,
                            height: 24.h,
                            decoration: BoxDecoration(
                              color: AppColors.grayE3E3DC,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          Gap(8.w),
                          Container(
                            width: 60.w,
                            height: 20.h,
                            decoration: BoxDecoration(
                              color: AppColors.grayE3E3DC,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          Gap(8.w),
                          Container(
                            width: 100.w,
                            height: 24.h,
                            decoration: BoxDecoration(
                              color: AppColors.grayE3E3DC,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ],
                      ),
                      Gap(18.h),
                      // Promotional banner shimmer
                      Container(
                        height: 50.h,
                        decoration: BoxDecoration(
                          color: AppColors.grayE3E3DC,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      Gap(24.h),
                      // Preference selection shimmer
                      Container(
                        width: 200.w,
                        height: 20.h,
                        decoration: BoxDecoration(
                          color: AppColors.grayE3E3DC,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      Gap(12.h),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 120.h,
                              decoration: BoxDecoration(
                                color: AppColors.grayE3E3DC,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          Gap(12.w),
                          Expanded(
                            child: Container(
                              height: 120.h,
                              decoration: BoxDecoration(
                                color: AppColors.grayE3E3DC,
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Gap(24.h),
                      // Expandable sections shimmer
                      ...List.generate(4, (index) {
                        return Column(
                          children: [
                            Container(
                              height: 50.h,
                              decoration: BoxDecoration(
                                color: AppColors.grayE3E3DC,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            Gap(12.h),
                            if (index < 3)
                              Divider(
                                height: 1,
                                thickness: 1,
                                color: AppColors.grayE3E3DC,
                              ),
                            Gap(12.h),
                          ],
                        );
                      }),
                      Gap(24.h),
                    ],
                  ),
                ),
                // Key Benefits shimmer
                Container(height: 200.h, color: AppColors.grayE3E3DC),
                Gap(24.h),
                // Real Customers shimmer
                Container(height: 300.h, color: AppColors.grayE3E3DC),
                Gap(30.h),
                // Comparison Table shimmer
                Container(height: 250.h, color: AppColors.grayE3E3DC),
                Gap(24.h),
                // Recently Viewed shimmer
                Container(height: 200.h, color: AppColors.grayE3E3DC),
                Gap(40.h),
                // FAQ shimmer
                Container(height: 300.h, color: AppColors.grayE3E3DC),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Promotional Banner
  Widget _buildPromotionalBanner(BuildContext context, Product product) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: () {
            Get.to(() => MembershipView(product: product));
          },
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(8.r),
              gradient: LinearGradient(
                colors: [
                  Color(0xFFCEF9EF),
                  Color(0xFF9DF2DE).withValues(alpha: 0.4),
                  Color(0xFFEDDFA5).withValues(alpha: 0.4),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Assets.icons.icPersentage.svg(),
                      SizedBox(width: 5.w),
                      Expanded(
                        child: Text(
                          "${'just'.tr} ${product.price?.currency ?? "\$"} ${product.price?.amount ?? 0.0} ${'product_detail_premium_membership'.tr}",
                          textAlign: TextAlign.center,
                          style: TextStyles.medium(
                            14.sp,
                            fontColor: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_outlined,
                  size: 16.sp,
                  color: AppColors.textPrimary,
                ),
              ],
            ),
          ),
        ),
        // Triangle indicator pointing to price above
        Positioned(
          left: 20.w, // Align with the price badge area
          top: -11.h,
          child: CustomPaint(
            size: Size(15.w, 12.h),
            painter: _TrianglePainter(color: Color(0xffD7F7EE)),
          ),
        ),
      ],
    );
  }

  /// Get total count of images (productImage + galleryImages)
  int _getTotalImageCount(Product product) {
    int count = 0;
    if (product.productImage != null && product.productImage!.isNotEmpty) {
      count++;
    }
    if (product.galleryImages != null) {
      count += product.galleryImages!.length;
    }
    return count;
  }

  /// Shimmer for product info section
  Widget _buildProductInfoShimmer() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: ShimmerWidget(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Name and Share shimmer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    height: 28.h,
                    decoration: BoxDecoration(
                      color: AppColors.grayE3E3DC,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                Gap(12.w),
                Container(
                  width: 24.w,
                  height: 24.w,
                  decoration: BoxDecoration(
                    color: AppColors.grayE3E3DC,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
            Gap(2.h),
            // Tagline shimmer
            Container(
              width: 200.w,
              height: 16.h,
              decoration: BoxDecoration(
                color: AppColors.grayE3E3DC,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Gap(12.h),
            // Pricing shimmer
            Row(
              children: [
                Container(
                  width: 80.w,
                  height: 24.h,
                  decoration: BoxDecoration(
                    color: AppColors.grayE3E3DC,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Gap(8.w),
                Container(
                  width: 60.w,
                  height: 20.h,
                  decoration: BoxDecoration(
                    color: AppColors.grayE3E3DC,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Gap(8.w),
                Container(
                  width: 100.w,
                  height: 24.h,
                  decoration: BoxDecoration(
                    color: AppColors.grayE3E3DC,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ],
            ),
            Gap(18.h),
            // Promotional banner shimmer
            Container(
              height: 50.h,
              decoration: BoxDecoration(
                color: AppColors.grayE3E3DC,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            Gap(24.h),
            // Preference selection shimmer
            Container(
              width: 200.w,
              height: 20.h,
              decoration: BoxDecoration(
                color: AppColors.grayE3E3DC,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Gap(12.h),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 120.h,
                    decoration: BoxDecoration(
                      color: AppColors.grayE3E3DC,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                Gap(12.w),
                Expanded(
                  child: Container(
                    height: 120.h,
                    decoration: BoxDecoration(
                      color: AppColors.grayE3E3DC,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            Gap(24.h),
            // Expandable sections shimmer
            ...List.generate(4, (index) {
              return Column(
                children: [
                  Container(
                    height: 50.h,
                    decoration: BoxDecoration(
                      color: AppColors.grayE3E3DC,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Gap(12.h),
                  if (index < 3)
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.grayE3E3DC,
                    ),
                  Gap(12.h),
                ],
              );
            }),
            Gap(24.h),
          ],
        ),
      ),
    );
  }

  /// Shimmer for bottom sections
  Widget _buildSectionsShimmer() {
    return ShimmerWidget(
      child: Column(
        children: [
          // Key Benefits shimmer
          Container(height: 200.h, color: AppColors.grayE3E3DC),
          Gap(24.h),
          // Real Customers shimmer
          Container(height: 300.h, color: AppColors.grayE3E3DC),
          Gap(30.h),
          // Comparison Table shimmer
          Container(height: 250.h, color: AppColors.grayE3E3DC),
          Gap(24.h),
          // Recently Viewed shimmer
          Container(height: 200.h, color: AppColors.grayE3E3DC),
          Gap(40.h),
          // FAQ shimmer
          Container(height: 300.h, color: AppColors.grayE3E3DC),
        ],
      ),
    );
  }

  Widget _buildProductImageCarousel(
    Product product,
    bool isLoading,
    String heroTag,
  ) {
    // Use cached productImage if available (from list), otherwise use from API
    // This prevents reloading the same image
    final String? productImageUrl =
        _cachedProductImageUrl ?? product.productImage;

    // Update cache if API productImage is different (shouldn't happen, but just in case)
    if (_cachedProductImageUrl == null &&
        product.productImage != null &&
        product.productImage!.isNotEmpty) {
      _cachedProductImageUrl = product.productImage;
    }

    // Combine productImage (as first) with galleryImages
    // Filter out empty or null URLs to prevent errors
    final List<String> allImages = [];
    if (productImageUrl != null && productImageUrl.isNotEmpty) {
      allImages.add(productImageUrl);
    }
    if (product.galleryImages != null) {
      // Filter out empty URLs from galleryImages
      final validGalleryImages = product.galleryImages!
          .where((url) => url.isNotEmpty)
          .toList();
      allImages.addAll(validGalleryImages);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: constraints.maxHeight,
          child: PageView.builder(
            itemCount: allImages.length,
            onPageChanged: (index) {
              setState(() {
                _selectedImageIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final imageUrl = allImages[index];
              final isFirstImage = index == 0;

              // Use Hero widget for the first image (productImage) when navigating from product card
              // Add key to help Flutter identify it as the same image (prevents reload)
              final imageWidget = CommonNetworkImage(
                key: ValueKey(imageUrl),
                imageUrl: imageUrl,
                fit: BoxFit.cover,
              );

              return Container(
                width: double.infinity,
                color: AppColors.offWhite,
                child:
                    isFirstImage &&
                        productImageUrl != null &&
                        productImageUrl.isNotEmpty
                    ? Hero(tag: heroTag, child: imageWidget)
                    : imageWidget,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildPreferenceOption(
    String label,
    String imagePath,
    String value,
    Product product,
  ) {
    final isSelected = _selectedPreference == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPreference = value;
          if (_selectedPreference == 'sachets') {
            _selectedPrice = product.sachetPrices?.thirtyDays;
          } else {
            final standup = product.standupPouchPrice;
            _selectedCapsuleCount =
                standup?.count60?.capsuleCount ??
                standup?.count120?.capsuleCount ??
                60;
            _selectedPrice =
                (standup?.count60?.capsuleCount == _selectedCapsuleCount)
                ? standup?.count60
                : standup?.count120;
            // Keep previous _pouchQuantity when switching sachets ↔ pouch; sync text field to state.
            _quantityController.text = _pouchQuantity.toString();
          }
        });
      },
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.yellowF0EFE4 : AppColors.surfaceColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? AppColors.black1414141 : AppColors.grayE3E3DC,
            width: isSelected ? 1 : 1,
          ),
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.asset(imagePath, fit: BoxFit.contain),
            ),
            Gap(8.h),
            Text(
              label,
              style: TextStyles.medium(
                12.sp,
                fontColor: AppColors.black1414141,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// One-time purchase card for Stand-up pouch: title, price, count, capsule dropdown, quantity +/- with validation.
  /// Uses capsuleCount directly from product.standupPouchPrice (count60/count120 NinetyDays) from API.
  Widget _buildStandUpPouchOneTimeWidget(Product product) {
    final standup = product.standupPouchPrice;
    final capsuleOptions = <int>[];
    final c60 = standup?.count60?.capsuleCount;
    final c120 = standup?.count120?.capsuleCount;
    if (c60 != null) capsuleOptions.add(c60);
    if (c120 != null) capsuleOptions.add(c120);
    if (capsuleOptions.isEmpty) return const SizedBox.shrink();

    final effectiveCapsuleCount = capsuleOptions.contains(_selectedCapsuleCount)
        ? _selectedCapsuleCount
        : capsuleOptions.first;
    final ninetyDays = (standup?.count60?.capsuleCount == effectiveCapsuleCount)
        ? standup?.count60
        : standup?.count120;

    if (!capsuleOptions.contains(_selectedCapsuleCount)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _selectedCapsuleCount = capsuleOptions.first;
            _selectedPrice =
                (standup?.count60?.capsuleCount == _selectedCapsuleCount)
                ? standup?.count60
                : standup?.count120;
          });
        }
      });
    }

    return AnimatedSize(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: Container(
          key: const ValueKey('pouch_one_time'),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.surfaceColor,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.grayE3E3DC, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'product_detail_one_time_purchase'.tr,
                    style: TextStyles.semiBold(
                      16.sp,
                      fontColor: AppColors.black1414141,
                    ),
                  ),
                  Text(
                    '${ninetyDays?.currency ?? '\$'} ${ninetyDays?.totalAmount?.toStringAsFixed(2) ?? '0.00'}',
                    style: TextStyles.semiBold(
                      16.sp,
                      fontColor: AppColors.primaryColor,
                    ),
                  ),
                ],
              ),
              Gap(4.h),
              Text(
                '$effectiveCapsuleCount count',
                style: TextStyles.regular(
                  13.sp,
                  fontColor: AppColors.gray949391,
                ),
              ),
              Gap(16.h),
              Text(
                'checkout_capsules_options'.tr,
                style: TextStyles.bold(
                  14.sp,
                  fontColor: AppColors.black1414141,
                ),
              ),
              Gap(8.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: _buildCapsuleDropdown(product, capsuleOptions),
                  ),
                  Gap(12.w),
                  _buildQuantitySelector(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCapsuleDropdown(Product product, List<int> capsuleOptions) {
    final dropdownKey = GlobalKey();
    return GestureDetector(
      onTap: () {
        final RenderBox? renderBox =
            dropdownKey.currentContext?.findRenderObject() as RenderBox?;
        if (renderBox == null) return;
        final Offset offset = renderBox.localToGlobal(Offset.zero);
        showMenu<int>(
          context: context,
          position: RelativeRect.fromLTRB(
            offset.dx,
            offset.dy + renderBox.size.height,
            offset.dx + renderBox.size.width,
            offset.dy + renderBox.size.height + (capsuleOptions.length * 48.h),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          items: capsuleOptions.map((count) {
            return PopupMenuItem<int>(
              value: count,
              child: Text(
                '$count Capsules',
                style: TextStyles.regular(
                  14.sp,
                  fontColor: AppColors.black1414141,
                ),
              ),
            );
          }).toList(),
        ).then((value) {
          if (value != null && mounted) {
            final standup = product.standupPouchPrice;
            setState(() {
              _selectedCapsuleCount = value;
              _selectedPrice = (standup?.count60?.capsuleCount == value)
                  ? standup?.count60
                  : standup?.count120;
            });
          }
        });
      },
      child: Container(
        key: dropdownKey,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: AppColors.grayE3E3DC, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$_selectedCapsuleCount Capsules',
              style: TextStyles.regular(
                14.sp,
                fontColor: AppColors.black1414141,
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down,
              size: 20.sp,
              color: AppColors.gray949391,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.grayE3E3DC, width: 1),
      ),
      child: IntrinsicHeight(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _QuantityButton(
              icon: Icons.remove,
              onTap: () {
                setState(() {
                  if (_pouchQuantity > _minPouchQuantity) {
                    _pouchQuantity--;
                    _quantityController.text = _pouchQuantity.toString();
                  }
                });
              },
            ),
            Container(width: 1, color: AppColors.grayE3E3DC),
            SizedBox(
              width: 44.w,
              child: TextFormField(
                controller: _quantityController,
                focusNode: _quantityFocusNode,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: TextStyles.semiBold(
                  14.sp,
                  fontColor: AppColors.black1414141,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(2),
                ],
                onChanged: (value) {
                  final parsed = int.tryParse(value);
                  if (parsed != null &&
                      parsed >= _minPouchQuantity &&
                      parsed <= _maxPouchQuantity) {
                    setState(() {
                      _pouchQuantity = parsed;
                    });
                  }
                },
                onFieldSubmitted: (_) => _validateAndSyncQuantity(),
                onTapOutside: (_) => _validateAndSyncQuantity(),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                  filled: false,
                ),
              ),
            ),
            Container(width: 1, color: AppColors.grayE3E3DC),
            _QuantityButton(
              icon: Icons.add,
              onTap: () {
                setState(() {
                  if (_pouchQuantity < _maxPouchQuantity) {
                    _pouchQuantity++;
                    _quantityController.text = _pouchQuantity.toString();
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  void _validateAndSyncQuantity() {
    final text = _quantityController.text.trim();
    final parsed = int.tryParse(text);
    if (parsed == null || parsed < _minPouchQuantity) {
      _pouchQuantity = _minPouchQuantity;
    } else if (parsed > _maxPouchQuantity) {
      _pouchQuantity = _maxPouchQuantity;
    } else {
      _pouchQuantity = parsed;
    }
    _quantityController.text = _pouchQuantity.toString();
    setState(() {});
  }

  String _sectionTitle(String key) {
    switch (key) {
      case 'Description':
        return 'product_detail_description'.tr;
      case 'Ingredients':
        return 'product_detail_ingredients'.tr;
      case 'Nutrition Info':
        return 'product_detail_nutrition_info'.tr;
      case 'How To Use':
        return 'product_detail_how_to_use'.tr;
      default:
        return key;
    }
  }

  Widget _buildExpandableSectionIngredients(
    String title,
    List<Ingredient> items,
  ) {
    final isExpanded = _expandedSections[title] ?? false;
    final textStyle = TextStyles.regular(
      15.sp,
      fontColor: AppColors.black1414141,
    );
    final nameStyle = TextStyles.semiBold(
      16.sp,
      fontColor: AppColors.black1414141,
    );

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            overlayColor: WidgetStateColor.fromMap({
              MaterialState.pressed: Colors.transparent,
            }),
            onTap: () {
              setState(() {
                _expandedSections[title] = !isExpanded;
              });
            },
            child: Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _sectionTitle(title),
                    style: TextStyles.semiBold(
                      16.sp,
                      fontColor: AppColors.black1414141,
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.remove : Icons.add,
                    color: AppColors.black1414141,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: items.map((item) {
                  final name = item.name?.trim() ?? '';
                  final desc = item.description?.trim() ?? '';
                  if (name.isEmpty && desc.isEmpty)
                    return const SizedBox.shrink();
                  return Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: name.isEmpty
                        ? HtmlWidget(desc, textStyle: textStyle)
                        : desc.isEmpty
                        ? Text(name, style: nameStyle)
                        : RichText(
                            text: TextSpan(
                              style: textStyle,
                              children: [
                                TextSpan(text: '$name : ', style: nameStyle),
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.baseline,
                                  baseline: TextBaseline.alphabetic,
                                  child: HtmlWidget(desc, textStyle: textStyle),
                                ),
                              ],
                            ),
                          ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildExpandableSection(String title, String content) {
    final isExpanded = _expandedSections[title] ?? false;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        children: [
          InkWell(
            overlayColor: WidgetStateColor.fromMap({
              MaterialState.pressed: Colors.transparent,
            }),
            onTap: () {
              setState(() {
                _expandedSections[title] = !isExpanded;
              });
            },
            child: Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _sectionTitle(title),
                    style: TextStyles.semiBold(
                      16.sp,
                      fontColor: AppColors.black1414141,
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.remove : Icons.add,
                    color: AppColors.black1414141,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) content.isNotEmpty ? HtmlWidget(content) :  Text('notification_no_data'.tr, style: TextStyles.semiBold(18.sp, fontColor: AppColors.black1414141)),
        ],
      ),
    );
  }

  Widget _buildKeyBenefitsSection(Specification? specification) {
    return specification != null ? Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(Assets.images.darkGreenBg.path),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        children: [
          Text(
            specification.mainTitle ?? '',
            style: TextStyles.bold(18.sp, fontColor: AppColors.surfaceColor),
            textAlign: TextAlign.center,
          ),
          Gap(20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children:
            specification.items?.map((e) {
              return _buildBenefitIcon(e.imageMobile ?? "");
            }).toList() ??
                [],
          ),
        ],
      ),
    ) : SizedBox.shrink();
  }

  Widget _buildBenefitIcon(String imagePath) {
    return ClipOval(
      child: Container(
        width: 80.w,
        height: 80.w,
        decoration: BoxDecoration(shape: BoxShape.circle),
        child: CommonNetworkImage(imageUrl: imagePath),
      ),
    );
  }

  Widget _buildRealCustomersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            'product_detail_real_customers'.tr,
            style: TextStyles.bold(18.sp, fontColor: AppColors.black1414141),
          ),
        ),
        Gap(16.h),
        SizedBox(
          height: 375.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: shopAllController.productReviews?.length,
            itemBuilder: (context, index) {
              final review = shopAllController.productReviews?[index];
              return Container(
                margin: EdgeInsets.only(
                  right:
                      index ==
                          (shopAllController.productReviews?.length ?? 0) - 1
                      ? 0
                      : 12.w,
                ),
                child: CustomerReviewCard(review: review),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildComparisonTable(ComparisonSection? comparisonSection) {
    return comparisonSection != null ? Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            comparisonSection.title ?? "",
            style: TextStyles.bold(18.sp, fontColor: AppColors.black1414141),
          ),
          Gap(16.h),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceColor,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Stack(
              children: [
                // Full column background for Viteezy column
                Positioned.fill(
                  child: Row(
                    children: [
                      Spacer(flex: 3), // Spacer for feature column
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.yellowF0EFE4,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                      ),
                      Spacer(), // Spacer for Others column
                    ],
                  ),
                ),
                // Content
                Column(
                  children: [
                    // Header Row
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            '',
                            style: TextStyles.semiBold(
                              14.sp,
                              fontColor: AppColors.black1414141,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 16.h,
                              ),
                              child: Text(
                                'Viteezy',
                                style: TextStyles.semiBold(
                                  12.sp,
                                  fontColor: AppColors.black1414141,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              'product_detail_others'.tr,
                              style: TextStyles.semiBold(
                                12.sp,
                                fontColor: AppColors.black1414141,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Build rows from comparisonSection rows data
                    if (comparisonSection != null &&
                        comparisonSection.rows != null &&
                        comparisonSection.rows!.isNotEmpty)
                      ...List.generate(comparisonSection.rows!.length, (
                        rowIndex,
                      ) {
                        final row = comparisonSection.rows![rowIndex];
                        final rowLabel = row.label ?? '';
                        final othersValue =
                            row.values != null && row.values!.isNotEmpty
                            ? row.values!.first
                            : false;
                        const viteezyValue = true;

                        return Column(
                          children: [
                            _buildComparisonRow(
                              rowLabel,
                              viteezyValue,
                              othersValue,
                              isFirst: rowIndex == 0,
                            ),
                            if (rowIndex < comparisonSection.rows!.length - 1)
                              _buildDivider1(),
                          ],
                        );
                      })
                    else
                      // Fallback to empty state if no data
                      const SizedBox.shrink(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ) : SizedBox.square();
  }

  Widget _buildComparisonRow(
    String text,
    bool viteezy,
    bool others, {
    bool isFirst = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h, top: isFirst ? 0 : 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: Padding(
              padding: EdgeInsets.only(right: 18.w),
              child: Text(
                text,
                style: TextStyles.semiBold(
                  13.sp,
                  fontColor: AppColors.black1414141,
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: (viteezy ? Assets.icons.icChecked : Assets.icons.icCancel)
                  .svg(width: 22.w, height: 22.w),
            ),
          ),
          Expanded(
            child: Center(
              child: (others ? Assets.icons.icChecked : Assets.icons.icCancel)
                  .svg(width: 22.w, height: 22.w),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, color: AppColors.backgroundColor);
  }

  Widget _buildDivider1() {
    return Divider(height: 1, color: AppColors.dividerE9E9E9);
  }

  Widget _buildRecentlyViewedSection(Product currentProduct) {
    return _similarProducts.isNotEmpty ?  Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            'product_detail_similar_products'.tr,
            style: TextStyles.bold(18.sp, fontColor: AppColors.black1414141),
          ),
        ),
        Gap(16.h),
        AspectRatio(
          aspectRatio: 1.3,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: _similarProducts.length,
            itemBuilder: (context, index) {
              final p = _similarProducts[index];
              // Always use unique hero tag for similar products section to avoid conflicts
              // This prevents duplicate hero tags when navigating back (both routes are in tree during transition)
              // Use index to ensure uniqueness even if same product appears multiple times
              final heroTag = 'similar_product_image_${p.id ?? ''}_$index';
              return Container(
                width: 180.w,
                margin: EdgeInsets.only(
                  right: index == _similarProducts.length - 1 ? 0 : 12.w,
                ),
                child: ProductCardWidget(
                  product: p,
                  heroTag: heroTag,
                  onTap: () {
                    if (p.id != null && p.id!.isNotEmpty) {
                      Get.toNamed(
                        AppRoutes.productDetail,
                        arguments: {'productId': p.id},
                      );
                    }
                  },
                  onFavoriteTap: () {
                    // Check login before updating UI
                    final isLoggedIn =
                        PrefService.getBool(PrefKeys.isLogin) &&
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
                    p.isLiked = !(p.isLiked ?? false);
                    setState(() {});
                    // Call API to toggle like/dislike
                    shopAllController.toggleLikeDislike(p);
                  },
                  onAddToCart: () async {
                    if (p.id == null || p.id!.isEmpty) {
                      return {
                        'success': false,
                        'message': 'product_detail_product_id_missing'.tr,
                      };
                    }

                    try {
                      // Call add to cart API with default SACHETS variant
                      final result = await shopAllController.addToCart(
                        p.id!,
                        "SACHETS",
                      );

                      if (result['success'] == true) {
                        // Update product's isInCart flag
                        p.isInCart = true;
                        // Update selectedProduct if it matches
                        if (shopAllController.selectedProduct.value?.id ==
                            p.id) {
                          shopAllController.selectedProduct.value?.isInCart =
                              true;
                          shopAllController.selectedProduct.refresh();
                        }
                        // Update the product in the products list if it exists
                        final index = shopAllController.products.indexWhere(
                          (prod) => prod.id == p.id,
                        );
                        if (index != -1) {
                          shopAllController.products[index].isInCart = true;
                          shopAllController.products.refresh();
                        }
                        if (mounted) setState(() {});
                      }

                      return result;
                    } catch (e) {
                      return {
                        'success': false,
                        'message': 'product_detail_error_occurred'.tr,
                      };
                    }
                  },
                  onGoToCart: () {
                    Get.toNamed(AppRoutes.cart);
                  },
                ),
              );
            },
          ),
        ),
      ],
    ) : SizedBox.shrink();
  }

  void _showShareBottomSheet(BuildContext context, Product product) {
    Get.bottomSheet(
      ShareProductBottomSheet(product: product),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  /// Product Not Found Error UI
  Widget _buildProductNotFoundError() {
    final arguments = Get.arguments;
    final String? productId = arguments?['productId'];

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error Icon
            Container(
              width: 120.w,
              height: 120.w,
              decoration: BoxDecoration(
                color: AppColors.grayE3E3DC,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off,
                size: 60.sp,
                color: AppColors.gray949391,
              ),
            ),
            Gap(24.h),
            // Error Title
            Text(
              'product_detail_not_found'.tr,
              style: TextStyles.bold(24.sp, fontColor: AppColors.black1414141),
              textAlign: TextAlign.center,
            ),
            Gap(12.h),
            // Error Message
            Text(
              'product_detail_not_found_message'.tr,
              style: TextStyles.regular(14.sp, fontColor: AppColors.gray949391),
              textAlign: TextAlign.center,
            ),
            Gap(32.h),
            // Retry Button
            ElevatedButton(
              onPressed: () {
                if (productId != null && productId.isNotEmpty) {
                  shopAllController.getProductById(productId);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: AppColors.surfaceColor,
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.r),
                ),
                elevation: 0,
              ),
              child: Text(
                'product_detail_try_again'.tr,
                style: TextStyles.semiBold(
                  16.sp,
                  fontColor: AppColors.surfaceColor,
                ),
              ),
            ),
            Gap(16.h),
            // Back Button
            TextButton(
              onPressed: () => Get.back(),
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 14.h),
              ),
              child: Text(
                'product_detail_go_back'.tr,
                style: TextStyles.semiBold(
                  16.sp,
                  fontColor: AppColors.primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(Product product) {
    final bool isAddedForCurrentSelection =
        _lastAddedCartSelectionKey == _currentCartSelectionKey;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: (isAddedForCurrentSelection || _isAddingToCart)
                    ? null
                    : () async {
                        if (product.id == null || product.id!.isEmpty) return;

                        // Set loading state
                        setState(() {
                          _isAddingToCart = true;
                        });

                        try {
                          // Call add to cart API
                          final result = await shopAllController.addToCart(
                            product.id!,
                            _selectedPreference == "sachets"
                                ? "SACHETS"
                                : "STAND_UP_POUCH",
                            quantity: _selectedPreference == 'pouch'
                                ? _pouchQuantity
                                : null,
                            planDays: _selectedPreference == 'pouch'
                                ? _selectedCapsuleCount
                                : null,
                          );

                          if (result['success'] == true) {
                            // Update product's isInCart flag
                            product.isInCart = true;
                            _lastAddedCartSelectionKey =
                                _currentCartSelectionKey;
                            // Update selectedProduct to trigger UI refresh
                            shopAllController.selectedProduct.value = product;
                            // Update the product in the products list if it exists
                            final index = shopAllController.products.indexWhere(
                              (p) => p.id == product.id,
                            );
                            if (index != -1) {
                              shopAllController.products[index].isInCart = true;
                              shopAllController.products.refresh();
                            }
                            final similarIndex = _similarProducts.indexWhere(
                              (p) => p.id == product.id,
                            );
                            if (similarIndex != -1) {
                              _similarProducts[similarIndex].isInCart = true;
                            }
                            // Show success message only if login was successful (not showing login dialog)
                            CustomToast.showItemAddedToCart(
                              context: context,
                              message:
                                  result['message'] as String? ??
                                  'product_detail_item_added'.tr,
                              onGoToCart: () {
                                Get.toNamed(AppRoutes.cart);
                              },
                            );
                          }
                          // Don't show error toast if login dialog was shown (result['success'] == false due to login check)
                          // else {
                          //   // Show error message
                          //   CustomToast.show(
                          //     context: context,
                          //     message: result['message'] as String? ?? 'Failed to add item to cart',
                          //   );
                          // }
                        } finally {
                          // Reset loading state
                          if (mounted) {
                            setState(() {
                              _isAddingToCart = false;
                            });
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isAddedForCurrentSelection
                      ? AppColors.gray949391
                      : AppColors.black1414141,
                  foregroundColor: AppColors.surfaceColor,
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                  elevation: 0,
                ),
                child: _isAddingToCart
                    ? SizedBox(
                        height: 20.h,
                        width: 20.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.surfaceColor,
                          ),
                        ),
                      )
                    : isAddedForCurrentSelection
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check,
                            size: 18.sp,
                            color: AppColors.surfaceColor,
                          ),
                          Gap(8.w),
                          Text(
                            'product_detail_added'.tr,
                            style: TextStyles.semiBold(
                              16.sp,
                              fontColor: AppColors.surfaceColor,
                            ),
                          ),
                        ],
                      )
                    : Text(
                        'product_detail_add_to_cart'.tr,
                        style: TextStyles.semiBold(
                          16.sp,
                          fontColor: AppColors.surfaceColor,
                        ),
                      ),
              ),
            ),
            Gap(12.w),
            Expanded(
              child: ElevatedButton(
                onPressed: (_isBuyingNow || _isAddingToCart)
                    ? null
                    : () async {
                        if (product.id == null || product.id!.isEmpty) return;

                        // Set loading state
                        setState(() {
                          _isBuyingNow = true;
                        });

                        try {
                          // Call add to cart API
                          final result = await shopAllController.addToCart(
                            product.id!,
                            _selectedPreference == "sachets"
                                ? "SACHETS"
                                : "STAND_UP_POUCH",
                            quantity: _selectedPreference == 'pouch'
                                ? _pouchQuantity
                                : null,
                            planDays: _selectedPreference == 'pouch'
                                ? _selectedCapsuleCount
                                : null,
                          );

                          if (result['success'] == true) {
                            // Update product's isInCart flag
                            product.isInCart = true;
                            _lastAddedCartSelectionKey =
                                _currentCartSelectionKey;
                            // Update selectedProduct to trigger UI refresh
                            shopAllController.selectedProduct.value = product;
                            // Update the product in the products list if it exists
                            final index = shopAllController.products.indexWhere(
                              (p) => p.id == product.id,
                            );
                            if (index != -1) {
                              shopAllController.products[index].isInCart = true;
                              shopAllController.products.refresh();
                            }
                            final similarIndex = _similarProducts.indexWhere(
                              (p) => p.id == product.id,
                            );
                            if (similarIndex != -1) {
                              _similarProducts[similarIndex].isInCart = true;
                            }
                            // Navigate to checkout page
                            Get.toNamed(AppRoutes.checkout);
                          } else {
                            // Show error message if needed
                            // CustomToast.show(
                            //   context: context,
                            //   message: result['message'] as String? ?? 'Failed to add item to cart',
                            // );
                          }
                        } finally {
                          // Reset loading state
                          if (mounted) {
                            setState(() {
                              _isBuyingNow = false;
                            });
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: AppColors.surfaceColor,
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                  elevation: 0,
                ),
                child: _isBuyingNow
                    ? SizedBox(
                        height: 20.h,
                        width: 20.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.surfaceColor,
                          ),
                        ),
                      )
                    : Text(
                        'product_detail_buy_now'.tr,
                        style: TextStyles.semiBold(
                          16.sp,
                          fontColor: AppColors.surfaceColor,
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

/// Minus/plus button for quantity selector
class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QuantityButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          child: Icon(icon, size: 20.sp, color: AppColors.black1414141),
        ),
      ),
    );
  }
}

/// Custom Painter for Triangle Indicator
class _TrianglePainter extends CustomPainter {
  final Color color;

  _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    // Create upward-pointing triangle
    path.moveTo(size.width / 2, 0); // Top point
    path.lineTo(0, size.height); // Bottom left
    path.lineTo(size.width, size.height); // Bottom right
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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

  final List<String> _menuItems = [
    'product_detail_faq',
    'product_detail_about_us',
    'auth_login',
  ];

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
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
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
              title.tr,
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

import 'package:get/get.dart';
import 'package:viteezy/core/models/wishlist_model.dart' hide Product;
import 'package:viteezy/core/utils/app_prefrence.dart';
import 'package:viteezy/core/utils/exports.dart';
import '../../../../core/models/product_response_model.dart';
import '../../../../core/utils/app_functions.dart';
import '../../shop_all_view/controller/shop_all_controller.dart';

class WishlistController extends GetxController {
  // Get favorites from ShopAllController
  ShopAllController? get shopAllController =>
      Get.isRegistered<ShopAllController>() ? Get.find<ShopAllController>() : null;

  // Wishlist products (only favorites) - reactive to favorites changes
  List<Product> get wishlistProducts => [];

  // Filter states - sync with ShopAllController
  RxList<String> get selectedIngredients => shopAllController?.selectedIngredients ?? <String>[].obs;

  RxList<String> get selectedHealthGoals => shopAllController?.selectedHealthGoals ?? <String>[].obs;

  RxList<String> get selectedProductTypes => shopAllController?.selectedProductTypes ?? <String>[].obs;

  RxString get selectedSortBy => shopAllController?.selectedSortBy ?? 'relevance'.obs;

  // Filter options
  final ingredientOptions = ['Ashwagandha', 'Vitamin C', 'Omega-3', 'Chlorella', 'Spirulina'];
  final healthGoalOptions = [
    'Immunity Boost',
    'Energy & Stamina',
    'Better Sleep',
    'Skin & Hair Health',
    'Heart Health',
  ];
  final productTypeOptions = ['Stand-up pouch', 'Viteezy Sachets'];
  final sortByOptions = [
    'Popularity',
    'Price: Low to High',
    'Price: High to Low',
    'Customer Rating',
    'Newest First',
    'Best Selling',
    'relevance',
  ];

  ProductRepository productRepository = ProductRepository();
  int pageNumber = 1;
  List<Product> wishlistProductList = [];
  WishlistModel wishlistModel = WishlistModel();
  RxBool loader = false.obs;

  Future getProductWishlist({bool isRefresh = false}) async {
    if (isRefresh) {
      pageNumber = 1;
      wishlistProductList.clear();
    }
    
    loader.value = isMoreLoading.value == true ? false : true;
    await productRepository.productWishlist(
      page: pageNumber,
      onSuccess: (ApiResponse response) {
        // wishlistModel = WishlistModel.fromJson(response.toJson());
        // List<Product> wishProducts = (response.data as List)
        //     .map((x) {
        //       try {
        //         return Product.fromJson(x as Map<String, dynamic>);
        //       } catch (e) {
        //         print('Error parsing product: $e');
        //         return null;
        //       }
        //     })
        //     .whereType<Product>()
        //     .toList();
        List<Product> wishProducts = List<Product>.from(response.data.map((x) => Product.fromJson(x['product'])));
        wishlistModel = WishlistModel(
          success: response.success,
          message: response.message,
          data: wishProducts,
          pagination: response.pagination,
        );

        if (isRefresh) {
          // On refresh, replace all products
          wishlistProductList = wishlistModel.data ?? [];
        } else {
          // On load more, append products
          wishlistProductList = wishlistProductList + (wishlistModel.data ?? []);
        }
        loader.value = false;
        isMoreLoading.value = false;
        update();
      },
      onError: (AppException error) {
        loader.value = false;
        wishlistProductList = wishlistProductList;

        isMoreLoading.value = false;
        debugPrint('Error loading product Wishlist: ${error.message}');
        AppFunctions().showToast(error.message, bgColor: AppColors.red);
      },
    );
  }

  /// Refresh wishlist data (used for pull-to-refresh)
  Future<void> refreshWishlist() async {
    await getProductWishlist(isRefresh: true);
  }

  Future init() async {
    await getProductWishlist();
  }

  RxBool isMoreLoading = false.obs;

  loadMoreWishlistData() {
    isMoreLoading.value = true;
    pageNumber++;
    getProductWishlist();
    update();
  }

  Future<void> toggleLikeDislike({required String productId, required int index}) async {
    await productRepository.toggleLike(
      body: {"productId": productId, "status": 1},
      onSuccess: (data) {
        Get.find<ShopAllController>().getProductAll(isRefresh: true);

        Get.find<ShopAllController>().getProductCategories();
      },
      onError: (error) async {
        AppFunctions().showToast(error.message, bgColor: AppColors.red);
        pageNumber = 1;
        wishlistProductList.clear();
        await getProductWishlist();
      },
    );
  }

  @override
  void onInit() {
    super.onInit();
    if (!Get.isRegistered<ShopAllController>()) {
      Get.put(ShopAllController(), permanent: true);
    }
    // Wishlist is loaded from WishlistView.initState via getProductWishlist()
  }
}

import '../exceptions/app_exception.dart';
import '../models/api_response.dart';
import '../repositories/base_repository.dart';
import '../services/api_service.dart';
import '../services/api_endpoints.dart';

/// Product Repository - Simple API calls for products
class ProductRepository extends BaseRepository {
  ProductRepository({super.apiClient});

  /// Get all Categories
  Future<void> getProductCategories({
    Function(ApiResponse data)? onSuccess,
    Function(AppException data)? onError,
  }) async {
    await apiClient.request(
      url: getFullUrl(ApiEndpoints.productCategories, withLang: true),
      type: RequestType.get,
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  Future<void> getProduct({
    int page = 1,
    int limit = 10,
    Map<String, dynamic>? queryParams,
    Function(ApiResponse data)? onSuccess,
    Function(AppException data)? onError,
  }) async {
    // Default query parameters
    final defaultParams = {'page': page, 'limit': limit};

    // Merge custom queryParams with default ones (custom params override defaults)
    final mergedParams = {...defaultParams, if (queryParams != null) ...queryParams};

    await apiClient.request(
      url: getFullUrl(ApiEndpoints.products, withLang: true),
      type: RequestType.get,
      queryParams: mergedParams,
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  Future<void> getFeaturedProduct({
    Map<String, dynamic>? queryParams,
    Function(ApiResponse data)? onSuccess,
    Function(AppException data)? onError,
  }) async {
    await apiClient.request(
      url: getFullUrl(ApiEndpoints.featuredProducts, withLang: true),
      type: RequestType.get,
      queryParams: {"minCount": 5, "maxCount": 5},
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  Future<void> getProductById({
    required String id,
    Function(ApiResponse data)? onSuccess,
    Function(AppException data)? onError,
  }) async {
    await apiClient.request(
      url: getFullUrl('${ApiEndpoints.products}/$id', withLang: true),
      type: RequestType.get,
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  Future<void> toggleLike({
    Map<String, dynamic>? body,
    Function(ApiResponse data)? onSuccess,
    Function(AppException data)? onError,
  }) async {
    await apiClient.request(
      url: getFullUrl(ApiEndpoints.toggleLike),
      type: RequestType.put,
      body: body,
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  Future<void> productTestimonials({
    int page = 1,
    int limit = 10,
    required String id,
    Function(ApiResponse data)? onSuccess,
    Function(AppException data)? onError,
  }) async {
    await apiClient.request(
      url: getFullUrl(ApiEndpoints.productTestimonials),
      type: RequestType.get,
      onSuccess: onSuccess,
      queryParams: {'page': page, 'limit': limit, "productId": id},
      onError: onError,
    );
  }

  Future<void> getProductFilters({Function(ApiResponse data)? onSuccess, Function(AppException data)? onError}) async {
    await apiClient.request(
      url: getFullUrl(ApiEndpoints.productFilters, withLang: true),
      type: RequestType.get,
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  Future<void> productWishlist({
    required int page,
    int limit = 10,
    Function(ApiResponse data)? onSuccess,
    Function(AppException data)? onError,
  }) async {
    await apiClient.request(
      url: getFullUrl(ApiEndpoints.wishlist(page.toString(), limit.toString())),
      type: RequestType.get,
      onSuccess: onSuccess,
      // queryParams: {'page': page, 'limit': limit},
      onError: onError,
    );
  }
}

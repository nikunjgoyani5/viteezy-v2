import 'package:viteezy/core/exceptions/app_exception.dart' show AppException;
import 'package:viteezy/core/models/api_response.dart';
import 'package:viteezy/core/repositories/base_repository.dart';
import 'package:viteezy/core/services/api_endpoints.dart';
import 'package:viteezy/core/services/api_service.dart';

class CartRepository extends BaseRepository {
  CartRepository({super.apiClient});

  Future<void> addToCartItem({
    Function(ApiResponse data)? onSuccess,
    Function(AppException error)? onError,
    required Map<String, dynamic> body,
  }) async {
    await apiClient.request(
      url: getFullUrl(ApiEndpoints.addToCart),
      type: RequestType.post,
      onSuccess: onSuccess,
      onError: onError,
      body: body,
    );
  }

  Future<void> getCart({
    Function(ApiResponse data)? onSuccess,
    Function(AppException error)? onError,
    Map<String, dynamic>? queryParams,
  }) async {
    await apiClient.request(
      url: getFullUrl(ApiEndpoints.cart),
      type: RequestType.get,
      queryParams: queryParams,
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  Future<void> deleteCartItem({
    Function(ApiResponse data)? onSuccess,
    Function(AppException error)? onError,
    required Map<String, dynamic> body,
  }) async {
    await apiClient.request(
      url: getFullUrl(ApiEndpoints.addToCart),
      type: RequestType.delete,
      onSuccess: onSuccess,
      onError: onError,
      body: body,
    );
  }

  /// Remove product from subscription update cart (when fromSubscriptionUpdate). POST body: { "productId": "..." }.
  Future<void> removeSubscriptionUpdateProduct({
    required String subscriptionId,
    required String productId,
    Function(ApiResponse data)? onSuccess,
    Function(AppException error)? onError,
  }) async {
    await apiClient.request(
      url: getFullUrl(ApiEndpoints.subscriptionUpdateProductsRemove(subscriptionId)),
      type: RequestType.post,
      body: {'productId': productId},
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  Future<void> applyDiscountCode({
    Function(ApiResponse data)? onSuccess,
    Function(AppException error)? onError,
    required String discountCode,
  }) async {
    // Assuming the endpoint is carts/apply-discount or similar
    // If the endpoint is different, update this accordingly
    await apiClient.request(
      url: getFullUrl('${ApiEndpoints.cart}/apply-discount'),
      type: RequestType.post,
      onSuccess: onSuccess,
      onError: onError,
      body: {'discountCode': discountCode},
    );
  }

  Future<void> validateCoupon({
    Function(ApiResponse data)? onSuccess,
    Function(AppException error)? onError,
    required Map<String, dynamic> body,
  }) async {
    await apiClient.request(
      url: getFullUrl(ApiEndpoints.validateCoupon),
      type: RequestType.post,
      onSuccess: onSuccess,
      onError: onError,
      body: body,
    );
  }

  Future<void> clearCart({
    Function(ApiResponse data)? onSuccess,
    Function(AppException error)? onError,
  }) async {
    await apiClient.request(
      url: getFullUrl(ApiEndpoints.cart),
      type: RequestType.delete,
      onSuccess: onSuccess,
      onError: onError,
    );
  }


}

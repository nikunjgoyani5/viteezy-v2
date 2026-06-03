import '../exceptions/app_exception.dart';
import '../models/api_response.dart';
import '../repositories/base_repository.dart';
import '../services/api_endpoints.dart';
import '../services/api_service.dart';

class CheckoutRepository extends BaseRepository {
  CheckoutRepository({super.apiClient});

  Future<void> getCheckoutPageSummary({
    Map<String, dynamic>? body,
    Function(ApiResponse data)? onSuccess,
    Function(AppException error)? onError,
  }) async {
    await apiClient.request(
      url: getFullUrl(ApiEndpoints.checkoutPageSummary),
      type: RequestType.post,
      body: body,
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  /// GET subscription actions summary (for checkout when fromSubscriptionUpdate).
  /// Pass couponCode and optionally shippingAddressId (e.g. when continuing from address step).
  Future<void> getSubscriptionActionsSummary({
    String? couponCode,
    String? shippingAddressId,
    Function(ApiResponse data)? onSuccess,
    Function(AppException error)? onError,
  }) async {
    final queryParams = <String, dynamic>{};
    if (couponCode != null && couponCode.trim().isNotEmpty) {
      queryParams['couponCode'] = couponCode.trim();
    }
    if (shippingAddressId != null && shippingAddressId.trim().isNotEmpty) {
      queryParams['shippingAddressId'] = shippingAddressId.trim();
    }
    await apiClient.request(
      url: getFullUrl(ApiEndpoints.subscriptionActionsSummary),
      type: RequestType.get,
      queryParams: queryParams.isNotEmpty ? queryParams : null,
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  /// POST confirm subscription update (when fromSubscriptionUpdate). Body: { "cartId": "..." }.
  Future<void> confirmSubscriptionUpdate({
    required String subscriptionId,
    required String cartId,
    Function(ApiResponse data)? onSuccess,
    Function(AppException error)? onError,
  }) async {
    await apiClient.request(
      url: getFullUrl(ApiEndpoints.subscriptionUpdateConfirm(subscriptionId)),
      type: RequestType.post,
      body: {'cartId': cartId},
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  Future<void> createOrder({
    required Map<String, dynamic> body,
    Function(ApiResponse data)? onSuccess,
    Function(AppException error)? onError,
  }) async {
    await apiClient.request(
      url: getFullUrl(ApiEndpoints.orders),
      type: RequestType.post,
      body: body,
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  Future<void> createPayment({
    required Map<String, dynamic> body,
    Function(ApiResponse data)? onSuccess,
    Function(AppException error)? onError,
  }) async {
    await apiClient.request(
      url: getFullUrl(ApiEndpoints.createPayment),
      type: RequestType.post,
      body: body,
      onSuccess: onSuccess,
      onError: onError,
    );
  }
}

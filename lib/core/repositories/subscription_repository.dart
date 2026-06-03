import 'package:viteezy/core/exceptions/app_exception.dart' show AppException;
import 'package:viteezy/core/models/api_response.dart';
import 'package:viteezy/core/repositories/base_repository.dart';
import 'package:viteezy/core/services/api_endpoints.dart';
import 'package:viteezy/core/services/api_service.dart';

class SubscriptionRepository extends BaseRepository {
  SubscriptionRepository({super.apiClient});

  Future<void> getSubscriptions({
    int page = 1,
    int limit = 10,
    Function(ApiResponse data)? onSuccess,
    Function(AppException error)? onError,
  }) async {
    await apiClient.request(
      url: getFullUrl(ApiEndpoints.subscriptions),
      type: RequestType.get,
      queryParams: {'page': page, 'limit': limit},
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  Future<void> cancelSubscription({
    required String subscriptionId,
    Function(ApiResponse data)? onSuccess,
    Function(AppException error)? onError,
  }) async {
    await apiClient.request(
      url: getFullUrl(ApiEndpoints.cancelSubscription(subscriptionId)),
      type: RequestType.post,
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  Future<void> pauseSubscription({
    required String subscriptionId,
    Function(ApiResponse data)? onSuccess,
    Function(AppException error)? onError,
  }) async {
    await apiClient.request(
      url: getFullUrl(ApiEndpoints.pauseSubscription(subscriptionId)),
      type: RequestType.post,
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  Future<void> getPostponements({
    required String subscriptionId,
    int page = 1,
    int limit = 10,
    Function(ApiResponse data)? onSuccess,
    Function(AppException error)? onError,
  }) async {
    await apiClient.request(
      url: getFullUrl(ApiEndpoints.postponements),
      type: RequestType.get,
      queryParams: {'subscriptionId': subscriptionId, 'page': page, 'limit': limit},
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  Future<void> changeShippingAddress({
    required String subscriptionId,
    required String shippingAddressId,
    Function(ApiResponse data)? onSuccess,
    Function(AppException error)? onError,
  }) async {
    await apiClient.request(
      url: getFullUrl(ApiEndpoints.changeShippingAddress(subscriptionId)),
      type: RequestType.post,
      body: {'shippingAddressId': shippingAddressId},
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  Future<void> createPostponement({
    required Map<String, dynamic> body,
    Function(ApiResponse data)? onSuccess,
    Function(AppException error)? onError,
  }) async {
    await apiClient.request(
      url: getFullUrl(ApiEndpoints.postponements),
      type: RequestType.post,
      body: body,
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  Future<void> getUserTransactions({
    required String subscriptionId,
    Function(ApiResponse data)? onSuccess,
    Function(AppException error)? onError,
  }) async {
    await apiClient.request(
      url: getFullUrl(ApiEndpoints.userTransactions),
      type: RequestType.get,
      queryParams: {'subscriptionId': subscriptionId},
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  Future<void> getSubscriptionActivity({
    required String subscriptionId,
    int page = 1,
    int limit = 10,
    Function(ApiResponse data)? onSuccess,
    Function(AppException error)? onError,
  }) async {
    await apiClient.request(
      url: getFullUrl(ApiEndpoints.subscriptionActivity(subscriptionId)),
      type: RequestType.get,
      // queryParams: {'page': page, 'limit': limit},
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  Future<void> getSubscriptionProducts({
    required String subscriptionId,
    Function(ApiResponse data)? onSuccess,
    Function(AppException error)? onError,
  }) async {
    await apiClient.request(
      url: getFullUrl(ApiEndpoints.subscriptionProducts(subscriptionId)),
      type: RequestType.get,
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  Future<void> getSubscriptionProductsStatus({
    required String subscriptionId,
    int page = 1,
    int limit = 10,
    Function(ApiResponse data)? onSuccess,
    Function(AppException error)? onError,
  }) async {
    await apiClient.request(
      url: getFullUrl(ApiEndpoints.subscriptionProductsStatus(subscriptionId)),
      type: RequestType.get,
      queryParams: {'page': page, 'limit': limit},
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  Future<void> updateSubscriptionProducts({
    required String subscriptionId,
    required List<String> productIds,
    Function(ApiResponse data)? onSuccess,
    Function(AppException error)? onError,
  }) async {
    await apiClient.request(
      url: getFullUrl(ApiEndpoints.subscriptionUpdateProducts(subscriptionId)),
      type: RequestType.post,
      body: {'productIds': productIds},
      onSuccess: onSuccess,
      onError: onError,
    );
  }
}


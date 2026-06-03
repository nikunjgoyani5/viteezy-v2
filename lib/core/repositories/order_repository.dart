import 'package:viteezy/core/exceptions/app_exception.dart' show AppException;
import 'package:viteezy/core/models/api_response.dart';
import 'package:viteezy/core/repositories/base_repository.dart';
import 'package:viteezy/core/services/api_endpoints.dart';
import 'package:viteezy/core/services/api_service.dart';

class OrdersRepository extends BaseRepository {
  OrdersRepository({super.apiClient});

  Future<void> getOrders({Function(ApiResponse data)? onSuccess, Function(AppException error)? onError}) async {
    await apiClient.request(
      url: getFullUrl(ApiEndpoints.orders),
      type: RequestType.get,
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  Future<void> getOrderDetail({
    required String orderId,
    Function(ApiResponse data)? onSuccess,
    Function(AppException error)? onError,
  }) async {
    await apiClient.request(
      url: getFullUrl(ApiEndpoints.orderDetail(orderId)),
      type: RequestType.get,
      onSuccess: onSuccess,
      onError: onError,
    );
  }
}

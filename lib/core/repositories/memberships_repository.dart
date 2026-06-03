import 'package:viteezy/core/exceptions/app_exception.dart' show AppException;
import 'package:viteezy/core/models/api_response.dart';
import 'package:viteezy/core/repositories/base_repository.dart';
import 'package:viteezy/core/services/api_endpoints.dart';
import 'package:viteezy/core/services/api_service.dart';

class MembershipsRepository extends BaseRepository {
  MembershipsRepository({super.apiClient});

  Future<void> getMembershipsPlans({
    Function(ApiResponse data)? onSuccess,
    Function(AppException error)? onError,
  }) async {
    await apiClient.request(
      url: getFullUrl(ApiEndpoints.membershipsPlans),
      type: RequestType.get,
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  Future<void> buyMembership({
    required String planId,
    required String paymentMethod,
    Function(ApiResponse data)? onSuccess,
    Function(AppException error)? onError,
  }) async {
    await apiClient.request(
      url: getFullUrl(ApiEndpoints.membershipsBuy),
      type: RequestType.post,
      body: {
        'planId': planId,
        'paymentMethod': paymentMethod,
      },
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  Future<void> trackPayment({
    required String membershipId,
    Function(ApiResponse data)? onSuccess,
    Function(AppException error)? onError,
  }) async {
    await apiClient.request(
      url: getFullUrl(ApiEndpoints.trackPayment(membershipId)),
      type: RequestType.get,
      onSuccess: onSuccess,
      onError: onError,
    );
  }
}

import 'package:viteezy/core/exceptions/app_exception.dart';
import 'package:viteezy/core/models/membership_model.dart';
import 'package:viteezy/core/models/transaction_model.dart';
import 'package:viteezy/core/repositories/base_repository.dart';
import 'package:viteezy/core/services/api_endpoints.dart';
import 'package:viteezy/core/services/api_service.dart';

import '../models/api_response.dart';

class MembershipRepository extends BaseRepository {
  MembershipRepository({super.apiClient});

  /// Get all memberships for the current user
  Future<void> getMemberships({
    Function(List<MembershipListItem> memberships)? onSuccess,
    Function(AppException error)? onError,
  }) async {
    await apiClient.request(
      url: getFullUrl(ApiEndpoints.memberships),
      type: RequestType.get,
      onSuccess: (data) {
        final list = <MembershipListItem>[];
        if (data.data != null) {
          // Handle if data is directly a list
          if (data.data is List) {
            final raw = data.data as List;
            for (final item in raw) {
              if (item is Map<String, dynamic>) {
                list.add(MembershipListItem.fromJson(item));
              }
            }
          }
          // Handle if data is wrapped in a field
          else if (data.data is Map<String, dynamic>) {
            final dataMap = data.data as Map<String, dynamic>;
            // Try different possible field names
            List raw = dataMap['memberships'] ?? dataMap['data'] ?? [];
            for (final item in raw) {
              if (item is Map<String, dynamic>) {
                list.add(MembershipListItem.fromJson(item));
              }
            }
          }
        }
        onSuccess?.call(list);
      },
      onError: onError,
    );
  }

  /// Get transaction history for the current user
  Future<void> getMembershipsTransactionsHistoryGetById({
    required String membershipId,
    Function(ApiResponse response)? onSuccess,
    Function(AppException error)? onError,
  }) async {
    await apiClient.request(
      url: getFullUrl(ApiEndpoints.membershipsTransactionsHistoryGetById(membershipId)),
      type: RequestType.get,
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  Future<void> canselMembership({
    required String membershipId,
    Function(ApiResponse data)? onSuccess,
    Function(AppException error)? onError,
  }) async {
    await apiClient.request(
      url: getFullUrl(ApiEndpoints.canselMembership(membershipId)),
      type: RequestType.post,
      onSuccess: onSuccess,
      onError: onError,
    );
  }
}

import 'package:viteezy/core/exceptions/app_exception.dart';
import 'package:viteezy/core/models/api_response.dart';
import 'package:viteezy/core/repositories/base_repository.dart';
import 'package:viteezy/core/services/api_endpoints.dart';
import 'package:viteezy/core/services/api_service.dart';

class NotificationRepository extends BaseRepository {
  NotificationRepository({super.apiClient});

  Future<void> getNotifications({
    int page = 1,
    int limit = 10,
    Function(ApiResponse data)? onSuccess,
    Function(AppException error)? onError,
  }) async {
    await apiClient.request(
      url: getFullUrl(ApiEndpoints.notifications(page, limit)),
      type: RequestType.get,
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  Future<void> markNotificationAsRead({
    required String notificationId,
    Function(ApiResponse data)? onSuccess,
    Function(AppException error)? onError,
  }) async {
    await apiClient.request(
      url: getFullUrl(ApiEndpoints.notificationMarkRead(notificationId)),
      type: RequestType.patch,
      onSuccess: onSuccess,
      onError: onError,
    );
  }
}

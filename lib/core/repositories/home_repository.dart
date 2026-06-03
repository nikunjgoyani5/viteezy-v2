import 'package:viteezy/core/exceptions/app_exception.dart' show AppException;
import 'package:viteezy/core/models/api_response.dart';
import 'package:viteezy/core/repositories/base_repository.dart';
import 'package:viteezy/core/services/api_endpoints.dart';
import 'package:viteezy/core/services/api_service.dart';

class HomeRepository extends BaseRepository {
  HomeRepository({super.apiClient});

  Future<void> getLandingPage({
    Function(ApiResponse data)? onSuccess,
    Function(AppException error)? onError,
  }) async {
    await apiClient.request(
      url: getFullUrl(ApiEndpoints.landingPage, withLang: true),
      type: RequestType.get,
      onSuccess: onSuccess,
      onError: onError,
    );
  }
}


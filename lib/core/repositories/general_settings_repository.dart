import '../exceptions/app_exception.dart';
import '../models/api_response.dart';
import '../repositories/base_repository.dart';
import '../services/api_endpoints.dart';
import '../services/api_service.dart';

class GeneralSettingsRepository extends BaseRepository {
  GeneralSettingsRepository({super.apiClient});

  Future<void> getGeneralSettings({
    Function(ApiResponse data)? onSuccess,
    Function(AppException data)? onError,
  }) async {
    await apiClient.request(
      url: getFullUrl(ApiEndpoints.generalSettings),
      type: RequestType.get,
      onSuccess: onSuccess,
      onError: onError,
    );
  }
}


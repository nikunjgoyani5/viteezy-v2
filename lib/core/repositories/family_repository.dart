import 'package:viteezy/core/exceptions/app_exception.dart';
import 'package:viteezy/core/models/family_info_model.dart';
import 'package:viteezy/core/repositories/base_repository.dart';
import 'package:viteezy/core/services/api_endpoints.dart';
import 'package:viteezy/core/services/api_service.dart';

class FamilyRepository extends BaseRepository {
  FamilyRepository({super.apiClient});

  Future<void> getFamilyInfo({
    Function(FamilyInfoData data)? onSuccess,
    Function(AppException error)? onError,
  }) async {
    await apiClient.request(
      url: getFullUrl(ApiEndpoints.familyInfo),
      type: RequestType.get,
      onSuccess: (response) {
        try {
          final model = FamilyInfoModel.fromJson(response.toJson());
          onSuccess?.call(model.data);
        } catch (_) {
          onError?.call(AppException(message: 'Unable to parse family details'));
        }
      },
      onError: onError,
    );
  }

  Future<void> removeFamilyMember({
    required String userId,
    Function(dynamic data)? onSuccess,
    Function(AppException error)? onError,
  }) async {
    await apiClient.request(
      url: getFullUrl(ApiEndpoints.removeFamilyMember(userId)),
      type: RequestType.delete,
      onSuccess: (response) => onSuccess?.call(response),
      onError: onError,
    );
  }
}

import 'package:viteezy/core/exceptions/app_exception.dart' show AppException;
import 'package:viteezy/core/models/api_response.dart';
import 'package:viteezy/core/repositories/base_repository.dart';
import 'package:viteezy/core/services/api_endpoints.dart';
import 'package:viteezy/core/services/api_service.dart';

class AiChatRepository extends BaseRepository {
  AiChatRepository({super.apiClient});

  Future<void> health({Function(ApiResponse data)? onSuccess, Function(AppException error)? onError}) async {
    await apiClient.request(
      url: getQuizFullUrl(ApiEndpoints.health),
      type: RequestType.get,
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  Future<void> createSession({
    Map<String, dynamic>? body,
    Function(ApiResponse data)? onSuccess,
    Function(AppException error)? onError,
  }) async {
    await apiClient.request(
      url: getQuizFullUrl(ApiEndpoints.sessions),
      body: body,
      type: RequestType.post,
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  Future<void> getFirstQuestion({
    Map<String, dynamic>? body,
    Function(ApiResponse data)? onSuccess,
    Function(AppException error)? onError,
  }) async {
    await apiClient.request(
      url: getQuizFullUrl(ApiEndpoints.firstQuestion),
      queryParams: body,
      type: RequestType.get,
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  Future<void> sendMessage({
    Map<String, dynamic>? body,
    Function(ApiResponse data)? onSuccess,
    Function(AppException error)? onError,
  }) async {
    await apiClient.request(
      url: getQuizFullUrl(ApiEndpoints.chat),
      body: body,
      type: RequestType.post,
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  Future<void> useridLogin({
    Map<String, dynamic>? body,
    Function(ApiResponse data)? onSuccess,
    Function(AppException error)? onError,
  }) async {
    await apiClient.request(
      url: getQuizFullUrl(ApiEndpoints.useridLogin),
      body: body,
      type: RequestType.post,
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  Future<void> getSessionByUser({
    required String userId,
    int page = 1,
    int limit = 10,
    Function(ApiResponse data)? onSuccess,
    Function(AppException error)? onError,
  }) async {
    await apiClient.request(
      url: getQuizFullUrl(ApiEndpoints.sessionByUser),
      type: RequestType.get,
      queryParams: {"user_id": userId, "page": page, "limit": limit},
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  Future<void> getSearchSessionByUser({
    required String userId,
    required String? search,
    Function(ApiResponse data)? onSuccess,
    Function(AppException error)? onError,
  }) async {
    await apiClient.request(
      url: getQuizFullUrl(ApiEndpoints.searchMessages),
      type: RequestType.get,
      queryParams: {"user_id": userId, "word": search},
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  Future<void> getSessionsHistory({
    required String userId,
    required String sessionId,
    int page = 1,
    Function(ApiResponse data)? onSuccess,
    Function(AppException error)? onError,
  }) async {
    await apiClient.request(
      url: getQuizFullUrl(ApiEndpoints.sessionsHistory),
      type: RequestType.get,
      queryParams: {"user_id": userId, "session_id": sessionId, "page": page},
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  Future<void> deleteSession({
    required String sessionId,
    required String userId,
    Function(ApiResponse data)? onSuccess,
    Function(AppException error)? onError,
  }) async {
    await apiClient.request(
      url: getQuizFullUrl(ApiEndpoints.deleteSession(sessionId)),
      type: RequestType.delete,
      queryParams: {"user_id": userId},
      onSuccess: onSuccess,
      onError: onError,
    );
  }
}

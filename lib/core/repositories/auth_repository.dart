import 'package:viteezy/core/exceptions/app_exception.dart' show AppException;
import 'package:viteezy/core/models/api_response.dart';
import 'package:viteezy/core/repositories/base_repository.dart';
import 'package:viteezy/core/services/api_endpoints.dart';
import 'package:viteezy/core/services/api_service.dart';

class AuthRepository extends BaseRepository {
  AuthRepository({super.apiClient});

  Future<void> login({
    Function(ApiResponse data)? onSuccess,
    Function(AppException error)? onError,
    required Map<String, dynamic> body,
  }) async {
    await apiClient.request(
      url: getFullUrl(ApiEndpoints.login),
      type: RequestType.post,
      onSuccess: onSuccess,
      onError: onError,
      body: body,
    );
  }
  Future<void> googleLoginAPi({
    Function(ApiResponse data)? onSuccess,
    Function(AppException error)? onError,
    required Map<String, dynamic> body,
  }) async {
    await apiClient.request(
      url: getFullUrl(ApiEndpoints.googleLogin),
      type: RequestType.post,
      onSuccess: onSuccess,
      onError: onError,
      body: body,
    );
  } Future<void> appleLoginAPi({
    Function(ApiResponse data)? onSuccess,
    Function(AppException error)? onError,
    required Map<String, dynamic> body,
  }) async {
    await apiClient.request(
      url: getFullUrl(ApiEndpoints.appleLogin),
      type: RequestType.post,
      onSuccess: onSuccess,
      onError: onError,
      body: body,
    );
  }

  Future<void> signUp({
    Function(ApiResponse data)? onSuccess,
    Function(AppException error)? onError,
    required Map<String, dynamic> body,
  }) async {
    await apiClient.request(
      url: getFullUrl(ApiEndpoints.register),
      type: RequestType.post,
      onSuccess: onSuccess,
      onError: onError,
      body: body,
    );
  }

  Future<void> otpVerification({
    Function(ApiResponse data)? onSuccess,
    Function(AppException error)? onError,
    required Map<String, dynamic> body,
  }) async {
    await apiClient.request(
      url: getFullUrl(ApiEndpoints.verifyOtp),
      type: RequestType.post,
      onSuccess: onSuccess,
      onError: onError,
      body: body,
    );
  }

  Future<void> resendOtp({
    Function(ApiResponse data)? onSuccess,
    Function(AppException error)? onError,
    required Map<String, dynamic> body,
  }) async {
    await apiClient.request(
      url: getFullUrl(ApiEndpoints.resendOtp),
      type: RequestType.post,
      onSuccess: onSuccess,
      onError: onError,
      body: body,
    );
  }

  Future<void> forgotPass({
    Function(ApiResponse data)? onSuccess,
    Function(AppException error)? onError,
    required Map<String, dynamic> body,
  }) async {
    await apiClient.request(
      url: getFullUrl(ApiEndpoints.forgotPassword),
      type: RequestType.post,
      onSuccess: onSuccess,
      onError: onError,
      body: body,
    );
  }

  Future<void> resetPassword({
    Function(ApiResponse data)? onSuccess,
    Function(AppException error)? onError,
    required Map<String, dynamic> body,
  }) async {
    await apiClient.request(
      url: getFullUrl(ApiEndpoints.resetPassword),
      type: RequestType.post,
      onSuccess: onSuccess,
      onError: onError,
      body: body,
    );
  }

  Future<void> sessionLink({
    Function(ApiResponse data)? onSuccess,
    Function(AppException error)? onError,
    required Map<String, dynamic> body,
  }) async {
    await apiClient.request(
      url: getQuizFullUrl(ApiEndpoints.sessionLink),
      type: RequestType.post,
      onSuccess: onSuccess,
      onError: onError,
      body: body,
    );
  }
}

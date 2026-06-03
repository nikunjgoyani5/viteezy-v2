import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:viteezy/core/exceptions/app_exception.dart' show AppException;
import 'package:viteezy/core/models/api_response.dart';
import 'package:viteezy/core/repositories/base_repository.dart';
import 'package:viteezy/core/services/api_endpoints.dart';
import 'package:viteezy/core/services/api_service.dart';

class ProfileRepository extends BaseRepository {
  ProfileRepository({super.apiClient});

  Future<void> changePassword({
    Function(ApiResponse data)? onSuccess,
    Function(AppException error)? onError,
    required Map<String, dynamic> body,
  }) async {
    await apiClient.request(
      url: getFullUrl(ApiEndpoints.changePass),
      type: RequestType.post,
      onSuccess: onSuccess,
      onError: onError,
      body: body,
    );
  }

  Future<void> logout({Function(ApiResponse data)? onSuccess, Function(AppException error)? onError}) async {
    await apiClient.request(
      url: getFullUrl(ApiEndpoints.logout),
      type: RequestType.post,
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  Future<void> getUserProfile({Function(ApiResponse data)? onSuccess, Function(AppException error)? onError}) async {
    await apiClient.request(
      url: getFullUrl(ApiEndpoints.getUserProfile),
      type: RequestType.get,
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  /// Update user language on server (PUT users/me with form language=...). Call when user selects language from sheet.
  Future<void> updateUserLanguage({
    required String language,
    Function(ApiResponse data)? onSuccess,
    Function(AppException error)? onError,
  }) async {
    await apiClient.request(
      url: getFullUrl(ApiEndpoints.getUserProfile),
      type: RequestType.put,
      formData: dio.FormData.fromMap({'language': language}),
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  /// Register device token (e.g. OneSignal push token) with backend for push notifications.
  Future<void> registerDeviceToken({
    required String deviceToken,
    String platform = 'Mobile',
    Function(ApiResponse data)? onSuccess,
    Function(AppException error)? onError,
  }) async {
    await apiClient.request(
      url: getFullUrl(ApiEndpoints.deviceToken),
      type: RequestType.post,
      body: {'deviceToken': deviceToken, 'platform': platform},
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  Future<void> updateUserProfile({
    Function(ApiResponse data)? onSuccess,
    Function(AppException error)? onError,
    required Map<String, dynamic> data,
    File? profileImage,
    bool shouldRemoveImage = false,
  }) async {
    // Create FormData for multipart request
    final formData = dio.FormData.fromMap(data);

    // Add image file if provided
    if (profileImage != null) {
      final fileName = profileImage.path.split('/').last;
      formData.files.add(
        MapEntry('profileImage', await dio.MultipartFile.fromFile(profileImage.path, filename: fileName)),
      );
    } else if (shouldRemoveImage) {
      // Send null to remove the profile image
      formData.fields.add(MapEntry('profileImage', ''));
    }

    await apiClient.request(
      url: getFullUrl(ApiEndpoints.getUserProfile),
      type: RequestType.put,
      formData: formData,
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  Future<void> getFaqCategory({
    Function(ApiResponse data)? onSuccess,
    Function(AppException error)? onError,
    required Map<String, dynamic> data,
  }) async {
    await apiClient.request(
      url: getFullUrl(ApiEndpoints.faqCategory, withLang: true),
      type: RequestType.post,
      onSuccess: onSuccess,
      onError: onError,
      body: data,
    );
  }

  Future<void> getFaqsByCategory({
    Function(ApiResponse data)? onSuccess,
    Function(AppException error)? onError,
    required Map<String, dynamic> data,
  }) async {
    await apiClient.request(
      url: getFullUrl(ApiEndpoints.faqs, withLang: true),
      type: RequestType.post,
      body: data,
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  Future<void> addAddressAPI({
    Function(ApiResponse data)? onSuccess,
    Function(AppException error)? onError,
    required Map<String, dynamic> data,
  }) async {
    await apiClient.request(
      url: getFullUrl(ApiEndpoints.address),
      type: RequestType.post,
      body: data,
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  Future<void> getAddresses({
    Map<String, dynamic>? queryParams,
    Function(ApiResponse data)? onSuccess,
    Function(AppException error)? onError,
  }) async {
    await apiClient.request(
      url: getFullUrl(ApiEndpoints.address),
      type: RequestType.get,
      queryParams: queryParams,
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  Future<void> getSubMembers({
    Function(ApiResponse data)? onSuccess,
    Function(AppException error)? onError,
  }) async {
    await apiClient.request(
      url: getFullUrl(ApiEndpoints.subMembers),
      type: RequestType.get,
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  Future<void> getAddressById({
    required String addressId,
    Function(ApiResponse data)? onSuccess,
    Function(AppException error)? onError,
  }) async {
    await apiClient.request(
      url: getFullUrl('${ApiEndpoints.address}/$addressId'),
      type: RequestType.get,
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  Future<void> updateAddressAPI({
    required String addressId,
    Function(ApiResponse data)? onSuccess,
    Function(AppException error)? onError,
    required Map<String, dynamic> data,
  }) async {
    await apiClient.request(
      url: getFullUrl('${ApiEndpoints.address}/$addressId'),
      type: RequestType.put,
      body: data,
      onSuccess: onSuccess,
      onError: onError,
    );
  }

  Future<void> deleteAddressAPI({
    required String addressId,
    Function(ApiResponse data)? onSuccess,
    Function(AppException error)? onError,
  }) async {
    await apiClient.request(
      url: getFullUrl('${ApiEndpoints.address}/$addressId'),
      type: RequestType.delete,
      onSuccess: onSuccess,
      onError: onError,
    );
  }
}

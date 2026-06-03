import '../l10n/locale_service.dart';
import '../services/api_service.dart';
import '../services/api_endpoints.dart';
import '../utils/app_constant.dart';

abstract class BaseRepository {
  final ApiClient apiClient;

  BaseRepository({ApiClient? apiClient}) : apiClient = apiClient ?? ApiClient();

  /// Builds full URL for [endpoint]. Set [withLang] true to append current locale (e.g. &lang=nl).
  String getFullUrl(String endpoint, {bool withLang = false}) {
    var path = '$baseUrl$endpoint';
    if (withLang) {
      final sep = path.contains('?') ? '&' : '?';
      path = '$path${sep}lang=${LocaleService.localeCode}';
    }
    return path;
  }

  String getQuizFullUrl(String endpoint) {
    return '$quizBaseUrl$endpoint';
  }
}

import 'dart:developer';
import 'package:get/get.dart';
import '../models/general_settings_model.dart';
import '../models/home_data_model.dart';
import '../repositories/general_settings_repository.dart';
import '../repositories/home_repository.dart';
import '../theme/app_colors.dart';
import '../utils/app_functions.dart';

/// Global service to store and access general settings throughout the app
class GlobalSettingsService extends GetxService {
  static GlobalSettingsService get to => Get.find<GlobalSettingsService>();

  final GeneralSettingsRepository _repository = GeneralSettingsRepository();
  final HomeRepository _homeRepository = HomeRepository();

  // Reactive settings that can be accessed globally
  final Rx<Settings> settings = Settings.defaultValues().obs;

  // Flag to track if settings have been loaded
  final RxBool isSettingsLoaded = false.obs;

  // Landing page data
  final Rx<HomeData?> landingPageData = Rx<HomeData?>(null);
  final RxBool isLandingPageLoaded = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize with default values
    settings.value = Settings.defaultValues();
  }

  /// Fetch general settings and landing page data from API (called in background, no loading indicator)
  /// Both APIs are called in parallel for early data loading
  Future<void> fetchGeneralSettings() async {
    try {
      // Call both APIs in parallel
      await Future.wait([_fetchGeneralSettings(), _fetchLandingPage()]);
    } catch (e) {
      log('Exception in fetchGeneralSettings: $e');
    }
  }

  /// Fetch general settings from API
  Future<void> _fetchGeneralSettings() async {
    try {
      await _repository.getGeneralSettings(
        onSuccess: (data) {
          try {
            if (data.data != null && data.data is Map<String, dynamic>) {
              final settingsData = GeneralSettingsData.fromJson(data.data as Map<String, dynamic>);
              if (settingsData.settings != null) {
                settings.value = settingsData.settings!;
                isSettingsLoaded.value = true;
                log('General settings loaded successfully');
              }
            }
          } catch (e, stackTrace) {
            log('Error parsing general settings: $e');
            log('Stack trace: $stackTrace');
            // Keep default values on error
            isSettingsLoaded.value = false;
          }
        },
        onError: (error) {
          log('Error loading general settings: ${error.message}');
          // Keep default values on error
          isSettingsLoaded.value = false;
          AppFunctions().showToast(error.message, bgColor: AppColors.red);
        },
      );
    } catch (e) {
      log('Exception in _fetchGeneralSettings: $e');
      isSettingsLoaded.value = false;
    }
  }

  /// Fetch landing page data from API
  Future<void> _fetchLandingPage() async {
    try {
      await _homeRepository.getLandingPage(
        onSuccess: (data) {
          try {
            if (data.data != null && data.data is Map<String, dynamic>) {
              final homeDataModel = HomeDataModel.fromJson({
                'success': data.success,
                'message': data.message,
                'data': data.data,
              });
              landingPageData.value = homeDataModel.data;
              isLandingPageLoaded.value = true;
              log('Landing page data loaded successfully');
            }
          } catch (e, stackTrace) {
            log('Error parsing landing page data: $e');
            log('Stack trace: $stackTrace');
            landingPageData.value = null;
            isLandingPageLoaded.value = false;
          }
        },
        onError: (error) {
          log('Error loading landing page: ${error.message}');
          landingPageData.value = null;
          isLandingPageLoaded.value = false;
          AppFunctions().showToast(error.message, bgColor: AppColors.red);
        },
      );
    } catch (e) {
      log('Exception in _fetchLandingPage: $e');
      isLandingPageLoaded.value = false;
    }
  }

  /// Refresh landing page data (public method for pull-to-refresh)
  Future<void> refreshLandingPage() async {
    await _fetchLandingPage();
  }

  /// Get current settings (always returns a value, defaults if API failed)
  Settings get currentSettings => settings.value;

  /// Get logo light URL
  String get logoLight => settings.value.logoLight ?? '';

  /// Get logo dark URL
  String get logoDark => settings.value.logoDark ?? '';

  /// Get tagline
  String get tagline => settings.value.tagline ?? '';

  /// Get support email
  String get supportEmail => settings.value.supportEmail ?? 'support@viteezy.com';

  /// Get support phone
  String get supportPhone => settings.value.supportPhone ?? '';

  /// Get address
  // Address? get address => settings.value.address;
  String? get address => settings.value.address;

  /// Get enabled languages
  List<Language> get enabledLanguages =>
      settings.value.languages?.where((lang) => lang.isEnabled == true).toList() ?? [];

  /// Get all languages
  List<Language> get allLanguages => settings.value.languages ?? [];

  /// Get social media links
  SocialMedia? get socialMedia => settings.value.socialMedia;

  /// Get landing page data (always returns a value, null if API failed)
  HomeData? get landingPage => landingPageData.value;
}

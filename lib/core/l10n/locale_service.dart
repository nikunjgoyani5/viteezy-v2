import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:viteezy/core/utils/app_prefrence.dart';

/// Manages app locale for GetX. Persists and restores locale (en, nl, de, fr, es).
class LocaleService {
  static const String _en = 'en';
  static const String _nl = 'nl';
  static const String _de = 'de';
  static const String _fr = 'fr';
  static const String _es = 'es';

  static const Locale fallbackLocale = Locale('en');
  static const Locale dutchLocale = Locale('nl');
  static const Locale germanLocale = Locale('de');
  static const Locale frenchLocale = Locale('fr');
  static const Locale spanishLocale = Locale('es');

  /// Map language name (from API) to locale code.
  static String _nameToCode(String languageName) {
    final lower = languageName.toLowerCase();
    if (lower == 'dutch' || lower == 'nederlands') return _nl;
    if (lower == 'german' || lower == 'deutsch') return _de;
    if (lower == 'french' || lower == 'français' || lower == 'francais') return _fr;
    if (lower == 'spanish' || lower == 'español' || lower == 'espanol') return _es;
    return _en; // English or default
  }

  /// Map locale code to display name in English (for API/controller).
  static String _codeToName(String code) {
    switch (code) {
      case _nl:
        return 'Dutch';
      case _de:
        return 'German';
      case _fr:
        return 'French';
      case _es:
        return 'Spanish';
      default:
        return 'English';
    }
  }

  /// Initial locale for GetMaterialApp (read from pref after PrefService.init()).
  static Locale getInitialLocale() {
    final saved = PrefService.getString(PrefKeys.locale);
    switch (saved) {
      case _nl:
        return dutchLocale;
      case _de:
        return germanLocale;
      case _fr:
        return frenchLocale;
      case _es:
        return spanishLocale;
      default:
        return fallbackLocale;
    }
  }

  /// Switch app language and persist. Pass display name from API: e.g. 'English', 'Dutch', 'German', 'French', 'Spanish'.
  static Future<void> setLanguage(String languageName) async {
    final code = _nameToCode(languageName);
    final locale = Locale(code);
    Get.updateLocale(locale);
    await PrefService.setValue(PrefKeys.locale, code);
  }

  /// Current locale code: 'en', 'nl', 'de', 'fr', or 'es'.
  static String get localeCode {
    final fromGet = Get.locale?.languageCode;
    if (fromGet != null && fromGet.isNotEmpty) return fromGet;
    final saved = PrefService.getString(PrefKeys.locale);
    return saved.isEmpty ? _en : saved;
  }

  /// Display name of current language in English (for passing to setLanguage / controller).
  static String get currentLanguageName => _codeToName(localeCode);

  /// Normalize API language code (e.g. EN, NL) to locale code (en, nl).
  static String normalizeCode(String? code) {
    if (code == null || code.isEmpty) return _en;
    final lower = code.toLowerCase();
    if (lower == 'nl') return _nl;
    if (lower == 'de') return _de;
    if (lower == 'fr') return _fr;
    if (lower == 'es') return _es;
    return lower == 'en' ? _en : lower;
  }

  /// Apply language from API (UserData.language). Accepts either code ('nl', 'en') or name ('Dutch', 'English').
  /// Updates app locale and persists so the app and language sheet reflect the user's saved language.
  static Future<void> applyLanguageFromApi(String? apiValue) async {
    if (apiValue == null || apiValue.trim().isEmpty) return;
    final trimmed = apiValue.trim();
    final name = trimmed.length <= 3 ? _codeToName(normalizeCode(trimmed)) : trimmed;
    await setLanguage(name);
  }
}

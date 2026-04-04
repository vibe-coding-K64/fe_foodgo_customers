import 'dart:convert';
import 'dart:ui' show Locale;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Custom delegate de load translations cho Flutter.
class _AppLocalizationsDelegate extends LocalizationsDelegate<dynamic> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['vi', 'en'].contains(locale.languageCode);
  }

  @override
  Future<dynamic> load(Locale locale) async {
    return null;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

/// Service quan ly da ngon ngu, truy cap bang static methods.
class LanguageService {
  LanguageService._();

  static const String _enJsonPath = 'lib/core/localization/app_en.json';
  static const String _viJsonPath = 'lib/core/localization/app_vi.json';

  static Locale _locale = const Locale('vi', 'VN');
  static Map<String, String> _translations = {};
  static bool _initialized = false;

  /// Delegate de su dung trong MaterialApp.localizationsDelegates.
  static const LocalizationsDelegate<dynamic> localizationsDelegate =
      _AppLocalizationsDelegate();

  /// Khoi tao ngon ngu mac dinh (goi 1 lan).
  static Future<void> init() async {
    if (_initialized) return;
    await _loadTranslations();
    _initialized = true;
  }

  /// Lay gia tri dich tu key.
  static String translate(String key) {
    return _translations[key] ?? key;
  }

  /// Thay doi ngon ngu.
  static Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    await _loadTranslations();
  }

  static Locale get locale => _locale;

  static List<Locale> get supportedLocales => const [
        Locale('vi', 'VN'),
        Locale('en', 'US'),
      ];

  static String getLanguageName(String code) {
    switch (code) {
      case 'vi':
        return 'Tieng Viet';
      case 'en':
        return 'English';
      default:
        return code;
    }
  }

  static Future<void> _loadTranslations() async {
    final path = _locale.languageCode == 'vi' ? _viJsonPath : _enJsonPath;
    try {
      final jsonString = await rootBundle.loadString(path);
      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
      _translations = jsonMap.map((key, value) => MapEntry(key, value.toString()));
    } catch (e, st) {
      _translations = {};
      debugPrint('LanguageService: khong load duoc ban dich ($path): $e\n$st');
    }
  }
}

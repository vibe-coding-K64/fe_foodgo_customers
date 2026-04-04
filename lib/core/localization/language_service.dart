import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Service quan ly da ngon ngu cho ung dung.
class LanguageService extends ChangeNotifier {
  static const String _enJsonPath = 'lib/core/localization/app_en.json';
  static const String _viJsonPath = 'lib/core/localization/app_vi.json';

  Locale _locale = const Locale('vi', 'VN');
  Map<String, String> _translations = {};

  Locale get locale => _locale;

  /// Khoi tao ngon ngu mac dinh.
  Future<void> init() async {
    await _loadTranslations();
  }

  /// Thay doi ngon ngu.
  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    await _loadTranslations();
    notifyListeners();
  }

  /// Lay danh sach ngon ngu ho tro.
  List<Locale> get supportedLocales => const [
        Locale('vi', 'VN'),
        Locale('en', 'US'),
      ];

  /// Lay ten ngon ngu theo ma.
  String getLanguageName(String code) {
    switch (code) {
      case 'vi':
        return 'Tieng Viet';
      case 'en':
        return 'English';
      default:
        return code;
    }
  }

  /// Lay gia tri dich tu key.
  String translate(String key) {
    return _translations[key] ?? key;
  }

  Future<void> _loadTranslations() async {
    try {
      final path = _locale.languageCode == 'vi' ? _viJsonPath : _enJsonPath;
      final jsonString = await rootBundle.loadString(path);
      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
      _translations = jsonMap.map((key, value) => MapEntry(key, value.toString()));
    } catch (e) {
      _translations = {};
    }
  }
}

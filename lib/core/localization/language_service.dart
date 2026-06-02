import 'dart:convert';
import 'dart:ui' show Locale;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Lop Localizations chua ban dich, tra ve tu delegate.
///
/// Day la object duoc luu tru trong Flutter widget tree,
/// no chi can chua translations map va mot extension method
/// de truy cap qua BuildContext.
class AppLocalizations {
  final Map<String, String> _translations;

  AppLocalizations(this._translations);

  String translate(String key, [List<Object>? args]) {
    String text = _translations[key] ?? key;
    if (args != null) {
      for (var i = 0; i < args.length; i++) {
        text = text.replaceAll('\$${i + 1}', args[i].toString());
      }
    }
    return text;
  }
}

/// Extension method de goi dich truc tiep tren BuildContext.
extension AppLocalizationsExtension on BuildContext {
  AppLocalizations get translations {
    return Localizations.of<AppLocalizations>(this, AppLocalizations)
        ?? AppLocalizations({});
  }

  String t(String key, [List<Object>? args]) {
    return translations.translate(key, args);
  }
}

/// Delegate load translations cho Flutter.
///
/// Moỗi khi locale thay đổi, Flutter se goi load() de tao
/// mot instance AppLocalizations moi chua ban dich moi.
class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['vi', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final jsonPath = locale.languageCode == 'vi'
        ? LanguageService.viJsonPath
        : LanguageService.enJsonPath;

    try {
      final jsonString = await rootBundle.loadString(jsonPath);
      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
      final translations = jsonMap.map(
        (key, value) => MapEntry(key, value.toString()),
      );

      // Cap nhat translations trong LanguageService.
      LanguageService._updateTranslations(translations);

      return AppLocalizations(translations);
    } catch (e, st) {
      debugPrint('LanguageService: khong load duoc ban dich ($jsonPath): $e\n$st');
      return AppLocalizations({});
    }
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => true;
}

/// Service quan ly da ngon ngu.
///
/// Su dung:
///   - Khoi tao: `await LanguageService.init()`
///   - Lay gia tri dich: `LanguageService.translate('key')`
///   - Doi ngon ngu: `await LanguageService.setLocale(...)`
///   - Trong widget: `context.t('key')`
class LanguageService {
  LanguageService._();

  static const String _enJsonPath = 'lib/core/localization/app_en.json';
  static const String _viJsonPath = 'lib/core/localization/app_vi.json';

  static Locale _locale = const Locale('vi', 'VN');
  static Map<String, String> _translations = {};
  static bool _initialized = false;
  static final List<VoidCallback> _listeners = [];

  /// Duong dan toi file JSON tieng Anh.
  static String get enJsonPath => _enJsonPath;

  /// Duong dan toi file JSON tieng Viet.
  static String get viJsonPath => _viJsonPath;

  /// Delegate de su dung trong MaterialApp.localizationsDelegates.
  static const LocalizationsDelegate<AppLocalizations> localizationsDelegate =
      _AppLocalizationsDelegate();

  /// Khoi tao ngon ngu mac dinh (goi 1 lan).
  static Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
  }

  /// Lay gia tri dich tu key.
  static String translate(String key, [List<Object>? args]) {
    String text = _translations[key] ?? key;
    if (args != null) {
      for (var i = 0; i < args.length; i++) {
        text = text.replaceAll('\$${i + 1}', args[i].toString());
      }
    }
    return text;
  }

  /// Thay doi ngon ngu, thong bao cho toan bo app.
  static Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;

    // Load lai translations (LanguageService.load se duoc goi
    // boi Flutter Localizations widget, nhung ta goi notify
    // de cac widget khong phu thuoc Localizations cung nhan biet).
    await _notifyListeners();
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

  /// Cap nhat translations map (duoc goi boi delegate sau khi load xong).
  static void _updateTranslations(Map<String, String> translations) {
    _translations = translations;
  }

  /// Thong bao cho cac listener biet ngon ngu da thay doi.
  /// Ham nay goi `_notifyLocaleChanged` tren tat ca listener.
  static Future<void> _notifyListeners() async {
    for (final listener in _listeners) {
      listener();
    }
  }

  /// Dang ky listener de nhan thong bao khi ngon ngu thay doi.
  ///
  /// Su dung khi mot widget muon tu dong cap nhat khi nguoi dung
  /// doi ngon ngu ma khong su dung Localizations.of (vi du: cac
  /// widget khong co BuildContext hoac khong rebuild tu dong).
  static void addLocaleChangeListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  /// Huy dang ky listener.
  static void removeLocaleChangeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }
}

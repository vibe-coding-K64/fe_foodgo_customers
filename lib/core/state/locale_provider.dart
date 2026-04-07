import 'dart:ui' show Locale;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../localization/language_service.dart';

/// State quan ly ngon ngu hien tai cua ung dung.
///
/// Su dung ChangeNotifier de thong bao cho toan bo widget tree
/// khi nguoi dung thay doi ngon ngu.
///
/// Su dung voi `LocaleProvider.of(context)` de lay instance
/// tu bat ky widget con nao.
class LocaleProvider extends ChangeNotifier {
  Locale _locale = LanguageService.locale;

  Locale get locale => _locale;

  /// Khoi tao locale tu LanguageService.
  LocaleProvider() {
    _locale = LanguageService.locale;
  }

  /// Thay doi ngon ngu.
  ///
  /// Thu tu: Switch ON = Tieng Viet, Switch OFF = English.
  Future<void> setLocale(bool isVietnamese) async {
    final newLocale = isVietnamese
        ? const Locale('vi', 'VN')
        : const Locale('en', 'US');

    if (_locale == newLocale) return;

    await LanguageService.setLocale(newLocale);
    _locale = newLocale;
    notifyListeners();
  }

  /// Tra ve trang thai Switch: true = Tieng Viet, false = English.
  bool get isVietnamese => _locale.languageCode == 'vi';

  /// Lay LocaleProvider tu context.
  static LocaleProvider of(BuildContext context) {
    final element = context
        .getElementForInheritedWidgetOfExactType<LocaleProviderScope>();

    if (element == null) {
      throw FlutterError(
          'Khong tim thay LocaleProvider. Dam bao rang '
          'app duoc wrap trong LocaleProviderScope.');
    }

    final widget = element.widget;
    if (widget is LocaleProviderScope) {
      final notifier = widget.notifier;
      if (notifier is LocaleProvider) {
        return notifier;
      }
    }

    throw FlutterError(
        'LocaleProvider khong dung kieu. Dam bao rang '
        'LocaleProviderScope duoc khoi tao dung.');
  }
}

/// Widget trung gian cung cap LocaleProvider xuong widget tree.
///
/// Day la InheritedNotifier, nghia la bat ky widget con nao goi
/// `LocaleProvider.of(context)` se tu dong rebuild khi
/// LocaleProvider thong bao thay doi.
class LocaleProviderScope extends InheritedNotifier<LocaleProvider> {
  const LocaleProviderScope({
    required LocaleProvider notifier,
    required super.child,
  }) : super(notifier: notifier);
}

/// Wrap widget con voi LocaleProvider scope.
///
/// Su dung trong main.dart de bao wrapper cho toan bo app.
Widget wrapWithLocaleProvider({
  required Widget child,
  required LocaleProvider provider,
}) {
  return LocaleProviderScope(
    notifier: provider,
    child: child,
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'features/main/views/main_view.dart';
import 'core/localization/language_service.dart';
import 'core/state/locale_provider.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/data_seeder.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khoi tao Firebase.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Khoi tao service ngon ngu.
  await LanguageService.init();

  // Tao LocaleProvider de quan ly trang thai ngon ngu toan app.
  final localeProvider = LocaleProvider();

  // Seed du lieu mau vao Firestore (neu chua co).
  await DataSeeder.seedAll();

  runApp(
    LocaleProviderScope(
      notifier: localeProvider,
      child: FoodGoApp(provider: localeProvider),
    ),
  );
}

/// Widget root cua ung dung FoodGo.
///
/// Lang nghe thay doi tu LocaleProvider de tu dong cap nhat
/// ngon ngu khi nguoi dung chuyen doi trong man hinh Cai dat.
class FoodGoApp extends StatelessWidget {
  final LocaleProvider provider;

  const FoodGoApp({
    super.key,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: provider,
      builder: (context, _) {
        return MaterialApp(
          title: 'FoodGo',
          locale: provider.locale,
          supportedLocales: const [
            Locale('vi', 'VN'),
            Locale('en', 'US'),
          ],
          localizationsDelegates: const [
            LanguageService.localizationsDelegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: const MainView(),
        );
      },
    );
  }
}

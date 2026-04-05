import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'features/main/views/main_view.dart';
import 'core/localization/language_service.dart';
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

  // Seed du lieu mau vao Firestore (neu chua co).
  await DataSeeder.seedAll();

  runApp(const FoodGoApp());
}

class FoodGoApp extends StatelessWidget {
  const FoodGoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FoodGo',
      locale: const Locale('vi', 'VN'),
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
  }
}

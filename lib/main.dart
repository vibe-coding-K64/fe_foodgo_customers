import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'features/main/views/main_view.dart';
import 'features/auth/views/login_view.dart';
import 'core/localization/language_service.dart';
import 'core/state/locale_provider.dart';
import 'core/state/cart_state.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/auth_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khoi tao Firebase.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Khoi tao AuthStorage de doc trang thai dang nhap.
  await AuthStorage.init();

  // Khoi tao service ngon ngu.
  await LanguageService.init();

  // Tao LocaleProvider de quan ly trang thai ngon ngu toan app.
  final localeProvider = LocaleProvider();

  // Tao CartState de quan ly gio hang real-time voi Firestore.
  final cartState = CartState();

  runApp(
    CartStateScope(
      notifier: cartState,
      child: LocaleProviderScope(
        notifier: localeProvider,
        child: FoodGoApp(provider: localeProvider),
      ),
    ),
  );
}

/// Widget root cua ung dung FoodGo.
///
/// Lang nghe thay doi tu LocaleProvider de tu dong cap nhat
/// ngon ngu khi nguoi dung chuyen doi trong man hinh Cai dat.
class FoodGoApp extends StatelessWidget {
  final LocaleProvider provider;

  const FoodGoApp({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: provider,
      builder: (context, _) {
        return MaterialApp(
          title: 'FoodGo',
          locale: provider.locale,
          supportedLocales: const [Locale('vi', 'VN'), Locale('en', 'US')],
          localizationsDelegates: const [
            LanguageService.localizationsDelegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: AuthStorage.isLoggedIn() ? const MainView() : const LoginView(),
        );
      },
    );
  }
}

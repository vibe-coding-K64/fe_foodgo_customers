import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
// Import file cau hinh vua duoc sinh ra
import 'firebase_options.dart';

void main() async {
  // Dam bao cac native code duoc khoi tao truoc khi chay
  WidgetsFlutterBinding.ensureInitialized();

  // Tien hanh ket noi voi Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FoodGo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('Ket noi Firebase thanh cong'),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/main_navigation.dart';

// TODO: Import your firebase_options.dart after running flutterfire configure
// import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize AdMob
  await MobileAds.instance.initialize();

  runApp(
    const ProviderScope(
      child: CelebritySocialApp(),
    ),
  );
}

class CelebritySocialApp extends StatelessWidget {
  const CelebritySocialApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tikki',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF0F0F0F),
      ),
      // Start at Login. Later we add auth state listener.
      home: const LoginScreen(),
      // home: const MainNavigation(), // uncomment to preview navigation
    );
  }
}

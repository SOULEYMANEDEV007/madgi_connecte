import 'package:flutter/material.dart';
import 'pages/onboringscreen.dart';
import 'pages/home.dart';
import 'pages/manual.dart';
import 'pages/scanner.dart';

void main() {
  runApp(const MadgiConnectApp());
}

class MadgiConnectApp extends StatelessWidget {
  const MadgiConnectApp({super.key});

  static const Color orange = Color(0xFFFF9900);
  static const Color vert   = Color(0xFF3CA55C);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Madgi Connecte',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: orange,
          primary: orange,
          secondary: vert,
        ),
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const OnboardingPage(),
      routes: {
        "/home":    (_) => const HomePage(),
        "/manual":  (_) => const ManualRegisterPage(),
        "/scanner": (_) => const QRGeneratorScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
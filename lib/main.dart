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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Madgi Connect',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),

      home: const HomePage(),

      routes: {
        "/home": (_) => const HomePage(),
        "/manual": (_) => const ManualRegisterPage(),
        "/scanner": (_) => const QRGeneratorScreen(),
      },

      debugShowCheckedModeBanner: false,
    );
  }
}
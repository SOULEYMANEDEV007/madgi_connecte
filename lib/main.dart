import 'package:flutter/material.dart';
import 'onboringscreen.dart';
import 'home.dart';
import 'manual.dart';
import 'scanner.dart';

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
        "/scanner": (_) => const ScannerScreen(),
      },

      debugShowCheckedModeBanner: false,
    );
  }
}

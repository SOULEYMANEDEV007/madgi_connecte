import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:http/http.dart' as http;

class QRGeneratorScreen extends StatefulWidget {
  const QRGeneratorScreen({super.key});

  @override
  State<QRGeneratorScreen> createState() => _QRGeneratorScreenState();
}

class _QRGeneratorScreenState extends State<QRGeneratorScreen> {
  String qrData = "";
  Timer? timer;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAndGenerateQR();
    timer = Timer.periodic(const Duration(seconds: 5), (_) {
      _fetchAndGenerateQR();
    });
  }

  Future<void> _fetchAndGenerateQR() async {
    try {
      print('🔄 Génération nouveau QR code...');

      final response = await http.get(
        Uri.parse('http://192.168.1.5:8000/api/v1/generate-qr'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['code'] == 200) {
          setState(() {
            qrData = json.encode(data['data']); // Encode tout l'objet JSON
            isLoading = false;
          });
          print('✅ QR code généré: ${data['data']['session_id']}');
          print('📋 Contient ${data['data']['matricules']?.length ?? 0} matricules');
        }
      }
    } catch (e) {
      print('❌ Erreur génération QR: $e');
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("QR Code Pointage"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Montrez ce QR code pour scanner",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              "Rafraîchi toutes les 5 secondes",
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 40),

            if (isLoading)
              const CircularProgressIndicator()
            else if (qrData.isEmpty)
              const Text("Erreur de génération QR")
            else
              Column(
                children: [
                  // QR Code
                  QrImageView(
                    data: qrData,
                    version: QrVersions.auto,
                    size: 280.0,
                    backgroundColor: Colors.white,
                  ),
                  const SizedBox(height: 20),

                  // Informations
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        FutureBuilder<Map<String, dynamic>>(
                          future: Future.value(json.decode(qrData)),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              final data = snapshot.data!;
                              return Column(
                                children: [
                                  Text(
                                    "Session: ${data['session_id']?.substring(0, 8) ?? 'N/A'}",
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Expire dans: ${DateTime.parse(data['expires_at']).difference(DateTime.now()).inSeconds}s",
                                    style: const TextStyle(fontSize: 12, color: Colors.orange),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Matricules: ${data['matricules']?.length ?? 0}",
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              );
                            }
                            return const SizedBox();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
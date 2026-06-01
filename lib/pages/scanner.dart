import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:http/http.dart' as http;
import '../core/config/api_config.dart';

class QRGeneratorScreen extends StatefulWidget {
  const QRGeneratorScreen({super.key});

  @override
  State<QRGeneratorScreen> createState() => _QRGeneratorScreenState();
}

class _QRGeneratorScreenState extends State<QRGeneratorScreen> {
  static const Color orange = Color(0xFFFF9900);
  static const Color vert   = Color(0xFF3CA55C);

  String qrData  = "";
  String errorMsg = "";
  Timer? timer;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAndGenerateQR();
    timer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _fetchAndGenerateQR(),
    );
  }

  Future<void> _fetchAndGenerateQR() async {
    if (!mounted) return;
    setState(() { isLoading = true; errorMsg = ""; });

    try {
      print("🚀 [Scanner] Génération QR code depuis : ${ApiConfig.generateQr}");
      final response = await http.get(
        Uri.parse(ApiConfig.generateQr),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (!mounted) return;

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        if (body['code'] == 200) {
          final sessionId = body['data']['session_id']?.toString() ?? '';
          setState(() {
            qrData    = sessionId;
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
            errorMsg  = body['message'] ?? "Réponse inattendue";
          });
        }
      } else {
        setState(() {
          isLoading = false;
          errorMsg  = "Erreur serveur (${response.statusCode})";
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMsg  = e.toString();
      });
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenW = MediaQuery.of(context).size.width;
    final bool isTablet  = screenW > 600;
    final double qrSize  = isTablet ? 380.0 : 280.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          "QR Code Pointage",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: isTablet ? 22 : 18,
          ),
        ),
        backgroundColor: vert,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/logo.png',
                  height: isTablet ? 90 : 65,
                  width: isTablet ? 90 : 65,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: isTablet ? 24 : 16),
              Text(
                "Présentez ce QR code pour le pointage",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isTablet ? 24 : 16,
                  fontWeight: FontWeight.bold,
                  color: vert,
                ),
              ),
              SizedBox(height: isTablet ? 8 : 6),
              Text(
                "Rafraîchi toutes les 5 secondes",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isTablet ? 16 : 12,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: isTablet ? 32 : 24),

              if (isLoading)
                const CircularProgressIndicator(color: vert)
              else if (errorMsg.isNotEmpty)
                Column(
                  children: [
                    const Icon(Icons.wifi_off, size: 56, color: Colors.grey),
                    const SizedBox(height: 12),
                    Text(
                      errorMsg,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _fetchAndGenerateQR,
                      icon: const Icon(Icons.refresh),
                      label: const Text("Réessayer"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: vert,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                )
              else
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: vert.withOpacity(0.15),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                    border: Border.all(color: vert.withOpacity(0.3), width: 2),
                  ),
                  child: QrImageView(
                    data: qrData,
                    version: QrVersions.auto,
                    size: qrSize,
                    backgroundColor: Colors.white,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: orange,
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: vert,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
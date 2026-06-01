import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/scanner_model.dart';
import '../../core/config/api_config.dart';

class ScannerService {
  final String apiUrl = ApiConfig.emarger;

  Future<Map<String, dynamic>> scan(ScannerModel data) async {
    try {
      // Vérification image
      if (!File(data.imagePath).existsSync()) {
        return {
          "status": 400,
          "code": 400,
          "message": "Image introuvable sur l'appareil",
          "data": null,
        };
      }

      var uri = Uri.parse(apiUrl);
      print("🚀 [ScannerService] Envoi de la requête vers : $uri");
      var request = http.MultipartRequest("POST", uri);

      // Champs
      request.fields["matricule"] = data.matricule;
      request.fields["observation"] = data.observation;

      // Image envoyée par l'utilisateur
      request.files.add(
        await http.MultipartFile.fromPath("image", data.imagePath),
      );

      // Exécution
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      var decoded = jsonDecode(responseBody);

      return {
        "status": response.statusCode,
        "code": decoded["code"],
        "message": decoded["message"] ?? "",
        "data": decoded["data"] ?? null,
      };
    } catch (e) {
      return {
        "status": 500,
        "code": 500,
        "message": "Erreur : $e",
        "data": null,
      };
    }
  }
}

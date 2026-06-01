import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/manual_register_model.dart';
import '../../core/config/api_config.dart';

class ManualRegisterService {
  final String baseUrl = ApiConfig.emarger;

  Future<Map<String, dynamic>> registerManual(ManualRegisterModel data) async {
    try {
      if (!File(data.imagePath).existsSync()) {
        return {
          "status": 400,
          "code": 400,
          "message": "Image introuvable sur l'appareil",
          "data": null,
        };
      }

      var uri = Uri.parse(baseUrl);
      print("🚀 [ManualRegisterService] Envoi de la requête vers : $uri");
      var request = http.MultipartRequest("POST", uri);

      // Champs
      request.fields["matricule"] = data.matricule;
      request.fields["observation"] = data.observation;

      // Image
      request.files.add(await http.MultipartFile.fromPath("image", data.imagePath));

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      // Décodage JSON
      var decoded = jsonDecode(responseBody);

      return {
        "status": response.statusCode,
        "code": decoded["code"],
        "message": decoded["message"] ?? "",
        "data": decoded["data"],
        "justification_required": decoded["justification_required"] ?? false,
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

class ApiConfig {
  // URL de base — modifiable ici uniquement
  static const String baseUrl = 'http://150.107.201.90:8089/api/v1';

  // Endpoints
  static const String emarger = '$baseUrl/emarger';
  static const String scanEmargement = '$baseUrl/scan-emargement';
  static const String generateQr = '$baseUrl/generate-qr';
}

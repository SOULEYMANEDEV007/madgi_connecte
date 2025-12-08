// scanner_model.dart

class ScannerModel {
  final String matricule;      // matricule décodé depuis le QR
  final String imagePath;      // photo prise automatiquement pendant le scan
  String observation;          // observation complémentaire, ex: 'scan'

  // Optionnel (retourné par l’API)
  final String? fullName;
  final String? phone;
  final String? email;

  ScannerModel({
    required this.matricule,
    required this.imagePath,
    this.observation = "scan",
    this.fullName,
    this.phone,
    this.email,
  });
}

class ManualRegisterModel {
  final String matricule;
  String observation;
  final String imagePath;

  // Si tu veux conserver les autres champs optionnels
  final String? fullName;
  final String? phone;
  final String? email;

  ManualRegisterModel({
    required this.matricule,
    required this.observation,
    required this.imagePath,
    this.fullName,
    this.phone,
    this.email,
  });
}

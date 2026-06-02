class ManualRegisterModel {
  final String matricule;
  String observation;
  final String imagePath;
  final String? justificatifArrive;
  final String? justificatifDepart;
  final bool avecJustificatif;

  // Si tu veux conserver les autres champs optionnels
  final String? fullName;
  final String? phone;
  final String? email;

  ManualRegisterModel({
    required this.matricule,
    required this.observation,
    required this.imagePath,
    this.justificatifArrive,
    this.justificatifDepart,
    this.avecJustificatif = false,
    this.fullName,
    this.phone,
    this.email,
  });
}

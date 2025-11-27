import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../data/models/manual_register_model.dart';
import '../data/services/manual_register_service.dart';

class ManualRegisterPage extends StatefulWidget {
  const ManualRegisterPage({super.key});

  @override
  State<ManualRegisterPage> createState() => _ManualRegisterPageState();
}

class _ManualRegisterPageState extends State<ManualRegisterPage> {
  final Color vert = const Color(0xFF3CA55C);
  final Color orange = const Color(0xFFFF9900);

  final TextEditingController matriculeCtrl = TextEditingController();
  final TextEditingController observationCtrl = TextEditingController();

  File? selectedImage;
  final ManualRegisterService service = ManualRegisterService();

  bool isObservationRequired = false;

  // ---------------- IMAGE PICKER ----------------
  Future pickImage() async {
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.camera);

    if (file != null) {
      setState(() => selectedImage = File(file.path));
    }
  }

  // ---------------- POPUP OBSERVATION ----------------
  Future<void> _askObservation() async {
    final TextEditingController obsCtrl = TextEditingController();
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Justification requise"),
        content: TextField(
          controller: obsCtrl,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: "Saisir votre observation / justification",
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              observationCtrl.text = obsCtrl.text.trim();
              Navigator.pop(context);
            },
            child: const Text("Valider"),
          ),
        ],
      ),
    );
  }

  // ---------------- POPUP RESULT ----------------
  Future showResultDialog({
    required String title,
    required String message,
    required bool success,
  }) {
    return showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                success ? Icons.check_circle : Icons.error,
                color: success ? Colors.green : Colors.red,
                size: 60,
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: success ? Colors.green : Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              Text(
                message,
                style: const TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 25),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: success ? Colors.green : Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "OK",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- SUBMIT ----------------
  Future submit() async {
    if (matriculeCtrl.text.isEmpty || selectedImage == null) {
      await showResultDialog(
        title: "Champs manquants",
        message: "Veuillez remplir les champs obligatoires.",
        success: false,
      );
      return;
    }

    if (isObservationRequired && observationCtrl.text.isEmpty) {
      await _askObservation();
      if (observationCtrl.text.isEmpty) {
        await showResultDialog(
          title: "Observation requise",
          message: "Veuillez fournir une justification pour l'arrivée/départ.",
          success: false,
        );
        return;
      }
    }

    ManualRegisterModel model = ManualRegisterModel(
      matricule: matriculeCtrl.text.trim(),
      observation: observationCtrl.text.trim(),
      imagePath: selectedImage!.path,
    );

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => Center(child: CircularProgressIndicator(color: orange)),
    );

    var response = await service.registerManual(model);
    Navigator.pop(context);

    // Lecture correcte du message backend
    final bool success = response["code"] == 200;
    final String message = response["message"] ?? "Erreur inconnue";

    await showResultDialog(
      title: success ? "Enregistrement Réussi" : "Échec",
      message: message,
      success: success,
    );

    if (success) {
      setState(() {
        matriculeCtrl.clear();
        observationCtrl.clear();
        selectedImage = null;
      });
    }
  }

  // ---------------- INPUT ----------------
  Widget _bigInput({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    TextInputType keyboard = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))
            ],
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboard,
            style: const TextStyle(fontSize: 26),
            decoration: InputDecoration(
              border: InputBorder.none,
              icon: Icon(icon, size: 32, color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: orange,
        elevation: 0,
        title: const Text(
          "Enregistrement Manuel",
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              "Formulaire d’Enregistrement",
              style: TextStyle(
                fontSize: 32,
                color: vert,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              "Veuillez remplir les informations ci-dessous",
              style: TextStyle(
                fontSize: 24,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 40),
            _bigInput(
              label: "N° Matricule / Numéro Téléphone",
              icon: Icons.badge_outlined,
              controller: matriculeCtrl,
            ),
            const SizedBox(height: 30),
            GestureDetector(
              onTap: pickImage,
              child: Container(
                height: 220,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: orange),
                ),
                child: selectedImage == null
                    ? Center(
                  child: Text(
                    "Appuyer pour prendre une photo",
                    style: TextStyle(fontSize: 24, color: Colors.grey),
                  ),
                )
                    : Image.file(selectedImage!, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 90,
              child: ElevatedButton(
                onPressed: submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: vert,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  "Enregistrer",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

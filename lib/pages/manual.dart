import 'dart:io';
import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../data/models/manual_register_model.dart';
import '../data/services/manual_register_service.dart';

class ManualRegisterPage extends StatefulWidget {
  const ManualRegisterPage({super.key});

  @override
  State<ManualRegisterPage> createState() => _ManualRegisterPageState();
}

class _ManualRegisterPageState extends State<ManualRegisterPage> with SingleTickerProviderStateMixin {
  final Color vert = const Color(0xFF3CA55C);
  final Color orange = const Color(0xFFFF9900);
  final Color errorGradientStart = const Color(0xFFFF416C);
  final Color errorGradientEnd = const Color(0xFFFF4B2B);
  final Color warningGradientStart = const Color(0xFFFFB347);
  final Color warningGradientEnd = const Color(0xFFFFCC33);

  final TextEditingController matriculeCtrl = TextEditingController();
  final TextEditingController observationCtrl = TextEditingController();

  File? selectedImage;
  final ManualRegisterService service = ManualRegisterService();

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _rotationAnimation;

  bool isObservationRequired = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 2 * pi).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  Future pickImage() async {
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
      maxWidth: 800,
      maxHeight: 800,
    );
    if (file != null) setState(() => selectedImage = File(file.path));
  }

  Future<String?> _showErrorWithJustificatifPopup({
    required String title,
    required String message,
    required bool isRetard,
  }) async {
    _animationController.reset();
    _animationController.forward();
    final TextEditingController justificatifCtrl = TextEditingController();
    bool isSubmitting = false;

    return await showDialog<String?>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8),
      barrierDismissible: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Dialog(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    child: Container(
                      width: 350,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isRetard
                              ? [errorGradientStart, errorGradientEnd]
                              : [warningGradientStart, warningGradientEnd],
                        ),
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: (isRetard ? errorGradientEnd : warningGradientEnd).withOpacity(0.4),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                                ),
                              ),
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [Colors.white.withOpacity(0.9), Colors.white.withOpacity(0.6)],
                                  ),
                                  boxShadow: [
                                    BoxShadow(color: Colors.white.withOpacity(0.5), blurRadius: 20, spreadRadius: 5),
                                  ],
                                ),
                              ),
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5)),
                                  ],
                                ),
                                child: Center(
                                  child: Text(isRetard ? '😞' : '⏰', style: const TextStyle(fontSize: 30)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Text(
                            title,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              shadows: [Shadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 2))],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            message,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 24),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Justificatif :', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 8),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                                ),
                                child: TextField(
                                  controller: justificatifCtrl,
                                  maxLines: 3,
                                  enabled: !isSubmitting,
                                  style: const TextStyle(color: Colors.white, fontSize: 14),
                                  decoration: InputDecoration(
                                    hintText: 'Saisissez votre justificatif ici...',
                                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),
                          if (isSubmitting)
                            Column(
                              children: [
                                const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                                const SizedBox(height: 16),
                                Text('Traitement en cours...', style: TextStyle(color: Colors.white.withOpacity(0.9))),
                              ],
                            )
                          else
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))],
                                    ),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        _animationController.reverse().then((_) => Navigator.of(ctx).pop(null));
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: isRetard ? errorGradientEnd : warningGradientEnd,
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      ),
                                      child: const Text('ANNULER', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))],
                                    ),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        final justificatif = justificatifCtrl.text.trim();
                                        if (justificatif.isEmpty) {
                                          ScaffoldMessenger.of(ctx).showSnackBar(
                                            const SnackBar(content: Text('Veuillez saisir un justificatif'), backgroundColor: Colors.red),
                                          );
                                          return;
                                        }
                                        setStateDialog(() => isSubmitting = true);
                                        Future.delayed(const Duration(milliseconds: 500), () {
                                          _animationController.reverse().then((_) => Navigator.of(ctx).pop(justificatif));
                                        });
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: isRetard ? errorGradientEnd : warningGradientEnd,
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      ),
                                      child: const Text('ENVOYER', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future showSuccessPopup({required String title, required String message}) {
    _animationController.reset();
    _animationController.forward();

    return showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      barrierDismissible: true,
      builder: (ctx) {
        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Dialog(
                backgroundColor: Colors.transparent,
                elevation: 0,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Opacity(
                    opacity: _fadeAnimation.value,
                    child: Container(
                      width: 320,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF00B09B), Color(0xFF96C93D)],
                        ),
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(color: const Color(0xFF96C93D).withOpacity(0.4), blurRadius: 30, spreadRadius: 5),
                          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10)),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                                ),
                              ),
                              Transform.rotate(
                                angle: _rotationAnimation.value,
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [Colors.white.withOpacity(0.9), Colors.white.withOpacity(0.6)],
                                    ),
                                    boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.5), blurRadius: 20, spreadRadius: 5)],
                                  ),
                                ),
                              ),
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
                                ),
                                child: const Center(child: Text('🎉', style: TextStyle(fontSize: 40))),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          AnimatedOpacity(
                            opacity: _animationController.value > 0.5 ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 300),
                            child: Transform.translate(
                              offset: Offset(0, _animationController.value > 0.5 ? 0 : 20),
                              child: Text(
                                title,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  shadows: [Shadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 2))],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          AnimatedOpacity(
                            opacity: _animationController.value > 0.7 ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 300),
                            child: Transform.translate(
                              offset: Offset(0, _animationController.value > 0.7 ? 0 : 20),
                              child: Text(
                                message,
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                          AnimatedOpacity(
                            opacity: _animationController.value > 0.9 ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 300),
                            child: Transform.translate(
                              offset: Offset(0, _animationController.value > 0.9 ? 0 : 20),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))],
                                ),
                                child: ElevatedButton(
                                  onPressed: () {
                                    _animationController.reverse().then((_) => Navigator.of(ctx).pop());
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: const Color(0xFF96C93D),
                                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  ),
                                  child: const Text('CONTINUER', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future submit() async {
    if (matriculeCtrl.text.isEmpty || selectedImage == null) {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Champs manquants", style: TextStyle(color: Colors.red)),
          content: const Text("Veuillez remplir les champs obligatoires."),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))],
        ),
      );
      return;
    }

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => Center(child: CircularProgressIndicator(color: vert)),
    );

    ManualRegisterModel model = ManualRegisterModel(
      matricule: matriculeCtrl.text.trim(),
      observation: observationCtrl.text.trim(),
      imagePath: selectedImage!.path,
    );

    var response = await service.registerManual(model);
    Navigator.pop(context);

    final bool success = response["code"] == 200;
    String message = response["message"] ?? "Erreur inconnue";
    final bool justificationRequired = (response["justification_required"] == true) || 
                                       message.toLowerCase().contains('retard') || 
                                       message.toLowerCase().contains('anticipé');

    if (success) {
      message = _formatSuccessMessage(message, response["data"]);
      await showSuccessPopup(title: "ENREGISTRÉ !", message: message);
      setState(() { matriculeCtrl.clear(); observationCtrl.clear(); selectedImage = null; });
    } else if (justificationRequired) {
      final bool isRetard = message.toLowerCase().contains('retard');
      final String? justificatif = await _showErrorWithJustificatifPopup(
        title: isRetard ? 'RETARD DÉTECTÉ' : 'DÉPART ANTICIPÉ',
        message: message,
        isRetard: isRetard,
      );

      if (justificatif != null && justificatif.isNotEmpty) {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (_) => Center(child: CircularProgressIndicator(color: vert)),
        );

        ManualRegisterModel modelWithJustificatif = ManualRegisterModel(
          matricule: matriculeCtrl.text.trim(),
          observation: justificatif,
          imagePath: selectedImage!.path,
        );

        var newResponse = await service.registerManual(modelWithJustificatif);
        Navigator.pop(context);

        final bool newSuccess = newResponse["code"] == 200;
        String newMessage = newResponse["message"] ?? "Erreur inconnue";

        if (newSuccess) {
          newMessage = _formatSuccessMessage(newMessage, newResponse["data"]);
          await showSuccessPopup(title: "ENREGISTRÉ AVEC JUSTIFICATIF", message: newMessage);
          setState(() { matriculeCtrl.clear(); observationCtrl.clear(); selectedImage = null; });
        } else {
          await showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text("Échec", style: TextStyle(color: Colors.red)),
              content: Text(newMessage),
              actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))],
            ),
          );
        }
      }
    } else {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Échec", style: TextStyle(color: Colors.red)),
          content: Text(message),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))],
        ),
      );
    }
  }

  String _formatSuccessMessage(String originalMsg, dynamic dataObj) {
    String employeName = "";
    if (dataObj != null && dataObj is Map) {
      final civilite = dataObj["civilite"] ?? "";
      final nom = dataObj["nom"] ?? dataObj["nom_employe"] ?? "";
      final prenom = dataObj["prenom"] ?? dataObj["prenom_employe"] ?? "";
      if (nom.toString().isNotEmpty) {
        employeName = "$civilite $nom $prenom".trim();
      }
    }
    if (employeName.isEmpty) {
      if (originalMsg.contains(" pour ")) {
        employeName = originalMsg.split(" pour ").last.trim();
      } else if (originalMsg.contains(" de ")) {
        employeName = originalMsg.split(" de ").last.trim();
      }
    }

    if (originalMsg.toLowerCase().contains("arriv")) {
      return "Arrivée : Bienvenue et passez une agréable journée${employeName.isNotEmpty ? ' suivie de $employeName' : ''}".trim();
    } else if (originalMsg.toLowerCase().contains("départ") || originalMsg.toLowerCase().contains("depart")) {
      return "Départ : Au revoir et passez une agréable soirée${employeName.isNotEmpty ? ' suivie de $employeName' : ''}".trim();
    }
    return originalMsg;
  }

  Widget _bigInput({required String label, required IconData icon, required TextEditingController controller, TextInputType keyboard = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: vert)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboard,
            style: const TextStyle(fontSize: 18),
            decoration: InputDecoration(
              border: InputBorder.none,
              icon: Icon(icon, size: 26, color: orange),
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
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset('assets/logo.png', height: 36, width: 36, fit: BoxFit.cover),
            ),
            const SizedBox(width: 10),
            const Expanded(child: Text("Enregistrement Manuel", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white), overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text("Formulaire d'Enregistrement", style: TextStyle(fontSize: 28, color: vert, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Text("Veuillez remplir les informations ci-dessous", style: TextStyle(fontSize: 16, color: Colors.grey.shade700)),
            const SizedBox(height: 40),
            _bigInput(label: "N° Matricule / Numéro Téléphone", icon: Icons.badge_outlined, controller: matriculeCtrl),
            const SizedBox(height: 30),
            GestureDetector(
              onTap: pickImage,
              child: Container(
                height: 220,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: orange, width: 2),
                ),
                child: selectedImage == null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt_outlined, size: 48, color: orange),
                            const SizedBox(height: 10),
                            const Text("Appuyer pour prendre une photo", style: TextStyle(fontSize: 16, color: Colors.grey)),
                          ],
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.file(selectedImage!, fit: BoxFit.cover),
                      ),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: vert,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 3,
                ),
                child: const Text("Enregistrer", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
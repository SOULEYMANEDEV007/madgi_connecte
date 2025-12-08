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
  final Color errorGradientStart = Color(0xFFFF416C);
  final Color errorGradientEnd = Color(0xFFFF4B2B);
  final Color warningGradientStart = Color(0xFFFFB347);
  final Color warningGradientEnd = Color(0xFFFFCC33);

  final TextEditingController matriculeCtrl = TextEditingController();
  final TextEditingController observationCtrl = TextEditingController();

  File? selectedImage;
  final ManualRegisterService service = ManualRegisterService();

  // Animation controller pour les pop-ups
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _rotationAnimation;

  bool isObservationRequired = false;

  @override
  void initState() {
    super.initState();

    // Initialiser les animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 2 * pi).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  // ---------------- IMAGE PICKER ----------------
  Future pickImage() async {
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(source: ImageSource.camera);

    if (file != null) {
      setState(() => selectedImage = File(file.path));
    }
  }

  // ---------------- POPUP D'ERREUR AVEC JUSTIFICATIF ----------------
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
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
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
                                color: (isRetard ? errorGradientEnd : warningGradientEnd)
                                    .withOpacity(0.4),
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
                              // Animation d'émoji
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 500),
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.3),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.white.withOpacity(0.9),
                                          Colors.white.withOpacity(0.6),
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.white.withOpacity(0.5),
                                          blurRadius: 20,
                                          spreadRadius: 5,
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Émoji selon le type d'erreur
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 10,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        isRetard ? '😞' : '⏰',
                                        style: TextStyle(fontSize: 30),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 24),

                              // Titre
                              AnimatedOpacity(
                                opacity: _animationController.value > 0.5 ? 1.0 : 0.0,
                                duration: const Duration(milliseconds: 300),
                                child: Transform.translate(
                                  offset: Offset(0, _animationController.value > 0.5 ? 0 : 20),
                                  child: Text(
                                    title,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withOpacity(0.3),
                                          blurRadius: 10,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Message
                              AnimatedOpacity(
                                opacity: _animationController.value > 0.7 ? 1.0 : 0.0,
                                duration: const Duration(milliseconds: 300),
                                child: Transform.translate(
                                  offset: Offset(0, _animationController.value > 0.7 ? 0 : 20),
                                  child: Text(
                                    message,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Zone de saisie du justificatif
                              AnimatedOpacity(
                                opacity: _animationController.value > 0.8 ? 1.0 : 0.0,
                                duration: const Duration(milliseconds: 300),
                                child: Transform.translate(
                                  offset: Offset(0, _animationController.value > 0.8 ? 0 : 20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Justificatif :',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: Colors.white.withOpacity(0.3),
                                          ),
                                        ),
                                        child: TextField(
                                          controller: justificatifCtrl,
                                          maxLines: 3,
                                          enabled: !isSubmitting,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                          decoration: InputDecoration(
                                            hintText: 'Saisissez votre justificatif ici...',
                                            hintStyle: TextStyle(
                                              color: Colors.white.withOpacity(0.6),
                                            ),
                                            border: InputBorder.none,
                                            contentPadding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 32),

                              // Boutons
                              if (isSubmitting)
                                AnimatedOpacity(
                                  opacity: _animationController.value > 0.9 ? 1.0 : 0.0,
                                  duration: const Duration(milliseconds: 300),
                                  child: Transform.translate(
                                    offset: Offset(0, _animationController.value > 0.9 ? 0 : 20),
                                    child: Column(
                                      children: [
                                        CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Traitement en cours...',
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.9),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              else
                                AnimatedOpacity(
                                  opacity: _animationController.value > 0.9 ? 1.0 : 0.0,
                                  duration: const Duration(milliseconds: 300),
                                  child: Transform.translate(
                                    offset: Offset(0, _animationController.value > 0.9 ? 0 : 20),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(16),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.2),
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 5),
                                                ),
                                              ],
                                            ),
                                            child: ElevatedButton(
                                              onPressed: () {
                                                _animationController.reverse().then((_) {
                                                  Navigator.of(ctx).pop(null);
                                                });
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.white,
                                                foregroundColor: isRetard ? errorGradientEnd : warningGradientEnd,
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 12,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(16),
                                                ),
                                              ),
                                              child: Text(
                                                'ANNULER',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(16),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.2),
                                                  blurRadius: 10,
                                                  offset: const Offset(0, 5),
                                                ),
                                              ],
                                            ),
                                            child: ElevatedButton(
                                              onPressed: () {
                                                final justificatif = justificatifCtrl.text.trim();
                                                if (justificatif.isEmpty) {
                                                  ScaffoldMessenger.of(ctx).showSnackBar(
                                                    SnackBar(
                                                      content: Text('Veuillez saisir un justificatif'),
                                                      backgroundColor: Colors.red,
                                                    ),
                                                  );
                                                  return;
                                                }

                                                setStateDialog(() => isSubmitting = true);

                                                // Simuler un traitement
                                                Future.delayed(const Duration(milliseconds: 500), () {
                                                  _animationController.reverse().then((_) {
                                                    Navigator.of(ctx).pop(justificatif);
                                                  });
                                                });
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.white,
                                                foregroundColor: isRetard ? errorGradientEnd : warningGradientEnd,
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 12,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(16),
                                                ),
                                              ),
                                              child: Text(
                                                'ENVOYER',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
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
      },
    );
  }

  // ---------------- POPUP SUCCÈS MODERNE ----------------
  Future showSuccessPopup({
    required String title,
    required String message,
  }) {
    _animationController.reset();
    _animationController.forward();

    return showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      barrierDismissible: false,
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
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF00B09B), Color(0xFF96C93D)],
                        ),
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF96C93D).withOpacity(0.4),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Animation de cercle de succès
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 2,
                                  ),
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
                                      colors: [
                                        Colors.white.withOpacity(0.9),
                                        Colors.white.withOpacity(0.6),
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.white.withOpacity(0.5),
                                        blurRadius: 20,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Emoji moderne
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    '🎉',
                                    style: TextStyle(fontSize: 40),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Titre
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
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Message
                          AnimatedOpacity(
                            opacity: _animationController.value > 0.7 ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 300),
                            child: Transform.translate(
                              offset: Offset(0, _animationController.value > 0.7 ? 0 : 20),
                              child: Text(
                                message,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Bouton
                          AnimatedOpacity(
                            opacity: _animationController.value > 0.9 ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 300),
                            child: Transform.translate(
                              offset: Offset(0, _animationController.value > 0.9 ? 0 : 20),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: () {
                                    _animationController.reverse().then((_) {
                                      Navigator.of(ctx).pop();
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Color(0xFF96C93D),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 48,
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: Text(
                                    'CONTINUER',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
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

  // ---------------- SUBMIT ----------------
  Future submit() async {
    if (matriculeCtrl.text.isEmpty || selectedImage == null) {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Champs manquants", style: TextStyle(color: Colors.red)),
          content: Text("Veuillez remplir les champs obligatoires."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) => Center(
        child: CircularProgressIndicator(color: orange),
      ),
    );

    // Première tentative sans justificatif
    ManualRegisterModel model = ManualRegisterModel(
      matricule: matriculeCtrl.text.trim(),
      observation: observationCtrl.text.trim(),
      imagePath: selectedImage!.path,
    );

    var response = await service.registerManual(model);
    Navigator.pop(context);

    final bool success = response["code"] == 200;
    final String message = response["message"] ?? "Erreur inconnue";
    final bool justificationRequired = response["justification_required"] ?? false;

    // Si succès direct
    if (success) {
      await showSuccessPopup(
        title: "ENREGISTRÉ !",
        message: message,
      );

      setState(() {
        matriculeCtrl.clear();
        observationCtrl.clear();
        selectedImage = null;
      });
    }
    // Si besoin de justificatif (retard ou départ anticipé)
    else if (justificationRequired) {
      final bool isRetard = message.contains('Retard');

      // Afficher le popup d'erreur avec zone de justificatif
      final String? justificatif = await _showErrorWithJustificatifPopup(
        title: isRetard ? 'RETARD DÉTECTÉ' : 'DÉPART ANTICIPÉ',
        message: message,
        isRetard: isRetard,
      );

      // Si l'utilisateur a saisi un justificatif
      if (justificatif != null && justificatif.isNotEmpty) {
        // Montrer l'indicateur de chargement
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (_) => Center(
            child: CircularProgressIndicator(color: orange),
          ),
        );

        // Nouvelle tentative AVEC justificatif
        ManualRegisterModel modelWithJustificatif = ManualRegisterModel(
          matricule: matriculeCtrl.text.trim(),
          observation: justificatif,
          imagePath: selectedImage!.path,
        );

        var newResponse = await service.registerManual(modelWithJustificatif);
        Navigator.pop(context);

        final bool newSuccess = newResponse["code"] == 200;
        final String newMessage = newResponse["message"] ?? "Erreur inconnue";

        if (newSuccess) {
          await showSuccessPopup(
            title: "ENREGISTRÉ AVEC JUSTIFICATIF",
            message: newMessage,
          );

          setState(() {
            matriculeCtrl.clear();
            observationCtrl.clear();
            selectedImage = null;
          });
        } else {
          await showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text("Échec", style: TextStyle(color: Colors.red)),
              content: Text(newMessage),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("OK"),
                ),
              ],
            ),
          );
        }
      }
      // Si l'utilisateur a annulé
      else {
        // Ne rien faire, l'utilisateur a annulé
      }
    }
    // Autre erreur
    else {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Échec", style: TextStyle(color: Colors.red)),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            ),
          ],
        ),
      );
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
              "Formulaire d'Enregistrement",
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

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
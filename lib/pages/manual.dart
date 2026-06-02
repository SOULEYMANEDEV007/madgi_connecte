import 'dart:io';
import 'dart:async';
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
      barrierColor: Colors.black.withValues(alpha: 0.8),
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
                            color: (isRetard ? errorGradientEnd : warningGradientEnd).withValues(alpha: 0.4),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
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
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
                                ),
                              ),
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [Colors.white.withValues(alpha: 0.9), Colors.white.withValues(alpha: 0.6)],
                                  ),
                                  boxShadow: [
                                    BoxShadow(color: Colors.white.withValues(alpha: 0.5), blurRadius: 20, spreadRadius: 5),
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
                                    BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 5)),
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
                              shadows: [Shadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 2))],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            message,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 24, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 24),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Justificatif :', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 8),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                                ),
                                child: TextField(
                                  controller: justificatifCtrl,
                                  maxLines: 3,
                                  enabled: !isSubmitting,
                                  style: const TextStyle(color: Colors.white, fontSize: 14),
                                  decoration: InputDecoration(
                                    hintText: 'Saisissez votre justificatif ici...',
                                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
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
                                Text('Traitement en cours...', style: TextStyle(color: Colors.white.withValues(alpha: 0.9))),
                              ],
                            )
                          else
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 5))],
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
                                      child: const Text('ANNULER', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 5))],
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
                                      child: const Text('ENVOYER', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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

  Future<void> showErrorPopup({required String title, required String message}) {
    _animationController.reset();
    _animationController.forward();

    return showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.7),
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
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [errorGradientStart, errorGradientEnd],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(color: errorGradientEnd.withValues(alpha: 0.4), blurRadius: 30, spreadRadius: 5),
                          BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 10)),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.error_outline, color: Colors.white, size: 48),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            message,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.95),
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                _animationController.reverse().then((_) => Navigator.of(ctx).pop());
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: errorGradientEnd,
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: const Text(
                                'OK',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
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

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    
    try {
      DateTime date = DateTime.parse(dateStr);
      const months = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin', 'Juil', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'];
      String day = date.day.toString().padLeft(2, '0');
      String month = months[date.month - 1];
      String year = date.year.toString();
      return '$day-$month-$year';
    } catch (e) {
      return dateStr;
    }
  }

  Future showSuccessPopup({required String title, required String message, dynamic pointageData}) {
    _animationController.reset();
    _animationController.forward();

    bool hasData = pointageData != null && pointageData is Map;
    String nom = hasData ? (pointageData['nom'] ?? pointageData['nom_employe'] ?? '') : '';
    String prenom = hasData ? (pointageData['prenom'] ?? pointageData['prenom_employe'] ?? '') : '';
    String civilite = hasData ? (pointageData['civilite'] ?? '') : '';
    
    // Si nom et prenom sont vides, essayer d'extraire depuis le message
    if ((nom.isEmpty || nom == 'null') && (prenom.isEmpty || prenom == 'null')) {
      // Extraire depuis le message si format "pour Nom Prenom" ou "de Nom Prenom"
      if (message.contains(' pour ')) {
        final parts = message.split(' pour ');
        if (parts.length > 1) {
          final namePart = parts[1].trim().replaceAll('.', '');
          nom = namePart;
        }
      } else if (message.contains(' de ')) {
        final parts = message.split(' de ');
        if (parts.length > 1) {
          final namePart = parts[1].trim().replaceAll('.', '');
          nom = namePart;
        }
      }
    }
    
    // Si nom et prenom sont vides, ne pas afficher juste la civilité
    String displayName = '';
    if (nom.isNotEmpty && nom != 'null') {
      if (prenom.isNotEmpty && prenom != 'null') {
        displayName = civilite.isNotEmpty ? '$civilite $nom $prenom'.trim() : '$nom $prenom'.trim();
      } else {
        displayName = civilite.isNotEmpty ? '$civilite $nom'.trim() : nom;
      }
    }
    
    bool isDepart = false;
    if (message.toLowerCase().contains('au revoir') || 
        message.toLowerCase().contains('départ') || 
        (hasData && pointageData['heure_depart'] != null)) {
      isDepart = true;
    }

    String titleMessage = displayName.isNotEmpty
        ? (isDepart ? "Au revoir $displayName" : "Bienvenue $displayName")
        : (isDepart ? "Au revoir" : "Bienvenue");

    return showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.7),
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
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF00B09B), Color(0xFF96C93D)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: const Color(0xFF96C93D).withValues(alpha: 0.4), blurRadius: 30, spreadRadius: 5),
                          BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 10)),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check_circle, color: Colors.white, size: 48),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            titleMessage,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (message.isNotEmpty && message != 'Pointage validé') ...[
                            const SizedBox(height: 8),
                            Text(
                              message,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: 20,
                              ),
                            ),
                          ],
                          if (hasData) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.person, color: Colors.white, size: 26),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          '${pointageData['civilite'] ?? ''} ${nom} ${prenom}'.trim(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_today, color: Colors.white, size: 26),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Date: ${_formatDate(pointageData['date'])}',
                                          style: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.login, color: Colors.white, size: 26),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Arrivée: ${pointageData['heure_arrive'] ?? ''}',
                                          style: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (pointageData['heure_depart'] != null) ...[
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.logout, color: Colors.white, size: 26),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Départ: ${pointageData['heure_depart']}',
                                            style: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  if (pointageData['est_en_retard'] == true) ...[
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: orange.withValues(alpha: 0.3),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(Icons.warning, color: orange, size: 24),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Retard signalé',
                                            style: TextStyle(
                                              color: orange,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                _animationController.reverse().then((_) => Navigator.of(ctx).pop());
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF96C93D),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'CONTINUER',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
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
      await showErrorPopup(
        title: "Champs manquants",
        message: "Veuillez remplir les champs obligatoires.",
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
    if (!mounted) return;
    Navigator.pop(context);

    // 🔍 DEBUG TEMPORAIRE
    debugPrint('========= RÉPONSE BACKEND =========');
    debugPrint('CODE: ${response["code"]}');
    debugPrint('MESSAGE: ${response["message"]}');
    debugPrint('JUSTIFICATION_REQUIRED: ${response["justification_required"]}');
    debugPrint('DATA: ${response["data"]}');
    if (response["data"] != null && response["data"] is Map) {
      debugPrint('EST_EN_RETARD: ${response["data"]["est_en_retard"]}');
    }
    debugPrint('===================================');

    final int code = response["code"] ?? 500;
    String message = response["message"] ?? "Erreur inconnue";
    final bool justificationRequired = response["justification_required"] == true;
    final dynamic data = response["data"];
    
    // Vérifier si c'est un retard même avec code 200
    bool isRetardDetected = false;
    if (data != null && data is Map && data["est_en_retard"] == true) {
      isRetardDetected = true;
    }

    // CAS 1 : Retard détecté (soit code 403, soit est_en_retard = true)
    if ((code == 403 && justificationRequired) || (code == 200 && isRetardDetected && justificationRequired)) {
      final bool isRetard = message.toLowerCase().contains('retard') || isRetardDetected;
      final String? justificatif = await _showErrorWithJustificatifPopup(
        title: isRetard ? 'RETARD DÉTECTÉ' : 'DÉPART ANTICIPÉ',
        message: message,
        isRetard: isRetard,
      );

      if (justificatif != null && justificatif.isNotEmpty) {
        if (!mounted) return;
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (_) => Center(child: CircularProgressIndicator(color: vert)),
        );

        ManualRegisterModel modelWithJustificatif = ManualRegisterModel(
          matricule: matriculeCtrl.text.trim(),
          observation: observationCtrl.text.trim(),
          imagePath: selectedImage!.path,
          justificatifArrive: isRetard ? justificatif : null,
          justificatifDepart: !isRetard ? justificatif : null,
          avecJustificatif: true,
        );

        var newResponse = await service.registerManual(modelWithJustificatif);
        if (!mounted) return;
        Navigator.pop(context);

        final bool newSuccess = newResponse["code"] == 200;
        String newMessage = newResponse["message"] ?? "Erreur inconnue";

        if (newSuccess) {
          newMessage = _formatSuccessMessage(newMessage, newResponse["data"]);
          await showSuccessPopup(title: "ENREGISTRÉ AVEC JUSTIFICATIF", message: newMessage, pointageData: newResponse["data"]);
          setState(() { matriculeCtrl.clear(); observationCtrl.clear(); selectedImage = null; });
        } else {
          await showErrorPopup(
            title: "Échec",
            message: newMessage,
          );
        }
      }
    }
    // CAS 2 : Succès (code 200 sans retard)
    else if (code == 200) {
      message = _formatSuccessMessage(message, response["data"]);
      await showSuccessPopup(title: "ENREGISTRÉ !", message: message, pointageData: response["data"]);
      setState(() { matriculeCtrl.clear(); observationCtrl.clear(); selectedImage = null; });
    } 
    // CAS 3 : Autre erreur
    else {
      await showErrorPopup(
        title: "Échec",
        message: message,
      );
    }
  }

  String _formatSuccessMessage(String originalMsg, dynamic dataObj) {
    if (originalMsg.toLowerCase().contains("arriv")) {
      return "Bonne journée !";
    } else if (originalMsg.toLowerCase().contains("départ") || originalMsg.toLowerCase().contains("depart")) {
      return "Passez une agréable soirée !";
    }
    return originalMsg;
  }

  Widget _bigInput({required String label, required IconData icon, required TextEditingController controller, TextInputType keyboard = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: vert)),
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
            Text("Veuillez remplir les informations ci-dessous", style: TextStyle(fontSize: 24, color: Colors.grey.shade700)),
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
                            const Text("Appuyer pour prendre une photo", style: TextStyle(fontSize: 24, color: Colors.grey)),
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
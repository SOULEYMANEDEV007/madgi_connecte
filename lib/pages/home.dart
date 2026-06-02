import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const Color orange = Color(0xFFFF9900);
  static const Color vert   = Color(0xFF3CA55C);
  static const Color gris   = Color(0xFF6F6F6F);

  @override
  Widget build(BuildContext context) {
    final double screenW = MediaQuery.of(context).size.width;
    final bool isTablet  = screenW > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: Column(
        children: [
          // --- HEADER MADGI ---
          Container(
            padding: EdgeInsets.only(
              top: isTablet ? 60 : 50,
              bottom: isTablet ? 30 : 24,
              left: 24,
              right: 24,
            ),
            width: double.infinity,
            decoration: const BoxDecoration(
              color: orange,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/logo.png',
                    height: isTablet ? 70 : 60,
                    width: isTablet ? 70 : 60,
                  ),
                ),
                const SizedBox(width: 14),
                const Icon(Icons.settings, color: Colors.white, size: 26),
                const SizedBox(width: 8),
                Text(
                  "Madgi Connecte",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isTablet ? 32 : 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // --- SECTION BIENVENUE ---
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: EdgeInsets.all(isTablet ? 24 : 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: isTablet ? 72 : 60,
                  height: isTablet ? 72 : 60,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: vert,
                  ),
                  child: Icon(Icons.shield_outlined,
                      color: Colors.white, size: isTablet ? 40 : 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Bienvenue !",
                        style: TextStyle(
                          fontSize: isTablet ? 32 : 24,
                          color: vert,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Choisissez votre méthode d'enregistrement",
                        style: TextStyle(
                          fontSize: isTablet ? 32 : 24,
                          color: gris,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // --- CARTES D'ACTION ---
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // Enregistrement Manuel
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pushNamed(context, "/manual"),
                      child: _buildActionCard(
                        icon: Icons.edit_note,
                        title: "Enregistrement Manuel",
                        subtitle: "Saisir le matricule manuellement",
                        gradientColors: const [
                          Color(0xFF4DB06C),
                          vert,
                        ],
                        imagePath: null,
                        isTablet: isTablet,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Émargement Automatique
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pushNamed(context, "/scanner"),
                      child: _buildActionCard(
                        icon: Icons.qr_code_scanner,
                        title: "Enregistrement Automatique",
                        subtitle: "Générer le QR Code de pointage",
                        gradientColors: const [
                          Color(0xFF4DB06C),
                          vert,
                        ],
                        imagePath: null,
                        isTablet: isTablet,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> gradientColors,
    required bool isTablet,
    String? imagePath,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        boxShadow: [
          BoxShadow(
            color: gradientColors.last.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Image de fond si disponible
          if (imagePath != null)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Opacity(
                  opacity: 0.12,
                  child: Image.asset(imagePath, fit: BoxFit.cover),
                ),
              ),
            ),

          // Contenu centré
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: isTablet ? 80 : 64,
                    height: isTablet ? 80 : 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.2),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.4),
                          width: 2),
                    ),
                    child: Icon(icon,
                        color: Colors.white, size: isTablet ? 44 : 36),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isTablet ? 32 : 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isTablet ? 22 : 18,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
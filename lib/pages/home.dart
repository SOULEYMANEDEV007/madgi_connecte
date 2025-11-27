import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Définition des couleurs principales
    const Color orange = Color(0xFFFF9900);
    const Color vert = Color(0xFF3CA55C);
    const Color gris = Color(0xFF6F6F6F);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),

      body: Column(
        children: [
          // --- HEADER ORANGE ---
          Container(
            padding: const EdgeInsets.only(top: 45, bottom: 20),
            width: double.infinity,
            color: orange,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.settings, color: Colors.white, size: 26),
                const SizedBox(width: 8),
                const Text(
                  "Madgi Connecte",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // --- SECTION "BIENVENUE" ---
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                )
              ],
            ),
            child: Row(
              children: [
                // Icône ronde verte
                Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    color: vert,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.shield_outlined, color: Colors.white, size: 32),
                ),
                const SizedBox(width: 20),

                // Textes
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Bienvenue !",
                      style: TextStyle(
                        fontSize: 20,
                        color: vert,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Choisissez votre méthode d’enregistrement",
                      style: TextStyle(
                        fontSize: 14,
                        color: gris,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),

          const SizedBox(height: 25),

          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, "/manual");
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 50),
              padding: const EdgeInsets.all(25),
              height: 350, //
              width: 800,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  )
                ],
              ),

              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icône ronde centrée
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: Color(0xFF3CA55C),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.edit_note, color: Colors.white, size: 50),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    "Enregistrement Manuel",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      color: Color(0xFF3CA55C),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 18),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, "/scanner");
            },
            child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(25),
                height: 350, // >>> IDENTIQUE AU MANUEL
                width: 800,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    )
                  ],
                ),

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icône ronde centrée
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: Color(0xFF3CA55C),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 50),
                    ),

                    const SizedBox(height: 18),

                    const Text(
                      "Enregistrement Automatique",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        color: Color(0xFF3CA55C),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )
            ),
          ),
        ],
      ),
    );
  }
}
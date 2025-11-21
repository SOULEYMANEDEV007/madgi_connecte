import 'package:flutter/material.dart';

class ManualRegisterPage extends StatefulWidget {
  const ManualRegisterPage({super.key});

  @override
  State<ManualRegisterPage> createState() => _ManualRegisterPageState();
}

class _ManualRegisterPageState extends State<ManualRegisterPage> {
  final Color vert = const Color(0xFF3CA55C);
  final Color orange = const Color(0xFFFF9900);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: orange,
        elevation: 0,
        title: const Text(
          "Enregistrement Manuel",
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 20),

            // TITRE PRINCIPAL
            Text(
              "Formulaire d’Enregistrement",
              style: TextStyle(
                fontSize: 30,
                color: vert,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            Text(
              "Veuillez remplir les informations ci-dessous",
              style: TextStyle(
                fontSize: 22,
                color: Colors.grey.shade700,
              ),
            ),

            const SizedBox(height: 40),

            // --- FULL NAME ---
            _bigInput(
              label: "Nom Complet",
              icon: Icons.person,
            ),

            const SizedBox(height: 25),

            // --- PHONE ---
            _bigInput(
              label: "Numéro de Téléphone",
              icon: Icons.phone_android,
              keyboard: TextInputType.phone,
            ),

            const SizedBox(height: 25),

            // --- EMAIL ---
            _bigInput(
              label: "Adresse Email",
              icon: Icons.email_outlined,
              keyboard: TextInputType.emailAddress,
            ),

            const SizedBox(height: 25),

            // --- CNI / IDENTIFIANT ---
            _bigInput(
              label: "N° de Carte d’Identité / Identifiant",
              icon: Icons.badge_outlined,
            ),

            const SizedBox(height: 40),

            // --- BUTTON ---
            SizedBox(
              width: double.infinity,
              height: 80, // GROS BOUTON POUR TABLETTE
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: vert,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  "Enregistrer",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // --- WIDGET INPUT AGRANDI ---
  Widget _bigInput({
    required String label,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 3),
              )
            ],
          ),
          child: TextField(
            keyboardType: keyboard,
            style: const TextStyle(fontSize: 24),
            decoration: InputDecoration(
              border: InputBorder.none,
              icon: Icon(icon, size: 32, color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }
}

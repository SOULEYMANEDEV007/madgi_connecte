import 'package:flutter/material.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int _index = 0;

  final Color bgColor = const Color(0xFFFDF5D9);
  final Color accent = const Color(0xFFFF9900);
  final Color titleColor = const Color(0xFF3CA55C);
  final Color textColor = const Color(0xFF696969);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _index = i),
                children: [
                  _buildPage(
                    icon: Icons.shield_outlined,
                    title: "Connexion Sécurisée",
                    description: "Vos données sont protégées avec les meilleures technologies de sécurité",
                  ),
                  _buildPage(
                    icon: Icons.person_add_alt_1,
                    title: "Enregistrement Simple",
                    description: "Enregistrez-vous manuellement ou automatiquement en quelques étapes",
                  ),
                  _buildPage(
                    icon: Icons.wifi_tethering,
                    title: "Bienvenue sur Madgi Connect",
                    description: "La plateforme de connexion intelligente pour tous vos besoins",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                    (i) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: _index == i ? accent : Colors.grey.shade400,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    if (_index < 2) {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      // Navigate to your home / login / etc.
                      Navigator.pushReplacementNamed(context, "/home");
                    }
                  },
                  child: Text(
                    _index == 0 ? "Commencer" : "Suivant",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            GestureDetector(
              onTap: () => Navigator.pushReplacementNamed(context, "/home"),
              child: const Text(
                "Passer",
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPage({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            color: const Color(0xFFFF9900),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 80),
        ),
        const SizedBox(height: 30),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: titleColor,
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: textColor,
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'Informes.dart';

class MenuScreen extends StatelessWidget {
  static const String routeName = '/menu';
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final agente = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Column(
          children: [
            // Usuario logueado
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    agente, 
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            // Logo
            Center(
              child: Image.asset(
                'lib/assets/images/logo.jpeg',
                width: 300,
                height: 300,
              ),
            ),
            const SizedBox(height: 32),

            // Buttons area - centered vertically
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _MenuButton(
                    label: 'Condenas',
                    icon: Icons.gavel,
                    onTap: () => Navigator.pushNamed(context, '/condenas', arguments: agente),
                    height: 110,
                  ),
                  const SizedBox(height: 20),
                  _MenuButton(
                    label: 'Informes',
                    icon: Icons.article,
                    onTap: () => Navigator.pushNamed(context, '/informes', arguments: agente),
                    height: 110,
                  ),
                ],
              ),
            ),

            // Logout image button at bottom
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: GestureDetector(
                onTap: () {
                  // Back to login
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                },
                child: Column(
                  children: [
                    // Use logout asset image if present, otherwise fallback icon
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 4),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          'lib/assets/images/logout.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.exit_to_app, size: 32),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final double height;

  const _MenuButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.height = 84,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 36),
              const SizedBox(width: 12),
              Text(label, style: const TextStyle(fontSize: 20)),
            ],
          ),
        ),
      ),
    );
  }
}

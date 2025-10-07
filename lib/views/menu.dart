import 'package:flutter/material.dart';
import 'Informes.dart';
import '../helpers/loadpageperview.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class MenuScreen extends StatelessWidget {
  static const String routeName = '/menu';
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final agente = ModalRoute.of(context)!.settings.arguments as String;

    return WillPopScope(
      onWillPop: () async {
        // Intercepta el botón "Atrás" del dispositivo
        AwesomeDialog(
          context: context,
          dialogType: DialogType.warning,
          animType: AnimType.bottomSlide,
          title: '¿Cerrar sesión?',
          desc: '¿Estás seguro de terminar la sesión?',
          btnCancelText: 'Cancelar',
          btnOkText: 'Si',
          btnCancelOnPress: () {},
          btnOkOnPress: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/login',
              (route) => false,
            );
          },
        ).show();
        return false; // Evita que la pantalla se cierre automáticamente
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: const Color(0xFFe7e7e7),
        body: SafeArea(
          child: Column(
            children: [
              // Usuario logueado
              Padding(
                padding: const EdgeInsets.only(right: 16.0, top: 16.0),
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
              // Logo centrado
              Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                child: Center(
                  child: Image.asset(
                    'lib/assets/images/logo.jpeg',
                    width: 220,
                    height: 220,
                  ),
                ),
              ),
              // Botones tipo tarjeta
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 80.0),
                child: Column(
                  children: [
                    _MenuCardButton(
                      label: 'Condenas',
                      icon: Icons.gavel,
                      onTap: () => navigateWithLoading(
                        context,
                        '/condenas',
                        arguments: agente,
                      ),
                      height: 80,
                    ),
                    const SizedBox(height: 20),
                    _MenuCardButton(
                      label: 'Informes',
                      icon: Icons.article,
                      onTap: () => navigateWithLoading(
                        context,
                        '/informes',
                        arguments: agente,
                      ),
                      height: 80,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Botón de logout
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0, top: 8.0),
                child: IconButton(
                  icon: Image.asset(
                    'lib/assets/images/logout.png',
                    width: 75,
                    height: 75,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.exit_to_app, size: 60),
                  ),
                  iconSize: 75.0,
                  onPressed: () {
                    AwesomeDialog(
                      context: context,
                      dialogType: DialogType.warning,
                      animType: AnimType.bottomSlide,
                      title: '¿Cerrar sesión?',
                      desc: '¿Estás seguro de terminar la sesión?',
                      btnCancelText: 'Cancelar',
                      btnOkText: 'Si',
                      btnCancelOnPress: () {},
                      btnOkOnPress: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/login',
                          (route) => false,
                        );
                      },
                    ).show();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuCardButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final double height;

  const _MenuCardButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.height = 48,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 2.0,
        margin: const EdgeInsets.only(bottom: 12.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        color: Colors.white,
        child: SizedBox(
          height: height,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 36, color: Colors.black),
                const SizedBox(width: 18),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

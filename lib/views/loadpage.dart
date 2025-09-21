import 'package:flutter/material.dart';
// Asegúrate de que esta ruta sea correcta para tu proyecto.
import 'login.dart';

class Loadpage extends StatefulWidget {
  static const String routeName = '/loadpage';
  const Loadpage({Key? key}) : super(key: key);

  @override
  _LoadpageState createState() => _LoadpageState();
}

class _LoadpageState extends State<Loadpage> with TickerProviderStateMixin {
  late AnimationController _exitController;
  late Animation<Offset> _exitOffsetAnimation;
  late Animation<double> _exitFadeAnimation;

  late AnimationController _bounceController;
  late Animation<Offset> _bounceAnimation;

  @override
  void initState() {
    super.initState();

    // --- Controlador para la TRANSICIÓN DE SALIDA ---
    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350), // Un poco más rápida
    );

    // CAMBIO: Se usa una curva más agresiva que empieza rápido (efecto "salto")
    _exitOffsetAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.0, 3.0),
    ).animate(CurvedAnimation(
      parent: _exitController,
      curve: const Cubic(0.55, 0.055, 0.675, 0.19), // Curva "EaseInBack"
    ));

    _exitFadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _exitController,
      // El desvanecimiento ocurre en el 80% inicial de la animación
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
    ));

    // --- Controlador para el MOVIMIENTO SUTIL (flotación) ---
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _bounceAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.0, -0.05),
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.easeInOutSine,
    ));

    _startTransition();
  }

  _startTransition() async {
    await Future.delayed(const Duration(seconds: 2));

    _bounceController.stop();
    _exitController.forward();

    // Retraso más corto para una transición más enlazada
    await Future.delayed(const Duration(milliseconds: 150));

    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
          transitionDuration: const Duration(milliseconds: 500),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      );
    }
  }

  @override
  void dispose() {
    _exitController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 134, 134, 134),
      body: Center(
        // CAMBIO: Se usa AnimatedBuilder para un control total y evitar "saltos"
        child: AnimatedBuilder(
          // Escucha ambos controladores para reconstruir en cada frame
          animation: Listenable.merge([_bounceController, _exitController]),
          builder: (context, child) {
            // Combina el offset de ambas animaciones en uno solo.
            // Esto asegura que la salida comience desde la posición exacta donde se detuvo la flotación.
            final totalOffset = _bounceAnimation.value + _exitOffsetAnimation.value;

            // Se usa FractionalTranslation que es como SlideTransition pero con control directo
            return FractionalTranslation(
              translation: totalOffset,
              child: child,
            );
          },
          // El 'child' es la parte que no necesita reconstruirse (el FadeTransition y la Imagen)
          child: FadeTransition(
            opacity: _exitFadeAnimation,
            child: Image.asset(
              'lib/assets/images/logo.jpeg',
              width: 150,
              height: 150,
            ),
          ),
        ),
      ),
    );
  }
}
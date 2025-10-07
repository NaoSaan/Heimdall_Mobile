import 'package:flutter/material.dart';
import '../views/loadpage.dart';

/// Muestra la pantalla de carga y luego navega a la ruta [targetRoute].
Future<void> navigateWithLoading(
  BuildContext context,
  String targetRoute, {
  Object? arguments,
}) async {
  // Navega primero a la pantalla de carga
  await Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const Loadpage(intermediate: true)),
  );

  // Después de que Loadpage termine su animación, redirige a la vista real
  Navigator.pushReplacementNamed(context, targetRoute, arguments: arguments);
}

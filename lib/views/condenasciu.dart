import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class CondenasCiuScreen extends StatefulWidget {
  static const String routeName = '/condenasciu';
  const CondenasCiuScreen({super.key});

  @override
  State<CondenasCiuScreen> createState() => _CondenasCiuScreenState();
}

class _CondenasCiuScreenState extends State<CondenasCiuScreen> {
  @override
  Widget build(BuildContext context) {
    // Se recibe el argumento 'ciudadano' para mostrarlo en pantalla.
    final ciudadano = ModalRoute.of(context)!.settings.arguments as String;

    return WillPopScope(
      onWillPop: () async {
        // Mostrar diálogo de confirmación al presionar botón "Atrás"
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
        backgroundColor: const Color(0xFFe7e7e7),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              children: [
                // --- Widget para mostrar el nombre del agente ---
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        ciudadano,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // --- Lista de Tarjetas ---
                Expanded(
                  child: ListView.builder(
                    itemCount: 6,
                    itemBuilder: (context, index) {
                      return const TransactionCard();
                    },
                  ),
                ),

                // --- Botones Inferiores ---
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Botón de logout
                      IconButton(
                        icon: const Icon(Icons.output),
                        iconSize: 48.0,
                        color: Colors.black54,
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
                    ],
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

// --- Widget para la Tarjeta de Transacción ---
class TransactionCard extends StatelessWidget {
  const TransactionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Asunto',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                SizedBox(height: 2),
                Text(
                  'Importe',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: const BoxDecoration(
                color: Color(0xFFb2ffc8),
                shape: BoxShape.circle,
              ),
              child: const Text(
                '\$',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

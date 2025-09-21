import 'package:flutter/material.dart';

class CondenasScreen extends StatefulWidget {
  static const String routeName = '/condenas';
  const CondenasScreen({super.key});

  @override
  State<CondenasScreen> createState() => _CondenasScreenState();
}

class _CondenasScreenState extends State<CondenasScreen> {
  @override
  Widget build(BuildContext context) {
    // Reemplazamos el Placeholder con el Scaffold que contiene el diseño.
    return Scaffold(
      resizeToAvoidBottomInset: false,
      // Se aplica el color de fondo solicitado.
      backgroundColor: const Color(0xFFe7e7e7),
      body: SafeArea(
        child: Padding(
          // Se aumenta el padding horizontal.
          padding: const EdgeInsets.symmetric(horizontal: 50.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // --- Barra de Búsqueda ---
              TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none, // Sin borde visible
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    // Se cambia el color del borde al estar seleccionado a negro.
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // --- Lista de Tarjetas ---
              Expanded(
                child: ListView.builder(
                  itemCount: 7, // Número de tarjetas a mostrar
                  itemBuilder: (context, index) {
                    // Datos de ejemplo para cada tarjeta
                    final ids = [
                      "0001",
                      "0002",
                      "0003",
                      "0004",
                      "0005",
                      "0006",
                      "0007",
                    ];
                    return InfoCard(
                      id: ids[index],
                      asunto: 'Asunto',
                      curp: 'CURP-EJEMPLO',
                      estatus: 'estatus',
                    );
                  },
                ),
              ),

              // --- Botones Inferiores ---
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Botón de Inicio (Home)
                    IconButton(
                      icon: const Icon(Icons.home_outlined),
                      iconSize: 75.0,
                      // Se cambia el color del ícono a negro.
                      color: Colors.black,
                      onPressed: () {
                        // Acción para el botón de inicio (no funcional por ahora)
                        Navigator.pushNamed(context, '/menu');
                      },
                    ),
                    // Botón de Lista (List)
                    IconButton(
                      icon: const Icon(Icons.library_books_outlined),
                      iconSize: 75.0,
                      // Se cambia el color del ícono a negro.
                      color: Colors.black,
                      onPressed: () {
                        // Acción para el botón de lista (no funcional por ahora)
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Widget para la Tarjeta de Información ---
// Lo mantenemos como un widget separado para mayor claridad y reutilización.
class InfoCard extends StatelessWidget {
  final String id;
  final String asunto;
  final String curp; // Se añade el campo para la CURP
  final String estatus;

  const InfoCard({
    super.key,
    required this.id,
    required this.asunto,
    required this.curp, // Se añade al constructor
    required this.estatus,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0, // Sombra sutil
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
      // Se establece explícitamente el color de fondo de la tarjeta a blanco.
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              id,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                // Se establece el color del texto a negro.
                color: Colors.black,
              ),
            ),
            // Se reemplaza el Text por una Column para apilar el asunto y la CURP.
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  asunto,
                  style: const TextStyle(
                    fontSize: 16,
                    // Se establece el color del texto a negro.
                    color: Colors.black,
                  ),
                ),
                Text(
                  curp,
                  style: const TextStyle(
                    fontSize: 14, // Fuente ligeramente más pequeña para la CURP
                    // Se establece el color del texto a negro.
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            Text(
              estatus,
              style: const TextStyle(
                fontSize: 16,
                // Se establece el color del texto a negro.
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

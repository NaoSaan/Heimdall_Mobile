import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart'; // Librería para diálogos personalizados
import 'package:http/http.dart' as http; // Librería para llamadas HTTP
import 'dart:convert'; // Para codificar/decodificar JSON

// --- Pantalla principal que muestra las condenas de un ciudadano ---
class CondenasCiuScreen extends StatefulWidget {
  static const String routeName = '/condenasciu'; // Ruta para navegación
  const CondenasCiuScreen({super.key});

  @override
  State<CondenasCiuScreen> createState() => _CondenasCiuScreenState();
}

class _CondenasCiuScreenState extends State<CondenasCiuScreen> {
  // Variable para almacenar la respuesta futura de la API
  late Future<List<dynamic>> _futureCondenas;
  late Future<List<dynamic>> _futureCondenasFil;
  TextEditingController _searchController = TextEditingController();

  // --- Función para obtener condenas desde la API usando POST ---
  Future<List<dynamic>> fetchCondenas(String curp) async {
    final response = await http.post(
      Uri.parse('https://heimdall-qxbv.onrender.com/api/condenas/allf'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'curp': curp,
      }), // Se envía el CURP en el cuerpo de la solicitud
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(
        response.body,
      ); // Decodificar la respuesta JSON
      return data;
    } else {
      // Manejo de errores en caso de fallo de la API
      throw Exception('Error al cargar las condenas');
    }
  }

  Future<List<dynamic>> fetchCondenasFi(String curp, String filtro) async {
    final response = await http.post(
      Uri.parse('https://heimdall-qxbv.onrender.com/api/condenas/mufi'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'curp': curp, 'filtro': filtro}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data is List) {
        // Si la respuesta es una lista, retornamos directamente
        return data;
      } else if (data is Map && data.containsKey('message')) {
        // Si la respuesta es un objeto con mensaje, retornamos lista vacía
        return [];
      } else {
        // Otro tipo inesperado
        throw Exception('Formato de respuesta inesperado');
      }
    } else {
      throw Exception('Error al cargar las condenas');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Obtener los argumentos enviados a esta pantalla (curp, ciudadano)
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final curp = args['curp'];
    _futureCondenas = fetchCondenas(
      curp,
    ); // Inicializar el Future con la llamada a la API
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final ciudadano = args['ciudadano']; // Nombre del ciudadano

    return WillPopScope(
      onWillPop: () async {
        // Intercepta el botón "atrás" para mostrar un diálogo de confirmación de cierre de sesión
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
            // Navega a la pantalla de login y elimina la pila de navegación
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/login',
              (route) => false,
            );
          },
        ).show();
        return false; // Prevenir la acción por defecto de volver atrás
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFe7e7e7),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 16.0,
            ),
            child: Column(
              children: [
                // --- Nombre del ciudadano en la parte superior ---
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
                TextField(
                  controller: _searchController,
                  onSubmitted: (value) async {
                    final args =
                        ModalRoute.of(context)!.settings.arguments
                            as Map<String, dynamic>;
                    final curp = args['curp'];

                    if (value.isEmpty) {
                      // Si no hay texto, mostrar todas las condenas
                      setState(() {
                        _futureCondenas = fetchCondenas(curp);
                      });
                    } else {
                      // Si hay texto, buscar filtrado
                      setState(() {
                        _futureCondenas = fetchCondenasFi(curp, value);
                      });
                    }
                  },
                  decoration: InputDecoration(
                    hintText: 'Buscar...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 15.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: const BorderSide(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // --- Lista de condenas obtenidas de la API ---
                Expanded(
                  child: FutureBuilder<List<dynamic>>(
                    future: _futureCondenas,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        // Mostrar indicador de carga mientras se obtiene la información
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        // Mostrar error en caso de fallo de la API
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        // Mensaje si no hay condenas
                        return const Center(
                          child: Text('No se encontraron condenas.'),
                        );
                      }

                      final condenas = snapshot.data!;
                      return ListView.builder(
                        itemCount: condenas.length,
                        itemBuilder: (context, index) {
                          final c = condenas[index];
                          // Crear una tarjeta para cada condena
                          return TransactionCard(
                            asunto: c['Tipo'],
                            importe: c['Importe'],
                          );
                        },
                      );
                    },
                  ),
                ),

                // --- Botón para cerrar sesión ---
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.output),
                        iconSize: 48.0,
                        color: Colors.black54,
                        onPressed: () {
                          // Mostrar diálogo de confirmación de cierre de sesión
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

// --- Widget independiente para mostrar cada condena en forma de tarjeta ---
class TransactionCard extends StatelessWidget {
  final String asunto; // Tipo de condena
  final String importe; // Importe de la condena

  const TransactionCard({
    super.key,
    required this.asunto,
    required this.importe,
  });

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
            // --- Información de la condena ---
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  asunto,
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 2),
                Text(
                  'Importe: $importe',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            // --- Ícono de dólar al lado derecho ---
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

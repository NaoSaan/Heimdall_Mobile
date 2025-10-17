import 'package:flutter/material.dart';
import '../helpers/loadpageperview.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class InformesScreen extends StatefulWidget {
  static const String routeName = '/informes';
  const InformesScreen({super.key});

  @override
  State<InformesScreen> createState() => _InformesScreenState();
}

class _InformesScreenState extends State<InformesScreen> {
  TextEditingController _searchController = TextEditingController();
  late Future<List<dynamic>> _futureInformes;

  Future<List<dynamic>> fetchInformesFil(String filtro) async {
    final response = await http.get(
      Uri.parse(
        'https://heimdall-qxbv.onrender.com/api/informes/?by=${filtro}',
      ),
      headers: {'Content-Type': 'application/json'},
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
      throw Exception('Error al cargar los informes.');
    }
  }

  Future<List<dynamic>> fetchInformes() async {
    final response = await http.get(
      Uri.parse('https://heimdall-qxbv.onrender.com/api/informes/all'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(
        response.body,
      ); // Decodificar la respuesta JSON
      return data;
    } else {
      // Manejo de errores en caso de fallo de la API
      throw Exception('Error al cargar los informes');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _futureInformes = fetchInformes();
  }

  @override
  Widget build(BuildContext context) {
    final agente = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xFFe7e7e7),
      body: SafeArea(
        child: Column(
          children: [
            // --- Texto del agente fuera del padding general ---
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

            // --- Contenido principal ---
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50.0),
                child: Column(
                  children: [
                    const SizedBox(height: 25),
                    // --- Barra de Búsqueda ---
                    TextField(
                      controller: _searchController,
                      onSubmitted: (value) {
                        if (value.isEmpty) {
                          setState(() {
                            _futureInformes = fetchInformes();
                          });
                        } else {
                          setState(() {
                            _futureInformes = fetchInformesFil(value);
                          });
                        }
                      },
                      decoration: InputDecoration(
                        hintText: 'Buscar...',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 15.0,
                        ),
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

                    // --- Lista de Tarjetas ---
                    Expanded(
                      child: FutureBuilder<List<dynamic>>(
                        future: _futureInformes,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            // Mostrar indicador de carga mientras se obtiene la información
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (snapshot.hasError) {
                            // Mostrar error en caso de fallo de la API
                            return Center(
                              child: Text('Error: ${snapshot.error}'),
                            );
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            // Mensaje si no hay condenas
                            return const Center(
                              child: Text('No se encontraron informes.'),
                            );
                          }

                          final informes = snapshot.data!;
                          return ListView.builder(
                            itemCount: informes.length,
                            itemBuilder: (context, index) {
                              final c = informes[index];
                              // Crear una tarjeta para cada condena
                              return InfoCard(
                                folio: c['_id'],
                                estatus: c['Estatus'] == 'A'
                                    ? 'Activo'
                                    : 'Inactivo',
                                fecha: c['Fecha_Informe'],
                              );
                            },
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
                          IconButton(
                            icon: const Icon(Icons.home_outlined),
                            iconSize: 75.0,
                            color: Colors.black,
                            onPressed: () {
                              navigateWithLoading(
                                context,
                                '/menu',
                                arguments: agente,
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.gavel),
                            iconSize: 75.0,
                            color: Colors.black,
                            onPressed: () {
                              navigateWithLoading(
                                context,
                                '/condenas',
                                arguments: agente,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
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

// --- Widget para la Tarjeta de Información ---
class InfoCard extends StatelessWidget {
  final String folio;
  final String estatus;
  final String fecha;

  const InfoCard({
    super.key,
    required this.folio,
    required this.estatus,
    required this.fecha,
  });

  @override
  Widget build(BuildContext context) {
    // Determinar el icono basado en el estatus
    final IconData statusIcon = estatus == 'Activo'
        ? Icons
              .lock_open // Candado abierto para activo
        : Icons.lock; // Candado cerrado para inactivo

    // Color del icono basado en el estatus
    final Color statusColor = estatus == 'Activo'
        ? Colors
              .green // Verde para activo
        : Colors.red; // Rojo para inactivo

    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        child: Row(
          children: [
            // Icono del estatus en la parte izquierda
            Container(
              margin: const EdgeInsets.only(right: 16.0),
              child: Icon(statusIcon, color: statusColor, size: 32.0),
            ),

            // Información del informe - CENTRADA
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Folio: $folio',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Fecha: $fecha',
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../helpers/loadpageperview.dart';
import 'package:http/http.dart' as http; // Librería para llamadas HTTP
import 'dart:convert'; // Para codificar/decodificar JSON

class CondenasScreen extends StatefulWidget {
  static const String routeName = '/condenas';
  const CondenasScreen({super.key});

  @override
  State<CondenasScreen> createState() => _CondenasScreenState();
}

class _CondenasScreenState extends State<CondenasScreen> {
  TextEditingController _searchController = TextEditingController();
  late Future<List<dynamic>> _futureCondenasAg;
  // Variable para almacenar la respuesta futura de la API
  Future<List<dynamic>> fetchCondenasAgFil(String filtro) async {
    final response = await http.get(
      Uri.parse(
        'https://heimdall-qxbv.onrender.com/api/condenas/axcf/?by=${filtro}',
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
      throw Exception('Error al cargar las condenas');
    }
  }

  Future<List<dynamic>> fetchCondenasAg() async {
    final response = await http.get(
      Uri.parse('https://heimdall-qxbv.onrender.com/api/condenas/allxc'),
      headers: {'Content-Type': 'application/json'},
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Obtener los argumentos enviados a esta pantalla (curp, ciudadano)
    _futureCondenasAg = fetchCondenasAg();
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
                    const SizedBox(height: 20),
                    // --- Barra de Búsqueda ---
                    TextField(
                      controller: _searchController,
                      onSubmitted: (value) {
                        if (value.isEmpty) {
                          setState(() {
                            _futureCondenasAg = fetchCondenasAg();
                          });
                        } else {
                          setState(() {
                            _futureCondenasAg = fetchCondenasAgFil(value);
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
                        future: _futureCondenasAg,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (snapshot.hasError) {
                            return Center(
                              child: Text('Error: ${snapshot.error}'),
                            );
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
                            return const Center(
                              child: Text('No se encontraron condenas.'),
                            );
                          }

                          // Usamos directamente todas las condenas sin filtrar
                          final condenas = snapshot.data!;

                          return ListView.builder(
                            itemCount: condenas.length,
                            itemBuilder: (context, index) {
                              final c = condenas[index];
                              return InfoCard(
                                id: c['ID_Condena'].toString(),
                                asunto: c['Tipo'] ?? 'Sin tipo',
                                curp: c['CURP'] ?? '---',
                                estatus: "\$${c['Importe'] ?? '0'}",
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
                            icon: const Icon(Icons.library_books_outlined),
                            iconSize: 75.0,
                            color: Colors.black,
                            onPressed: () {
                              navigateWithLoading(
                                context,
                                '/informes',
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
  final String id;
  final String asunto;
  final String curp;
  final String estatus;

  const InfoCard({
    super.key,
    required this.id,
    required this.asunto,
    required this.curp,
    required this.estatus,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ID con icono de condena
            Row(
              children: [
                Icon(
                  Icons.gavel,
                  color: Colors.red,
                  size: 24.0,
                ),
                const SizedBox(width: 8),
                // Mostrar ID si es necesario, de lo contrario puedes omitirlo
                // Text(id), // Descomenta si quieres mostrar el ID
              ],
            ),
            
            // Información central - Usar Expanded para evitar overflow
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      asunto,
                      style: const TextStyle(
                        fontSize: 16, 
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2, // Limitar a 2 líneas
                      overflow: TextOverflow.ellipsis, // Puntos suspensivos si es muy largo
                    ),
                    const SizedBox(height: 4),
                    Text(
                      curp,
                      style: const TextStyle(
                        fontSize: 14, 
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            
            // Estatus - Aseguramos que no se desborde
            Flexible(
              child: Text(
                estatus,
                style: const TextStyle(
                  fontSize: 16, 
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
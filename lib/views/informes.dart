//import 'dart:nativewrappers/_internal/vm/lib/ffi_native_type_patch.dart';

import 'package:flutter/material.dart';
import '../helpers/loadpageperview.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io'; // Necesario para manejar archivos
import 'package:image_picker/image_picker.dart'; // Para seleccionar imágenes

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

  // --- Función para obtener Agentes de la API ---
  Future<List<dynamic>> fetchAgentes() async {
    final response = await http.get(
      Uri.parse('https://heimdall-qxbv.onrender.com/api/agentes/allm'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al cargar agentes');
    }
  }

   // --- Función para obtener ciudadanos de la API ---
  Future<List<dynamic>> fetchCiudadanos() async {
    final response = await http.get(
      Uri.parse('https://heimdall-qxbv.onrender.com/api/ciudadanos/all'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al cargar ciudadanos');
    }
  }

// --- Función para obtener Artículos del Código Penal ---
  Future<List<dynamic>> fetchArticulos() async {
    // CORRECCIÓN: Actualizamos la ruta a 'codigopenal/all'
    final response = await http.get(
      Uri.parse('https://heimdall-qxbv.onrender.com/api/codigopenal/all'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al cargar artículos');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _futureInformes = fetchInformes();
  }

  List<XFile> _selectedImages = []; // Para almacenar las imágenes seleccionadas

  void _showAddReportModal() {
    // Controladores para los campos del formulario
    final _fechaController = TextEditingController();
    final _calleController = TextEditingController();
    final _coloniaController = TextEditingController();
    final _numeroExteriorController = TextEditingController();
    final _ciudadController = TextEditingController();
    final _estadoController = TextEditingController();
    final _paisController = TextEditingController();
    final _descripcionController = TextEditingController();
    final _involucradosController = TextEditingController(); // Nuevo controlador
    final _agentesController = TextEditingController(); // Nuevo controlador

    _selectedImages.clear();
    bool isActivo = true; // Estado inicial del candado (Activo)

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder( // Usamos StatefulBuilder para actualizar el estado del modal
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Agregar Nuevo Informe'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // --- Icono de Candado Interactivo ---
                    GestureDetector(
                      onTap: () {
                        setState(() { // Cambia el estado al hacer clic
                          isActivo = !isActivo;
                        });
                      },
                      child: Icon(
                        isActivo ? Icons.lock_open : Icons.lock,
                        color: isActivo ? Colors.green : Colors.red,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Fecha',
                    ),
                    TextField(controller: _fechaController, decoration: const InputDecoration(labelText: 'Selecciona una fe')),
                    const Text(
                      'Dirección',
                      style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      ),
                    ),
                    // --- Campos del Formulario ---
                    TextField(controller: _calleController, decoration: const InputDecoration(labelText: 'Calle')),
                    TextField(controller: _coloniaController, decoration: const InputDecoration(labelText: 'Colonia')),
                    TextField(controller: _numeroExteriorController, decoration: const InputDecoration(labelText: 'Número Exterior')),
                    TextField(controller: _ciudadController, decoration: const InputDecoration(labelText: 'Ciudad')),
                    TextField(controller: _estadoController, decoration: const InputDecoration(labelText: 'Estado')),
                    TextField(controller: _paisController, decoration: const InputDecoration(labelText: 'País')),
                    const SizedBox(height: 15),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[300], // Color verde similar al boton '+' de la imagen
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          onPressed: () {
                            // Llamamos a la nueva ventana pasando los controladores
                            _showInvolucradosDialog(
                              context,
                              _involucradosController,
                              _agentesController,
                              _descripcionController
                            );
                          },
                          child: const Text('Gestionar informe', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    
                    TextField(controller: _descripcionController, decoration: const InputDecoration(labelText: 'Descripción')),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _addReport(
                      calle: _calleController.text,
                      colonia: _coloniaController.text,
                      numeroExterior: _numeroExteriorController.text,
                      ciudad: _ciudadController.text,
                      estado: _estadoController.text,
                      pais: _paisController.text,
                      descripcion: _descripcionController.text,
                      involucrados: _involucradosController.text, // Pasar valor
                      agentes: _agentesController.text, // Pasar valor
                      fotos: _selectedImages,
                      isActivo: isActivo, // Pasa el estado del candado
                    );
                    Navigator.of(context).pop();
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Nueva función para mostrar el diálogo de involucrados
  void _showInvolucradosDialog(
      BuildContext context,
      TextEditingController involucradosCtrl,
      TextEditingController agentesCtrl,
      TextEditingController descripcionCtrl) {
    
    showDialog(
      context: context,
      barrierDismissible: false, // Obliga a usar la X o Actualizar
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: const Color(0xFFE0E0E0), // Fondo gris claro
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0), // Bordes muy redondeados (Phone shape)
          ),
          child: Container(
            height: 600, // Altura fija para simular la pantalla
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              children: [
                // "Notch" decorativo superior
                Container(
                  width: 60,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 20),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // --- Tarjeta 1: Lista de Involucrados ---
                        _buildEstiloTarjeta(
                          label: "Lista de Involucrados",
                          controller: involucradosCtrl,
                          icon: Icons.add, // Icono + verde simulado
                          onIconPressed: () {
                            _showSeleccionarCiudadanos(context, involucradosCtrl);
                          },
                        ),
                        const SizedBox(height: 15),

                        // --- Tarjeta 2: Lista de Agentes ---
                       _buildEstiloTarjeta(
                          label: "Lista de Agentes\nInvolucrados",
                          controller: agentesCtrl,
                          maxLines: 4, // <--- MODIFICACIÓN: Caja más grande
                          icon: Icons.add, // <--- MODIFICACIÓN: Icono '+' activado
                          onIconPressed: () {
                             // <--- MODIFICACIÓN: Abrir modal de agentes
                            _showSeleccionarAgentes(context, agentesCtrl);
                          },
                        ),
                        const SizedBox(height: 15),

                        // --- Tarjeta 3: Descripción ---
                        _buildEstiloTarjeta(
                          label: "Descripción",
                          controller: descripcionCtrl,
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // --- Botón Actualizar (Azul claro) ---
                SizedBox(
                  width: 200,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC4D7FF), // Azul pastel similar a la imagen
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(); // Cierra el diálogo guardando lo escrito en los controllers
                    },
                    child: const Text(
                      "Actualizar",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // --- Botón X (Cerrar) ---
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(
                    Icons.close,
                    size: 50,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- Nuevo Modal: Lista de Ciudadanos (API) ---
  void _showSeleccionarCiudadanos(BuildContext context, TextEditingController controller) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: const Color(0xFFE0E0E0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          child: Container(
            height: 600,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              children: [
                 // Notch
                Container(
                  width: 60, height: 6,
                  decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(10)),
                ),
                const SizedBox(height: 20),
                
                // Título
                const Text("Seleccionar Ciudadano", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),

                // --- Contenedor Blanco con la Lista ---
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: FutureBuilder<List<dynamic>>(
                      future: fetchCiudadanos(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text("Error: ${snapshot.error}"));
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(child: Text("No hay ciudadanos registrados."));
                        }

                        final ciudadanos = snapshot.data!;
                        
                        return ListView.separated(
                          itemCount: ciudadanos.length,
                          separatorBuilder: (_, __) => const Divider(),
                          itemBuilder: (context, index) {
                          final c = ciudadanos[index];
                          
                          // CORRECCIÓN 1: Manejo de nulos para evitar "Luis null null"
                          // Si el dato es null, usamos una cadena vacía ''
                          String nombrePila = c['Nombre'] ?? '';
                          String paterno = c['Apellido_Paterno'] ?? '';
                          String materno = c['Apellido_Materno'] ?? '';
                          
                          // .trim() elimina espacios extra si falta algún apellido
                          final nombreCompleto = "$nombrePila $paterno $materno".trim();
                          
                          final curp = c['CURP'] ?? 'Sin CURP';

                          return ListTile(
                            leading: const Icon(Icons.person, color: Colors.blueGrey),
                            title: Text(nombreCompleto, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(curp),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                            onTap: () {
                              // CORRECCIÓN 2: En lugar de agregar directo, abrimos el nuevo modal
                              // Pasamos los datos del ciudadano y el controlador original
                              _showDetalleInvolucrado(context, c, controller);
                            },
                          );
                        },
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                
                // Botón X (Cerrar)
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(Icons.close, size: 50, color: Colors.black),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- Nuevo Modal: Detalle Involucrado (Diseño Image) ---
  void _showDetalleInvolucrado(BuildContext context, Map<String, dynamic> ciudadano, TextEditingController controllerParent) {
    // Preparamos los datos limpios
    String nombre = ciudadano['Nombre'] ?? '';
    String paterno = ciudadano['Apellido_Paterno'] ?? '';
    String materno = ciudadano['Apellido_Materno'] ?? '';
    String nombreCompleto = "$nombre $paterno $materno".trim();
    String curp = ciudadano['CURP'] ?? 'Sin CURP';

    // Lista temporal para almacenar los artículos que se agreguen en este modal
    List<String> articulosLocales = []; 

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Usamos StatefulBuilder para poder actualizar la lista de artículos dentro del modal
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return Dialog(
              backgroundColor: const Color(0xFFE0E0E0), // Fondo gris claro
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: Container(
                height: 650, 
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Notch decorativo
                    Container(
                      width: 60, height: 6,
                      decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(10)),
                    ),
                    const SizedBox(height: 20),

                    // --- Campo CURP (Solo lectura) ---
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        children: [
                          const Text("Curp Ciudadano", style: TextStyle(fontSize: 12, color: Colors.grey)),
                          Text(curp, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // --- Campo Nombre (Solo lectura) ---
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        children: [
                          const Text("Nombre Ciudadano", style: TextStyle(fontSize: 12, color: Colors.grey)),
                          Text(nombreCompleto, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // --- Caja Grande: Lista de Artículos ---
                    Expanded(
                      child: Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Center(
                                  child: Text("Lista de artículos", style: TextStyle(fontSize: 16, color: Colors.black87)),
                                ),
                                const Divider(),
                                Expanded(
                                  child: articulosLocales.isEmpty 
                                  ? const Center(child: Text("Sin artículos", style: TextStyle(color: Colors.grey)))
                                  : ListView.builder(
                                      itemCount: articulosLocales.length,
                                      itemBuilder: (ctx, idx) => Text("- ${articulosLocales[idx]}"),
                                    ),
                                ),
                              ],
                            ),
                          ),
                          // Botón flotante "+" dentro de la caja blanca
                          Positioned(
                            right: 10,
                            top: 10,
                            child: GestureDetector(
                              onTap: () {
                                // MODIFICACIÓN: Llamar al modal de Selección de Artículos
                                _showSeleccionarArticulos(context, (nuevoArticulo) {
                                  // Esta función se ejecuta cuando el usuario elige un artículo
                                  setStateModal(() {
                                    articulosLocales.add(nuevoArticulo);
                                  });
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFA5F2C8), // Verde pastel
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.add, color: Colors.black54),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // --- Botón Agregar Involucrados (Verde Grande) ---
                    SizedBox(
                      width: 200,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFA5F2C8), // Verde similar a la imagen
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        onPressed: () {
                        // 1. Recopilar texto existente en el controlador padre
                        String textoPrevio = controllerParent.text;
                        
                        // 2. Construir la cadena del nuevo ciudadano con sus artículos
                        // Formato: "JUAN PEREZ (CURP123) [Articulo1, Articulo2]"
                        String articulosString = articulosLocales.isEmpty 
                            ? "Sin artículos" 
                            : articulosLocales.join(" / ");

                        String nuevoRegistro = "$nombreCompleto ($curp)\n   -> Delitos: $articulosString";

                        // 3. Unir con lo que ya había
                        if (textoPrevio.isNotEmpty) {
                          controllerParent.text = "$textoPrevio\n\n$nuevoRegistro";
                        } else {
                          controllerParent.text = nuevoRegistro;
                        }

                        // 4. Cerrar el modal
                        Navigator.of(context).pop(); 
                        // Si se había cerrado el de selección antes, con este pop basta.
                      },
                        child: const Text(
                          "Agregar\nInvolucrados",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // --- Botón X (Cerrar) ---
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: const Icon(Icons.close, size: 40, color: Colors.black),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

// --- Nuevo Modal: Lista de Artículos (API) ---
  void _showSeleccionarArticulos(BuildContext context, Function(String) onArticuloSelected) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: const Color(0xFFE0E0E0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          child: Container(
            height: 600,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              children: [
                // Notch
                Container(
                  width: 60, height: 6,
                  decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(10)),
                ),
                const SizedBox(height: 20),

                // Título
                const Text("Seleccionar Artículo", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),

                // --- Contenedor Blanco con la Lista ---
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: FutureBuilder<List<dynamic>>(
                      future: fetchArticulos(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text("Error: ${snapshot.error}"));
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(child: Text("No hay artículos registrados."));
                        }

                        final articulos = snapshot.data!;

                        return ListView.separated(
                          itemCount: articulos.length,
                          separatorBuilder: (_, __) => const Divider(),
                          itemBuilder: (context, index) {
                            final a = articulos[index];

                            // CORRECCIÓN: Búsqueda robusta de datos
                            // 1. Intentamos obtener el NUMERO del artículo (puede venir como 'Articulo', 'id', etc.)
                            String numArticulo = (a['N_Articulo'] ?? a['N_Articulo']).toString();
                            
                            // 2. Intentamos obtener el NOMBRE o DESCRIPCIÓN (puede venir como 'Nombre', 'Delito', etc.)
                            String nombre = a['NombreArt'] ?? a['NombreArt'] ?? a['Delito'] ?? a['delito'] ?? 'Sin Nombre';
                            
                            // 3. Creamos el título combinado
                            String tituloMostrado = "Art. $numArticulo - $nombre";

                            return ListTile(
                              leading: const Icon(Icons.gavel, color: Colors.blueGrey), // Icono de mazo legal
                              title: Text(
                                tituloMostrado, 
                                style: const TextStyle(fontWeight: FontWeight.bold)
                              ),
                              // Si hay una descripción extra larga, la ponemos abajo, si no, no ponemos nada
                              subtitle: a['Descripcion'] != null 
                                  ? Text(a['Descripcion'].toString(), maxLines: 2, overflow: TextOverflow.ellipsis) 
                                  : null,
                              trailing: const Icon(Icons.add_circle_outline, color: Colors.green),
                              onTap: () {
                                Navigator.of(context).pop(); 

                                // Pasamos el objeto 'a' completo al siguiente modal
                                _showDetalleArticulo(context, a, (infoCompleta) {
                                  onArticuloSelected(infoCompleta);
                                });
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Botón X (Cerrar)
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(Icons.close, size: 50, color: Colors.black),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

 // --- Nuevo Modal: Detalle Específico del Artículo (Solo lectura Importe) ---
  void _showDetalleArticulo(BuildContext context, Map<String, dynamic> articuloData, Function(String) onGuardar) {
    
    // Obtener datos
    String numArticulo = (articuloData['N_Articulo'] ?? articuloData['articulo'] ?? articuloData['id'] ?? 'S/N').toString();
    String nombreArticulo = articuloData['NombreArt'] ?? articuloData['nombre'] ?? articuloData['Delito'] ?? 'Sin Nombre';
    String descripcionBase = articuloData['Descripcion'] ?? articuloData['descripcion'] ?? '';
    
    // NUEVO: Obtener importe fijo
    String importeFijo = (articuloData['Importe'] ?? articuloData['importe'] ?? articuloData['Multa'] ?? '0').toString();

    // Solo queda editable el tiempo y la descripción
    final TextEditingController _tiempoCtrl = TextEditingController();
    final TextEditingController _descCtrl = TextEditingController(text: descripcionBase);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: const Color(0xFFE0E0E0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
          child: Container(
            height: 650,
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: 60, height: 6,
                    decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(10)),
                  ),
                  const SizedBox(height: 20),

                  // 1. Número de Artículo (Solo lectura)
                  _buildReadOnlyField("Número de Artículo: $numArticulo"),
                  const SizedBox(height: 10),

                  // 2. Nombre Artículo (Solo lectura)
                  _buildReadOnlyField("Nombre: $nombreArticulo"),
                  const SizedBox(height: 10),

                  // 3. Importe (CAMBIO: AHORA ES SOLO LECTURA)
                  _buildReadOnlyField("Importe: \$$importeFijo"),
                  const SizedBox(height: 10),

                  // 4. Tiempo Condena (Sigue siendo editable)
                  _buildEditableField("Tiempo Condena", _tiempoCtrl),
                  const SizedBox(height: 10),

                  // 5. Descripción
                  Container(
                    height: 150,
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Descripción", style: TextStyle(color: Colors.grey, fontSize: 12)),
                        Expanded(
                          child: TextField(
                            controller: _descCtrl,
                            maxLines: 5,
                            decoration: const InputDecoration(border: InputBorder.none),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Botón Agregar
                  SizedBox(
                    width: 200,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFA5F2C8),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                      ),
                      onPressed: () {
                        // Armamos la cadena final usando el importe fijo
                        String infoFinal = "$nombreArticulo (Art. $numArticulo)";
                        
                        // Agregamos el importe fijo
                        infoFinal += " - Importe: \$$importeFijo";

                        // Agregamos tiempo si se escribió algo
                        if (_tiempoCtrl.text.isNotEmpty) infoFinal += " - Tiempo: ${_tiempoCtrl.text}";
                        
                        onGuardar(infoFinal);
                        Navigator.of(context).pop();
                      },
                      child: const Text("Agregar Artículo", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(Icons.close, size: 40, color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // --- Nuevo Modal: Lista de Agentes (API) ---
  void _showSeleccionarAgentes(BuildContext context, TextEditingController controller) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: const Color(0xFFE0E0E0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          child: Container(
            height: 600,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              children: [
                // Notch
                Container(
                  width: 60, height: 6,
                  decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(10)),
                ),
                const SizedBox(height: 20),

                // Título
                const Text("Seleccionar Agente", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),

                // --- Lista de Agentes ---
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: FutureBuilder<List<dynamic>>(
                      future: fetchAgentes(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text("Error: ${snapshot.error}"));
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return const Center(child: Text("No hay agentes disponibles."));
                        }

                        final agentes = snapshot.data!;

                        return ListView.separated(
                          itemCount: agentes.length,
                          separatorBuilder: (_, __) => const Divider(),
                          itemBuilder: (context, index) {
                            final a = agentes[index];
                            
                            // Construimos nombre y placa de forma segura
                            String nombre = a['Nombre'] ?? '';
                            String paterno = a['Apellido_Paterno'] ?? '';
                            String placa = a['N_Placa']?.toString() ?? 'Sin Placa';
                            String nombreCompleto = "$nombre $paterno".trim();

                            return ListTile(
                              leading: const Icon(Icons.badge, color: Colors.indigo), // Icono de placa
                              title: Text(nombreCompleto, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text("Placa: $placa"),
                              trailing: const Icon(Icons.add_circle_outline, color: Colors.green),
                              onTap: () {
                                // Lógica para agregar al input sin borrar lo anterior
                                String nuevoAgente = "$nombreCompleto (Placa: $placa)";
                                String textoActual = controller.text;

                                if (textoActual.isNotEmpty) {
                                  controller.text = "$textoActual\n$nuevoAgente";
                                } else {
                                  controller.text = nuevoAgente;
                                }
                                
                                Navigator.of(context).pop(); // Cierra el modal tras seleccionar
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Botón X (Cerrar)
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(Icons.close, size: 50, color: Colors.black),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Auxiliar para campos de solo lectura
  Widget _buildReadOnlyField(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), textAlign: TextAlign.center),
    );
  }

  // Auxiliar para campos editables
  Widget _buildEditableField(String label, TextEditingController ctrl) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: ctrl,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          hintText: label,
          border: InputBorder.none,
        ),
      ),
    );
  }

  // Helper para dibujar las tarjetas blancas de la imagen
  Widget _buildEstiloTarjeta({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
    IconData? icon,
    VoidCallback? onIconPressed,
  }) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: [
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              TextField(
                controller: controller,
                maxLines: maxLines,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "Escribir aquí...",
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        if (icon != null)
          Positioned(
            right: 10,
            top: 10,
            child: GestureDetector( // <--- Hacemos el icono clickeable
              onTap: onIconPressed,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Color(0xFFA5F2C8), // Verde pastel
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 20, color: Colors.black54),
              ),
            ),
          )
      ],
    );
  }

 

  Future<void> _addReport({
    required String calle,
    required String colonia,
    required String numeroExterior,
    required String ciudad,
    required String estado,
    required String pais,
    required String descripcion,
    required String involucrados, // Nuevo parámetro
    required String agentes, // Nuevo parámetro
    required List<XFile> fotos,
    required bool isActivo, // Recibe el estado del candado
  }) async {
    final url = Uri.parse('https://heimdall-qxbv.onrender.com/api/informes/add');
    var request = http.MultipartRequest('POST', url);

    Map<String, dynamic> datos = {
      'Estatus': isActivo ? 'A' : 'C', // Usa el estado del candado para el API
      'Fecha_Informe': DateTime.now().toIso8601String(),
      'Descripcion': descripcion,
      'Direccion': {
        'Calle': calle,
        'Colonia': colonia,
        'Numero_Exterior': numeroExterior,
        'Ciudad': ciudad,
        'Estado': estado,
        'Pais': pais,
      },
      'Informe_Agentes': agentes.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      'Informe_Involucrados': involucrados.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
    };

    // 2. Agrega los datos JSON como un campo 'datos'
    request.fields['datos'] = jsonEncode(datos);

    // 3. Agrega las fotos
    for (var imageFile in fotos) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'fotos', // El nombre del campo en el backend
          imageFile.path,
        ),
      );
    }

    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        setState(() {
          _futureInformes = fetchInformes();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Informe agregado con éxito')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al agregar informe: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de conexión: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final agente = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddReportModal,
        child: const Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
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
                              return InfoCard(
                                folio: c['_id'],
                                estatus: c['Estatus'] == 'A' ? 'Activo' : 'Inactivo',
                                fecha: c['Fecha_Informe'],
                                calle: c['Direccion']['Calle'] ?? 'No especificada',
                                colonia: c['Direccion']['Colonia'] ?? 'No especificada',
                                ciudad: c['Direccion']['Ciudad'] ?? 'No especificada',
                                estado: c['Direccion']['Estado'] ?? 'No especificado',
                                pais: c['Direccion']['Pais'] ?? 'No especificado',
                                descripcion: c['Descripcion'] ?? 'Sin descripción',
                                numeroExterior: c['Direccion']['Numero_Exterior'] ?? 'S/N',
                                involucrados: c['Informe_Involucrados'] ?? [],
                                agentes: c['Informe_Agentes'] ?? [],
                                fotos: c['Foto'] ?? []
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
  final String calle;
  final String colonia;
  final String ciudad;
  final String estado;
  final String pais;
  final String descripcion;
  final String numeroExterior;
  final List<dynamic> involucrados;
  final List<dynamic> agentes;
  final List<dynamic> fotos;

  const InfoCard({
    Key? key,
    required this.folio,
    required this.estatus,
    required this.fecha,
    required this.calle,
    required this.colonia,
    required this.ciudad,
    required this.estado,
    required this.pais,
    required this.descripcion,
    required this.numeroExterior,
    required this.involucrados,
    required this.agentes,
    required this.fotos,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final IconData statusIcon = estatus == 'Activo'
        ? Icons.lock_open
        : Icons.lock;

    final Color statusColor = estatus == 'Activo'
        ? Colors.green
        : Colors.red;

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              title: Column(
                children: [
                  
                  const Text(
                    'Detalles del Informe',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const Divider(thickness: 2),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Informe: $folio'),
                    const SizedBox(height: 10),
                    Text('Estatus: $estatus'),
                    const SizedBox(height: 10),
                    Text('Fecha: $fecha'),
                    const SizedBox(height: 10),
                    const Text(
                      'Dirección:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text('Calle: $calle'),
                    Text('Número Exterior: $numeroExterior'),
                    Text('Colonia: $colonia'),
                    Text('Ciudad: $ciudad'),
                    Text('Estado: $estado'),
                    Text('País: $pais'),
                    const SizedBox(height: 10),
                    const Text(
                      'Descripción:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(descripcion),
                    const SizedBox(height: 10),
                    const Text(
                      'Involucrados:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ...involucrados.map((inv) => Text('CURP: ${inv['CURP']}')),
                    const SizedBox(height: 10),
                    const Text(
                      'Agentes:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ...agentes.map((ag) => Text('Placa: ${ag['Num_Placa']}')),
                    if (fotos.isNotEmpty) ...[  
                      const SizedBox(height: 10),
                      const Text(
                        'Fotos:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      ...fotos.map((foto) => Text('URL: ${foto['URL']}')),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cerrar'),
                ),
              ],
            );
          },
        );
      },
      child: Card(
        elevation: 2.0,
        margin: const EdgeInsets.only(bottom: 16.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          child: Row(
            children: [
              Container(
                margin: const EdgeInsets.only(right: 16.0),
                child: Icon(statusIcon, color: statusColor, size: 32.0),
              ),
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
      ),
    );
  }
}

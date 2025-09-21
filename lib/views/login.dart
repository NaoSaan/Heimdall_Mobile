import 'package:flutter/material.dart';
import 'package:heimdall_flutter/views/condenasciu.dart';
import 'package:heimdall_flutter/views/menu.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  static const String routeName = '/login';
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  bool _isLoading = false;
  final TextEditingController _user = TextEditingController();
  final TextEditingController _pwd = TextEditingController();

  Future<void> login() async {
    final String user = _user.text;
    final String pwd = _pwd.text;

    if (user.isEmpty || pwd.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (!validarCurp(user)) {
        final response = await http.post(
          Uri.parse('https://heimdall-qxbv.onrender.com/api/auth/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'N_Placa': user, 'password': pwd}),
        );
        final data = jsonDecode(response.body);

        if (response.statusCode == 200) {
          final agenteData = data['agente'];
          final nombre = agenteData['Nombre'];
          final aP = agenteData['APaterno'];
          final aM = agenteData['AMaterno'];
          final agente = "$nombre $aP $aM";
          Navigator.pushNamed(context, MenuScreen.routeName, arguments: agente);
        } else {
          final messageAPI = data['message'] ?? 'Error desconocido';
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $messageAPI')));
        }
      } else {
        final response = await http.post(
          Uri.parse('https://heimdall-qxbv.onrender.com/api/auth/loginCiu'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'CURP': user, 'password': pwd}),
        );
        final data = jsonDecode(response.body);

        if (response.statusCode == 200) {
          final nombre = data['Nombre'];
          final aP = data['APaterno'];
          final aM = data['AMaterno'];
          final ciudadano = "$nombre $aP $aM";
          Navigator.pushNamed(context, CondenasCiuScreen.routeName, arguments: ciudadano);
        } else {
          final messageAPI = data['message'] ?? 'Error desconocido';
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $messageAPI')));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error de conexión: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE7E7E7),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('lib/assets/images/logo.jpeg', width: 200, height: 250),

            // Input de usuario
            SizedBox(
              width: 300,
              height: 60,
              child: TextField(
                controller: _user,
                decoration: InputDecoration(
                  labelText: 'Usuario',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Input de contraseña
            SizedBox(
              width: 300,
              height: 60,
              child: TextField(
                controller: _pwd,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: 160,
              height: 45,
              child: ElevatedButton(
                onPressed: _isLoading ? null : login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Iniciar sesión',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

bool validarCurp(String curp) {
  final RegExp curpRegex = RegExp(
    r'^[A-Z]{1}[AEIOU]{1}[A-Z]{2}[0-9]{2}'
    r'(0[1-9]|1[0-2])'
    r'(0[1-9]|[12][0-9]|3[01])'
    r'[HM]{1}'
    r'(AS|BC|BS|CC|CL|CM|CS|CH|DF|DG|GT|GR|HG|JC|MC|MN|MS|NT|NL|OC|PL|QT|QR|SP|SL|SR|TC|TL|TS|VZ|YN|ZS|NE)'
    r'[B-DF-HJ-NP-TV-Z]{3}'
    r'[0-9A-Z]{1}'
    r'[0-9]{1}$',
  );
  return curpRegex.hasMatch(curp);
}

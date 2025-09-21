import 'package:flutter/material.dart';
import 'views/login.dart';
import 'views/condenas.dart';
import 'views/informes.dart';
import 'views/menu.dart';
import 'views/condenasciu.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Heimdall',
      initialRoute: LoginScreen.routeName,
      debugShowCheckedModeBanner: false,
      routes: {
        LoginScreen.routeName: (context) => const LoginScreen(),
        CondenasScreen.routeName: (context) => const CondenasScreen(),
        InformesScreen.routeName: (context) => const InformesScreen(),
        MenuScreen.routeName: (context) => const MenuScreen(),
        CondenasCiuScreen.routeName: (context) => const CondenasCiuScreen()
      },
    );
  }
}

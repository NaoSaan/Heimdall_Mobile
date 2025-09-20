import 'package:flutter/material.dart';

class MenuScreen extends StatelessWidget {
  static const String routeName = '/menu';
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menú'),
      ),
      body: const Center(
        child: Text('Bienvenido al menú'),
      ),
    );
  }
}
import 'package:flutter/material.dart';

class CondenasCiuScreen extends StatelessWidget {
  static const String routeName = '/condenasciu';
  const CondenasCiuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Multas'),
      ),
      body: const Center(
        child: Text('Multas ciudadanos'),
      ),
    );
  }
}
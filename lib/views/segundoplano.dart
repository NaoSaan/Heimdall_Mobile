import 'package:flutter/material.dart';
import '../main.dart';
import 'loadpage.dart';

class SecondPlaneHandler extends StatefulWidget {
  final Widget child;

  const SecondPlaneHandler({super.key, required this.child});

  @override
  State<SecondPlaneHandler> createState() => _SecondPlaneHandlerState();
}

class _SecondPlaneHandlerState extends State<SecondPlaneHandler> with WidgetsBindingObserver {
  DateTime? _pausedTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _pausedTime = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      if (_pausedTime != null) {
        final difference = DateTime.now().difference(_pausedTime!).inSeconds;
        if (difference > 10) {
          // Usar navigatorKey para reiniciar la app
          navigatorKey.currentState?.pushNamedAndRemoveUntil(
            Loadpage.routeName,
            (route) => false,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

import 'package:flutter/material.dart';
import 'package:heimdall_flutter/views/loadpage.dart';
import 'views/login.dart';
import 'views/condenas.dart';
import 'views/informes.dart';
import 'views/menu.dart';
import 'views/condenasciu.dart';
import 'views/segundoplano.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:heimdall_flutter/secret/stripe_key.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
    // Inicializa Stripe con tu clave pública
  Stripe.publishableKey = publishableKey; // clave pública
  await Stripe.instance.applySettings(); // configuración de Stripe
  runApp(
     ProviderScope( // para que funcione el pago con Riverpod
      child: SecondPlaneHandler(
        child: const MyApp(),
      ),
    ),
  );
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Heimdall',
      initialRoute: Loadpage.routeName,
      debugShowCheckedModeBanner: false,
      routes: {
        LoginScreen.routeName: (context) => const LoginScreen(),
        CondenasScreen.routeName: (context) => const CondenasScreen(),
        InformesScreen.routeName: (context) => const InformesScreen(),
        MenuScreen.routeName: (context) => const MenuScreen(),
        CondenasCiuScreen.routeName: (context) => const CondenasCiuScreen(),
        Loadpage.routeName: (context) => const Loadpage(),
      },
    );
  }
}

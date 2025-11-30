import 'package:flutter/material.dart';
import 'neumorphism_theme.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'payments_screen.dart';
import 'activities_screen.dart';
import 'observations_screen.dart';
import 'app_dimensions.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: Neumorphism.themeData,
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/pagos': (context) => const PaymentsScreen(),
        '/actividades': (context) => const ActivitiesScreen(),
        '/observaciones': (context) => const ObservationsScreen(),
      },
    );
  }
}

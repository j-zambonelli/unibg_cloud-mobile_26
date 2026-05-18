import 'package:flutter/material.dart';
import 'screens/login_screen.dart'; // Importa la schermata di login

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TEDexplore',
      debugShowCheckedModeBanner: false, // Rimuove la striscia di debug in alto a destra
      theme: ThemeData(
        brightness: Brightness.dark, // Imposta un tema scuro nativo globale
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE74A32),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const LoginScreen(), // La prima pagina visualizzata sarà il Login
    );
  }
}
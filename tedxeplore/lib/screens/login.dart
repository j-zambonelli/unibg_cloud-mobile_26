import 'package:flutter/material.dart';
import 'main_wrapper.dart'; // Importa il nuovo wrapper invece di home.dart

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text.rich(
                TextSpan(
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(text: "TED", style: TextStyle(color: Color(0xFFEB0028))),
                    TextSpan(text: "xplore", style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Dai libri alle idee. Connetti il tuo Kindle per rompere la bolla culturale.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 48),
              
              // Bottone Login con Amazon
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9900),
                  foregroundColor: Colors.black,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.import_contacts), 
                label: const Text(
                  'Login with Amazon',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  // Sostituisce lo schermo corrente con il MainWrapper
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => const MainWrapper()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
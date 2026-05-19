import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        title: const Text('TEDexplore Dashboard'),
        backgroundColor: const Color(0xFFE74A32),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Consigliati per te dal tuo Kindle',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Lista dei Talk (Simulata per ora in attesa delle Lambda)
            Expanded(
              child: ListView.builder(
                itemCount: 3, // Per ora mostriamo 3 elementi finti
                itemBuilder: (context, index) {
                  return Card(
                    color: const Color(0xFF222222),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: const Icon(Icons.video_library, color: Color(0xFFE74A32)),
                      title: Text(
                        'Talk di Esempio #${index + 1}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text(
                        'Descrizione breve del talk estratto dal database...',
                        style: TextStyle(color: Colors.white70),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16),
                      onTap: () {
                        // Qui gestiremo l'apertura e la funzionalità Watch Next
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
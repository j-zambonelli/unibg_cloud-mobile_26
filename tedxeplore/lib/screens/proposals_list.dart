import 'package:flutter/material.dart';
import 'package:tedxeplore/components/video_card.dart'; // Sfrutta il tuo componente card

class ProposalsScreen extends StatelessWidget {
  final String genereIniziale;

  const ProposalsScreen({
    super.key, 
    required this.genereIniziale,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          'Proposte: $genereIniziale',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: 12, // Visualizza l'intero parco video per quel genere
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,       // Griglia a 2 colonne
            crossAxisSpacing: 14,    // Spaziatura orizzontale
            mainAxisSpacing: 14,     // Spaziatura verticale
            childAspectRatio: 0.82,  // Ottimizzato per non tagliare titoli e durata della tua card
          ),
          itemBuilder: (context, index) {
            return TedxVideoCard(
              title: 'Talk di approfondimento su $genereIniziale #${index + 1}',
              speaker: 'Speaker TEDx',
              imageUrl: 'https://picsum.photos/seed/proposals_${genereIniziale}_$index/300/200',
              duration: '15:45',
              onTap: () => print('In riproduzione da griglia: $index'),
            );
          },
        ),
      ),
    );
  }
}
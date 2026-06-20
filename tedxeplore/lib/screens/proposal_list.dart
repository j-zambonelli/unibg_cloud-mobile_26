import 'package:flutter/material.dart';
import '../components/video_card.dart';
import '../models/profile_model.dart';

class ProposalsScreen extends StatelessWidget {
  final List<String> favoriteIds;
  final Function(String) onToggleFavorite;
  final UserProfileData userProfile; // Riceve correttamente l'intero profilo

  const ProposalsScreen({
    super.key, 
    required this.favoriteIds,
    required this.onToggleFavorite,
    required this.userProfile,
  });

  @override
  Widget build(BuildContext context) {
    // CORRETTO: rimosso "widget." perché siamo in uno StatelessWidget
    final List<String> tuttiIGeneri = userProfile.percentualiGeneri.keys.toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C1E),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Tutte le Proposte', 
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: 15, // Mostra il mix completo dei 5 generi
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 0.76, 
          ),
          itemBuilder: (context, index) {
            // Distribuisce ciclicamente i video tra tutti i generi attivi dell'account
            final genereCorrente = tuttiIGeneri.isNotEmpty 
                ? tuttiIGeneri[index % tuttiIGeneri.length] 
                : "Consigliati";
                
            final String videoId = 'grid_mix_video_$index';
            
            return TedxVideoCard(
              title: 'Approfondimento di livello su $genereCorrente #${(index ~/ tuttiIGeneri.length) + 1}',
              speaker: 'TEDx Speaker',
              imageUrl: 'https://picsum.photos/seed/mix_proposal_$index/300/200',
              duration: '${12 + index}:30',
              views: '${10 + index * 4}K',
              year: '2026',
              isFavorite: favoriteIds.contains(videoId),
              onTap: () {},
              onToggleFavorite: () => onToggleFavorite(videoId),
            );
          },
        ),
      ),
    );
  }
}
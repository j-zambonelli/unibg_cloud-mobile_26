import 'package:flutter/material.dart';
import 'package:tedxeplore/components/category_wheel.dart';
import 'package:tedxeplore/components/video_card.dart';
import 'package:tedxeplore/screens/proposals_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late String genereSelezionato;

  final List<Map<String, dynamic>> generiData = [
    {'nome': 'Scienza', 'tagDatabase': ['science', 'biology', 'nature', 'animals'],'percentuale': 0.02, 'colore': Colors.grey },
    {'nome': 'Tecnologia e Ingegneria', 'tagDatabase': ['technology', 'innovation', 'future', 'engineering', 'computers'],'percentuale': 0.02, 'colore': Colors.grey },
    {'nome': 'Medicina e Corpo umano', 'tagDatabase': ['health', 'medicine', 'brain', 'health care', 'human body'],'percentuale': 0.02, 'colore': Colors.grey },
    {'nome': 'Core', 'tagDatabase': ['business', 'work', 'economics', 'history', 'education'],'percentuale': 0.02, 'colore': Colors.grey },
    {'nome': 'Crescita professionale', 'tagDatabase': ['leadership', 'collaboration', 'marketing'],'percentuale': 0.02, 'colore': Colors.grey },
    {'nome': 'Mente e Comportamento', 'tagDatabase': ['psychology', 'brain', 'identity'],'percentuale': 0.02, 'colore': Colors.grey },
    {'nome': 'Sviluppo personale', 'tagDatabase': ['personal growth', 'creativity', 'storytelling'],'percentuale': 0.03, 'colore': Colors.grey },
    {'nome': 'Società e cultura', 'tagDatabase': ['social change', 'culture', 'society', 'humanity', 'community'],'percentuale': 0.08, 'colore': Colors.grey },
    {'nome': 'Politica e istruzione', 'tagDatabase': ['politics', 'government', 'activism', 'women'],'percentuale': 0.07, 'colore': Colors.grey },
    {'nome': 'Ambiente e sostenibilità', 'tagDatabase': ['climate change', 'environment', 'sustainability', 'Countdown'],'percentuale': 0.15, 'colore': Colors.grey },
    {'nome': 'Scenari globali', 'tagDatabase': ['global issue'],'percentuale': 0.08, 'colore': Colors.grey },
    {'nome': 'Narrazione', 'tagDatabase': ['humanity', 'identity'],'percentuale': 0.14, 'colore': Colors.grey },
    {'nome': 'Arti visive e performative', 'tagDatabase': ['design', 'art', 'entertainment', 'music', 'performance'],'percentuale': 0.31, 'colore': Colors.grey },
    {'nome': 'Contenuti multimediali', 'tagDatabase': ['animation', 'media'],'percentuale': 0.01, 'colore': Colors.grey },
  ];

  Map<String,String> traduzione = {
  };

  @override
  void initState() {
    super.initState();
    generiData.sort((a, b) => b['percentuale'].compareTo(a['percentuale']));
    genereSelezionato = generiData.first['nome'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: RichText(
          text: const TextSpan(
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            children: [
              TextSpan(text: "TED", style: TextStyle(color: Color(0xFFEB0028))),
              TextSpan(text: "xplore", style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            CategoryWheel(
              generiData: generiData,
              genereSelezionato: genereSelezionato,
              onCategorySelected: (nuovoGenere) {
                setState(() {
                  genereSelezionato = nuovoGenere;
                });
              },
            ),

            const SizedBox(height: 30),
            const Divider(color: Color(0xFF222222)),
            const SizedBox(height: 16),

            _buildSectionHeader(
              title: 'Per te',
              subtitle: 'Ispirati ai tuoi libri di $genereSelezionato',
              showSeeMore: true,
              onSeeMorePressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ProposalsScreen(genereIniziale: genereSelezionato),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 205, // Altezza per riga singola pulita
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 6,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 14.0),
                    child: TedxVideoCard(
                      title: 'Talk consigliato su $genereSelezionato #${index + 1}',
                      speaker: 'Speaker TEDx',
                      imageUrl: 'https://picsum.photos/seed/home_perte_${genereSelezionato}_$index/300/200',
                      duration: '14:20',
                      onTap: () => print('Cliccato per te $index'),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 32),

            // 3. RIGA DI "NOVITÀ" SCORREVOLE (Fissa a 10 elementi, senza espansione)
            _buildSectionHeader(
              title: 'Novità della settimana',
              subtitle: 'Gli ultimi talk pubblicati da non perdere',
              showSeeMore: false,
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 205,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 10, // Massimo 10 fissi
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 14.0),
                    child: TedxVideoCard(
                      title: 'Nuovissimo Talk di questa settimana #${index + 1}',
                      speaker: 'Nuovo Speaker',
                      imageUrl: 'https://picsum.photos/seed/home_novita_$index/300/200',
                      duration: '12:40',
                      onTap: () => print('Cliccato novità $index'),
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    required bool showSeeMore,
    VoidCallback? onSeeMorePressed,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              if (showSeeMore)
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 18),
                  onPressed: onSeeMorePressed,
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
          child: Text(
            subtitle,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ),
      ],
    );
  }
}
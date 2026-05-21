import 'dart:math';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, dynamic>> generiData = const [
    {
      "nome": "Saggistica",
      "sigla": "SAGGISTICA",
      "colore": Color.fromARGB(255, 123, 122, 122),
      "percentuale": 0.02,
    },
    {
      "nome": "Scienza e Tecnologia",
      "sigla": "SCIENZA E TECNOLOGIA",
      "colore": Color.fromARGB(255, 123, 122, 122),
      "percentuale": 0.10,
    },
    {
      "nome": "Biografie",
      "sigla": "BIOGRAFIE",
      "colore": Color.fromARGB(255, 123, 122, 122),
      "percentuale": 0.18,
    },
    {
      "nome": "Self-help",
      "sigla": "SELF-HELP",
      "colore": Color.fromARGB(255, 123, 122, 122),
      "percentuale": 0.30,
    },
    {
      "nome": "Economia",
      "sigla": "ECONOMIA",
      "colore": Color.fromARGB(255, 123, 122, 122),
      "percentuale": 0.15,
    },
    {
      "nome": "Thriller",
      "sigla": "THRILLER",
      "colore": Color.fromARGB(255, 123, 122, 122),
      "percentuale": 0.25,
    },
  ];

  String genereSelezionato = "Saggistica";

  @override
  Widget build(BuildContext context) {
    List<Color> coloriArco = generiData
        .map((g) => g['colore'] as Color)
        .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              fontFamily: 'Urbanist',
            ),
            children: [
              TextSpan(
                text: "TED",
                style: TextStyle(color: Colors.red),
              ),
              TextSpan(
                text: "xplore",
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              const Text(
                "I tuoi generi prediletti",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),

              // ================= IL GRAFICO AD ARCO REATTIVO =================
              Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(350, 170),
                    painter: ArcoGeneriPainter(
                      generi: generiData,
                      genereAttivo: genereSelezionato,
                    ),
                  ),
                  Positioned(
                    bottom: 15,
                    child: Column(
                      children: [
                        Text(
                          genereSelezionato.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "${(generiData.firstWhere((g) => g['nome'] == genereSelezionato)['percentuale'] * 100).toInt()}%",
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 35),

              // ================= LE CHIPS PULITE (SENZA PERCENTUALE) =================
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 10.0,
                runSpacing: 10.0,
                children: generiData.map((genere) {
                  final bool isSelected = genere['nome'] == genereSelezionato;
                  final Color coloreGenere = genere['colore'];

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        genereSelezionato = genere['nome'];
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFEB0028)
                            : const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isSelected
                              ? Colors.white
                              : coloreGenere.withOpacity(0.3),
                          width: isSelected ? 1.8 : 1.2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            genere['nome'],
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.grey[300],
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 40),
              const Divider(color: Color(0xFF222222)),
              const SizedBox(height: 20),

              // ================= SEZIONE CONTENUTI SUGGERITI =================
              Row(
                children: [
                  Text(
                    "Per te: $genereSelezionato",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 2, // Mostriamo due card per genere di esempio
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[900]!),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.play_circle_outline,
                        color: generiData.firstWhere(
                          (g) => g['nome'] == genereSelezionato,
                        )['colore'],
                        size: 36,
                      ),
                    ),
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

class ArcoGeneriPainter extends CustomPainter {
  final List<Map<String, dynamic>> generi;
  final String genereAttivo; //

  ArcoGeneriPainter({required this.generi, required this.genereAttivo});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth =
          12.0 // Spessore premium per l'arco
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height * 2);

    double totaleAngolo = pi; // 180 gradi
    double startAngle = pi; // Inizia da sinistra

    for (var genere in generi) {
      double percentuale = genere['percentuale'];
      double ampiezzaSpicchio = totaleAngolo * percentuale;

      // LA LOGICA DI ACCENSIONE:
      // Se questo spicchio è quello attivo, si accende di Rosso TEDx, altrimenti diventa grigio scuro
      if (genere['nome'] == genereAttivo) {
        paint.color = const Color(0xFFEB0028); // Rosso iconico TEDx
      } else {
        paint.color = const Color(
          0xFF2A2A2A,
        ); // Grigio scuro per le fette "spente"
      }

      // Disegna il singolo segmento dell'arco
      canvas.drawArc(rect, startAngle, ampiezzaSpicchio, false, paint);

      // Avanza con l'angolo per il prossimo spicchio
      startAngle += ampiezzaSpicchio;
    }
  }

  @override
  bool shouldRepaint(covariant ArcoGeneriPainter oldDelegate) {
    // Si ridisegna ogni volta che il genere attivo cambia
    return oldDelegate.genereAttivo != genereAttivo;
  }
}

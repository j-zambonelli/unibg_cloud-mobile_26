import 'dart:math';
import 'package:flutter/material.dart';

class CategoryWheel extends StatelessWidget {
  final List<Map<String, dynamic>> generiData;
  final String genereSelezionato;
  final ValueChanged<String> onCategorySelected;

  const CategoryWheel({
    super.key,
    required this.generiData,
    required this.genereSelezionato,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    // Cerca il genere attuale in modo sicuro per evitare eccezioni di Null
    final genereAttualeData = generiData.firstWhere(
      (g) => g['nome'].toString().toLowerCase() == genereSelezionato.toLowerCase(),
      orElse: () => generiData.first,
    );

    final List<Map<String, dynamic>> generiOrdinati = List<Map<String,dynamic>>.from(generiData)..sort((a,b) => b['percentuale'].compareTo(a['percentuale']));
    final List<Map<String, dynamic>> top5Chips = generiOrdinati.take(5).toList();


    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: SizedBox(
            width: 350,
            height: 170,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size(350, 170),
                  painter: ArcoGeneriPainter(
                    generi: generiData,
                    genereActivo: genereSelezionato,
                  ),
                ),
                Positioned(
                  bottom: 15,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        genereSelezionato.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "${(genereAttualeData['percentuale'] * 100).toInt()}%",
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 25),

        // 2. STRUTTURA DELLE CHIPS ADATTIVA SU UNA SOLA RIGA
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: top5Chips.map((genere) {
              final bool isSelected = genere['nome'].toString().toLowerCase() == genereSelezionato.toLowerCase();
              
              final Color coloreGenere = (genere['colore'] is Color) 
                  ? genere['colore'] as Color 
                  : Colors.grey;

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3.0),
                  child: GestureDetector(
                    onTap: () => onCategorySelected(genere['nome']),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFEB0028) : const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isSelected ? Colors.white : coloreGenere.withOpacity(0.3),
                          width: isSelected ? 1.8 : 1.2,
                        ),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          genere['nome'],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey[300],
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class ArcoGeneriPainter extends CustomPainter {
  final List<Map<String, dynamic>> generi;
  final String genereActivo;

  ArcoGeneriPainter({required this.generi, required this.genereActivo});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12.0
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height * 2);
    double totaleAngolo = pi; 
    double startAngle = pi; 

    for (var genere in generi) {
      double percentuale = genere['percentuale'];
      double ampiezzaSpicchio = totaleAngolo * percentuale;

      paint.color = (genere['nome'].toString().toLowerCase() == genereActivo.toLowerCase())
          ? const Color(0xFFEB0028)
          : const Color(0xFF2A2A2A);

      canvas.drawArc(rect, startAngle, ampiezzaSpicchio, false, paint);
      startAngle += ampiezzaSpicchio;
    }
  }

  @override
  bool shouldRepaint(covariant ArcoGeneriPainter oldDelegate) {
    return oldDelegate.genereActivo != genereActivo;
  }
}
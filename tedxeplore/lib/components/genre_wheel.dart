import 'dart:math' as math;
import 'package:flutter/material.dart';

class GenreWheel extends StatelessWidget {
  final List<Map<String, dynamic>> genres;
  final String? selectedGenreId;

  const GenreWheel({super.key, required this.genres, required this.selectedGenreId});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(320, 150), // Leggermente più larga e bassa per armonia
      painter: WheelPainter(genres: genres, selectedGenreId: selectedGenreId),
    );
  }
}

class WheelPainter extends CustomPainter {
  final List<Map<String, dynamic>> genres;
  final String? selectedGenreId;

  WheelPainter({required this.genres, required this.selectedGenreId});

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height - 10);
    const double radius = 125.0; // Raggio aumentato
    const double strokeWidth = 14.0; // Molto più fine (prima era 32)
    final Rect rect = Rect.fromCircle(center: center, radius: radius);

    double currentAngle = math.pi;

    for (var genre in genres) {
      final double percentage = (genre['percentage'] as num).toDouble() / 100.0;
      final double sweepAngle = percentage * math.pi;
      final bool isSelected = genre['id'] == selectedGenreId;

      final Paint paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round // Arrotonda perfettamente le estremità
        ..color = isSelected ? const Color(0xFFFF3B30) : const Color(0xFF2C2C2E)
        ..isAntiAlias = true;

      canvas.drawArc(rect, currentAngle, sweepAngle, false, paint);

      if (isSelected && genre['percentage'] > 0) {
        final double middleAngle = currentAngle + (sweepAngle / 2);
        final double textX = center.dx + (radius + 22) * math.cos(middleAngle);
        final double textY = center.dy + (radius + 22) * math.sin(middleAngle);

        final textPainter = TextPainter(
          text: TextSpan(
            text: '${genre['percentage']}%',
            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        
        textPainter.paint(canvas, Offset(textX - textPainter.width / 2, textY - textPainter.height / 2));
      }
      currentAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant WheelPainter oldDelegate) => true;
}
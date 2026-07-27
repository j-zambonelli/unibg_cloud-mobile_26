import 'package:flutter/material.dart';

class GenreChips extends StatelessWidget {
  final List<Map<String, dynamic>> genres;
  final String? selectedGenreId;
  final Function(String) onSelectGenre;

  const GenreChips({
    super.key,
    required this.genres,
    required this.selectedGenreId,
    required this.onSelectGenre,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36, 
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: genres.length,
        itemBuilder: (context, index) {
          final genre = genres[index];
          final bool isSelected = genre['id'] == selectedGenreId;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              onTap: () => onSelectGenre(genre['id']),
              borderRadius: BorderRadius.circular(8),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFFF3B30) : const Color(0xFF1C1C1E),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  genre['name'],
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF8E8E93),
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    letterSpacing: -0.1, 
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
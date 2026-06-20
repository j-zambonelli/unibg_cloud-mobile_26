import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ThemeManagementScreen extends StatefulWidget {
  const ThemeManagementScreen({super.key});

  @override
  State<ThemeManagementScreen> createState() => _ThemeManagementScreenState();
}

class _ThemeManagementScreenState extends State<ThemeManagementScreen> {
  int _selectedThemeIndex = 0; 

  final List<Map<String, dynamic>> _temi = [
    {'nome': 'Scuro Puro (OLED)', 'desc': 'Nero assoluto per display AMOLED'},
    {'nome': 'Grigio Notte', 'desc': 'Tonalità scure soffuse stile iOS'},
    {'nome': 'Chiaro', 'desc': 'Interfaccia ad alta luminosità'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C1E),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Temi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.only(left: 8.0, bottom: 6.0),
              child: Text('OPZIONI TEMA', style: TextStyle(color: Color(0xFF8E8E93), fontSize: 13, fontWeight: FontWeight.w500)),
            ),
            
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1E),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _temi.length,
                separatorBuilder: (c, i) => Divider(height: 0.5, thickness: 0.5, indent: 16, color: Colors.white.withOpacity(0.1)),
                itemBuilder: (context, index) {
                  final tema = _temi[index];
                  final bool isSelected = _selectedThemeIndex == index;
                  
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    title: Text(tema['nome'], style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                    subtitle: Text(tema['desc'], style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 13)),
                    trailing: isSelected 
                        ? const Icon(CupertinoIcons.checkmark, color: Color(0xFFFF3B30), size: 20) 
                        : null,
                    onTap: () {
                      setState(() {
                        _selectedThemeIndex = index;
                      });
                    },
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
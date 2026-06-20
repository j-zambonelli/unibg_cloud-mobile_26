import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../models/profile_model.dart';
import 'theme_management.dart';

class SettingsScreen extends StatelessWidget {
  final UserProfileData userProfile;

  const SettingsScreen({super.key, required this.userProfile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C1E),
        elevation: 0,
        title: const Text(
          'Impostazioni',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            
            const Padding(
              padding: EdgeInsets.only(left: 8.0, bottom: 6.0),
              child: Text(
                'INTERFACCIA', 
                style: TextStyle(color: Color(0xFF8E8E93), fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1E),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ListTile(
                leading: const Icon(CupertinoIcons.paintbrush, color: Color(0xFFFF3B30)),
                title: const Text('Gestione Temi', style: TextStyle(color: Colors.white, fontSize: 16)),
                trailing: const Icon(CupertinoIcons.chevron_forward, color: Color(0xFF8E8E93), size: 18),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const ThemeManagementScreen()),
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
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/profile_model.dart';
import 'login.dart';

class ProfileScreen extends StatefulWidget {
  final UserProfileData userProfile;

  const ProfileScreen({super.key, required this.userProfile});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;

  final int _videoVistiCount = 24;
  final int _likeCount = 12;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF151517), 
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              
              Stack(
                alignment: Alignment.center,
                children: [
                  const Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Account',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Serif', 
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color(0xFF2C2C2E),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          CupertinoIcons.xmark,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 28),

              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF242426), 
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3A3A3C),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.05)),
                      ),
                      child: const Icon(
                        CupertinoIcons.person_fill,
                        color: Color(0xFF8E8E93),
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.userProfile.username,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.userProfile.email,
                            style: const TextStyle(
                              color: Color(0xFF8E8E93),
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),
              
              const Padding(
                padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
                child: Text(
                  'ATTIVITÀ',
                  style: TextStyle(
                    color: Color(0xFF8E8E93),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF242426),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(CupertinoIcons.play_circle, color: Colors.white),
                      title: const Text('Visti', style: TextStyle(color: Colors.white, fontSize: 16)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('$_videoVistiCount', style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 16)),
                          const SizedBox(width: 6),
                          const Icon(CupertinoIcons.chevron_forward, color: Color(0xFF3A3A3C), size: 16),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 56.0),
                      child: Container(height: 0.5, color: Colors.white.withOpacity(0.05)),
                    ),
                    ListTile(
                      leading: const Icon(CupertinoIcons.heart, color: Colors.white),
                      title: const Text('Mi piace', style: TextStyle(color: Colors.white, fontSize: 16)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('$_likeCount', style: const TextStyle(color: Color(0xFF8E8E93), fontSize: 16)),
                          const SizedBox(width: 6),
                          const Icon(CupertinoIcons.chevron_forward, color: Color(0xFF3A3A3C), size: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF242426),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  leading: const Icon(CupertinoIcons.bell, color: Colors.white),
                  title: const Text('Avvisi nuovi video', style: TextStyle(color: Colors.white, fontSize: 16)),
                  trailing: CupertinoSwitch(
                    value: _notificationsEnabled,
                    activeColor: const Color(0xFFFF3B30), // Rosso Apple
                    onChanged: (bool value) {
                      setState(() {
                        _notificationsEnabled = value;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 32),

              GestureDetector(
                onTap: () async {
                  final SharedPreferences prefs = await SharedPreferences.getInstance();
                  await prefs.remove('amazon_user_token');

                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF242426),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Text(
                      'Esci',
                      style: TextStyle(
                        color: Color(0xFFFF3B30),
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
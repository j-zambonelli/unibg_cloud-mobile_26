import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main_wrapper.dart';
import '../services/aws_service.dart';
import '../models/profile_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoggingIn = false;
  final AwsService _awsService = AwsService();

  Future<void> _handleAmazonLogin(BuildContext context) async {
    setState(() => _isLoggingIn = true);

    try {
      String accountAmazonToken = "amzn1.oa2-cs.v1.tedxplore_token_unibg";

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('amazon_user_token', accountAmazonToken);

      UserProfileData profile = await _awsService.fetchUserProfile(accountAmazonToken);

      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => MainWrapper(userProfile: profile),
          ),
        );
      }
    } catch (_) {
      setState(() => _isLoggingIn = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text.rich(
                TextSpan(
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                  children: [
                    TextSpan(text: "TED", style: TextStyle(color: Color(0xFFFF3B30))),
                    TextSpan(text: "xplore", style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Dai libri alle idee. Connetti il tuo Kindle per rompere la bolla culturale.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF8E8E93), fontSize: 15),
              ),
              const SizedBox(height: 48),
              _isLoggingIn
                  ? const CircularProgressIndicator(color: Color(0xFFFF3B30))
                  : ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF9900), // Colore istituzionale Amazon
                        foregroundColor: Colors.black,
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.import_contacts), 
                      label: const Text('Login with Amazon', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      onPressed: () => _handleAmazonLogin(context),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
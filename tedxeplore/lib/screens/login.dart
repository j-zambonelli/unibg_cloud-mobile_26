import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:url_launcher/url_launcher.dart';
import '../main_wrapper.dart';
import '../services/aws_service.dart';
import '../models/profile_model.dart';
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoggingIn = false;
  final AwsService _awsService = AwsService();

  @override
  void initState() {
    super.initState();
    _checkExistingSession(); // Controlla subito se siamo già loggati
  }

  Future<void> _checkExistingSession() async {
    try {
      final cognitoPlugin = Amplify.Auth.getPlugin(AmplifyAuthCognito.pluginKey);
      final session = await cognitoPlugin.fetchAuthSession();
      
      if (session.isSignedIn) {
        // L'utente aveva già fatto il login in precedenza o è appena tornato dal redirect
        final idToken = session.userPoolTokensResult.value.idToken.raw;
        UserProfileData profile = await _awsService.fetchUserProfile(idToken);

        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => MainWrapper(userProfile: profile),
            ),
          );
        }
      }
    } catch (e) {
      // Nessuna sessione attiva, l'utente deve cliccare il pulsante
      print("Utente non loggato, attendo input.");
    }
  }

  Future<void> _handleAmazonOAuthLogin() async {
    setState(() => _isLoggingIn = true);

    try {
      // Lancia la UI sicura. Se non ricarica la pagina, il codice prosegue qui
      final result = await Amplify.Auth.signInWithWebUI(
        provider: AuthProvider.amazon,
        options: SignInWithWebUIOptions(
          pluginOptions: CognitoSignInWithWebUIPluginOptions(
            isPreferPrivateSession: true,
          ),
        ),
      );

      if (result.isSignedIn) {
        final cognitoPlugin = Amplify.Auth.getPlugin(AmplifyAuthCognito.pluginKey);
        final session = await cognitoPlugin.fetchAuthSession();
        final idToken = session.userPoolTokensResult.value.idToken.raw;

        UserProfileData profile = await _awsService.fetchUserProfile(idToken);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('amazon_user_token', idToken);

        await prefs.setString('amazon_user_json', jsonEncode(profile.toJson()));

        if(context.mounted){
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context)=> MainWrapper(userProfile: profile),
            ),
          );
        }
        //await _checkExistingSession(); //Usa la stessa funzione per non duplicare il codice
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore Auth: ${e.message}'),
            backgroundColor: const Color(0xFFFF3B30),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoggingIn = false);
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
                        backgroundColor: const Color(0xFFFF9900), // Giallo Amazon
                        foregroundColor: Colors.black,
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.open_in_browser), 
                      label: const Text(
                        'Accedi con Amazon', 
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      onPressed: _handleAmazonOAuthLogin,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
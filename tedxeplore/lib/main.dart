import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login.dart';
import 'main_wrapper.dart';
import 'services/aws_service.dart';
import 'models/profile_model.dart';
import 'amplifyconfiguration.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? savedToken = prefs.getString('amazon_user_token');
  
  UserProfileData? loadedProfile;

  if (savedToken != null) {
    try {
      final AwsService awsService = AwsService();
      loadedProfile = await awsService.fetchUserProfile(savedToken);
    } catch (_) {
      loadedProfile = null;
    }
  }

  await _configureAmplify(); 

  runApp(TedXploreApp(initialProfile: loadedProfile, savedToken: savedToken));
}

Future<void> _configureAmplify() async {
  try {
    final auth = AmplifyAuthCognito();
    await Amplify.addPlugin(auth);
    await Amplify.configure(amplifyConfig);
    print('Amplify configurato con successo');
  } on Exception catch (e) {
    print('Errore nella configurazione di Amplify: $e');
  }
}

class TedXploreApp extends StatelessWidget {
  final UserProfileData? initialProfile;
  final String? savedToken;

  const TedXploreApp({super.key, this.initialProfile, this.savedToken});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TEDxplore',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121212),
          elevation: 0,
        ),
      ),
      home: (initialProfile != null && savedToken != null)
          ? MainWrapper(userProfile: initialProfile!, authToken: savedToken!) 
          : const LoginScreen(),
    );
  }
}
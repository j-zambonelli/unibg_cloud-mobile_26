import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/login.dart';
import 'main_wrapper.dart';
import 'services/aws_service.dart';
import 'models/profile_model.dart';

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

  runApp(TedXploreApp(initialProfile: loadedProfile));
}

class TedXploreApp extends StatelessWidget {
  final UserProfileData? initialProfile;

  const TedXploreApp({super.key, this.initialProfile});

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
      home: initialProfile != null 
          ? MainWrapper(userProfile: initialProfile!) 
          : const LoginScreen(),
    );
  }
}
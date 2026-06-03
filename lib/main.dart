import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/userdata.dart';
import 'screens/onboarding_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/feature_screens.dart';
import 'services/api_service.dart';
import 'services/background_location_service.dart';

import 'screens/messages_screen.dart';
import 'theme/app_theme.dart';
import '../home/home.dart';
import '../routes/installations.dart';
import '../routes/surveys.dart';
import '../routes/tickets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the background service
  await BackgroundLocationService.initializeService();

  // Start the app immediately to prevent ANR (App Not Responding)
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const NGComApp(),
    ),
  );
}

class NGComApp extends StatefulWidget {
  const NGComApp({super.key});

  @override
  State<NGComApp> createState() => _NGComAppState();
}

class _NGComAppState extends State<NGComApp> {
  final ApiService _apiService = ApiService();
  bool? _isLoggedIn;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }


  Future<void> _checkLoginStatus() async {
    final loggedIn = await _apiService.isLoggedIn();
    if (mounted) {
      setState(() {
        _isLoggedIn = loggedIn;
      });
    }
  }

  

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NGCOM',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // Use a conditional home widget to manage the loading state.
      home: _isLoggedIn == null 
          ? const SplashScreen() 
          : (_isLoggedIn! ? const DashboardScreen() : const LoginScreen()),
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        // '/dashboard': (context) => const MainScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/messages': (context) => const MessagesScreen(),
        '/req': (context) => const ReqScreen(),
        '/survey': (context) => const Surveys(),
        '/tickets': (context) => const Tickets(),
        '/installations': (context) => const Installations(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}

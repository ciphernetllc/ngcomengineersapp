import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/userdata.dart';
import 'screens/onboarding_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/feature_screens.dart';
import 'screens/location_disclosure_screen.dart';
import 'screens/privacy_policy_screen.dart';
import 'services/api_service.dart';
import 'services/background_location_service.dart';

import 'screens/messages_screen.dart';
import 'theme/app_theme.dart';
import '../routes/installations.dart';
import '../routes/surveys.dart';
import '../routes/tickets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Safely initialize background location service
  try {
    await BackgroundLocationService.initializeService();
  } catch (e) {
    debugPrint("BackgroundLocationService initialization error: $e");
  }

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
  bool? _hasLocationConsent;

  @override
  void initState() {
    super.initState();
    _checkAppState();
  }

  Future<void> _checkAppState() async {
    final loggedIn = await _apiService.isLoggedIn();
    final prefs = await SharedPreferences.getInstance();
    final hasConsent = prefs.getBool('location_disclosure_accepted') ?? false;

    if (mounted) {
      setState(() {
        _isLoggedIn = loggedIn;
        _hasLocationConsent = hasConsent;
      });
    }
  }

  Widget _getHomeScreen() {
    // Still loading
    if (_isLoggedIn == null || _hasLocationConsent == null) {
      return const SplashScreen();
    }

    // Not logged in — go to login
    if (!_isLoggedIn!) {
      return const LoginScreen();
    }

    // Logged in but hasn't consented to location disclosure yet
    if (!_hasLocationConsent!) {
      return LocationDisclosureScreen(
        onConsentGranted: () async {
          // Start the background service now that we have consent + permissions
          await BackgroundLocationService.startServiceAfterConsent();

          if (mounted) {
            setState(() {
              _hasLocationConsent = true;
            });
          }
        },
        onConsentDeclined: () {
          // Let the user proceed to dashboard without location tracking
          if (mounted) {
            setState(() {
              _hasLocationConsent = true; // Mark as handled (declined)
            });
          }
        },
      );
    }

    // Fully ready
    return const DashboardScreen();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NGCOM',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: _getHomeScreen(),
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/messages': (context) => const MessagesScreen(),
        '/req': (context) => const ReqScreen(),
        '/survey': (context) => const Surveys(),
        '/tickets': (context) => const Tickets(),
        '/installations': (context) => const Installations(),
        '/profile': (context) => const ProfileScreen(),
        '/privacy-policy': (context) => const PrivacyPolicyScreen(),
      },
    );
  }
}

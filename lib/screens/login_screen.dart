import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/userdata.dart';
import '../services/api_service.dart';
import '../services/background_location_service.dart';
import '../theme/app_theme.dart';
import 'location_disclosure_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _secretController = TextEditingController();
  bool _isLoading = false;
  bool _obscureText = true;

  Future<void> _login() async {
    if (_usernameController.text.isEmpty || _secretController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both username and secret')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      // Replicating original logic with new UI
      final result = await ApiService().getApiKeys(
        _usernameController.text,
        _secretController.text,
      );

      // Assuming a successful login response contains the api_key
      if (result['api_key'] != null) {
        final userData = result; // The response is the user data
        final apiKey = userData['api_key'] as String;
        final username = userData['username'] as String;

        ApiService().setCredentials(username, apiKey);
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.saveUserData(userData);

        final prefs = await SharedPreferences.getInstance();
        final hasConsent = prefs.getBool('location_disclosure_accepted') ?? false;

        if (!hasConsent) {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => LocationDisclosureScreen(
                  onConsentGranted: () async {
                    await BackgroundLocationService.startServiceAfterConsent();
                    if (context.mounted) {
                      Navigator.pushReplacementNamed(context, '/dashboard');
                    }
                  },
                  onConsentDeclined: () {
                    if (context.mounted) {
                      Navigator.pushReplacementNamed(context, '/dashboard');
                    }
                  },
                ),
              ),
            );
          }
        } else {
          try {
            await BackgroundLocationService.initializeService();
          } catch (e) {
            debugPrint("Error initializing background service on login: $e");
          }

          if (mounted) {
            Navigator.pushReplacementNamed(context, '/dashboard');
          }
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login Failed: Invalid credentials')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 100),
              Center(
                child: Image.asset(
                  'assets/images/ngcom_logo.webp',
                  width: 150,
                ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
              ),
              const SizedBox(height: 60),
              Text(
                'Welcome Back!',
                style: Theme.of(context).textTheme.displaySmall,
              ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1, end: 0),
              const SizedBox(height: 8),
              Text(
                'Sign in to manage your assignments.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.secondaryColor.withOpacity(0.5),
                    ),
              ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.1, end: 0),
              const SizedBox(height: 48),
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  prefixIcon: Icon(Icons.person_outline),
                ),
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),
              const SizedBox(height: 20),
              TextField(
                controller: _secretController,
                obscureText: _obscureText,
                decoration: InputDecoration(
                  labelText: 'Secret Key',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscureText = !_obscureText),
                  ),
                ),
              ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1, end: 0),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: const Text('Forgot Secret?'),
                ),
              ).animate().fadeIn(delay: 600.ms),
              const SizedBox(height: 32),
              _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
                  : ElevatedButton(
                      onPressed: _login,
                      child: const Text('Sign In'),
                    ).animate().fadeIn(delay: 700.ms).scale(duration: 400.ms),
              const Spacer(),
              // Padding(
              //   padding: const EdgeInsets.only(bottom: 40),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     children: [
              //       Text(
              //         "Don't have an account? ",
              //         style: TextStyle(color: AppTheme.secondaryColor.withOpacity(0.6)),
              //       ),
              //       TextButton(
              //         onPressed: () {},
              //         child: const Text(
              //           'Sign Up',
              //           style: TextStyle(fontWeight: FontWeight.bold),
              //         ),
              //       ),
              //     ],
              //   ),
              // ).animate().fadeIn(delay: 800.ms),


            ],
          ),
        ),
      ),
    );
  }
}

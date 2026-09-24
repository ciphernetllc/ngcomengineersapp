import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:provider/provider.dart';

import '../services/api_service.dart';
import '../models/userdata.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  static Future<void> performLogout(BuildContext context) async {
    // Stop background location tracking service on logout
    try {
      final service = FlutterBackgroundService();
      if (await service.isRunning()) {
        service.invoke('stopService');
      }
    } catch (e) {
      debugPrint("Error stopping background service on logout: $e");
    }

    // Clear user data from provider (SharedPreferences & ApiService)
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.clearUserData();
    await ApiService().clearCredentials();
    // Navigate to login screen and remove all previous routes
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  void _logout(BuildContext context) async {
    await performLogout(context);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _logout(context);
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
          decoration: BoxDecoration(
            color: Colors.deepOrangeAccent,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Logout',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 10), // Decreased width to better align with icon
              Icon(
                Icons.exit_to_app_rounded,
                color: Colors.white,
                size: 20, // Adjusted icon size for better appearance
              ),
            ],
          ),
        ),
      ),
    );
  }
}

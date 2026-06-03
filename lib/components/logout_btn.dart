// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/api_service.dart';
import '../models/userdata.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  void _logout(BuildContext context) async {
    // Clear user data from provider (SharedPreferences)
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.clearUserData();
    // Clear credentials from the running ApiService instance
    ApiService().clearCredentials();
    // Navigate to login screen and remove all previous routes
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../components/account_list_tile.dart';
import '../components/logout_btn.dart';
import '../constants.dart';
import '../models/userdata.dart';
import '../screens/privacy_policy_screen.dart';

class ProfileSettingsPage extends StatefulWidget {
  const ProfileSettingsPage({super.key});

  @override
  State<ProfileSettingsPage> createState() => _ProfileSettingsPageState();
}

class _ProfileSettingsPageState extends State<ProfileSettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        title: const Text(
          'Profile Settings',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, '/');
            }
          },
        ),
      ),
      body: Consumer<UserProvider>(builder: (context, userProvider, child) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 80),
                const CircleAvatar(
                  radius: 60,
                  backgroundImage: AssetImage(
                      'lib/images/smile.jpg'), // Replace with actual user image
                ),
                const SizedBox(height: 10),
                Text(
                  " ${userProvider.firstname}",
                  style: TextStyle(
                    fontSize: 24,
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  " ${userProvider.email}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Column(
                    children: [
                      const CustomListTile(
                        tileicons: '',
                        maintext: 'Account Profile',
                        subtext: 'Access your profile info',
                      ),
                      const SizedBox(height: 7),
                      const CustomListTile(
                        tileicons: '',
                        maintext: 'About',
                        subtext: 'Info about the application',
                      ),
                      const SizedBox(height: 7),
                      const CustomListTile(
                        tileicons: '',
                        maintext: 'Help Center',
                        subtext: 'Get help & support here',
                      ),
                      const SizedBox(height: 7),
                      // Privacy Policy — required by Google Play
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PrivacyPolicyScreen(),
                            ),
                          );
                        },
                        child: const CustomListTile(
                          tileicons: '',
                          maintext: 'Privacy Policy',
                          subtext: 'View our data handling practices',
                        ),
                      ),
                      const SizedBox(height: 7),
                      // Delete Account — required by Google Play
                      GestureDetector(
                        onTap: () => _showDeleteAccountDialog(context),
                        child: const CustomListTile(
                          tileicons: '',
                          maintext: 'Delete Account',
                          subtext: 'Permanently delete your account & data',
                        ),
                      ),
                      const SizedBox(height: 7),
                      GestureDetector(
                        onTap: () => LogoutButton.performLogout(context),
                        child: const CustomListTile(
                          tileicons: '',
                          maintext: 'Logout',
                          subtext: 'Sign out of your account',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Delete Account',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Are you sure you want to delete your account? '
            'This action is permanent and all your data will be removed. '
            'You will be redirected to the account deletion page.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                _launchAccountDeletion();
              },
              child: const Text('Delete Account'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _launchAccountDeletion() async {
    final uri = Uri.parse(PrivacyPolicyScreen.accountDeletionUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}


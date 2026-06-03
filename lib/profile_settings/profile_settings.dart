import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/account_list_tile.dart';
import '../constants.dart';
import '../models/userdata.dart';

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
      // bottomNavigationBar:
      //     const BottomNavigationBarWidget(), // Include the bottom navigation bar here

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
                const Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 25.0),
                      child: Column(
                        children: [
                          CustomListTile(
                            tileicons: '',
                            maintext: 'Account Profile',
                            subtext: 'Access your profile info',
                          ),
                          // CustomListTile(
                          //   tileicons: '',
                          //   maintext: 'Security',
                          //   subtext: 'Change your security details',
                          // ),
                          // SizedBox(height: 7),
                          // CustomListTile(
                          //   tileicons: '',
                          //   maintext: 'Notifications',
                          //   subtext: 'Access all notification',
                          // ),
                          SizedBox(height: 7),
                          CustomListTile(
                            tileicons: '',
                            maintext: 'About',
                            subtext: 'Info about the application',
                          ),
                          SizedBox(height: 7),
                          CustomListTile(
                            tileicons: '',
                            maintext: 'Help Center',
                            subtext: 'Get help & support here',
                          ),
                          SizedBox(height: 7),
                          CustomListTile(
                            tileicons: '',
                            maintext: 'Logout',
                            subtext: '',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // Divider(),
                // Add more settings as needed
              ],
            ),
          ),
        );
      }),
    );
  }
}

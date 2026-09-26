import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../components/logout_btn.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class BaseFeatureScreen extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;

  const BaseFeatureScreen({
    super.key,
    required this.title,
    required this.body,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(title),
        actions: actions,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: body.animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0),
    );
  }
}

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return BaseFeatureScreen(
      title: 'Support Chat',
      body: FutureBuilder(
        future: ApiService().getMessages(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
          }
          final msgs = snapshot.data?['data'] as List? ?? [];
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: msgs.length,
                  itemBuilder: (context, index) {
                    final msg = msgs[index];
                    bool isMe = msg['mode'] == 'sent';
                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isMe ? AppTheme.primaryColor : Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(20),
                            topRight: const Radius.circular(20),
                            bottomLeft: Radius.circular(isMe ? 20 : 0),
                            bottomRight: Radius.circular(isMe ? 0 : 20),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            Text(
                              msg['username'] ?? 'Support',
                              style: TextStyle(
                                color: isMe ? Colors.white70 : AppTheme.secondaryColor.withValues(alpha: 0.5),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              msg['message'] ?? '',
                              style: TextStyle(color: isMe ? Colors.white : AppTheme.secondaryColor),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Type a message...',
                          fillColor: AppTheme.backgroundColor,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        ApiService().reply(ApiService().username, "Hello from App");
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reply sent (mock)')));
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.send, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class ReqScreen extends StatelessWidget {
  const ReqScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return BaseFeatureScreen(
      title: 'Consent & Requests',
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildReqItem(
            context,
            'Get Test Data',
            FontAwesomeIcons.vial,
            () async {
              final res = await ApiService().getTest();
              if (context.mounted) _showDialog(context, 'Test Data', res.toString());
            },
          ),
          _buildReqItem(
            context,
            'New Outlet Consent Init',
            FontAwesomeIcons.store,
            () async {
              final res = await ApiService().newOutletConsentInit();
              if (context.mounted) _showDialog(context, 'Consent Init', res.toString());
            },
          ),
          _buildReqItem(
            context,
            'Mobile Dashboard Data',
            FontAwesomeIcons.chartPie,
            () async {
              final res = await ApiService().getMobileDashboardData('BD001');
              if (context.mounted) _showDialog(context, 'Dashboard Data', res.toString());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReqItem(BuildContext context, String title, FaIconData icon, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: FaIcon(icon, color: AppTheme.primaryColor, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  void _showDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(child: Text(content)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }
}

class SiteSurveyScreen extends StatelessWidget {
  const SiteSurveyScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return BaseFeatureScreen(
      title: 'Site Surveys',
      body: FutureBuilder(
        future: ApiService().getPendingSiteSurveys(ApiService().username),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
          }
          final data = snapshot.data?['data']?['site_surveys'] as List? ?? [];
          if (data.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(FontAwesomeIcons.mapLocationDot, size: 80, color: AppTheme.primaryColor.withValues(alpha: 0.2)),
                  const SizedBox(height: 24),
                  const Text('No pending surveys', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Your scheduled surveys will appear here.', style: TextStyle(color: AppTheme.secondaryColor.withValues(alpha: 0.5))),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text('Survey ID: ${item['id']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Status: ${item['executed'] == 0 ? 'Pending' : 'Executed'}'),
                  trailing: const Icon(Icons.chevron_right, color: AppTheme.primaryColor),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class TicketScreen extends StatelessWidget {
  const TicketScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return BaseFeatureScreen(
      title: 'My Tickets',
      actions: [
        IconButton(onPressed: () {}, icon: const Icon(Icons.add_circle_outline, color: AppTheme.primaryColor)),
      ],
      body: FutureBuilder(
        future: ApiService().getMyTickets(ApiService().username),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
          }
          final tickets = snapshot.data?['tickets'] as List? ?? [];
          if (tickets.isEmpty) {
            return const Center(child: Text('No tickets found'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: tickets.length,
            itemBuilder: (context, index) {
              final tkt = tickets[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(tkt['ticket_id'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: tkt['status'] == 'Open' ? Colors.orange.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              tkt['status'] ?? 'Unknown',
                              style: TextStyle(
                                color: tkt['status'] == 'Open' ? Colors.orange : Colors.green,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(tkt['subject'] ?? 'No Subject', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class InstallationScreen extends StatelessWidget {
  const InstallationScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return BaseFeatureScreen(
      title: 'Installations',
      body: FutureBuilder(
        future: ApiService().getPendingInstallationReports(ApiService().username),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
          }
          final data = snapshot.data?['data'] as List? ?? [];
          if (data.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(FontAwesomeIcons.tools, size: 80, color: AppTheme.primaryColor.withValues(alpha: 0.2)),
                  const SizedBox(height: 24),
                  const Text('No pending installations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final item = data[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const FaIcon(FontAwesomeIcons.tools, color: Colors.blue, size: 20),
                  ),
                  title: Text('Install ID: ${item['id']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Status: ${item['status']}'),
                  trailing: const Icon(Icons.chevron_right),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return BaseFeatureScreen(
      title: 'Profile',
      body: FutureBuilder(
        future: ApiService().getProfile(ApiService().username),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
          }
          final profile = snapshot.data?['portal_profile'] ?? {};
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 60,
                  backgroundColor: AppTheme.primaryColor,
                  child: Icon(Icons.person, size: 60, color: Colors.white),
                ),
                const SizedBox(height: 24),
                Text(profile['username'] ?? 'User', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                Text(profile['email'] ?? 'No email provided', style: TextStyle(color: AppTheme.secondaryColor.withValues(alpha: 0.5))),
                const SizedBox(height: 40),
                _buildProfileItem(Icons.person_outline, 'Personal Information'),
                _buildProfileItem(Icons.history, 'Billing History'),
                _buildProfileItem(Icons.security, 'Security Settings'),
                _buildProfileItem(Icons.help_outline, 'Help & Support'),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => LogoutButton.performLogout(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.withValues(alpha: 0.1),
                      foregroundColor: Colors.red,
                      elevation: 0,
                    ),
                    child: const Text('Logout'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.chevron_right, size: 20),
      ),
    );
  }
}

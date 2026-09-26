import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';

/// In-app Privacy Policy screen.
///
/// Google Play requires the privacy policy to be accessible from within the app
/// (not just on the Play Store listing). This screen provides a summary and
/// links to the full policy hosted on the company website.
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  // TODO: Replace this with the actual URL of your hosted privacy policy.
  static const String privacyPolicyUrl = 'https://erp.myngcom.com/privacy-policy';
  static const String accountDeletionUrl = 'https://erp.myngcom.com/account-deletion';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Privacy Policy'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.privacy_tip_outlined,
                          color: AppTheme.primaryColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'NGCOM Engineer',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.secondaryColor,
                              ),
                            ),
                            Text(
                              'Privacy & Data Handling',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppTheme.secondaryColor.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Last updated: August 2026',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.secondaryColor.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _buildPolicySection(
              'Data We Collect',
              'NGCOM Engineer collects the following data:\n'
                  '• Precise GPS location (latitude & longitude)\n'
                  '• Account credentials (username, API key)\n'
                  '• Device information for service operation\n'
                  '• Job and ticket activity data',
            ),

            _buildPolicySection(
              'How We Use Your Data',
              '• Job site tracking and engineer dispatching\n'
                  '• Assignment and work order verification\n'
                  '• Real-time field work coordination\n'
                  '• Service quality and performance monitoring\n'
                  '• Background location sync every 5 minutes on working days (Mon–Fri)',
            ),

            _buildPolicySection(
              'Data Sharing',
              'Your data is shared only with:\n'
                  '• NGCOM operations servers for job management\n'
                  '• Your organization\'s management team\n\n'
                  'We do NOT share your data with third-party advertisers or data brokers.',
            ),

            _buildPolicySection(
              'Data Security',
              'All data is transmitted over encrypted HTTPS connections. '
                  'Your API credentials are stored securely in on-device storage. '
                  'We implement industry-standard security measures to protect your information.',
            ),

            _buildPolicySection(
              'Data Retention & Deletion',
              'Your location data is retained only as long as needed for operational purposes. '
                  'You may request account deletion at any time, and all associated personal data will be permanently deleted.',
            ),

            const SizedBox(height: 16),

            // Full Policy Link
            _buildActionCard(
              context,
              icon: Icons.open_in_new,
              title: 'View Full Privacy Policy',
              subtitle: 'Opens in your browser',
              onTap: () => _launchUrl(privacyPolicyUrl),
            ),

            const SizedBox(height: 12),

            // Account Deletion Link
            _buildActionCard(
              context,
              icon: Icons.delete_outline,
              title: 'Request Account Deletion',
              subtitle: 'Delete your account and all data',
              onTap: () => _launchUrl(accountDeletionUrl),
              color: AppTheme.errorColor,
            ),

            const SizedBox(height: 16),

            // Contact
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.primaryColor.withValues(alpha: 0.15),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.email_outlined,
                    color: AppTheme.primaryColor.withValues(alpha: 0.7),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Privacy Contact',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.secondaryColor,
                          ),
                        ),
                        Text(
                          'For privacy inquiries, contact support@myngcom.com',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.secondaryColor.withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPolicySection(String title, String content) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppTheme.secondaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.secondaryColor.withValues(alpha: 0.7),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? color,
  }) {
    final cardColor = color ?? AppTheme.primaryColor;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cardColor.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: cardColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: cardColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: cardColor,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.secondaryColor.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: cardColor.withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

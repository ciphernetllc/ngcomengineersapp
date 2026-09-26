import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

/// Prominent Disclosure & Consent screen required by Google Play's User Data policy.
///
/// This screen MUST be shown before requesting any location permissions.
/// It clearly describes:
///   - What data is collected (precise location)
///   - How it is used (job tracking, dispatching, verification)
///   - When it is collected (including background collection)
///   - Who it is shared with (NGCOM operations)
///
/// Consent is obtained via an explicit affirmative action (button tap).
class LocationDisclosureScreen extends StatelessWidget {
  /// Called when user grants consent. Typically navigates to the next screen
  /// and triggers permission requests.
  final VoidCallback onConsentGranted;

  /// Called when user declines. Typically navigates to a limited-functionality screen.
  final VoidCallback onConsentDeclined;

  const LocationDisclosureScreen({
    super.key,
    required this.onConsentGranted,
    required this.onConsentDeclined,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),

                      // Icon
                      Center(
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.location_on_rounded,
                            size: 40,
                            color: AppTheme.primaryColor,
                          ),
                        ).animate().scale(
                              duration: 600.ms,
                              curve: Curves.easeOutBack,
                            ),
                      ),

                      const SizedBox(height: 24),

                      // Title
                      Center(
                        child: Text(
                          'Location Data Disclosure',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.secondaryColor,
                              ),
                        ).animate().fadeIn(duration: 500.ms),
                      ),

                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          'Please review before continuing',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppTheme.secondaryColor.withValues(alpha: 0.6),
                              ),
                        ).animate().fadeIn(delay: 200.ms),
                      ),

                      const SizedBox(height: 32),

                      // Disclosure items
                      _buildDisclosureItem(
                        context,
                        icon: Icons.gps_fixed,
                        title: 'What We Collect',
                        description:
                            'NGCOM Engineer collects your precise GPS location (latitude and longitude) from your device.',
                        delay: 300,
                      ),

                      _buildDisclosureItem(
                        context,
                        icon: Icons.engineering,
                        title: 'Why We Collect It',
                        description:
                            'Your location is used to enable job site tracking, engineer dispatching, assignment verification, and field work coordination.',
                        delay: 400,
                      ),

                      _buildDisclosureItem(
                        context,
                        icon: Icons.sync,
                        title: 'Background Collection',
                        description:
                            'Location data is collected periodically (every 5 minutes during working days) even when the app is closed or not in use, to ensure accurate field tracking.',
                        delay: 500,
                      ),

                      _buildDisclosureItem(
                        context,
                        icon: Icons.share,
                        title: 'How It Is Shared',
                        description:
                            'Your location data is transmitted securely to NGCOM\'s operations server for job management and coordination. It is not shared with third-party advertisers.',
                        delay: 600,
                      ),

                      _buildDisclosureItem(
                        context,
                        icon: Icons.privacy_tip_outlined,
                        title: 'Your Privacy',
                        description:
                            'You can review our full Privacy Policy in the app settings at any time. Location tracking only occurs on working days (Mon–Fri) while you are logged in.',
                        delay: 700,
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              // Consent buttons
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => _handleConsent(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'I Understand & Agree',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: TextButton(
                      onPressed: () => _handleDecline(context),
                      child: Text(
                        'Decline',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.secondaryColor.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ).animate().fadeIn(delay: 800.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDisclosureItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required int delay,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: AppTheme.primaryColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.secondaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.secondaryColor.withValues(alpha: 0.65),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: delay)).slideX(begin: 0.05, end: 0);
  }

  Future<void> _handleConsent(BuildContext context) async {
    // Save that user has given consent
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('location_disclosure_accepted', true);

    // Now request permissions AFTER consent
    await _requestLocationPermissions();

    onConsentGranted();
  }

  Future<void> _handleDecline(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('location_disclosure_accepted', false);
    onConsentDeclined();
  }

  /// Requests location permissions. This is called ONLY after the user
  /// has given explicit consent via the disclosure screen.
  Future<void> _requestLocationPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
  }
}

import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'api_service.dart';

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();

  // Wrap Android specific logic to handle isolate initialization warnings
  try {
    if (service is AndroidServiceInstance) {
      // CRITICAL: Set initial notification immediately to prevent "Bad notification" crash
      service.setForegroundNotificationInfo(
        title: "NGCOM Tracking",
        content: "Service is starting...",
      );

      service.on('setAsBackground').listen((event) {
        service.setAsBackgroundService();
      });
    }
  } catch (e) {
    debugPrint("Background Service Android specific setup failed: $e");
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  final apiService = ApiService();
  
  // Timer set to 5 minutes to balance battery life and tracking accuracy
  Timer.periodic(const Duration(minutes: 5), (timer) async {
    try {
      // 1. Check if it's a working day (Mon-Fri)
      if (!apiService.isWithinWorkingDays()) {
        if (service is AndroidServiceInstance) {
          final dayName = DateFormat('EEEE').format(DateTime.now());
          service.setForegroundNotificationInfo(
            title: "NGCOM Tracking Paused",
            content: "Tracking is disabled on $dayName.",
          );
        }
        return;
      }

      // 2. Ensure user is logged in and we have a username
      final prefs = await SharedPreferences.getInstance();
      await prefs.reload(); // Critical: Pick up changes from the UI isolate
      
      final isLoggedIn = await apiService.isLoggedIn();
      debugPrint('DEBUG: Background service - isLoggedIn: $isLoggedIn');
      
      final String? usernameFromPrefs = prefs.getString('username');
      final currentUsername = usernameFromPrefs?.trim() ?? ''; 

      if (isLoggedIn && currentUsername.isNotEmpty && apiService.username.isNotEmpty) {
        if (service is AndroidServiceInstance) {
          service.setForegroundNotificationInfo(
            title: "NGCOM Tracking",
            content: "Checking location status...",
          );
        }

        // 3. Check Location Services and Permissions
        bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) {
           if (service is AndroidServiceInstance) {
            service.setForegroundNotificationInfo(
              title: "NGCOM Tracking Error",
              content: "Location services are disabled on this device.",
            );
          }
          return;
        }

        LocationPermission permission = await Geolocator.checkPermission();
        if (permission != LocationPermission.always && permission != LocationPermission.whileInUse) {
          if (service is AndroidServiceInstance) {
            service.setForegroundNotificationInfo(
              title: "NGCOM Tracking Error",
              content: "Location permission required (Currently: $permission)",
            );
          }
          return;
        }

        if (service is AndroidServiceInstance) {
          service.setForegroundNotificationInfo(
            title: "NGCOM Tracking",
            content: "Acquiring GPS fix...",
          );
        }

        // 4. Get current coordinates
        Position? position;
        try {
          position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
            timeLimit: const Duration(seconds: 30),
          );
        } catch (e) {
          debugPrint("GPS Timeout, attempting last known position fallback...");
          position = await Geolocator.getLastKnownPosition();
          
          if (position == null) {
            throw Exception("GPS Timeout: Could not acquire location after 30s.");
          }
        }

        if (service is AndroidServiceInstance) {
          service.setForegroundNotificationInfo(
            title: "NGCOM Tracking",
            content: "Syncing with server...",
          );
        }

        // 5. Update API
        try {
          if (currentUsername.isNotEmpty) {
            final result = await apiService.updateEngineerLocation(
              username: currentUsername,
              latitude: position.latitude,
              longitude: position.longitude,
            );

            if (result['message'] == 'Session Expired') {
              if (service is AndroidServiceInstance) {
                service.setForegroundNotificationInfo(
                  title: "Session Expired",
                  content: "Please log in again to continue tracking.",
                );
              }
              return;
            }
          }
        } catch (apiError) {
          debugPrint("Background API Sync failed: $apiError");
          if (apiError.toString().contains('UNAUTHORIZED')) return;
        }

        if (service is AndroidServiceInstance) {
          final now = DateFormat('HH:mm:ss').format(DateTime.now());
          await service.setForegroundNotificationInfo(
            title: "NGCOM Tracking Active",
            content: "Last sync: $now (Lat: ${position.latitude.toStringAsFixed(4)})",
          );
        }
      } else {
        if (service is AndroidServiceInstance) {
          service.setForegroundNotificationInfo(
            title: "NGCOM Tracking",
            content: "Waiting for user login...",
          );
        }
      }
    } catch (e) {
      if (service is AndroidServiceInstance) {
        String errorMsg = "Network error: $e";
        if (e.toString().contains('TimeoutException')) {
          errorMsg = "GPS Timeout: Weak signal";
        } else if (e.toString().contains('400')) {
          errorMsg = "Server rejected data (400)";
        }

        service.setForegroundNotificationInfo(
          title: "NGCOM Sync Error",
          content: errorMsg,
        );
      }
    }
  });
}

class BackgroundLocationService {
  /// Called at app startup. Only starts the background service if the user
  /// has previously granted consent AND location permissions are available.
  /// Does NOT request permissions — that is handled by the disclosure screen.
  static Future<void> initializeService() async {
    final prefs = await SharedPreferences.getInstance();
    final hasConsented = prefs.getBool('location_disclosure_accepted') ?? false;

    if (!hasConsented) {
      debugPrint("BackgroundLocationService: User has not yet consented to location disclosure. Skipping service start.");
      return;
    }

    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint("BackgroundLocationService: Location services are disabled.");
      return;
    }

    // Check permissions (do NOT request them here)
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      debugPrint("BackgroundLocationService: Location permissions not granted (status: $permission). Skipping service start.");
      return;
    }

    await _configureAndStartService();
  }

  /// Called after the user grants consent on the LocationDisclosureScreen
  /// and system permissions are granted. Starts the background service.
  static Future<void> startServiceAfterConsent() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint("BackgroundLocationService: Location services are disabled.");
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      debugPrint("BackgroundLocationService: Location permissions not granted after consent.");
      return;
    }

    await _configureAndStartService();
  }

  /// Internal method to configure and start the Flutter background service.
  static Future<void> _configureAndStartService() async {
    final service = FlutterBackgroundService();

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        autoStartOnBoot: true,
        isForegroundMode: true,
        initialNotificationTitle: 'Location Tracking Active',
        initialNotificationContent: 'Updating location every 5 minutes during work days',
      ),
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );

    final isRunning = await service.isRunning();
    if (!isRunning) {
      await service.startService();
    }
  }
}
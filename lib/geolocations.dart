import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GetLocationButton extends StatefulWidget {
  const GetLocationButton({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _GetLocationButtonState createState() => _GetLocationButtonState();
}

class _GetLocationButtonState extends State<GetLocationButton> {
  String _locationMessage = '';

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, don't continue
      setState(() {
        _locationMessage = 'Location services are disabled.';
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      bool shouldShowRationale = await _shouldShowPermissionRationale();
      if (shouldShowRationale) {
        _showPermissionRationaleDialog();
        return;
      } else {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Permissions are denied, show an error message
          setState(() {
            _locationMessage = 'Location permissions are denied';
          });
          return;
        }
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      setState(() {
        _locationMessage =
            'Location permissions are permanently denied, we cannot request permissions.';
      });
      return;
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _locationMessage =
          'Latitude: ${position.latitude}, Longitude: ${position.longitude}';
    });
  }

  Future<void> _showPermissionRationaleDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Permission Needed'),
          content: const Text(
              'This app needs location permission to access your location. Please grant the permission.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _requestLocationPermission();
              },
              child: const Text('Grant Permission'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      setState(() {
        _locationMessage = 'Location permissions are denied';
      });
      _setPermissionDenied();
    } else if (permission == LocationPermission.deniedForever) {
      setState(() {
        _locationMessage =
            'Location permissions are permanently denied, we cannot request permissions.';
      });
    } else {
      _getCurrentLocation();
    }
  }

  Future<void> _setPermissionDenied() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('location_permission_denied', true);
  }

  Future<bool> _shouldShowPermissionRationale() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('location_permission_denied') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: _getCurrentLocation,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8.0),
            height: 60,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.deepOrangeAccent,
              borderRadius: BorderRadius.circular(50.0),
            ),
            child: const Center(
              child: Text(
                'Get Clients Coordinates',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        const SizedBox(height: 15),
        Text(_locationMessage),
      ],
    );
  }
}

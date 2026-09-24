import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class UserProvider with ChangeNotifier {
  String? _apiKey;
  String? _firstname;
  String? _lastname;
  String? _username;
  String? _email;
  String? _phone;
  String? _role;
  String? _engineer;
  String? _engineerType;

  String? get apiKey => _apiKey;
  String? get firstname => _firstname;
  String? get lastname => _lastname;
  String? get username => _username;
  String? get email => _email;
  String? get phone => _phone;
  String? get role => _role;
  String? get engineer => _engineer;
  String? get engineerType => _engineerType;
  bool get isLoggedIn => _apiKey != null;

  UserProvider() {
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    _apiKey = prefs.getString('api_key');
    _firstname = prefs.getString('firstname');
    _lastname = prefs.getString('lastname');
    _username = prefs.getString('username');
    _email = prefs.getString('email');
    _phone = prefs.getString('phone');
    _role = prefs.getString('role');
    _engineer = prefs.getString('is_engineer');
    _engineerType = prefs.getString('is_radio_fibre_engineer');
    notifyListeners();
  }

  Future<void> saveUserData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    _apiKey = data['api_key'];
    _firstname = data['firstname'];
    _lastname = data['lastname'];
    _username = data['username'];
    _email = data['email'];
    _phone = data['phone'];
    _role = data['role'];
    _engineer = data['is_engineer'];
    _engineerType = data['is_radio_fibre_engineer'];

    await prefs.setString('api_key', _apiKey!);
    await prefs.setString('firstname', _firstname!);
    await prefs.setString('lastname', _lastname!);
    await prefs.setString('username', _username!);
    await prefs.setString('email', _email!);
    await prefs.setString('phone', _phone!);
    await prefs.setString('role', _role!);
    await prefs.setString('is_engineer', _engineer!);
    await prefs.setString('is_radio_fibre_engineer', _engineerType!);

    notifyListeners();
  }

  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final hasConsent = prefs.getBool('location_disclosure_accepted');
    await prefs.clear();
    if (hasConsent != null) {
      await prefs.setBool('location_disclosure_accepted', hasConsent);
    }
    await ApiService().clearCredentials();
    _apiKey = null;
    _firstname = null;
    _lastname = null;
    _username = null;
    _email = null;
    _phone = null;
    _role = null;
    _engineer = null;
    _engineerType = null;
    notifyListeners();
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Use 10.0.2.2 for Android Emulator to access host localhost.
  // Use localhost or your IP for iOS/Web.
  static const String baseUrl = "https://erp.myngcom.com";
  // static const String baseUrl = "http://192.168.1.156/ngcomerp-v4/public";
  
  String? _username;
  String? _apiKey;

  void setCredentials(String username, String apiKey) {
    _username = username;
    _apiKey = apiKey;
  }

  Future<void> clearCredentials() async {
    _username = null;
    _apiKey = null;
    final prefs = await SharedPreferences.getInstance();
    final hasConsent = prefs.getBool('location_disclosure_accepted');
    await prefs.clear();
    if (hasConsent != null) {
      await prefs.setBool('location_disclosure_accepted', hasConsent);
    }
  }

  String get username => _username ?? '';

  Future<dynamic> _get(String path, {Map<String, String>? query, Map<String, String>? headers}) async {
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: query);
    final requestHeaders = {
      'Accept': 'application/json',
      'X-API-KEY': ?_apiKey,
    };
    if (headers != null) {
      requestHeaders.addAll(headers);
    }
    final response = await http.get(uri, headers: requestHeaders);
    return _processResponse(response);
  }

  Future<dynamic> _post(String path, Map<String, dynamic> body, {Map<String, String>? headers}) async {
    final uri = Uri.parse('$baseUrl$path');
    final requestHeaders = {
      'Content-Type': 'application/json', // Default to JSON
      'Accept': 'application/json',
      'X-API-KEY': ?_apiKey,
    };
    if (headers != null) {
      requestHeaders.addAll(headers);
    }

    Object? requestBody;
    final contentType = requestHeaders['Content-Type']?.toLowerCase() ?? '';
    if (contentType.contains('application/x-www-form-urlencoded')) {
      requestBody = body.map((key, value) => MapEntry(key, value.toString()));
    } else {
      requestBody = jsonEncode(body);
    }

    final response = await http.post(
      uri,
      headers: requestHeaders,
      body: requestBody,
    );
    return _processResponse(response);
  }

  Future<dynamic> _processResponse(http.Response response) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      // Session expired or invalid key
      await clearCredentials();
      throw Exception('UNAUTHORIZED');
    } else {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }
  }



  // --- Auth ---
  Future<Map<String, dynamic>> getApiKeys(String username, String secret) async {
    return await _post('/api/v1/auth/getkeys', {
      'username': username,
      'secret': secret,
    }, headers: {
      'Content-Type': 'application/json',
      
    });
  }

  // --- Main (Chat) ---
  Future<Map<String, dynamic>> getMessages() async {
    return await _get('/api/v1/main/getmessages');
  }

  Future<Map<String, dynamic>> markAsRead(String username) async {
    return await _get('/api/v1/main/marasread', query: {'username': username});
  }

  Future<Map<String, dynamic>> reply(String username, String message) async {
    return await _post('/api/v1/main/reply', {
      'username': username,
      'message': message,
     
      'mode': 'UNREAD'
    });
  }

  // --- Req (Consent) ---
  Future<Map<String, dynamic>> getTest() async {
    return await _get('/api/v1/req/gettest');
  }

  Future<Map<String, dynamic>> newOutletConsentInit() async {
    return await _get('/api/v1/req/newoutletconsentinit');
  }

  Future<Map<String, dynamic>> submitNewOutletConsent(Map<String, dynamic> data) async {
    return await _post('/api/v1/req/submitnewoutletconsent', data);
  }

  Future<Map<String, dynamic>> getOutletsByBdCode(String bdCode) async {
    return await _get('/api/v1/req/getoutletsbybdcodewithpendingconsents', query: {'bd_code': bdCode});
  }

  Future<Map<String, dynamic>> getMobileDashboardData(String bdCode) async {
    return await _get('/api/v1/req/mobiledasboarddata', query: {'bd_code': bdCode});
  }

  // --- Site Survey ---
  Future<Map<String, dynamic>> getAllInventory() async {
    return await _get('/api/v1/sitesurveyreq/allinventory');
  }

  Future<Map<String, dynamic>> getPendingSiteSurveys(String username) async {
    return await _get('/api/v1/sitesurveyreq/getpendingsitesurveysbyuser', query: {'username': username});
  }

  Future<Map<String, dynamic>> getExecutedSiteSurveys(String username) async {
    return await _get(
        '/api/v1/sitesurveyreq/getexecutedsitesurveysbyuser', query: {'username': username});
  }

  // --- Ticket ---
  Future<Map<String, dynamic>> getMyTickets(String username) async {
    return await _get('/api/v1/ticketreq/mytickets', query: {'username': username});
  }
  // --- Ticket ---
  Future<Map<String, dynamic>> getTicketDetails(String ticketId) async {
    final response = await _get('/api/v1/ticketreq/ticketdetails', query: {'ticket_id': ticketId});
    print('DEBUG: ApiService.getTicketDetails response: $response');
    return response;
  }
  // --- Ticket ---
  Future<Map<String, dynamic>> addMessageToTicket(String ticketId, String username, String message, String role) async {
    return await _post('/api/v1/ticketreq/addmessage?ticket_id=$ticketId',{
      'ticket_id': ticketId,
      'username': username,
      'message': message,
      'role': role,
    }, headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
    });
  }
  // --- Ticket ---
  Future<Map<String, dynamic>> checkMst(double lat, double lon) async {
    return await _post('/api/v1/coverage/check',  {
      'lat': lat.toString(),
      'long': lon.toString(),
    });
  }

  // --- Installation Report ---
  Future<Map<String, dynamic>> getPendingInstallationReports(String username) async {
    return await _get('/api/v1/installationreportreq/getpendinginstallationreportsbyuser', query: {'username': username});
  }

  // --- SMS ---
  Future<Map<String, dynamic>> sendSms(String to, String message) async {
    return await _post('/api/v1/smsreq/sendsms', {
      'to': to,
      'message': message,
    });
  }

  // --- Profile ---
  Future<Map<String, dynamic>> getProfile(String username) async {
    return await _get('/api/v1/profile/getprofile', query: {'username': username});
  }

  // --- Notification ---
  Future<Map<String, dynamic>> getUserMessage(String username) async {
    return await _get('/api/v1/main/getusermessages', query: {'username': username});
  }
 
  // --- Dashboard ---
  Future<Map<String, dynamic>> getDashboardData(String username) async {
    String effectiveUsername = username.trim();

    // If the provided username is empty, attempt to recover it from SharedPreferences
    if (effectiveUsername.isEmpty) {
      await isLoggedIn(); // This reloads prefs and populates _username and _apiKey
      effectiveUsername = _username?.trim() ?? '';
    }

    if (effectiveUsername.isEmpty) {
      // If still empty, it means the user is actually logged out
      throw Exception('UNAUTHORIZED');
    }

    return await _get('/api/v1/dashboard/index', query: {'username': effectiveUsername});
  }


  // location
  Future<Map<String, dynamic>> updateEngineerLocation({
  required String username,
  required double latitude,
  required double longitude,
}) async {
  // 1. If the passed username is empty, try to recover it from the instance or disk
  String effectiveUsername = username.trim();
  
  if (effectiveUsername.isEmpty) {
    await isLoggedIn(); // Attempt to hydrate _username from SharedPreferences
    effectiveUsername = _username?.trim() ?? '';
  }

  if (effectiveUsername.isEmpty) {
    print('DEBUG: ApiService.updateEngineerLocation - Provided username parameter is empty.');
    return {'operation_status': 'error', 'message': 'Local validation failed: No username available'};
  }

  print('DEBUG: ApiService.updateEngineerLocation - Using username: $effectiveUsername');

  try {
    final response = await _post(
      '/api/v1/engineer/getengineerslocation',
      {
        'username': effectiveUsername,
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
      },
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    );
    return response;
  } catch (e) {
    if (e.toString().contains('UNAUTHORIZED')) {
      return {'operation_status': 'error', 'message': 'Session Expired'};
    }
    rethrow;
  }
}


  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    // Ensure we have the latest data from disk
    await prefs.reload();
    
    final savedKey = prefs.getString('api_key');
    final savedUsername = prefs.getString('username');
    print('DEBUG: ApiService.isLoggedIn - savedKey: $savedKey, savedUsername: $savedUsername');
    
    if (savedKey != null && savedKey.isNotEmpty && savedUsername != null && savedUsername.isNotEmpty) {
      _apiKey = savedKey;
      _username = savedUsername;
      print('DEBUG: ApiService.isLoggedIn - Credentials loaded. _username: $_username');
      return true;
    }
    return false;
  }

  /// Checks if today is between Monday and Friday.
  bool isWithinWorkingDays() {
    final now = DateTime.now();
     return now.weekday >= DateTime.monday && now.weekday <= DateTime.friday;
    // Temporarily return true to test on weekends
    // return true; 
    // return now.weekday >= DateTime.monday && now.weekday <= DateTime.friday;
  }
}

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

  void clearCredentials() {
    _username = null;
    _apiKey = null;
  }

  String get username => _username ?? '';

  Future<dynamic> _get(String path, {Map<String, String>? query, Map<String, String>? headers}) async {
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: query);
    final requestHeaders = {
      'Accept': 'application/json',
      if (_apiKey != null) 'X-API-KEY': _apiKey!,
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
      if (_apiKey != null) 'X-API-KEY': _apiKey!,
    };
    if (headers != null) {
      requestHeaders.addAll(headers);
    }

    Object? requestBody;
    if (requestHeaders['Content-Type'] == 'application/x-www-form-urlencoded') {
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

  dynamic _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
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
    return await _get('/api/v1/ticketreq/ticketdetails', query: {'ticket_id': ticketId});
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
    return await _get('/api/v1/dashboard/index', query: {'username': username});
  }


  // location
  Future<Map<String, dynamic>> updateEngineerLocation({
  required String username,
  required double latitude,
  required double longitude,
}) async {
  print('DEBUG: updateEngineerLocation initiated for user: $username');

  // Force reload credentials from disk to ensure background isolate has them
  await isLoggedIn();

  final response = await _post(
    '/api/v1/engineer/getengineerslocation',
    {
      'username': username,
      'latitude': latitude,
      'longitude': longitude,
    },
    // Removed application/x-www-form-urlencoded to use default application/json
  );
  print('DEBUG: updateEngineerLocation response: $response');
  return response;
}


  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    // Ensure we have the latest data from disk
    await prefs.reload();
    
    final savedKey = prefs.getString('api_key');
    if (savedKey != null && savedKey.isNotEmpty) {
      _apiKey = savedKey;
      _username = prefs.getString('username');
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

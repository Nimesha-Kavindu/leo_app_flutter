import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // For local development with 'wrangler dev', use localhost:8787
  // On Android emulator, use 10.0.2.2:8787
  // Update this to your deployed Cloudflare Worker URL for production
  static const String baseUrl =
      'https://leo-app-backend.leo-connect-usj.workers.dev/api/auth';

  static Future<Map<String, dynamic>> register(
    String username,
    String email,
    String password,
    String leoDistrict,
    String clubName, {
    String? leoId,
    String? about,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
        'leoId': leoId,
        'leoDistrict': leoDistrict,
        'clubName': clubName,
        'about': about,
      }),
    );

    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> getProfile(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    return _handleResponse(response);
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    final body = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    } else {
      throw Exception(body['message'] ?? 'An error occurred');
    }
  }
}

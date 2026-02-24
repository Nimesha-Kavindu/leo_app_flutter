import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../main.dart' show navigatorKey;
import '../screens/auth/login_screen.dart';
import 'storage_service.dart';

class ApiService {
  // LOCAL DEV: uses adb reverse tcp:8787 tcp:8787 so the phone reaches the Mac's wrangler dev server.
  //   Run once per cable reconnect: adb reverse tcp:8787 tcp:8787
  //   Then start backend: cd backend/backend && bun run dev
  // PRODUCTION: https://leo-app-backend.leo-connect-usj.workers.dev/api/auth
  static const String _devBaseUrl = 'http://localhost:8787/api/auth';
  static const String _prodBaseUrl =
      'https://leo-app-backend.leo-connect-usj.workers.dev/api/auth';

  static String get baseUrl => kReleaseMode ? _prodBaseUrl : _devBaseUrl;

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

  static Future<Map<String, dynamic>> updateProfile(
    String token,
    String username,
    String? about,
    String? avatarUrl,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'username': username,
        'about': about,
        'avatarUrl': avatarUrl,
      }),
    );

    return _handleResponse(response);
  }

  // --- Posts ---

  static Future<Map<String, dynamic>> getFeed(
    String token, {
    String? cursor,
  }) async {
    final uri = Uri.parse('${baseUrl.replaceFirst('/api/auth', '/api')}/posts')
        .replace(queryParameters: cursor != null ? {'cursor': cursor} : null);
    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> createPost(
    String token, {
    String? imageUrl,
    String? caption,
  }) async {
    final response = await http.post(
      Uri.parse('${baseUrl.replaceFirst('/api/auth', '/api')}/posts'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'imageUrl': imageUrl, 'caption': caption}),
    );
    return _handleResponse(response);
  }

  static Future<void> likePost(String token, String postId) async {
    final response = await http.post(
      Uri.parse(
        '${baseUrl.replaceFirst('/api/auth', '/api')}/posts/$postId/like',
      ),
      headers: {'Authorization': 'Bearer $token'},
    );
    _handleResponse(response);
  }

  static Future<void> unlikePost(String token, String postId) async {
    final response = await http.delete(
      Uri.parse(
        '${baseUrl.replaceFirst('/api/auth', '/api')}/posts/$postId/like',
      ),
      headers: {'Authorization': 'Bearer $token'},
    );
    _handleResponse(response);
  }

  // --- Clubs ---

  static Future<Map<String, dynamic>> getClubs(
    String token, {
    String? district,
  }) async {
    final uri =
        Uri.parse('${baseUrl.replaceFirst('/api/auth', '/api')}/clubs').replace(
      queryParameters: district != null ? {'district': district} : null,
    );
    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );
    return _handleResponse(response);
  }

  static Future<void> followClub(String token, String clubId) async {
    final response = await http.post(
      Uri.parse(
        '${baseUrl.replaceFirst('/api/auth', '/api')}/clubs/$clubId/follow',
      ),
      headers: {'Authorization': 'Bearer $token'},
    );
    _handleResponse(response);
  }

  static Future<void> unfollowClub(String token, String clubId) async {
    final response = await http.delete(
      Uri.parse(
        '${baseUrl.replaceFirst('/api/auth', '/api')}/clubs/$clubId/follow',
      ),
      headers: {'Authorization': 'Bearer $token'},
    );
    _handleResponse(response);
  }

  // --- Events ---

  static Future<Map<String, dynamic>> getEvents(
    String token, {
    String? clubId,
    String? cursor,
  }) async {
    final params = <String, String>{};
    if (clubId != null) params['clubId'] = clubId;
    if (cursor != null) params['cursor'] = cursor;
    final uri = Uri.parse(
      '${baseUrl.replaceFirst('/api/auth', '/api')}/events',
    ).replace(queryParameters: params.isNotEmpty ? params : null);
    final response = await http.get(
      uri,
      headers: {'Authorization': 'Bearer $token'},
    );
    return _handleResponse(response);
  }

  static Future<void> rsvpEvent(String token, String eventId) async {
    final response = await http.post(
      Uri.parse(
        '${baseUrl.replaceFirst('/api/auth', '/api')}/events/$eventId/rsvp',
      ),
      headers: {'Authorization': 'Bearer $token'},
    );
    _handleResponse(response);
  }

  static Future<void> cancelRsvp(String token, String eventId) async {
    final response = await http.delete(
      Uri.parse(
        '${baseUrl.replaceFirst('/api/auth', '/api')}/events/$eventId/rsvp',
      ),
      headers: {'Authorization': 'Bearer $token'},
    );
    _handleResponse(response);
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    final body = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body as Map<String, dynamic>;
    }
    if (response.statusCode == 401) {
      // Token expired or invalid — clear local auth data and send user back to login.
      StorageService.clearAuthData().then((_) {
        navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
        );
      });
      throw Exception('Session expired. Please log in again.');
    }
    final message =
        (body as Map<String, dynamic>)['message'] ?? 'An error occurred';
    throw Exception(message);
  }
}

// File: lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/user.dart';
import '../models/dashboard_data.dart';

class ApiService {
  static final String baseUrl = "${dotenv.env['API_URL']}/api";
  final storage = const FlutterSecureStorage();

  Future<User> login(String userName, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_name': userName, 'user_pass': password}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['token'] == null) {
          throw Exception('Token not found in response');
        }
        await storage.write(key: 'token', value: data['token']);
        return User.fromJson(data);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(
          'Login failed: ${errorData['message'] ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    final token = await storage.read(key: 'token');
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        await storage.delete(key: 'token');
        await storage.delete(key: 'selectedSiteId');
      } else {
        throw Exception('Logout failed: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<DashboardData> getDashboard(String siteId) async {
    final token = await storage.read(key: 'token');
    final response = await http.get(
      Uri.parse('$baseUrl/dashboard?site_id=$siteId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return DashboardData.fromJson(data);
    } else {
      throw Exception('Failed to load dashboard: ${response.body}');
    }
  }

  Future<DashboardData> getRealtimeData(String siteId) async {
    final token = await storage.read(key: 'token');
    final response = await http.get(
      Uri.parse('$baseUrl/realtime?site_id=$siteId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return DashboardData.fromJson(data);
    } else {
      throw Exception('Failed to load realtime data: ${response.body}');
    }
  }

  Future<List<dynamic>> getAreas(String? siteId) async {
    final token = await storage.read(key: 'token');
    print('Fetching areas with token: $token, siteId: $siteId');
    final uri =
        siteId != null
            ? Uri.parse('$baseUrl/area?site_id=$siteId')
            : Uri.parse('$baseUrl/area');
    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load areas: ${response.body}');
    }
  }

  Future<List<dynamic>> getSensors() async {
    final response = await http.get(Uri.parse('$baseUrl/sensor'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load sensors: ${response.body}');
    }
  }

  Future<String> sendChatMessage(String message, String chatName) async {
    final token = await storage.read(key: 'token');
    final response = await http.post(
      Uri.parse('$baseUrl/chat/send'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'message': message, 'name_chat': chatName}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['response'];
    } else {
      throw Exception('Failed to send message: ${response.body}');
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app_env.dart';

class ApiClient {
  static final http.Client _client = http.Client();

  static Map<String, String> _getHeaders() {
    final token = Supabase.instance.client.auth.currentSession?.accessToken;
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('${AppEnv.apiBaseUrl}$endpoint');
    return await _client.get(url, headers: _getHeaders());
  }

  static Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('${AppEnv.apiBaseUrl}$endpoint');
    return await _client.post(url, headers: _getHeaders(), body: jsonEncode(body));
  }

  static Future<http.Response> patch(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('${AppEnv.apiBaseUrl}$endpoint');
    return await _client.patch(url, headers: _getHeaders(), body: jsonEncode(body));
  }

  static Future<http.Response> delete(String endpoint) async {
    final url = Uri.parse('${AppEnv.apiBaseUrl}$endpoint');
    return await _client.delete(url, headers: _getHeaders());
  }
}

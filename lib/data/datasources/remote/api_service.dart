import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://sandbox.zainpay.ng";
  static const String _authToken =
      "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwczovL3phaW5wYXkubmciLCJpYXQiOjE2OTIzNTcxMzEsImlkIjpmZDMxODYxNy00MGQyLTQzZGYtYTJjMi0wNTIwNGQ1NDM1YmQsIm5hbWUiOmhhdXdhLmRhbGhhdHVAaG90bWFpbC5jb20sInJvbGUiOmhhdXdhLmRhbGhhdHVAaG90bWFpbC5jb20sInNlY3JldEtleSI6Y2tJM2w1cko5VXZ5bWJUbDZGQkNHbUwwNElIcmdzOVFOaUxCMk0waHBqVjdPfQ.BhLQzwEzMGs2fNj1As12i3zhl9w0M66mOo-kDPGwrUM";

  final http.Client client;
  ApiService({http.Client? client}) : client = client ?? http.Client();

  /// ---- GET ----
  Future<Map<String, dynamic>> get(String endpoint) async {
    final url = Uri.parse("$baseUrl$endpoint");
    final response = await client.get(url, headers: _headers);
    return _handleResponse(response);
  }

  /// ---- POST ----
  Future<Map<String, dynamic>> post(
      String endpoint,
      Map<String, dynamic> body,
      ) async {
    final url = Uri.parse("$baseUrl$endpoint");
    final response = await client.post(
      url,
      headers: _headers,
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  /// ---- PUT ----
  Future<Map<String, dynamic>> put(
      String endpoint,
      Map<String, dynamic> body,
      ) async {
    final url = Uri.parse("$baseUrl$endpoint");
    final response = await client.put(
      url,
      headers: _headers,
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  /// ---- DELETE ----
  Future<Map<String, dynamic>> delete(String endpoint) async {
    final url = Uri.parse("$baseUrl$endpoint");
    final response = await client.delete(url, headers: _headers);
    return _handleResponse(response);
  }

  /// ---- Common headers ----
  Map<String, String> get _headers => {
    "Content-Type": "application/json",
    "Authorization": _authToken,
  };

  /// ---- Response handler ----
  Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['code'] == '00') {
        return data;
      } else {
        throw Exception(data['description'] ?? 'API call failed');
      }
    } catch (e) {
      debugPrint('Failed to decode response: ${response.body}');
      throw Exception('Invalid response from server: ${response.body}');
    }
  }
}

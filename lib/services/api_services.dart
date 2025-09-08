import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://sandbox.zainpay.ng";

  /// ⚠️ For now, token is hardcoded. In production, store in env/config.
  static const String _authToken =
      "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9."
      "eyJpc3MiOiJodHRwczovL3phaW5wYXkubmciLCJpYXQiOjE2OTIzNTcxMzEsImlkIjpmZDMxODYxNy00MGQyLTQzZGYtYTJjMi0wNTIwNGQ1NDM1YmQs"
      "Im5hbWUiOmhhdXdhLmRhbGhhdHVAaG90bWFpbC5jb20sInJvbGUiOmhhdXdhLmRhbGhhdHVAaG90bWFpbC5jb20sInNlY3JldEtleSI6Y2tJM2w1cko5"
      "VXZ5bWJUbDZGQkNHbUwwNElIcmdzOVFOaUxCMk0waHBqVjdPfQ.BhLQzwEzMGs2fNj1As12i3zhl9w0M66mOo-kDPGwrUM";

  final http.Client client;

  ApiService({http.Client? client}) : client = client ?? http.Client();

  // ---------- HTTP Methods ---------- //

  /// GET request
  Future<Map<String, dynamic>> get(String endpoint) async {
    final url = Uri.parse("$baseUrl$endpoint");
    final response = await client.get(url, headers: _headers);
    return _handleResponse(response);
  }

  /// POST request
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

  /// PUT request
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

  /// DELETE request
  Future<Map<String, dynamic>> delete(String endpoint) async {
    final url = Uri.parse("$baseUrl$endpoint");
    final response = await client.delete(url, headers: _headers);
    return _handleResponse(response);
  }

  // ---------- Helpers ---------- //

  Map<String, String> get _headers => {
    "Content-Type": "application/json",
    "Authorization": _authToken,
  };

  Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['code'] == '00') {
        return data as Map<String, dynamic>;
      } else {
        final message = data['description'] ?? 'Unknown API error';
        throw ApiException(message, statusCode: response.statusCode);
      }
    } catch (e) {
      throw ApiException(
        "Failed to parse response: $e",
        statusCode: response.statusCode,
      );
    }
  }

  void dispose() {
    client.close();
  }
}

// ---------- Custom Exception ---------- //

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

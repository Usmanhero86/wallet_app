import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://sandbox.zainpay.ng";
  static const String _authToken = "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwczovL3phaW5wYXkubmciLCJpYXQiOjE2OTIzNTcxMzEsImlkIjpmZDMxODYxNy00MGQyLTQzZGYtYTJjMi0wNTIwNGQ1NDM1YmQsIm5hbWUiOmhhdXdhLmRhbGhhdHVAaG90bWFpbC5jb20sInJvbGUiOmhhdXdhLmRhbGhhdHVAaG90bWFpbC5jb20sInNlY3JldEtleSI6Y2tJM2w1cko5VXZ5bWJUbDZGQkNHbUwwNElIcmdzOVFOaUxCMk0waHBqVjdPfQ.BhLQzwEzMGs2fNj1As12i3zhl9w0M66mOo-kDPGwrUM";

  final http.Client client;
  ApiService({http.Client? client}) : client = client ?? http.Client();

  Future<Map<String, dynamic>> get(String endpoint) async {
    final url = Uri.parse("$baseUrl$endpoint");
    final response = await client.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": _authToken,
      },
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse("$baseUrl$endpoint");
    final response = await client.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": _authToken,
      },
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['code'] == '00') {
      return data;
    } else {
      throw Exception(data['description'] ?? 'API call failed');
    }
  }
}

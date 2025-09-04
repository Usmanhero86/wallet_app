import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../domain/entities/account.dart';

class AccountApi {
  final String baseUrl;
  final String authToken;

  AccountApi({required this.baseUrl, required this.authToken});

  Future<Account> createVirtualAccount(Map<String, dynamic> payload) async {
    final url = Uri.parse('$baseUrl/virtual-account/create');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': authToken,
      },
      body: jsonEncode(payload),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['code'] == '00') {
      return Account(
        accountNumber: data['data']['accountNumber'],
        accountName: data['data']['accountName'],
      );
    } else {
      throw Exception(data['description'] ?? 'Failed to create account');
    }
  }
}

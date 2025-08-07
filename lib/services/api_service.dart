import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../model/balance_response.dart';
import '../model/transaction_history.dart';
import '../storage/save_account.dart';



class ApiService {
  static const baseUrl = 'https://sandbox.zainpay.ng';
  static const secretKey = 'ckI3l5rJ9UvymbTl6FBCGmL04IHrgs9QNiLB2M0hpjV7O';
  String authToken =   'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwczovL3phaW5wYXkubmciLCJpYXQiOjE2OTIzNTcxMzEsImlkIjpmZDMxODYxNy00MGQyLTQzZGYtYTJjMi0wNTIwNGQ1NDM1YmQsIm5hbWUiOmhhdXdhLmRhbGhhdHVAaG90bWFpbC5jb20sInJvbGUiOmhhdXdhLmRhbGhhdHVAaG90bWFpbC5jb20sInNlY3JldEtleSI6Y2tJM2w1cko5VXZ5bWJUbDZGQkNHbUwwNElIcmdzOVFOaUxCMk0waHBqVjdPfQ.BhLQzwEzMGs2fNj1As12i3zhl9w0M66mOo-kDPGwrUM';

      static Future<Map<String, dynamic>> createVirtualAccount(Map<String, dynamic> payload) async {
    final url = Uri.parse('https://sandbox.zainpay.ng/virtual-account/create/request');
    print('Sending payload: $payload');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwczovL3phaW5wYXkubmciLCJpYXQiOjE2OTIzNTcxMzEsImlkIjpmZDMxODYxNy00MGQyLTQzZGYtYTJjMi0wNTIwNGQ1NDM1YmQsIm5hbWUiOmhhdXdhLmRhbGhhdHVAaG90bWFpbC5jb20sInJvbGUiOmhhdXdhLmRhbGhhdHVAaG90bWFpbC5jb20sInNlY3JldEtleSI6Y2tJM2w1cko5VXZ5bWJUbDZGQkNHbUwwNElIcmdzOVFOaUxCMk0waHBqVjdPfQ.BhLQzwEzMGs2fNj1As12i3zhl9w0M66mOo-kDPGwrUM',
      },
      body: jsonEncode(payload),
    );
    print(response.body);
    return jsonDecode(response.body);
  }


  static Future<BalanceResponse> getWalletBalance(String key) async {
    // final key = await getAccountName();
    final url = Uri.parse('https://sandbox.zainpay.ng/virtual-account/wallet/balance/$key');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwczovL3phaW5wYXkubmciLCJpYXQiOjE2OTIzNTcxMzEsImlkIjpmZDMxODYxNy00MGQyLTQzZGYtYTJjMi0wNTIwNGQ1NDM1YmQsIm5hbWUiOmhhdXdhLmRhbGhhdHVAaG90bWFpbC5jb20sInJvbGUiOmhhdXdhLmRhbGhhdHVAaG90bWFpbC5jb20sInNlY3JldEtleSI6Y2tJM2w1cko5VXZ5bWJUbDZGQkNHbUwwNElIcmdzOVFOaUxCMk0waHBqVjdPfQ.BhLQzwEzMGs2fNj1As12i3zhl9w0M66mOo-kDPGwrUM',
      },
    );
    print(response.body);
    final Map<String, dynamic> data = jsonDecode(response.body);
    if (data['code'] == '00' || data['status'] == '200 OK') {
      final balance = data['data']['balanceAmount'];
      return BalanceResponse.fromJson(balance);
    } else {
      throw Exception('Failed to fetch wallet balance: ${data['description']}');
    }
  }


  // Add login method
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'token': responseData['token'],
          'user': responseData['user'],
        };
      } else {
        throw PlatformException(
          code: 'LOGIN_FAILED',
          message: responseData['message'] ?? 'Login failed',
        );
      }
    } catch (e) {
      throw PlatformException(
        code: 'LOGIN_ERROR',
        message: 'Failed to login: ${e.toString()}',
      );
    }
  }


  static Future<List<TransactionItem>> getTransactionDetails() async {
    final key = await getAccountName();
    final url = Uri.parse('https://sandbox.zainpay.ng/virtual-account/wallet/transactions/$key');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwczovL3phaW5wYXkubmciLCJpYXQiOjE2OTIzNTcxMzEsImlkIjpmZDMxODYxNy00MGQyLTQzZGYtYTJjMi0wNTIwNGQ1NDM1YmQsIm5hbWUiOmhhdXdhLmRhbGhhdHVAaG90bWFpbC5jb20sInJvbGUiOmhhdXdhLmRhbGhhdHVAaG90bWFpbC5jb20sInNlY3JldEtleSI6Y2tJM2w1cko5VXZ5bWJUbDZGQkNHbUwwNElIcmdzOVFOaUxCMk0waHBqVjdPfQ.BhLQzwEzMGs2fNj1As12i3zhl9w0M66mOo-kDPGwrUM',
      },
    );

    print(response.body);

    final Map<String, dynamic> data = jsonDecode(response.body);

    if (data['code'] == '00' || data['status'] == '200 OK') {
      final List<dynamic> rawList = data['data'];
      return rawList.map((item) => TransactionItem.fromJson(item)).toList();
    } else {
      throw Exception('Failed to fetch transactions: ${data['description']}');
    }
  }

  static Future<Map<String, dynamic>> sendPayment(
      String recipientAccount,
      double amount,
      String reference,
      String authToken,
      ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/payments/send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'recipient_account': recipientAccount,
          'amount': amount,
          'reference': reference,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Payment sent successfully',
          'data': responseData,
        };
      } else {
        throw PlatformException(
          code: 'API_ERROR',
          message: responseData['message'] ?? 'Failed to send payment',
        );
      }
    } on PlatformException catch (e) {
      rethrow;
    } catch (e) {
      throw PlatformException(
        code: 'UNKNOWN_ERROR',
        message: 'An unexpected error occurred',
      );
    }
  }
}
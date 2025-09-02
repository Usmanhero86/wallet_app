import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../model/balance_response.dart';
import '../model/transaction_history.dart';
import '../storage/save_account.dart';

class ApiService {
  static const baseUrl = 'https://sandbox.zainpay.ng';
  static const _authToken =
      'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwczovL3phaW5wYXkubmciLCJpYXQiOjE2OTIzNTcxMzEsImlkIjpmZDMxODYxNy00MGQyLTQzZGYtYTJjMi0wNTIwNGQ1NDM1YmQsIm5hbWUiOmhhdXdhLmRhbGhhdHVAaG90bWFpbC5jb20sInJvbGUiOmhhdXdhLmRhbGhhdHVAaG90bWFpbC5jb20sInNlY3JldEtleSI6Y2tJM2w1cko5VXZ5bWJUbDZGQkNHbUwwNElIcmdzOVFOaUxCMk0waHBqVjdPfQ.BhLQzwEzMGs2fNj1As12i3zhl9w0M66mOo-kDPGwrUM';

  // ---------------- CREATE VIRTUAL ACCOUNT ----------------
  static Future<Map<String, dynamic>> createVirtualAccount(Map<String, dynamic> payload) async {
    try {
      final url =
      Uri.parse('$baseUrl/virtual-account/create/request');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': _authToken,
        },
        body: jsonEncode(payload),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['code'] == '00') {
        return data;
      } else {
        throw PlatformException(
          code: 'ACCOUNT_CREATION_FAILED',
          message: data['description'] ?? 'Failed to create account',
        );
      }
    } catch (e) {
      throw PlatformException(
        code: 'ACCOUNT_ERROR',
        message: 'Error creating virtual account: ${e.toString()}',
      );
    }
  }

  // ---------------- GET WALLET BALANCE ----------------
  static Future<BalanceResponse> getWalletBalance(String key) async {
    try {
      final url =
      Uri.parse('$baseUrl/virtual-account/wallet/balance/$key');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': _authToken,
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['code'] == '00') {
        return BalanceResponse.fromJson(data['data']);
      } else {
        throw PlatformException(
          code: 'BALANCE_ERROR',
          message: data['description'] ?? 'Failed to fetch wallet balance',
        );
      }
    } catch (e) {
      throw PlatformException(
        code: 'BALANCE_EXCEPTION',
        message: 'Error fetching balance: ${e.toString()}',
      );
    }
  }

  // ---------------- LOGIN ----------------
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'token': data['token'],
          'user': data['user'],
        };
      } else {
        throw PlatformException(
          code: 'LOGIN_FAILED',
          message: data['message'] ?? 'Invalid email or password',
        );
      }
    } catch (e) {
      throw PlatformException(
        code: 'LOGIN_ERROR',
        message: 'Error logging in: ${e.toString()}',
      );
    }
  }

  // ---------------- GET TRANSACTION DETAILS ----------------
  static Future<List<TransactionItem>> getTransactionDetails() async {
    try {
      final key = await getAccountName();
      final url =
      Uri.parse('$baseUrl/virtual-account/wallet/transactions/$key');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': _authToken,
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['code'] == '00') {
        final List<dynamic> rawList = data['data'];
        return rawList
            .map((item) => TransactionItem.fromJson(item))
            .toList();
      } else {
        throw PlatformException(
          code: 'TRANSACTION_FAILED',
          message: data['description'] ?? 'Failed to fetch transactions',
        );
      }
    } catch (e) {
      throw PlatformException(
        code: 'TRANSACTION_ERROR',
        message: 'Error fetching transactions: ${e.toString()}',
      );
    }
  }

  // ---------------- SEND PAYMENT ----------------
  static Future<Map<String, dynamic>> sendPayment({required double amount, required String narration, required String recipientAccount,}) async {
    final url = Uri.parse('$baseUrl/payments/transfer');

    final body = {
      'amount': amount,
      'narration': narration,
      'recipientAccount': recipientAccount,
    };

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_authToken',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Payment failed: ${response.body}');
    }
  }

  // ---------------- RECEIVE PAYMENT ----------------
  static Future<List<Map<String, dynamic>>> receivePayments() async {
    final url = Uri.parse('$baseUrl/payments/transactions'); // adjust to actual endpoint

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_authToken', // use your real auth
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // assume API returns { "data": [ {...}, {...} ] }
      final List transactions = data['data'] ?? [];

      return transactions.cast<Map<String, dynamic>>();
    } else {
      throw Exception(
        'Failed to fetch received payments: ${response.statusCode} → ${response.body}',
      );
    }
  }

}

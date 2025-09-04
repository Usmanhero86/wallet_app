import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:wallet_app/data/datasources/remote/account_remote_datasource.dart';

import '../../domain/entities/account_response.dart';
import '../../domain/entities/transaction_history.dart';
import '../../domain/entities/wallet_balance.dart';

class AccountRemoteDataSourceImpl implements AccountRemoteDataSource {
  static const String baseUrl = 'https://sandbox.zainpay.ng';
  static const String _authToken = 'Bearer <your_token>';

  @override
  Future<AccountResponse> createVirtualAccount(Map<String, dynamic> payload) async {
    final url = Uri.parse('$baseUrl/virtual-account/create');
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
      return AccountResponse.fromJson(data['data']);
    } else {
      throw PlatformException(
        code: 'ACCOUNT_FAILED',
        message: data['description'] ?? 'Failed to create account',
      );
    }
  }

  @override
  Future<WalletBalance> getWalletBalance(String key) async {
    final url = Uri.parse('$baseUrl/virtual-account/wallet/balance/$key');
    final response = await http.get(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': _authToken,
    });

    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['code'] == '00') {
      return WalletBalance.fromJson(data['data']);
    } else {
      throw PlatformException(
        code: 'BALANCE_FAILED',
        message: data['description'] ?? 'Failed to fetch balance',
      );
    }
  }

  @override
  Future<List<TransactionItem>> getTransactions(String key) async {
    final url = Uri.parse('$baseUrl/virtual-account/wallet/transactions/$key');
    final response = await http.get(url, headers: {
      'Content-Type': 'application/json',
      'Authorization': _authToken,
    });

    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['code'] == '00') {
      final List<dynamic> rawList = data['data'];
      return rawList.map((item) => TransactionItem.fromJson(item)).toList();
    } else {
      throw PlatformException(
        code: 'TRANSACTION_FAILED',
        message: data['description'] ?? 'Failed to fetch transactions',
      );
    }
  }

  @override
  Future<String> sendPayment(double amount, String narration, String recipientAccount) async {
    final url = Uri.parse('$baseUrl/payments');
    final response = await http.post(url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': _authToken,
        },
        body: jsonEncode({
          'amount': amount,
          'narration': narration,
          'recipientAccount': recipientAccount,
        }));

    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['code'] == '00') {
      return 'success';
    } else if (data['code'] == 'INSUFFICIENT_FUNDS') {
      return 'insufficient';
    } else {
      return 'failed';
    }
  }
}

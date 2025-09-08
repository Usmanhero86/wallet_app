import 'package:flutter/cupertino.dart';

import '../../../domain/entities/account_response.dart';
import '../../../domain/entities/bank.dart';
import '../../../domain/entities/transaction_history.dart';
import '../../../domain/entities/wallet_balance.dart';
import 'api_service.dart';

abstract class AccountRemoteDataSource {
  Future<AccountResponse> createVirtualAccount(Map<String, dynamic> payload);
  Future<WalletBalance> getWalletBalance(String key);
  Future<List<TransactionItem>> getTransactions(String key);
  Future<String> sendPayment(double amount, String narration, String recipientAccount, payload);
  Future<List<Bank>> getBankList();
}

class AccountRemoteDataSourceImpl implements AccountRemoteDataSource {
  final ApiService apiService;

  AccountRemoteDataSourceImpl(this.apiService);

  @override
  Future<AccountResponse> createVirtualAccount(Map<String, dynamic> payload) async {
    final data = await apiService.post("/virtual-account/create/request", payload);
    return AccountResponse.fromJson(data["data"]);
  }

  @override
  Future<List<Bank>> getBankList() async {
    final response = await apiService.get("/bank/list"); // API endpoint
    final List<dynamic> banksJson = response['data'] ?? [];
    return banksJson.map((json) => Bank.fromJson(json)).toList();
  }


  @override
  Future<WalletBalance> getWalletBalance(String key) async {
    final data = await apiService.get("/virtual-account/wallet/balance/$key");
    return WalletBalance.fromJson(data["data"]);
  }

  @override
  Future<List<TransactionItem>> getTransactions(String key) async {
    final data = await apiService.get("/virtual-account/wallet/transactions/$key");
    final List<dynamic> rawList = data["data"];
    return rawList.map((e) => TransactionItem.fromJson(e)).toList();
  }

  @override
  Future<String> sendPayment(double amount, String narration, String recipientAccount, dynamic payload,) async {
    final data = await apiService.post("/payments", payload as Map<String, dynamic>);
    return data["code"] == "00" ? "success" : "failed";
  }



}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/balance_response.dart';
import '../model/model.dart';
import '../model/transaction_history.dart';
import 'api_service.dart';
import '../view/dashboard_screen.dart';


class AccountProvider with ChangeNotifier {
  final List<Map<String, dynamic>> _createdAccounts = [];
  bool isLoading = false;
  VirtualAccountResponse? accountResponse;
  BalanceResponse? balanceResponse;
  String? error;
  int walletBalance = 10000;
  bool loading = false;

  bool hasFetchedWalletBalance = false;
  bool hasFetchedTransaction = false;
  List<TransactionItem> _transactions = [];
  List<TransactionItem> get transactions => _transactions;
  List<TransactionItem> _sentPayments = [];
  List<TransactionItem> get sentPayments => _sentPayments;

  Future<void> recordSentPayment(TransactionItem payment) async {
    _sentPayments.add(payment);
    walletBalance -= payment.amount;
    notifyListeners();

    // Save to shared preferences for persistence
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('balance', walletBalance);
    final paymentsJson = _sentPayments.map((p) => p.toJson()).toList();
    await prefs.setString('sent_payments', jsonEncode(paymentsJson));
    notifyListeners();
  }

  // Add this to load payments when provider initializes
  Future<void> loadSentPayments() async {
    final prefs = await SharedPreferences.getInstance();
    final paymentsJson = prefs.getString('sent_payments');
    if (paymentsJson != null) {
      _sentPayments = (jsonDecode(paymentsJson) as List)
          .map((json) => TransactionItem.fromJson(json))
          .toList();
      notifyListeners();
    }
    }


  Future<void> fetchWalletBalance(BuildContext context) async {
    if (loading || hasFetchedWalletBalance) return;

    loading = true;
    notifyListeners();

    try {
      final result = await ApiService.getWalletBalance();
      walletBalance = result;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('balance', walletBalance);

      hasFetchedWalletBalance = true;
      print('Wallet balance saved: $walletBalance');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } catch (e) {
      debugPrint('Fetch balance error: $e');
      error = 'Failed to fetch wallet balance';
    } finally {
      loading = false;
      notifyListeners();
    }
  }
  Future<void> fetchTransaction(BuildContext context) async {
    if (loading || hasFetchedTransaction) return;

    loading = true;
    notifyListeners();

    try {
      final result = await ApiService.getTransactionDetails();
      _transactions = [...result, ..._sentPayments];
      _transactions.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
      hasFetchedTransaction = true;

      print("Transactions fetched: ${_transactions.length}");


    } catch (e) {
      debugPrint('Fetch transaction error: $e');
      error = 'Failed to fetch transactions';
    } finally {
      loading = false;
      notifyListeners();
    }
  }
  List<Map<String, dynamic>> get createdAccounts => _createdAccounts;
  Future<void> createVirtualAccount(Map<String, dynamic> payload, BuildContext context) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final result = await ApiService.createVirtualAccount(payload);
      if (result['status'] == '200 OK') {
        accountResponse = VirtualAccountResponse.fromJson(result);
        final accountName = accountResponse?.accountNumber;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accountResponse', jsonEncode(accountResponse?.toJson()));
        await prefs.setString('accountName', accountName ?? '');
        print('Account number saved: $accountName');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Account created successfully!')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      }
    } catch (e) {
      error = 'Error: ${e.toString()}';
      // Only show error if it's not a successful creation
      if (!(e.toString().contains('200'))) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }



    // isLoading = false;
    // notifyListeners();
  }
  Future<void> loadAccountInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('accountResponse');
    if (jsonString != null) {
      accountResponse = VirtualAccountResponse.fromJson(jsonDecode(jsonString));
      notifyListeners();
    }
  }



}
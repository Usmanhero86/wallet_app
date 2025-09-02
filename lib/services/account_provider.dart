import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/balance_response.dart';
import '../model/model.dart';
import '../model/transaction_history.dart';
import '../storage/save_account.dart';
import 'api_service.dart';
import '../view/dashboard_screen.dart';

/// State enum for provider
enum ProviderState { idle, loading, success, error }

class AccountProvider with ChangeNotifier {
  /// -------- STATE --------
  ProviderState state = ProviderState.idle;
  String? errorMessage;

  VirtualAccountResponse? accountResponse;
  BalanceResponse? balanceResponse;

  double walletBalance = 0.0;
  List<TransactionItem> _transactions = [];
  List<TransactionItem> _sentPayments = [];
  List<Map<String, dynamic>> createdAccounts = [];

  bool hasFetchedWalletBalance = false;
  bool hasFetchedTransaction = false;
  bool _isInitialized = false;

  List<TransactionItem> get transactions => _transactions;
  List<TransactionItem> get sentPayments => _sentPayments;
  List<TransactionItem> get allTransactions =>
      [..._transactions, ..._sentPayments];

  /// -------- CALCULATED VALUES --------
  double get totalIncome => allTransactions
      .where((t) => t.transactionType == 'credit')
      .fold(0, (sum, t) => sum + t.amount);

  double get totalExpenses => allTransactions
      .where((t) => t.transactionType == 'debit')
      .fold(0, (sum, t) => sum + t.amount);

  AccountProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    if (_isInitialized) return;
    await loadInitialBalance();
    await loadSentPayments();
    await loadAccountInfo();
    _isInitialized = true;
  }

  /// -------- STATE HELPERS --------
  void _setState(ProviderState newState, {String? error}) {
    state = newState;
    errorMessage = error;
    notifyListeners();
  }

  bool get isLoading => state == ProviderState.loading;
  bool get hasError => state == ProviderState.error;

  /// -------- CREATE ACCOUNT --------
  Future<void> createVirtualAccount(Map<String, dynamic> payload, BuildContext context) async {
    _setState(ProviderState.loading);
    try {
      final result = await ApiService.createVirtualAccount(payload);
      accountResponse = VirtualAccountResponse.fromJson(result);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('accountResponse', jsonEncode(result));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created successfully!')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );

      _setState(ProviderState.success);
    } catch (e) {
      _setState(ProviderState.error, error: e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  /// -------- PAYMENTS --------
  Future<String> sendPayment(double amount, String narration, String recipientAccount) async {
    _setState(ProviderState.loading);

    try {
      if (accountResponse == null) {
        _setState(ProviderState.error, error: 'Account not created');
        return 'no_account';
      }

      if (amount <= 100) {
        _setState(ProviderState.error, error: 'Invalid amount');
        return 'invalid_amount';
      }

      if (walletBalance < amount) {
        _setState(ProviderState.error, error: 'Insufficient funds');
        return 'insufficient';
      }

      final response = await ApiService.sendPayment(
        amount: amount,
        narration: narration,
        recipientAccount: recipientAccount,
      );

      if (response['code'] == '00') {
        walletBalance -= amount;

        final transaction = TransactionItem(
          accountNumber: await getAccountName() ?? 'N/A',
          destinationAccountNumber: recipientAccount,
          amount: amount,
          balance: walletBalance,
          narration: narration,
          transactionDate: DateTime.now(),
          transactionRef: response['transactionRef'] ??
              'TXN_${DateTime.now().millisecondsSinceEpoch}',
          transactionType: 'debit',
        );

        await recordSentPayment(transaction);

        _setState(ProviderState.success);
        return 'success';
      } else {
        _setState(ProviderState.error, error: response['description'] ?? 'Transaction failed');
        return 'failed';
      }
    } catch (e) {
      _setState(ProviderState.error, error: e.toString());
      return 'error';
    }
  }

  Future<void> recordSentPayment(TransactionItem payment) async {
    _sentPayments.insert(0, payment); // newest first
    await saveSentPayments(_sentPayments);
    await _saveBalance();
    notifyListeners();
  }

  Future<void> receivePayment(double amount, String narration, String senderAccount) async {
    if (accountResponse == null) {
      throw Exception('Please create an account first before receiving money');
    }

    walletBalance += amount;

    final transaction = TransactionItem(
      accountNumber: await getAccountName() ?? 'N/A',
      destinationAccountNumber: accountResponse!.accountNumber,
      amount: amount,
      balance: walletBalance,
      narration: narration,
      transactionDate: DateTime.now(),
      transactionRef: 'RCV_${DateTime.now().millisecondsSinceEpoch}',
      transactionType: 'credit',
    );

    _transactions.insert(0, transaction);
    await saveSentPayments([..._sentPayments, transaction]);
    await _saveBalance();
    notifyListeners();
  }

  /// -------- BALANCE --------
  Future<void> fetchWalletBalance(BuildContext context, String key) async {
    if (hasFetchedWalletBalance) return;
    _setState(ProviderState.loading);
    try {
      final result = await ApiService.getWalletBalance(key);
      walletBalance = result.data.balanceAmount;
      await _saveBalance();

      hasFetchedWalletBalance = true;
      _setState(ProviderState.success);
    } catch (e) {
      _setState(ProviderState.error, error: 'Failed to fetch balance');
    }
  }

  Future<void> _saveBalance() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('balance', walletBalance);
  }

  Future<void> loadInitialBalance() async {
    final prefs = await SharedPreferences.getInstance();
    final savedBalance = prefs.getDouble('balance');
    if (savedBalance != null) {
      walletBalance = savedBalance;
      notifyListeners();
    }
  }

  /// -------- TRANSACTIONS --------
  Future<void> fetchTransaction(BuildContext context) async {
    _setState(ProviderState.loading);
    try {
      final result = await ApiService.getTransactionDetails();
      _transactions = result
        ..sort((a, b) => b.transactionDate.compareTo(a.transactionDate));

      await fetchWalletBalance(context, await getAccountName() ?? '');

      hasFetchedTransaction = true;
      _setState(ProviderState.success);
    } catch (e) {
      _setState(ProviderState.error, error: 'Failed to fetch transactions');
    }
  }

  /// -------- PERSISTENCE --------
  Future<void> saveSentPayments(List<TransactionItem> payments) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = payments.map((e) => e.toJson()).toList();
    await prefs.setString('sent_payments', jsonEncode(jsonList));
  }

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

  Future<void> loadAccountInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('accountResponse');
    if (jsonString != null) {
      accountResponse = VirtualAccountResponse.fromJson(jsonDecode(jsonString));
      notifyListeners();
    }
  }

  void addCreatedAccount(Map<String, dynamic> account) {
    createdAccounts.add(account);
    notifyListeners();
  }
}

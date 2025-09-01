import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/balance_response.dart';
import '../model/model.dart';
import '../model/transaction_history.dart';
import '../storage/save_account.dart';
import 'api_service.dart';
import '../view/dashboard_screen.dart';

class AccountProvider with ChangeNotifier {
  bool isLoading = false;
  VirtualAccountResponse? accountResponse;
  BalanceResponse? balanceResponse;
  String? error;
  double walletBalance = 10000;
  bool loading = false;
  bool hasFetchedWalletBalance = false;
  bool hasFetchedTransaction = false;
  List<Map<String, dynamic>> createdAccounts = [];
  List<TransactionItem> _transactions = [];
  List<TransactionItem> get transactions => _transactions;
  List<TransactionItem> _sentPayments = [];
  List<TransactionItem> get sentPayments => _sentPayments;
  bool _isInitialized = false;
  double get totalIncome {
    return _sentPayments
        .where((t) => t.transactionType == 'credit')
        .fold(0, (sum, t) => sum + t.amount);
  }

  double get totalExpenses {
    return _sentPayments
        .where((t) => t.transactionType == 'debit')
        .fold(0, (sum, t) => sum + t.amount);
  }

  List<TransactionItem> get allTransactions => _sentPayments;


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

  Future<void> recordSentPayment(TransactionItem payment) async {
    _sentPayments.add(payment);
    await updateBalance(payment.amount);
    walletBalance -= payment.amount;
    notifyListeners();

    // Save to shared preferences for persistence
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('balance', walletBalance);
    final paymentsJson = _sentPayments.map((p) => p.toJson()).toList();
    await prefs.setString('sent_payments', jsonEncode(paymentsJson));
    notifyListeners();
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

  Future<void> loadInitialBalance() async {
    final prefs = await SharedPreferences.getInstance();
    final savedBalance = prefs.getDouble('balance');
    if (savedBalance != null) {
      walletBalance = savedBalance;
      notifyListeners();
    }
  }

  Future<void> receivePayment(double amount, String narration, String senderAccount) async {
    if (accountResponse == null) {
      throw Exception('Please create an account first before receiving money');
    }

    final transaction = TransactionItem(
      accountNumber: await getAccountName() ?? 'N/A',
      destinationAccountNumber: accountResponse!.accountNumber, // your account
      amount: amount,
      balance: walletBalance + amount,
      narration: narration,
      transactionDate: DateTime.now(),
      transactionRef: 'RCV_${DateTime.now().millisecondsSinceEpoch}',
      transactionType: 'credit', // incoming
    );

    _sentPayments.add(transaction);
    walletBalance += amount.toInt();

    await saveSentPayments(_sentPayments);
    notifyListeners();
  }

  Future<void> recordIncomingPayment(TransactionItem payment) async {
    _transactions.add(payment);
    await updateBalance(payment.amount, isCredit: true);
    notifyListeners();
  }

  Future<void> updateBalance(double amount, {bool isCredit = false}) async {
    walletBalance = isCredit
        ? walletBalance + amount
        : walletBalance - amount;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('balance', walletBalance);
    notifyListeners();
  }

  Future<void> fetchWalletBalance(BuildContext context, String key) async {
    if (loading || hasFetchedWalletBalance) return;

    loading = true;
    notifyListeners();

    try {
      final result = await ApiService.getWalletBalance(key);
      walletBalance = result.data.balanceAmount;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('balance', walletBalance);

      hasFetchedWalletBalance = true;
      debugPrint('Wallet balance: ₦$walletBalance');
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
      _transactions = result;

      for (final transaction in _transactions.where((t) => t.transactionType == 'credit')) {
        await updateBalance(transaction.amount, isCredit: true);
      }

      _transactions = [...result, ..._sentPayments];
      _transactions.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
      hasFetchedTransaction = true;

      debugPrint("Transactions fetched: ${_transactions.length}");
    } catch (e) {
      debugPrint('Fetch transaction error: $e');
      error = 'Failed to fetch transactions';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> createVirtualAccount(Map<String, dynamic> payload, BuildContext context) async {


    try {
      isLoading = true;
      error = null;
      notifyListeners();
      final result = await ApiService.createVirtualAccount(payload);
      if (result['status'] == '200 OK') {
        accountResponse = VirtualAccountResponse.fromJson(result);
        final accountName = accountResponse?.accountNumber;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('accountResponse', jsonEncode(accountResponse?.toJson()));
        await prefs.setString('accountName', accountName ?? '');

        debugPrint('Account number saved: $accountName');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created successfully!')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      }
    } catch (e) {
      error = 'Error: ${e.toString()}';
      if (!(e.toString().contains('200'))) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      isLoading = false;
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

  Future<void> sendPayment(double amount, String narration, String recipientAccount) async {
    if (accountResponse == null) {
      // No account created
      throw Exception('Please create an account first before sending money');
    }
    final transaction = TransactionItem(
      accountNumber: await getAccountName() ?? 'N/A',
      destinationAccountNumber: recipientAccount,
      amount: amount,
      balance: walletBalance - amount,
      narration: narration,
      transactionDate: DateTime.now(),
      transactionRef: 'TXN_${DateTime.now().millisecondsSinceEpoch}',
      transactionType: 'debit',
    );

    _sentPayments.add(transaction);
    walletBalance -= amount.toInt();

    await saveSentPayments(_sentPayments);
    notifyListeners();
  }
}

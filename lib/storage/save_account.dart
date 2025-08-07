import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../model/transaction_history.dart';
Future<void> saveAccountName(String accountName) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('accountName', accountName);

}

Future<String?> getAccountName() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('accountName');
}
Future<void> saveSentPayments(List<TransactionItem> payments) async {
  final prefs = await SharedPreferences.getInstance();
  final paymentsJson = payments.map((p) => p.toJson()).toList();
  await prefs.setString('sentPayments', jsonEncode(paymentsJson));
}


import '../domain/entities/account_response.dart';
import '../domain/entities/transaction_history.dart';
import '../domain/entities/wallet_balance.dart';

abstract class AccountRepository {
  Future<AccountResponse> createVirtualAccount(Map<String, dynamic> payload);
  Future<WalletBalance> getWalletBalance(String key);
  Future<List<TransactionItem>> getTransactions(String key);
  Future<String> sendPayment(double amount, String narration, String recipientAccount);

  // Optional: persistence for sent payments
  Future<void> saveSentPayments(List<TransactionItem> payments);
  Future<List<TransactionItem>> loadSentPayments();
}

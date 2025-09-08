import '../entities/account_response.dart';
import '../entities/bank.dart';
import '../entities/transaction_history.dart';
import '../entities/wallet_balance.dart';

abstract class AccountRepository {
  Future<AccountResponse> createVirtualAccount(Map<String, dynamic> payload);
  Future<WalletBalance> getWalletBalance(String key);
  Future<List<TransactionItem>> getTransactionDetails();
  Future<String> sendPayment(double amount, String narration, String recipientAccount, String bankCode);
  Future<void> saveSentPayments(List<TransactionItem> payments);
  Future<List<TransactionItem>> loadSentPayments();
  Future<List<Bank>> getBankList();
}

import 'package:get_storage/get_storage.dart';
import '../../domain/entities/account_response.dart';
import '../../domain/entities/bank.dart';
import '../../domain/entities/transaction_history.dart';
import '../../domain/entities/wallet_balance.dart';
import '../../domain/repositories/account_repository.dart';
import '../datasources/remote/account_remote_datasource.dart';

class AccountRepositoryImpl implements AccountRepository {
  final AccountRemoteDataSource remoteDataSource;
  final GetStorage storage;

  AccountRepositoryImpl({
    required this.remoteDataSource,
    GetStorage? storage,
  }) : storage = storage ?? GetStorage();

  @override
  Future<AccountResponse> createVirtualAccount(Map<String, dynamic> payload) {
    return remoteDataSource.createVirtualAccount(payload);
  }

  @override
  Future<WalletBalance> getWalletBalance(String key) {
    return remoteDataSource.getWalletBalance(key);
  }

  @override
  Future<List<TransactionItem>> getTransactions(String key) {
    return remoteDataSource.getTransactions(key);
  }

  @override
  Future<String> sendPayment(
      double amount,
      String narration,
      String recipientAccount,
      String bankCode,
      ) {
    final payload = {
      'amount': amount,
      'narration': narration,
      'recipientAccount': recipientAccount,
      'bankCode': bankCode,
    };

    return remoteDataSource.sendPayment(amount, narration, recipientAccount, payload);
  }




  @override
  Future<void> saveSentPayments(List<TransactionItem> payments) async {
    await storage.write(
      'sentPayments',
      payments.map((e) => e.toJson()).toList(),
    );
  }

  @override
  Future<List<TransactionItem>> loadSentPayments() async {
    final raw = storage.read<List>('sentPayments') ?? [];
    return raw
        .map((e) => TransactionItem.fromJson(
      Map<String, dynamic>.from(e as Map),
    ))
        .toList();
  }

  //  Get list of banks
  @override
  Future<List<Bank>> getBankList() {
    return remoteDataSource.getBankList();
  }

  //  Example placeholder for transaction details
  @override
  Future<List<TransactionItem>> getTransactionDetails() async {
    // You might want to replace "default-key" with real transaction lookup
    return remoteDataSource.getTransactions("default-key");
  }
}

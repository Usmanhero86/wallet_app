import 'package:get_storage/get_storage.dart';
import '../../domain/entities/account_response.dart';
import '../../domain/entities/transaction_history.dart';
import '../../domain/entities/wallet_balance.dart';
import '../../domain/repositories/account_repository.dart';
import '../datasources/remote/account_remote_datasource.dart';

class AccountRepositoryImpl implements AccountRepository {
  final AccountRemoteDataSource remoteDataSource;
  final GetStorage storage = GetStorage();

  AccountRepositoryImpl(this.remoteDataSource);

  @override
  Future<AccountResponse> createVirtualAccount(Map<String, dynamic> payload) async {
    final model = await remoteDataSource.createVirtualAccount(payload);
    return AccountResponse.fromModel(model);
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
  Future<String> sendPayment(double amount, String narration, String recipientAccount) {
    return remoteDataSource.sendPayment(amount, narration, recipientAccount);
  }

  @override
  Future<void> saveSentPayments(List<TransactionItem> payments) async {
    await storage.write(
      "sentPayments",
      payments.map((e) => e.toJson()).toList(),
    );
  }

  @override
  Future<List<TransactionItem>> loadSentPayments() async {
    final data = storage.read<List>("sentPayments") ?? [];
    return data.map((e) => TransactionItem.fromJson(e)).toList();
  }

  @override
  Future<List<TransactionItem>> getTransactionDetails() async {
    return remoteDataSource.getTransactions("12345");
  }

}

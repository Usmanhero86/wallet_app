import '../../model/account_model.dart';
import '../../../domain/entities/transaction_history.dart';
import '../../../domain/entities/wallet_balance.dart';
import '../remote/api_service.dart';

abstract class AccountRemoteDataSource {
  Future<AccountModel> createVirtualAccount(Map<String, dynamic> payload);
  Future<WalletBalance> getWalletBalance(String key);
  Future<List<TransactionItem>> getTransactions(String key);
  Future<String> sendPayment(double amount, String narration, String recipientAccount);
  Future<void> updateAccount(Map<String, dynamic> payload);
  Future<void> deleteAccount(String accountId);
}

class AccountRemoteDataSourceImpl implements AccountRemoteDataSource {
  final ApiService apiService;

  AccountRemoteDataSourceImpl(this.apiService);

  @override
  Future<AccountModel> createVirtualAccount(Map<String, dynamic> payload) async {
    final response = await apiService.post("/zainbox/virtual-account", payload);
    return AccountModel.fromJson(response['data']);
  }

  @override
  Future<WalletBalance> getWalletBalance(String key) async {
    final response = await apiService.get("/virtual-account/wallet/balance/$key");
    return WalletBalance.fromJson(response['data']);
  }

  @override
  Future<List<TransactionItem>> getTransactions(String key) async {
    final response = await apiService.get("/virtual-account/wallet/transactions/$key");
    final List<dynamic> list = response['data'] ?? [];
    return list.map((e) => TransactionItem.fromJson(e)).toList();
  }

  @override
  Future<String> sendPayment(double amount, String narration, String recipientAccount) async {
    final response = await apiService.post("/payments", {
      "amount": amount,
      "narration": narration,
      "recipientAccount": recipientAccount,
    });

    if (response['code'] == '00') {
      return 'success';
    } else if (response['code'] == 'INSUFFICIENT_FUNDS') {
      return 'insufficient';
    } else {
      return 'failed';
    }
  }

  @override
  Future<void> updateAccount(Map<String, dynamic> payload) async {
    await apiService.put("/zainbox/update-account", payload);
  }

  @override
  Future<void> deleteAccount(String accountId) async {
    await apiService.delete("/zainbox/delete-account/$accountId");
  }
}

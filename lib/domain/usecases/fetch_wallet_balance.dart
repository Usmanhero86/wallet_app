import '../entities/wallet_balance.dart';
import '../repositories/account_repository.dart';

class FetchWalletBalance {
  final AccountRepository repository;

  FetchWalletBalance(this.repository);

  Future<WalletBalance> execute(String key) {
    return repository.getWalletBalance(key);
  }
}

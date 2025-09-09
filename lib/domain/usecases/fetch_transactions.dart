import '../entities/transaction_history.dart';
import '../repositories/account_repository.dart';

class FetchTransactions {
  final AccountRepository repository;

  FetchTransactions(this.repository);

  Future<List<TransactionItem>> execute(String key) {
    return repository.getTransactionDetails();
  }
}

import '../entities/transaction_history.dart';
import '../repositories/account_repository.dart';

class FetchTransactions {
  final AccountRepository repository;
  FetchTransactions(this.repository);

  Future<List<TransactionItem>> call() {
    return repository.getTransactionDetails();
  }
}

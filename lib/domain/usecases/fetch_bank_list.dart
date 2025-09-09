import '../entities/bank.dart';
import '../repositories/account_repository.dart';

class FetchBankList {
  final AccountRepository repository;

  FetchBankList(this.repository);

  Future<List<Bank>> execute() {
    return repository.getBankList();
  }
}

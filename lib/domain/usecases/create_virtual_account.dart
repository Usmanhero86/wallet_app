import '../entities/account_response.dart';
import '../repositories/account_repository.dart';

class CreateVirtualAccount {
  final AccountRepository repository;
  CreateVirtualAccount(this.repository);

  Future<AccountResponse> call(Map<String, dynamic> payload) {
    return repository.createVirtualAccount(payload);
  }
}

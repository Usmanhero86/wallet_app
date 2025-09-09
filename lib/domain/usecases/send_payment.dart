import '../repositories/account_repository.dart';

class SendPayment {
  final AccountRepository repository;

  SendPayment(this.repository);

  /// Include bankCode as an extra parameter
  Future<String> call({
    required double amount,
    required String narration,
    required String recipientAccount,
    required String bankCode,
  }) {
    return repository.sendPayment(amount, narration, recipientAccount, bankCode);
  }
}

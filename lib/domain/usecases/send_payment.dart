import '../repositories/account_repository.dart';

class SendPayment {
  final AccountRepository repository;

  SendPayment(this.repository);

  Future<String> execute({
    required double amount,
    required String narration,
    required String recipientAccount,
  }) {
    return repository.sendPayment(amount, narration, recipientAccount);
  }
}

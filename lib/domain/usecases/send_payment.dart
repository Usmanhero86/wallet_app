import '../repositories/account_repository.dart';

class SendPayment {
  final AccountRepository repository;
  SendPayment(this.repository);

  Future<String> call(double amount, String narration, String recipientAccount) {
    return repository.sendPayment(amount, narration, recipientAccount);
  }
}

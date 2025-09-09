abstract class PaymentRepository {
  Future<void> sendPayment({
    required double amount,
    required String narration,
    required String recipientAccount,
  });

  Future<void> receivePayment({
    required double amount,
    required String narration,
    required String senderAccount,
  });
}

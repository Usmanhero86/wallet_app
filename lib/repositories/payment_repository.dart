import '../services/api_services.dart';

class PaymentRepository {
  final ApiService api;

  PaymentRepository(this.api);

  Future<void> sendPayment({
    required double amount,
    required String narration,
    required String recipientAccount,
  }) async {
    await api.post(
      "/payments/transfer",
      {
        "amount": amount,
        "narration": narration,
        "recipientAccount": recipientAccount,
      },
    );
  }

  Future<void> receivePayment({
    required double amount,
    required String narration,
    required String senderAccount,
  }) async {
    await api.post(
      "/payments/receive",
      {
        "amount": amount,
        "narration": narration,
        "senderAccount": senderAccount,
      },
    );
  }
}

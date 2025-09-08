import '../../domain/repositories/payment_repository.dart';
import '../datasources/remote/api_service.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final ApiService api;

  PaymentRepositoryImpl(this.api);

  @override
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

  @override
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

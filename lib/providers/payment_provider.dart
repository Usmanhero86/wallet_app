import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../di/providers.dart';
import '../domain/repositories/payment_repository.dart';

// --- Payment State ---
class PaymentState {final bool isLoading;final String? error;final bool success;

  const PaymentState({this.isLoading = false, this.error, this.success = false,});

  PaymentState copyWith({bool? isLoading, String? error, bool? success,}) {
    return PaymentState(isLoading: isLoading ?? this.isLoading, error: error ?? this.error, success: success ?? this.success,);
  }
}

// --- Payment Notifier ---
class PaymentNotifier extends StateNotifier<PaymentState> {
  final PaymentRepository repository;
  PaymentNotifier(this.repository) : super(const PaymentState());

  Future<void> sendPayment({required double amount, required String narration, required String recipientAccount,}) async {
    state = state.copyWith(isLoading: true, error: null, success: false);

    try {
      await repository.sendPayment(
        amount: amount,
        narration: narration,
        recipientAccount: recipientAccount,
      );

      state = state.copyWith(isLoading: false, success: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

// --- Provider ---
final paymentNotifierProvider =
StateNotifierProvider<PaymentNotifier, PaymentState>(
      (ref) => PaymentNotifier(ref.read(paymentRepositoryProvider)));

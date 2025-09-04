import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/account_response.dart';
import '../../domain/entities/transaction_history.dart';
import '../../domain/entities/wallet_balance.dart';
import '../../domain/usecases/create_virtual_account.dart';
import '../../domain/usecases/fetch_wallet_balance.dart';
import '../../domain/usecases/fetch_transactions.dart';
import '../../domain/usecases/send_payment.dart';
import 'account_state.dart';

class AccountNotifier extends StateNotifier<AccountState> {
  final CreateVirtualAccount createAccountUseCase;
  final FetchWalletBalance fetchBalanceUseCase;
  final FetchTransactions fetchTransactionsUseCase;
  final SendPayment sendPaymentUseCase;

  AccountNotifier({
    required this.createAccountUseCase,
    required this.fetchBalanceUseCase,
    required this.fetchTransactionsUseCase,
    required this.sendPaymentUseCase,
  }) : super(AccountState.initial());

  Future<String> createVirtualAccount(Map<String, dynamic> payload) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final account = await createAccountUseCase(payload);
      state = state.copyWith(isLoading: false, accountResponse: account);
      return 'success';
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return 'error';
    }
  }

  Future<void> fetchWalletBalance() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final balance = await fetchBalanceUseCase(""); // token if needed
      state = state.copyWith(isLoading: false, walletBalance: balance);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> fetchTransactions() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final txns = await fetchTransactionsUseCase();
      state = state.copyWith(isLoading: false, transactions: txns);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<String> sendPayment(double amount, String narration, String recipientAccount,) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final result =
      await sendPaymentUseCase(amount, narration, recipientAccount);
      return result;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return 'error';
    }
  }

  void updateBalance(double newBalance) {
    if (state.walletBalance != null) {
      state = state.copyWith(
        walletBalance: state.walletBalance!.copyWith(
          balanceAmount: newBalance,
        ),
      );
    }
  }

}

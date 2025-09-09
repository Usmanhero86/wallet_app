import 'dart:nativewrappers/_internal/vm/lib/ffi_allocation_patch.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/account_repository.dart';
import '../../domain/usecases/create_virtual_account.dart';
import '../../domain/usecases/fetch_wallet_balance.dart';
import '../../domain/usecases/fetch_transactions.dart';
import '../../domain/usecases/send_payment.dart';
import 'account_state.dart';

class AccountNotifier extends StateNotifier<AccountState> {
  final AccountRepository repository;
  final CreateVirtualAccount createAccountUseCase;
  final FetchWalletBalance fetchBalanceUseCase;
  final FetchTransactions fetchTransactionsUseCase;
  final SendPayment sendPaymentUseCase;

  AccountNotifier({
    required this.repository,
    required this.createAccountUseCase,
    required this.fetchBalanceUseCase,
    required this.fetchTransactionsUseCase,
    required this.sendPaymentUseCase,
  }) : super(AccountState.initial());

  Future<String> createVirtualAccount(Map<String, dynamic> payload) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final account = await createAccountUseCase.call(payload);
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
      final balance = await fetchBalanceUseCase.call();
      state = state.copyWith(isLoading: false, walletBalance: balance);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> fetchTransactions() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final txns = await fetchTransactionsUseCase.call();
      state = state.copyWith(isLoading: false, transactions: txns);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }


  Future<String> sendPayment({required double amount, required String narration, required String recipientAccount, required String bankCode,}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await sendPaymentUseCase.call(
        amount: amount,
        narration: narration,
        recipientAccount: recipientAccount,
        bankCode: bankCode,
      );

      state = state.copyWith(isLoading: false);
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
          availableBalance: newBalance,
        ),
      );
    }
  }

}

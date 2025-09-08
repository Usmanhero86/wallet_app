import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/usecases/create_virtual_account.dart';
import '../../../domain/usecases/fetch_wallet_balance.dart';
import '../../../domain/usecases/fetch_transactions.dart';
import '../../../domain/usecases/send_payment.dart';
import '../../../domain/entities/transaction_history.dart';
import '../../domain/entities/wallet_balance.dart';
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

  /// Create Virtual Account
  Future<void> createAccount(Map<String, dynamic> payload) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final account = await createAccountUseCase.execute(payload);
      state = state.copyWith(isLoading: false, accountResponse: account);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Fetch Wallet Balance
  Future<void> fetchBalance(String key) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final balance = await fetchBalanceUseCase.execute(key);
      state = state.copyWith(isLoading: false, walletBalance: balance);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Fetch Transactions
  Future<void> fetchTransactions(String key) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final txns = await fetchTransactionsUseCase.execute(key);
      state = state.copyWith(isLoading: false, transactions: txns);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  /// Send Payment
  Future<void> sendPayment({
    required double amount,
    required String narration,
    required String recipientAccount,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final result = await sendPaymentUseCase.execute(
        amount: amount,
        narration: narration,
        recipientAccount: recipientAccount,
      );

      if (result == 'success') {
        final currentBalance = state.walletBalance?.availableBalance ?? 0;
        final updatedBalance = currentBalance - amount;

        final newTxn = TransactionItem(
          accountNumber: state.accountResponse?.accountNumber ?? '',
          destinationAccountNumber: recipientAccount,
          amount: amount,
          balance: updatedBalance,
          narration: narration,
          transactionDate: DateTime.now(),
          transactionRef: DateTime.now().millisecondsSinceEpoch.toString(),
          transactionType: 'DEBIT',
        );

        state = state.copyWith(
          isLoading: false,
          walletBalance: WalletBalance(
            availableBalance: updatedBalance,
            ledgerBalance: updatedBalance,
          ),
          sentPayments: [...state.sentPayments, newTxn],
          transactions: [newTxn, ...state.transactions],
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: result == 'insufficient'
              ? 'Insufficient funds'
              : 'Payment failed',
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}

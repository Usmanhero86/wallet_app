import 'package:equatable/equatable.dart';
import '../../../domain/entities/account_response.dart';
import '../../../domain/entities/transaction_history.dart';
import '../../../domain/entities/wallet_balance.dart';

class AccountState extends Equatable {
  final bool isLoading;
  final String? errorMessage;
  final AccountResponse? accountResponse;
  final WalletBalance? walletBalance;
  final List<TransactionItem> transactions;
  final List<TransactionItem> sentPayments;

  const AccountState({
    this.isLoading = false,
    this.errorMessage,
    this.accountResponse,
    this.walletBalance,
    this.transactions = const [],
    this.sentPayments = const [],
  });

  factory AccountState.initial() {
    return const AccountState();
  }

  AccountState copyWith({
    bool? isLoading,
    String? errorMessage,
    AccountResponse? accountResponse,
    WalletBalance? walletBalance,
    List<TransactionItem>? transactions,
    List<TransactionItem>? sentPayments,
  }) {
    return AccountState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      accountResponse: accountResponse ?? this.accountResponse,
      walletBalance: walletBalance ?? this.walletBalance,
      transactions: transactions ?? this.transactions,
      sentPayments: sentPayments ?? this.sentPayments,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    errorMessage,
    accountResponse,
    walletBalance,
    transactions,
    sentPayments,
  ];
}

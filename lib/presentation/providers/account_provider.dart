// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../notifiers/account_state.dart';
// import '../../domain/entities/transaction_history.dart';
// import '../../domain/repositories/account_repository.dart';
//
//
// class AccountNotifier extends StateNotifier<AccountState> {
//   final AccountRepository repository;
//
//   AccountNotifier(this.repository) : super(const AccountState());
//
//   Future<void> createVirtualAccount(Map<String, dynamic> payload) async {
//     state = state.copyWith(isLoading: true, errorMessage: null);
//     try {
//       final account = await repository.createVirtualAccount(payload);
//       state = state.copyWith(isLoading: false, accountResponse: account);
//     } catch (e) {
//       state = state.copyWith(isLoading: false, errorMessage: e.toString());
//     }
//   }
//
//   Future<void> fetchWalletBalance(String key) async {
//     state = state.copyWith(isLoading: true, errorMessage: null);
//     try {
//       final balance = await repository.getWalletBalance(key);
//       state = state.copyWith(
//         isLoading: false,
//         walletBalance: balance.data.balanceAmount,
//       );
//     } catch (e) {
//       state = state.copyWith(isLoading: false, errorMessage: e.toString());
//     }
//   }
//
//   Future<void> fetchTransactions() async {
//     state = state.copyWith(isLoading: true, errorMessage: null);
//     try {
//       final txns = await repository.getTransactionDetails();
//       state = state.copyWith(isLoading: false, transactions: txns);
//     } catch (e) {
//       state = state.copyWith(isLoading: false, errorMessage: e.toString());
//     }
//   }
//
//   Future<String> sendPayment(double amount, String narration, String recipientAccount) async {
//     state = state.copyWith(isLoading: true, errorMessage: null);
//     try {
//       final result = await repository.sendPayment(amount, narration, recipientAccount);
//       if (result == 'success') {
//         final updatedBalance = state.walletBalance - amount;
//         final newPayment = TransactionItem(
//           accountNumber: state.accountResponse?.accountNumber ?? 'N/A',
//           destinationAccountNumber: recipientAccount,
//           amount: amount,
//           balance: updatedBalance,
//           narration: narration,
//           transactionDate: DateTime.now(),
//           transactionRef: 'TXN_${DateTime.now().millisecondsSinceEpoch}',
//           transactionType: 'debit',
//         );
//
//         final updatedSentPayments = [newPayment, ...state.sentPayments];
//         await repository.saveSentPayments(updatedSentPayments);
//
//         state = state.copyWith(
//           isLoading: false,
//           walletBalance: updatedBalance,
//           sentPayments: updatedSentPayments,
//         );
//       } else {
//         state = state.copyWith(isLoading: false, errorMessage: "Payment failed");
//       }
//       return result;
//     } catch (e) {
//       state = state.copyWith(isLoading: false, errorMessage: e.toString());
//       return 'error';
//     }
//   }
//
//   Future<void> loadSentPayments() async {
//     final payments = await repository.loadSentPayments();
//     state = state.copyWith(sentPayments: payments);
//   }
// }

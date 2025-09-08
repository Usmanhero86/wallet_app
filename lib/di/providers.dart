import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/account_repository_impl.dart';
import '../../domain/repositories/account_repository.dart';
import '../../domain/usecases/create_virtual_account.dart';
import '../../domain/usecases/fetch_wallet_balance.dart';
import '../../domain/usecases/fetch_transactions.dart';
import '../../domain/usecases/send_payment.dart';

import '../data/datasources/remote/account_remote_datasource.dart';
import '../data/datasources/remote/api_service.dart';
import '../presentation/notifiers/account_notifier.dart';
import '../presentation/notifiers/account_state.dart';

/// ApiService provider (low-level HTTP client)
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

/// RemoteDataSource provider (handles API calls)
final remoteDataSourceProvider = Provider<AccountRemoteDataSource>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return AccountRemoteDataSourceImpl(apiService);
});

/// Repository provider (abstracts data access)
final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  final remoteDataSource = ref.read(remoteDataSourceProvider);
  return AccountRepositoryImpl(remoteDataSource);
});

/// Use case providers
final createAccountUseCaseProvider = Provider<CreateVirtualAccount>((ref) {
  return CreateVirtualAccount(ref.read(accountRepositoryProvider));
});

final fetchBalanceUseCaseProvider = Provider<FetchWalletBalance>((ref) {
  return FetchWalletBalance(ref.read(accountRepositoryProvider));
});

final fetchTransactionsUseCaseProvider = Provider<FetchTransactions>((ref) {
  return FetchTransactions(ref.read(accountRepositoryProvider));
});

final sendPaymentUseCaseProvider = Provider<SendPayment>((ref) {
  return SendPayment(ref.read(accountRepositoryProvider));
});

/// Notifier provider
final accountNotifierProvider =
StateNotifierProvider<AccountNotifier, AccountState>((ref) {
  return AccountNotifier(
    createAccountUseCase: ref.read(createAccountUseCaseProvider),
    fetchBalanceUseCase: ref.read(fetchBalanceUseCaseProvider),
    fetchTransactionsUseCase: ref.read(fetchTransactionsUseCaseProvider),
    sendPaymentUseCase: ref.read(sendPaymentUseCaseProvider),
  );
});

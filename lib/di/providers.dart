import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/remote/account_remote_datasource.dart';
import '../../data/datasources/remote/api_service.dart';
import '../../data/repositories/account_repository_impl.dart';
import '../../data/repositories/payment_repository_impl.dart';
import '../../domain/repositories/account_repository.dart';
import '../../domain/repositories/payment_repository.dart';
import '../../domain/usecases/create_virtual_account.dart';
import '../../domain/usecases/fetch_wallet_balance.dart';
import '../../domain/usecases/fetch_transactions.dart';
import '../../domain/usecases/send_payment.dart';
import '../presentation/notifiers/account_notifier.dart';
import '../presentation/notifiers/account_state.dart';
import '../presentation/notifiers/payment_notifier.dart';
import '../providers/payment_provider.dart';

/// API SERVICE PROVIDER
final apiServiceProvider = Provider<ApiService>((ref) {return ApiService();});

/// REMOTE DATA SOURCE PROVIDER
final remoteDataSourceProvider = Provider<AccountRemoteDataSource>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return AccountRemoteDataSourceImpl(apiService);
});

/// ACCOUNT REPOSITORY PROVIDER
final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  final remoteDataSource = ref.read(remoteDataSourceProvider);
  return AccountRepositoryImpl(remoteDataSource: remoteDataSource);
});

/// ACCOUNT NOTIFIER PROVIDER
final accountNotifierProvider = StateNotifierProvider<AccountNotifier, AccountState>((ref) {
  final repo = ref.read(accountRepositoryProvider);
  return AccountNotifier(repository: repo,
    createAccountUseCase: ref.read(createAccountUseCaseProvider),
    fetchBalanceUseCase: ref.read(fetchBalanceUseCaseProvider),
    fetchTransactionsUseCase: ref.read(fetchTransactionsUseCaseProvider),
    sendPaymentUseCase: ref.read(sendPaymentUseCaseProvider),
  );
});

/// BANK NOTIFIER PROVIDER (if you already have BankNotifier/BankState defined)
final bankNotifierProvider = StateNotifierProvider<BankNotifier, BankState>((ref) {
  final repo = ref.read(accountRepositoryProvider);
  return BankNotifier(repo);
});

/// PAYMENT REPOSITORY PROVIDER
final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return PaymentRepositoryImpl(apiService);
});

/// PAYMENT NOTIFIER PROVIDER
final paymentNotifierProvider = StateNotifierProvider<PaymentNotifier, PaymentState>(
        (ref) {final repo = ref.read(paymentRepositoryProvider);
  return PaymentNotifier(repo);
});

/// USE CASE PROVIDERS
final createAccountUseCaseProvider = Provider<CreateVirtualAccount>((ref) {
  final repo = ref.read(accountRepositoryProvider);
  return CreateVirtualAccount(repo);
});

final fetchBalanceUseCaseProvider = Provider<FetchWalletBalance>((ref) {
  final repo = ref.read(accountRepositoryProvider);
  return FetchWalletBalance(repo);
});

final fetchTransactionsUseCaseProvider = Provider<FetchTransactions>((ref) {
  final repo = ref.read(accountRepositoryProvider);
  return FetchTransactions(repo);
});

final sendPaymentUseCaseProvider = Provider<SendPayment>((ref) {
  final repo = ref.read(accountRepositoryProvider);
  return SendPayment(repo);
});
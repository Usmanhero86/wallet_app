// // lib/di/providers.dart
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:wallet_app/domain/repositories/account_repository.dart' show AccountRepository;
// import 'package:wallet_app/presentation/providers/account_provider.dart';
// import '../../data/repositories/account_repository_impl.dart';
// import '../notifiers/account_state.dart';
//
//
// // Repository provider
// final accountRepositoryProvider = Provider<AccountRepository>((ref) {
//   return AccountRepositoryImpl();
// });
//
// // Notifier provider
// final accountNotifierProvider =
// StateNotifierProvider<AccountNotifier, AccountState>((ref) {
//   final repo = ref.watch(accountRepositoryProvider);
//   return AccountNotifier(repo);
// });

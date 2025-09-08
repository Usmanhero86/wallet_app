import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../di/providers.dart';
import '../../domain/entities/bank.dart'; // ✅ Import Bank entity
import '../../domain/repositories/account_repository.dart';

class BankState {
  final bool isLoading;
  final String? error;
  final List<Bank> banks;

  BankState({
    this.isLoading = false,
    this.error,
    this.banks = const [],
  });

  BankState copyWith({
    bool? isLoading,
    String? error,
    List<Bank>? banks,
  }) {
    return BankState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      banks: banks ?? this.banks,
    );
  }
}

class BankNotifier extends StateNotifier<BankState> {
  final AccountRepository repository;

  BankNotifier(this.repository) : super(BankState());

  Future<void> loadBanks() async {
    state = state.copyWith(isLoading: true, error: null);
    debugPrint('Loading banks...');
    try {
      final result = await repository.getBankList();
      debugPrint('Banks fetched: ${result.map((b) => b.name).join(", ")}');
      state = state.copyWith(isLoading: false, banks: result);
    } catch (e, st) {
      debugPrint('Error fetching banks: $e\n$st');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

}
final bankNotifierProvider =
StateNotifierProvider<BankNotifier, BankState>((ref) {
  final repo = ref.read(accountRepositoryProvider);
  return BankNotifier(repo);
});


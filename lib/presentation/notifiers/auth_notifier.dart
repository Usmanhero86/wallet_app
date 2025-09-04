import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthState {
  final bool isAuthenticated;
  const AuthState({this.isAuthenticated = false});

  AuthState copyWith({bool? isAuthenticated}) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  void login() {
    state = state.copyWith(isAuthenticated: true);
  }

  void logout() {
    state = state.copyWith(isAuthenticated: false);
  }
}

final authNotifierProvider =
StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

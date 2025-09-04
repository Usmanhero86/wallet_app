import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../di/providers.dart'; // make sure authNotifierProvider is exported here
import '../notifiers/auth_notifier.dart';
import 'dashboard_screen.dart';
import 'login_screen.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    if (authState.isAuthenticated) {
      return const DashboardScreen();
    } else {
      return  LoginScreen();
    }
  }
}

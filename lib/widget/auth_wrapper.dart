import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallet_app/view/create_account_screen.dart';
import '../services/auth_provider.dart';
import '../view/login_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.isAuthenticated) {
      return const CreateAccountScreen();
    } else {
      return  LoginScreen();
    }
  }
}
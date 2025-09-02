import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallet_app/view/create_account_screen.dart';
import 'package:wallet_app/view/dashboard_screen.dart';
import '../services/api_service.dart';
import '../themes/theme_provider.dart';
import '../services/auth_provider.dart';
import '../widget/app_button.dart';
import '../widget/input_field.dart';
import '../widget/u_app_bar.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginScreen({super.key});

  Future<void> _login(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) =>  DashboardScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UAppBar(title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            InputField(
              controller: emailController,
              labelText: 'Email',
            ),
            const SizedBox(height: 16),
            InputField(
              controller: passwordController,
              labelText: 'Password',
              obscureText: true,
            ),
            const SizedBox(height: 20),
            AppButton(
              onPressed: () => _login(context),
              text: 'Login',
            ),
          ],
        ),
      ),
    );
  }
}
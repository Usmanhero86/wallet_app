import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallet_app/view/create_account_screen.dart';
import '../themes/theme_provider.dart';
import '../services/auth_provider.dart';
import '../widget/app_button.dart';
import '../widget/input_field.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginScreen({super.key});

  Future<void> _login(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      // Call your authentication API here
      // For example:
      // final response = await ApiService.login(
      //   emailController.text,
      //   passwordController.text,
      // );

      // Mock login for demonstration
      authProvider.login(
        emailController.text,
        'your_auth_token_here', // Replace with actual token from API
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) =>  CreateAccountScreen()),
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
      appBar: AppBar(title: const Text('Login'),
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                icon: Icon(themeProvider.isDarkMode
                    ? Icons.light_mode
                    : Icons.dark_mode),
                onPressed: () {
                  themeProvider.toggleTheme(!themeProvider.isDarkMode);
                },
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CustomTextFormField(
              controller: emailController,
              labelText: 'Email',
            ),
            const SizedBox(height: 16),
            CustomTextFormField(
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
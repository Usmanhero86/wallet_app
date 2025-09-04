import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widget/app_button.dart';
import '../widget/input_field.dart';
import '../widget/u_app_bar.dart';
import 'dashboard_screen.dart';

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
      appBar: UAppBar(title: Text('Login')),
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
              onPressed: () => Navigator.push(
                  context, MaterialPageRoute(
                  builder: (context)=>DashboardScreen())),
              text: 'Login',
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallet_app/view/send_payment_screen.dart';
import '../themes/theme_provider.dart';
import '../services/account_provider.dart';
import '../widget/app_button.dart';
import 'create_account_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AccountProvider>(context, listen: false).fetchWalletBalance(context);
      Provider.of<AccountProvider>(context, listen: false).fetchTransaction(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AccountProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard'),
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
        ],),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text( 'Balance: ${provider.walletBalance}', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AppButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateAccountScreen()));
                  },
                 text: 'Create Virtual Account',
                ),
                AppButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SendPaymentScreen()));
                  },
                  text: 'sent payment',
                ),

              ],
            ),
          ],
        ),
      ),
    );
  }
}
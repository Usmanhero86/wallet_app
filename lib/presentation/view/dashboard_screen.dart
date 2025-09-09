import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_storage/get_storage.dart';
import '../../di/providers.dart';
import '../widget/app_button.dart';
import '../widget/balance_card.dart';
import '../widget/build_transaction_item.dart';
import '../widget/u_app_bar.dart';
import 'create_account_screen.dart';
import 'send_payment_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  Future<void> _loadDashboardData(WidgetRef ref) async {
    final notifier = ref.read(accountNotifierProvider.notifier);
    await notifier.fetchWalletBalance();
    await notifier.fetchTransactions();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(accountNotifierProvider);

    final allTransactions = [...state.transactions]
      ..sort((a, b) => b.transactionDate.compareTo(a.transactionDate));

    final storage = GetStorage();
    final savedAccount = storage.read("account");

    return Scaffold(
      appBar: const UAppBar(title: Text('Dashboard')),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.errorMessage != null
          ? _buildErrorState(context, state.errorMessage!, ref)
          : RefreshIndicator(
        onRefresh: () => _loadDashboardData(ref),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Account Details ---
              if (savedAccount != null)
                _buildAccountCard(context, savedAccount),

              // --- Balance Card ---
              if (savedAccount != null)
                BalanceCard(balance: state.walletBalance?.availableBalance ?? 0.0),

              const SizedBox(height: 24),

              // --- Quick Actions ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CreateAccountScreen(),
                        ),
                      );
                    },
                    text: 'Create Account',
                    padding: 12,
                  ),
                  AppButton(
                    onPressed: () async {
                      if (savedAccount == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Please create an account first")),
                        );
                      } else {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SendPaymentScreen(),
                          ),
                        );

                        if (result == true) {
                          // ✅ Reload dashboard automatically
                          _loadDashboardData(ref);
                        }
                      }
                    },
                    text: 'Send Money',
                    padding: 12,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // --- Recent Transactions ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Recent Transactions',
                      style: Theme.of(context).textTheme.titleLarge),
                  if (allTransactions.isNotEmpty)
                    AppButton(onPressed: () {}, text: 'View All'),
                ],
              ),

              const SizedBox(height: 12),

              if (allTransactions.isEmpty)
                const Center(child: Text('No transactions yet'))
              else
                ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: allTransactions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final transaction = allTransactions[index];
                    return buildTransactionItem(transaction, context);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountCard(BuildContext context, dynamic savedAccount) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Account Number: ${savedAccount["accountNumber"]}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 20),
                  onPressed: () {
                    Clipboard.setData(
                      ClipboardData(text: savedAccount["accountNumber"]),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Account number copied!")),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text("Name: ${savedAccount["accountName"]}",
                style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 4),
            Text("Bank: ${savedAccount["bankType"]}",
                style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _loadDashboardData(ref),
              icon: const Icon(Icons.refresh),
              label: const Text("Retry"),
            ),
          ],
        ),
      ),
    );
  }
}

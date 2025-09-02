import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallet_app/model/transaction_history.dart';
import 'package:wallet_app/view/send_payment_screen.dart';
import 'package:wallet_app/widget/balance_card.dart';
import 'package:wallet_app/widget/u_app_bar.dart';
import '../services/account_provider.dart';
import '../widget/app_button.dart';
import '../widget/build_spending_chart.dart';
import '../widget/build_transaction_item.dart';
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
      final provider = Provider.of<AccountProvider>(context, listen: false);
      _loadDashboardData(provider);
    });
  }

  Future<void> _loadDashboardData(AccountProvider provider) async {
    try {
      await provider.fetchWalletBalance(context, '');
      await provider.fetchTransaction(context);
      await provider.loadSentPayments();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading dashboard: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AccountProvider>(context);
    final allTransactions = [
      ...provider.sentPayments,
      ...provider.transactions
    ]..sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
    return Scaffold(
      appBar: const UAppBar(title: Text('Dashboard')),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.errorMessage != null
          ? _buildErrorState(provider.errorMessage!, provider)
          : RefreshIndicator(
        onRefresh: () => _loadDashboardData(provider),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Show Account Details only if account exists
              if (provider.accountResponse != null) ...[
                Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Account Name: ${provider.accountResponse!.accountName}'),
                        Text('Account Number: ${provider.accountResponse!.accountNumber}'),
                        Text('Bank: ${provider.accountResponse!.bankName}'),
                      ],
                    ),
                  ),
                ),

                // Show BalanceCard only if account exists
                if (provider.accountResponse != null)
                BalanceCard(balance: provider.walletBalance)
                else
                  Padding(padding: EdgeInsets.all(16.0),
                  child: Text(
                    "Please create an account to view your balance",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),),
                const SizedBox(height: 24),
              ],

              // Virtual Accounts
              if (provider.createdAccounts.isNotEmpty) ...[
                Text('Virtual Accounts',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: provider.createdAccounts.length,
                  itemBuilder: (context, index) {
                    final account = provider.createdAccounts[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(account['accountName'] ?? 'No Name'),
                        subtitle: Text('Account No: ${account['accountNumber']}'),
                        trailing: Text(account['bankName'] ?? ''),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],

              // Spending Chart
              buildSpendingChart(allTransactions, context),

              const SizedBox(height: 24),

              // Quick Actions
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
                      if (provider.accountResponse == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Please create an account first before sending money',
                            ),
                          ),
                        );
                        return;
                      }

                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SendPaymentScreen(),
                        ),
                      );

                      if (result == true && mounted) {
                        _loadDashboardData(provider);
                      }
                    },
                    text: 'Send Money',
                    padding: 12,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Recent Transactions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Recent Transactions',
                      style: Theme.of(context).textTheme.titleLarge),
                  if (allTransactions.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        // TODO: Navigate to full transactions screen
                      },
                      child: const Text('View All'),
                    ),
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
                  separatorBuilder: (context, index) =>
                  const SizedBox(height: 8),
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

  /// Error state widget with retry
  Widget _buildErrorState(String message, AccountProvider provider) {
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
              onPressed: () => _loadDashboardData(provider),
              icon: const Icon(Icons.refresh),
              label: const Text("Retry"),
            )
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallet_app/model/transaction_history.dart';
import 'package:wallet_app/view/send_payment_screen.dart';
import 'package:wallet_app/widget/balance_card.dart';
import 'package:wallet_app/widget/u_app_bar.dart';
import '../themes/theme_provider.dart';
import '../services/account_provider.dart';
import '../widget/app_button.dart';
import '../widget/build_info_item.dart';
import '../widget/build_spending_chart.dart';
import '../widget/build_transaction_item.dart';
import 'create_account_screen.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  double walletBalance = 10000;


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AccountProvider>(context, listen: false);
      provider.fetchWalletBalance(context, '');
      provider.fetchTransaction(context);
      provider.loadSentPayments();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AccountProvider>(context);
    final allTransactions = [
      ...provider.sentPayments,
      ...provider.transactions
    ]..sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
    return Scaffold(
      appBar:UAppBar(title: Text('Dashboard')),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await provider.fetchWalletBalance(context, '');
                await provider.fetchTransaction(context);
              },
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (provider.accountResponse != null) ...[
                      Text('Account Name: ${provider.accountResponse!.accountName}'),
                      Text('Account Number: ${provider.accountResponse!.accountNumber}'),
                      Text('Bank: ${provider.accountResponse!.bankName}'),
                    ],

                    // Balance Card
                    BalanceCard(balance: walletBalance),

                    SizedBox(height: 24),

                    if (provider.createdAccounts.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Text('Virtual Accounts', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: provider.createdAccounts.length,
                        itemBuilder: (context, index) {
                          final account = provider.createdAccounts[index];
                          return Card(
                            child: ListTile(
                              title: Text(account['accountName'] ?? 'No Name'),
                              subtitle: Text('Account No: ${account['accountNumber']}'),
                              trailing: Text(account['bankName'] ?? ''),
                            ),
                          );
                        },
                      ),
                    ],

                    const SizedBox(height: 24),

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
                                const SnackBar(content: Text('Please create an account first before sending money')),
                              );
                              return;
                            }

                            // Otherwise, proceed with send payment
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const SendPaymentScreen()),
                            );

                            if (result == true) {
                              final provider = Provider.of<AccountProvider>(context, listen: false);
                              await provider.fetchWalletBalance(context, 'key');
                              await provider.fetchTransaction(context);
                              await provider.loadSentPayments();
                            }
                          },
                          text: 'Send Money',
                          padding: 12,
                        ),

                      ],
                    ),

                    const SizedBox(height: 24),

                    // Recent Transactions Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Transactions',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        if (allTransactions.isNotEmpty)
                          TextButton(
                            onPressed: () {
                              // Navigate to full transactions screen
                            },
                            child: const Text('View All'),
                          ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Transactions List
                    if (allTransactions.isEmpty)
                      const Center(child: Text('No transactions yet'))
                    else
                      Consumer<AccountProvider>(
                        builder: (context, provider, child) {
                          final allTransactions = [
                            ...provider.sentPayments,
                            ...provider.transactions
                          ]..sort((a, b) => b.transactionDate.compareTo(a.transactionDate));

                          return ListView.separated(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: allTransactions.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final transaction = allTransactions[index];
                              return buildTransactionItem(transaction, context);
                            },
                          );
                        },
                      ),

                  ],
                ),
              ),
            ),
    );
  }



}



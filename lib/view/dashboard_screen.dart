import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wallet_app/model/transaction_history.dart';
import 'package:wallet_app/view/send_payment_screen.dart';
import '../themes/theme_provider.dart';
import '../services/account_provider.dart';
import '../widget/app_button.dart';
import '../widget/balance_card.dart';
import 'create_account_screen.dart';
import 'package:fl_chart/fl_chart.dart';

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
      final provider = Provider.of<AccountProvider>(context);
      provider.fetchWalletBalance(context);
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
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                icon: Icon(
                  themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                ),
                onPressed: () {
                  themeProvider.toggleTheme(!themeProvider.isDarkMode);
                },
              );
            },
          ),
        ],
      ),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await provider.fetchWalletBalance(context);
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
                    Consumer<AccountProvider>(
                      builder: (context, provider, child) {
                        return BalanceCard(balance: provider.walletBalance.toDouble());
                      },
                    ),


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
                    _buildSpendingChart(allTransactions),

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
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const SendPaymentScreen()),
                            );

                            if (result == true) {
                              final provider = Provider.of<AccountProvider>(context, listen: false);
                              await provider.fetchWalletBalance(context);
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
                              return _buildTransactionItem(transaction);
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

  Widget _buildSpendingChart(List<TransactionItem> transactions) {
    final chartData = transactions
        .map(
          (t) => ChartData(
            t.transactionDate,
            t.amount.toDouble(),
            t.transactionType == 'credit' ? 'Income' : 'Expense',
          ),
        )
        .toList();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: chartData.map((data) =>
                          FlSpot(data.date.millisecondsSinceEpoch.toDouble(), data.amount)
                      ).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(TransactionItem transaction) {
    final isCredit = transaction.transactionType == 'credit';

    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isCredit
                ? Colors.green.withOpacity(0.2)
                : Colors.red.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isCredit ? Icons.arrow_downward : Icons.arrow_upward,
            color: isCredit ? Colors.green : Colors.red,
          ),
        ),
        title: Text(
          transaction.narration,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          '${transaction.transactionDate.day}/${transaction.transactionDate.month}/${transaction.transactionDate.year}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${isCredit ? '+' : '-'}${transaction.amount}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: isCredit ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              transaction.transactionType.toUpperCase(),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildInfoItem(
      BuildContext context, {
        required String title,
        required IconData icon,
        required Color color,
      }) {
    final provider = Provider.of<AccountProvider>(context);

    // Calculate amounts
    final isExpense = title == 'Expenses';
    final amount = isExpense
        ? provider.sentPayments.fold(0, (sum, p) => sum + p.amount)
        : (provider.walletBalance * 0.6).toInt();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(title),
            const SizedBox(height: 8),
            Text(
              '₦${amount.toString()}',
              style: TextStyle(
                color: isExpense ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isExpense) Consumer<AccountProvider>(
              builder: (context, provider, child) {
                return Text(
                  '${provider.sentPayments.length} transactions',
                  style: const TextStyle(fontSize: 12),
                );
              },
            ),

          ],
        ),
      ),
    );
  }

}

// Helper class for chart data
class ChartData {
  final DateTime date;
  final double amount;
  final String category;

  ChartData(this.date, this.amount, this.category);
}

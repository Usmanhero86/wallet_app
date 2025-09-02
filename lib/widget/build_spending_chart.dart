import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../model/transaction_history.dart';
import 'chart_data.dart';

Widget buildSpendingChart(List<TransactionItem> transactions, BuildContext context) {
  if (transactions.isEmpty) {
    return const Center(child: Text("No transactions yet"));
  }

  final chartData = transactions
      .map((t) => ChartData(
    t.transactionDate,
    t.amount,
    t.transactionType == 'credit' ? 'Income' : 'Expense',
  ))
      .toList();

  // Sort by date
  chartData.sort((a, b) => a.date.compareTo(b.date));

  // Separate income and expense
  final incomeSpots = chartData
      .where((d) => d.category == 'Income')
      .map((d) => FlSpot(d.date.millisecondsSinceEpoch.toDouble(), d.amount))
      .toList();

  final expenseSpots = chartData
      .where((d) => d.category == 'Expense')
      .map((d) => FlSpot(d.date.millisecondsSinceEpoch.toDouble(), d.amount))
      .toList();

  // Chart width grows with number of transactions (min 400px)
  final double chartWidth = (chartData.length * 160.0).clamp(400, 4000);

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

          // Scrollable chart
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.3,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: chartWidth,
                child: LineChart(
                  LineChartData(
                    minX: chartData.first.date.millisecondsSinceEpoch.toDouble(),
                    maxX: chartData.last.date.millisecondsSinceEpoch.toDouble(),
                    lineBarsData: [
                      //  Income line
                      LineChartBarData(
                        isCurved: true,
                        barWidth: 3,
                        color: Colors.green,
                        spots: incomeSpots,
                        dotData: FlDotData(show: false),
                      ),
                      // Red Expense line
                      LineChartBarData(
                        isCurved: true,
                        barWidth: 3,
                        color: Colors.red,
                        spots: expenseSpots,
                        dotData: FlDotData(show: false),
                      ),
                    ],
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 36,
                          interval: (chartData.length / 5).ceilToDouble(),
                          getTitlesWidget: (value, meta) {
                            final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                            return Text(
                              "${date.day}/${date.month}",
                              style: const TextStyle(fontSize: 10),
                            );
                          },
                        ),
                      ),
                    ),
                    gridData: FlGridData(show: true),
                    borderData: FlBorderData(show: false),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.circle, color: Colors.green, size: 12),
              SizedBox(width: 4),
              Text("Income"),
              SizedBox(width: 16),
              Icon(Icons.circle, color: Colors.red, size: 12),
              SizedBox(width: 4),
              Text("Expense"),
            ],
          ),
        ],
      ),
    ),
  );
}

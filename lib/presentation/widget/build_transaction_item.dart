import 'package:flutter/material.dart';
import '../../domain/entities/transaction_history.dart';

Widget buildTransactionItem(TransactionItem transaction, context) {
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


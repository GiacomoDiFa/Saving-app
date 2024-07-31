import 'package:flutter/material.dart';
import 'package:frontend/model/label.dart';
import 'package:frontend/model/transaction.dart';

class TransactionDetailScreen extends StatelessWidget {
  final Transaction transaction;
  final List<Label> labels;

  TransactionDetailScreen({required this.transaction, required this.labels});

  String getLabelName(List<Label> labels, String labelId) {
    return labels.firstWhere((label) => label.id == labelId).label;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transaction Details'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: Icon(Icons.label, color: Colors.blue),
                  title: Text(
                    'Label',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  subtitle: Text(getLabelName(labels, transaction.labelId)),
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.description, color: Colors.blue),
                  title: Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  subtitle: Text(transaction.description),
                ),
                Divider(),
                ListTile(
                  leading: Icon(
                    Icons.attach_money,
                    color: transaction.transactionType == 'income'
                        ? Colors.green
                        : Colors.red,
                  ),
                  title: Text(
                    'Amount',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  subtitle: Text(transaction.amount.toString()),
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.date_range, color: Colors.blue),
                  title: Text(
                    'Date',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  subtitle: Text(transaction.date),
                ),
                Divider(),
                ListTile(
                  leading: Icon(
                    transaction.transactionType == 'income'
                        ? Icons.arrow_downward
                        : Icons.arrow_upward,
                    color: transaction.transactionType == 'income'
                        ? Colors.green
                        : Colors.red,
                  ),
                  title: Text(
                    'Type',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  subtitle: Text(transaction.transactionType),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

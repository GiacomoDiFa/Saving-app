import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/model/label.dart';
import 'package:frontend/model/transaction.dart';
import 'package:frontend/provider/provider.dart';

class TransactionDetailScreen extends ConsumerWidget {
  final Transaction transaction;

  TransactionDetailScreen({required this.transaction});

  String getLabelName(List<Label> labels, String labelId) {
    return labels.firstWhere((label) => label.id == labelId).label;
  }

  void _editTransaction(BuildContext context) {
    // Implementa la logica per modificare la transazione
  }

  void _deleteTransaction(
      BuildContext context, String id, dynamic provider, WidgetRef ref) {
    // Implementa la logica per eliminare la transazione
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Conferma Eliminazione'),
          content: Text('Sei sicuro di voler eliminare questa transazione?'),
          actions: <Widget>[
            TextButton(
              child: Text('Annulla'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Elimina'),
              onPressed: () {
                // Esegui l'eliminazione della transazione
                ref.watch(provider.notifier).deleteTransaction(id);
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, '/home');
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final labels = ref.watch(labelProvider);
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
                Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _editTransaction(context),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteTransaction(
                          context, transaction.id, transactionProvider, ref),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

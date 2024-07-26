import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/model/label.dart';
import 'package:frontend/model/transaction.dart';
import 'package:frontend/provider/auth_riverpod.dart';
import 'package:frontend/provider/provider.dart';
import 'package:frontend/services/api_service.dart';
import 'add_transaction_screen.dart';
import 'package:intl/intl.dart';

class TransactionScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(authProvider);
    final transactions = ref.watch(transactionProvider);
    final labels = ref.watch(labelProvider);
    final selectedLabel = ref.watch(selectedLabelProvider);
    final isLoading = ref.watch(isLoadingProvider);

    Future<void> _fetchInitialData() async {
      await ref.read(labelProvider.notifier).fetchLabels();
      await ref.read(transactionProvider.notifier).fetchTransactions();
    }

    void _filterTransactions() {
      ref.read(isLoadingProvider.notifier).state = true;

      ref
          .read(transactionProvider.notifier)
          .filterTransactions(
            ref.read(selectedLabelProvider)?.id,
            ref.read(selectedMonthProvider),
            ref.read(selectedYearProvider),
          )
          .then((_) {
        ref.read(isLoadingProvider.notifier).state = false;
      });
    }

    double getTotalExpenses() {
      double total = 0.0;
      for (var transaction in transactions) {
        if (transaction.transactionType == 'expense') {
          total += transaction.amount;
        }
      }
      return total;
    }

    double getTotalIncome() {
      double total = 0.0;
      for (var transaction in transactions) {
        if (transaction.transactionType == 'income') {
          total += transaction.amount;
        }
      }
      return total;
    }

    Future<void> _selectMonthYear(BuildContext context) async {
      showModalBottomSheet(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (BuildContext context) {
          int tempYear = ref.read(selectedYearProvider);
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setModalState) {
              void _incrementYear() {
                setModalState(() {
                  tempYear += 1;
                });
              }

              void _decrementYear() {
                setModalState(() {
                  tempYear -= 1;
                });
              }

              return Container(
                height: 400,
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back),
                          onPressed: _decrementYear,
                        ),
                        Text(
                          '$tempYear',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.arrow_forward),
                          onPressed: _incrementYear,
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Expanded(
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          childAspectRatio: 2,
                        ),
                        itemCount: 12,
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () {
                              ref.read(selectedMonthProvider.notifier).state =
                                  index + 1;
                              ref.read(selectedYearProvider.notifier).state =
                                  tempYear;
                              _filterTransactions();
                              Navigator.pop(context);
                            },
                            child: Container(
                              alignment: Alignment.center,
                              margin: EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: ref.read(selectedMonthProvider) ==
                                            index + 1 &&
                                        ref.read(selectedYearProvider) ==
                                            tempYear
                                    ? Colors.blueAccent
                                    : Colors.grey[300],
                              ),
                              child: Text(
                                DateFormat('MMM')
                                    .format(DateTime(0, index + 1)),
                                style: TextStyle(
                                  color: ref.read(selectedMonthProvider) ==
                                              index + 1 &&
                                          ref.read(selectedYearProvider) ==
                                              tempYear
                                      ? Colors.white
                                      : Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    }

    void _previousMonth() {
      if (ref.read(selectedMonthProvider) == 1) {
        ref.read(selectedMonthProvider.notifier).state = 12;
        ref.read(selectedYearProvider.notifier).state -= 1;
      } else {
        ref.read(selectedMonthProvider.notifier).state -= 1;
      }
      _filterTransactions();
    }

    void _nextMonth() {
      if (ref.read(selectedMonthProvider) == 12) {
        ref.read(selectedMonthProvider.notifier).state = 1;
        ref.read(selectedYearProvider.notifier).state += 1;
      } else {
        ref.read(selectedMonthProvider.notifier).state += 1;
      }
      _filterTransactions();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Transactions'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              // Resetta tutti i provider e distruggi lo stato esistente
              // Aggiorna lo stato di autenticazione

              // Logout dell'utente e reindirizzamento alla schermata di login
              bool success = await ApiService().logoutUser();
              if (success) {
                Navigator.pushReplacementNamed(context, '/login');
              } else {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text('Logout fallito.')));
              }
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: _previousMonth,
                      icon: Icon(Icons.arrow_left),
                    ),
                    GestureDetector(
                      onTap: () => _selectMonthYear(context),
                      child: Text(
                        '${ref.read(selectedMonthProvider)}/${ref.read(selectedYearProvider)}',
                        style: TextStyle(
                            fontSize: 18.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      onPressed: _nextMonth,
                      icon: Icon(Icons.arrow_right),
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButton<Label>(
                        isExpanded: true,
                        value: selectedLabel,
                        onChanged: (newValue) {
                          ref.read(selectedLabelProvider.notifier).state =
                              newValue;
                          _filterTransactions();
                        },
                        items: [
                          DropdownMenuItem<Label>(
                            value: null,
                            child: Row(
                              children: [
                                Icon(Icons.label, color: Colors.blue),
                                SizedBox(width: 8.0),
                                Text('All'),
                              ],
                            ),
                          ),
                          ...labels.map((label) {
                            return DropdownMenuItem<Label>(
                              value: label,
                              child: Row(
                                children: [
                                  Icon(Icons.label, color: Colors.blue),
                                  SizedBox(width: 8.0),
                                  Text(label.label),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.0),
                    IconButton(
                      onPressed: () {
                        ref.read(selectedLabelProvider.notifier).state = null;
                        ref.read(selectedMonthProvider.notifier).state =
                            DateTime.now().month;
                        ref.read(selectedYearProvider.notifier).state =
                            DateTime.now().year;
                        _filterTransactions();
                      },
                      icon: Icon(Icons.refresh),
                      tooltip: 'Reset Filters',
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: DefaultTextStyle.of(context).style,
                        children: <TextSpan>[
                          TextSpan(
                            text: 'Total Expenses: ',
                            style: TextStyle(color: Colors.red),
                          ),
                          TextSpan(
                            text: '${getTotalExpenses().toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        style: DefaultTextStyle.of(context).style,
                        children: <TextSpan>[
                          TextSpan(
                            text: 'Total Income: ',
                            style: TextStyle(color: Colors.green),
                          ),
                          TextSpan(
                            text: '${getTotalIncome().toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : transactions.isEmpty
                    ? Center(child: Text('No data available'))
                    : ListView.builder(
                        itemCount: transactions.length,
                        itemBuilder: (context, index) {
                          Transaction transaction = transactions[index];
                          return Card(
                            elevation: 2.0,
                            margin: EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            child: ListTile(
                              title: Text(transaction.description),
                              subtitle: Text(
                                "${transaction.date}",
                                style: TextStyle(color: Colors.grey),
                              ),
                              trailing: Text(
                                transaction.amount.toString(),
                                style: TextStyle(
                                  color: transaction.transactionType == 'income'
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          bool? result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddTransactionScreen(labels: labels),
            ),
          );
          if (result != null && result) {
            ref.read(transactionProvider.notifier).fetchTransactions();
            ref.read(labelProvider.notifier).fetchLabels();
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

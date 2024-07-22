import 'package:flutter/material.dart';
import 'package:frontend/model/label.dart';
import 'package:frontend/model/transaction.dart';
import 'package:frontend/services/api_service.dart';
import 'add_transaction_screen.dart'; // Import the new screen
import 'package:intl/intl.dart';

class TransactionScreen extends StatefulWidget {
  @override
  _TransactionScreenState createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  List<Transaction> transactions = [];
  List<Label> labels = [];
  Label? selectedLabel;
  int? selectedMonth;
  int? selectedYear;
  final ApiService _apiService = ApiService();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    selectedMonth = now.month;
    selectedYear = now.year;
    fetchTransactionsAndLabels();
  }

  void showStatusDialog(BuildContext context, String message, bool isSuccess) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              Icon(
                isSuccess ? Icons.check_circle : Icons.error,
                color: isSuccess ? Colors.green : Colors.red,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(message),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> fetchTransactionsAndLabels() async {
    try {
      setState(() {
        isLoading = true;
      });

      List<Transaction> fetchedTransactions =
          await _apiService.getTransactions();
      List<Label> fetchedLabels = await _apiService.getLabels();

      setState(() {
        transactions = fetchedTransactions;
        labels = fetchedLabels;
        isLoading = false;
      });

      if (selectedLabel != null && !labels.contains(selectedLabel)) {
        setState(() {
          selectedLabel = null;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      showStatusDialog(context, 'Failed to load transactions', false);
    }
  }

  Future<void> filterTransactions() async {
    try {
      setState(() {
        isLoading = true;
      });
      List<Transaction> filteredTransactions =
          await _apiService.filterTransactions(
        selectedLabel?.id,
        selectedMonth,
        selectedYear,
      );

      setState(() {
        transactions = filteredTransactions;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      showStatusDialog(context, 'Failed to filter transactions', false);
    }
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
        int tempYear = selectedYear!;
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
                            setState(() {
                              selectedMonth = index + 1;
                              selectedYear = tempYear;
                              filterTransactions();
                            });
                            Navigator.pop(context);
                          },
                          child: Container(
                            alignment: Alignment.center,
                            margin: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: selectedMonth == index + 1 &&
                                      selectedYear == tempYear
                                  ? Colors.blueAccent
                                  : Colors.grey[300],
                            ),
                            child: Text(
                              DateFormat('MMM').format(DateTime(0, index + 1)),
                              style: TextStyle(
                                color: selectedMonth == index + 1 &&
                                        selectedYear == tempYear
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

  void _selectDate(BuildContext context) async {
    _selectMonthYear(context);
  }

  void _previousMonth() {
    setState(() {
      if (selectedMonth == 1) {
        selectedMonth = 12;
        selectedYear = selectedYear! - 1;
      } else {
        selectedMonth = selectedMonth! - 1;
      }
      filterTransactions();
    });
  }

  void _nextMonth() {
    setState(() {
      if (selectedMonth == 12) {
        selectedMonth = 1;
        selectedYear = selectedYear! + 1;
      } else {
        selectedMonth = selectedMonth! + 1;
      }
      filterTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transactions'),
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
                      onTap: () => _selectDate(context),
                      child: Text(
                        '$selectedMonth/$selectedYear',
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
                          setState(() {
                            selectedLabel = newValue;
                            filterTransactions();
                          });
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
                        setState(() {
                          selectedLabel = null;
                          selectedMonth = DateTime.now().month;
                          selectedYear = DateTime.now().year;
                          filterTransactions();
                        });
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
                                "${transaction.date}", // Assuming transaction.date is a DateTime object
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
            fetchTransactionsAndLabels();
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/model/label.dart';
import 'package:frontend/provider/provider.dart';
import 'package:frontend/services/api_service.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  final List<Label> labels;

  AddTransactionScreen({required this.labels});

  @override
  _AddTransactionScreenState createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedLabel;
  String _transactionType = 'expense';
  num _transactionAmount = 0;
  String _transactionDescription = '';
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    if (widget.labels.isNotEmpty) {
      _selectedLabel = widget.labels[0].label;
    }
  }

  Future<void> _addTransaction() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      await ref.watch(transactionProvider.notifier).addTransaction(
          _selectedLabel!,
          _transactionType,
          _transactionAmount.toString(),
          _transactionDescription,
          ref.watch(selectedLabelProvider.notifier).state?.label,
          ref.watch(selectedMonthProvider),
          ref.watch(selectedYearProvider));
      await ref.watch(statisticalProvider.notifier).fetchStatistical(
          ref.watch(selectedMonthProvider), ref.watch(selectedYearProvider));
      await ref.watch(labelexpencesProvider.notifier).fetchLabelExpences(
          ref.watch(selectedMonthProvider), ref.watch(selectedYearProvider));
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Transaction'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Label'),
                value: _selectedLabel,
                onChanged: (newValue) {
                  setState(() {
                    _selectedLabel = newValue;
                  });
                },
                items: widget.labels.map((Label label) {
                  return DropdownMenuItem<String>(
                    value: label.label,
                    child: Text(label.label),
                  );
                }).toList(),
                validator: (value) =>
                    value == null ? 'Please select a label' : null,
              ),
              SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Transaction Type'),
                value: _transactionType,
                onChanged: (newValue) {
                  setState(() {
                    _transactionType = newValue!;
                  });
                },
                items: ['income', 'expense'].map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                decoration: InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                onSaved: (value) {
                  _transactionAmount = num.parse(value!);
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                decoration: InputDecoration(labelText: 'Description'),
                onSaved: (value) {
                  _transactionDescription = value!;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: _addTransaction,
                child: Text('Add Transaction'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/provider/provider.dart';
import 'package:frontend/model/transaction.dart';
import 'package:frontend/screens/home_screen.dart';
import 'package:frontend/model/label.dart';

class ModifyTransactionScreen extends ConsumerStatefulWidget {
  final Transaction transaction;

  const ModifyTransactionScreen({Key? key, required this.transaction})
      : super(key: key);

  @override
  _ModifyTransactionScreenState createState() =>
      _ModifyTransactionScreenState();
}

class _ModifyTransactionScreenState
    extends ConsumerState<ModifyTransactionScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  late TextEditingController _dateController;

  Label? _selectedLabel;
  String? _selectedTransactionType;

  @override
  void initState() {
    super.initState();

    _selectedTransactionType = widget.transaction.transactionType;
    _amountController =
        TextEditingController(text: widget.transaction.amount.toString());
    _descriptionController =
        TextEditingController(text: widget.transaction.description);
    _dateController = TextEditingController(text: widget.transaction.date);

    // Recupera la label corrente
    final labels = ref.read(labelProvider);
    _selectedLabel =
        labels.firstWhere((label) => label.id == widget.transaction.labelId);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _modifyTransaction() async {
    if (_formKey.currentState!.validate()) {
      final labelId = _selectedLabel?.id ?? '';
      final transactionId = widget.transaction.id;
      final transactionType = _selectedTransactionType ?? '';
      final amount = double.tryParse(_amountController.text) ?? 0;
      final description = _descriptionController.text;
      final date = DateTime.parse(_dateController.text);

      EasyLoading.show(status: 'Loading...');
      try {
        await ref.read(transactionProvider.notifier).modifyTransaction(
              transactionId,
              labelId,
              transactionType,
              amount.toString(),
              description,
              date.toIso8601String(), // Assicurati che la data sia convertita correttamente
              ref.read(selectedMonthProvider),
              ref.read(selectedYearProvider),
            );
        await ref.watch(statisticalProvider.notifier).fetchStatistical(
            ref.watch(selectedMonthProvider), ref.watch(selectedYearProvider));
        await ref.watch(labelexpencesProvider.notifier).fetchLabelExpences(
            ref.watch(selectedMonthProvider), ref.watch(selectedYearProvider));
        EasyLoading.showSuccess('Transaction modified succesfully');
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => HomeScreen()),
          (Route<dynamic> route) => false,
        );
      } catch (error) {
        EasyLoading.showError('Failed to modify transaction');
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(_dateController.text),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = picked.toIso8601String();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final labels = ref.watch(labelProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Modify Transaction'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              DropdownButtonFormField<Label>(
                value: _selectedLabel,
                decoration: InputDecoration(labelText: 'Label'),
                items: labels.map<DropdownMenuItem<Label>>((Label label) {
                  return DropdownMenuItem<Label>(
                    value: label,
                    child: Text(label.label),
                  );
                }).toList(),
                onChanged: (Label? newValue) {
                  setState(() {
                    _selectedLabel = newValue;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a label';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _selectedTransactionType,
                decoration: InputDecoration(labelText: 'Transaction Type'),
                items: ['expense', 'income']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedTransactionType = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a transaction type';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _dateController,
                    decoration: InputDecoration(labelText: 'Date'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a date';
                      }
                      if (DateTime.tryParse(value) == null) {
                        return 'Please enter a valid date';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _modifyTransaction,
                child: Text('Modify Transaction'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

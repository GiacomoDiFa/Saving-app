import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/provider/label_riverpod.dart';
import 'package:frontend/provider/transaction_riverpod.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/model/transaction.dart';
import 'package:frontend/model/label.dart';

// Provider per ApiService
final apiServiceProvider = Provider((ref) => ApiService());

final transactionProvider =
    StateNotifierProvider<TransactionState, List<Transaction>>((ref) {
  return TransactionState(ref);
});

final labelProvider = StateNotifierProvider<LabelState, List<Label>>((ref) {
  return LabelState(ref);
});

// Provider per il filtro selezionato
final selectedLabelProvider = StateProvider<Label?>((ref) => null);
final selectedMonthProvider = StateProvider<int>((ref) => DateTime.now().month);
final selectedYearProvider = StateProvider<int>((ref) => DateTime.now().year);

// Provider per lo stato di caricamento
final isLoadingProvider = StateProvider<bool>((ref) => true);

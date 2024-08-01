import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/model/label_expense.dart';
import 'package:frontend/model/statistical.dart';
import 'package:frontend/model/user.dart';
import 'package:frontend/provider/label_riverpod.dart';
import 'package:frontend/provider/labelexpences_riverpod.dart';
import 'package:frontend/provider/statistical_riverpod.dart';
import 'package:frontend/provider/transaction_riverpod.dart';
import 'package:frontend/provider/user_riverpod.dart';
import 'package:frontend/services/api_service.dart';
import 'package:frontend/model/transaction.dart';
import 'package:frontend/model/label.dart';

// Provider per ApiService
final apiServiceProvider = Provider((ref) => ApiService());

final transactionProvider =
    StateNotifierProvider<TransactionState, List<Transaction>>((ref) {
  final user = ref.watch(userProvider);
  final transactionNotifier = TransactionState(ref);
  ref.onDispose(() {
    transactionNotifier.clearTransactions();
  });
  if (user != null) {
    transactionNotifier.fetchTransactions(
        ref.watch(selectedLabelProvider.notifier).state?.label,
        ref.watch(selectedMonthProvider),
        ref.watch(selectedYearProvider));
  }

  return transactionNotifier;
});

final statisticalProvider =
    StateNotifierProvider<StatisticalState, Statistical>((ref) {
  final user = ref.watch(userProvider);
  final month = ref.watch(selectedMonthProvider);
  final year = ref.watch(selectedYearProvider);
  final statisticalNotifier = StatisticalState(ref);
  ref.onDispose(() {
    statisticalNotifier.clearStatistical();
  });
  if (user != null) {
    statisticalNotifier.fetchStatistical(month.toString(), year.toString());
  }
  return statisticalNotifier;
});

final labelexpencesProvider =
    StateNotifierProvider<LabelExpencesState, List<LabelExpense>>((ref) {
  final user = ref.watch(userProvider);
  final month = ref.watch(selectedMonthProvider);
  final year = ref.watch(selectedYearProvider);
  final labelespencesNotifier = LabelExpencesState(ref);
  ref.onDispose(() {
    labelespencesNotifier.clearLabelsExpences();
  });
  if (user != null) {
    labelespencesNotifier.fetchLabelExpences(month.toString(), year.toString());
  }
  return labelespencesNotifier;
});

// Provider per l'utente
final userProvider =
    StateNotifierProvider<UserState, User?>((ref) => UserState(ref));

// Provider per le etichette
final labelProvider = StateNotifierProvider<LabelState, List<Label>>((ref) {
  final user = ref.watch(userProvider);
  final labelNotifier = LabelState(ref);

  // Resetta le etichette quando l'utente cambia
  ref.onDispose(() {
    labelNotifier.clearLabels();
  });

  // Ricarica le etichette quando l'utente cambia
  if (user != null) {
    labelNotifier.fetchLabels();
  }

  return labelNotifier;
});

// Provider per il filtro selezionato
final selectedLabelProvider = StateProvider<Label?>((ref) {
  final user = ref.watch(userProvider);
  if (user != null) {
    return null;
  }
  return null;
});

final selectedMonthProvider = StateProvider<int>((ref) {
  final user = ref.watch(userProvider);
  if (user != null) {
    return DateTime.now().month;
  }
  return DateTime.now().month;
});

final selectedYearProvider = StateProvider<int>((ref) {
  final user = ref.watch(userProvider);
  if (user != null) {
    return DateTime.now().year;
  }
  return DateTime.now().year;
});

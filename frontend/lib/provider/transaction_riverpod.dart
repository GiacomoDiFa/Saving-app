import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/model/transaction.dart';
import 'package:frontend/provider/provider.dart';

// StateNotifier per la gestione delle transazioni e delle etichette
class TransactionState extends StateNotifier<List<Transaction>> {
  TransactionState(this.ref) : super([]) {
    fetchTransactions(ref.watch(selectedLabelProvider.notifier).state?.label,
        ref.watch(selectedMonthProvider), ref.watch(selectedYearProvider));
  }

  final Ref ref;

  bool isLoading = false;

  Future<void> fetchTransactions(String? labelId, int? month, int? year) async {
    try {
      isLoading = true;
      await filterTransactions(labelId, month, year);
      isLoading = false;
    } catch (error) {
      print('failed to load the transactions');
    }
  }

  Future<void> filterTransactions(
      String? labelId, int? month, int? year) async {
    final apiService = ref.read(apiServiceProvider);
    isLoading = true;
    final transactions =
        await apiService.filterTransactions(labelId, month, year);
    state = transactions;
    isLoading = false;
  }

  Future<void> deleteTransaction(
      String id, String? labelId, int? month, int? year) async {
    try {
      isLoading = true;
      final apiService = ref.read(apiServiceProvider);
      final success = await apiService.deleteTransaction(id);
      final label = ref.watch(selectedLabelProvider.notifier).state = null;
      print(success);
      if (success) {
        await fetchTransactions(label, month, year);
      } else {
        isLoading = false;
      }
    } catch (error) {
      isLoading = false;
    }
  }

  Future<void> addTransaction(
      String label,
      String transactionType,
      String amount,
      String description,
      String? labelId,
      int? month,
      int? year) async {
    try {
      isLoading = true;
      final apiService = ref.read(apiServiceProvider);
      final success = await apiService.addTransaction(
          label, transactionType, amount, description);
      final labelSelected =
          ref.watch(selectedLabelProvider.notifier).state = null;
      if (success) {
        await fetchTransactions(labelSelected, month, year);
      } else {
        isLoading = false;
      }
    } catch (error) {
      isLoading = false;
    }
  }

  // Funzione di pulizia
  void clearTransactions() {
    state = [];
  }
}

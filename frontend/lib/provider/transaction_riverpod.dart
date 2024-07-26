import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/model/transaction.dart';
import 'package:frontend/provider/provider.dart';

// StateNotifier per la gestione delle transazioni e delle etichette
class TransactionState extends StateNotifier<List<Transaction>> {
  TransactionState(this.ref) : super([]) {
    fetchTransactions();
  }

  final Ref ref;

  bool isLoading = false;

  Future<void> fetchTransactions() async {
    try {
      isLoading = true;
      final apiService = ref.read(apiServiceProvider);
      final transactions = await apiService.getTransactions();
      state = transactions;
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

  // Funzione di pulizia
  void clearTransactions() {
    state = [];
  }
}

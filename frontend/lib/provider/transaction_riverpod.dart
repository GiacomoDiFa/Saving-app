import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/model/transaction.dart';
import 'package:frontend/provider/provider.dart';
import 'package:frontend/screens/transaction_screen.dart';

// StateNotifier per la gestione delle transazioni e delle etichette
class TransactionState extends StateNotifier<List<Transaction>> {
  TransactionState(this.ref) : super([]) {
    fetchTransactions();
  }

  final Ref ref;

  Future<void> fetchTransactions() async {
    try {
      final apiService = ref.read(apiServiceProvider);
      final transactions = await apiService.getTransactions();
      state = transactions;
      ref.read(isLoadingProvider.notifier).state = false;
    } catch (error) {
      print('failed to load the transactions');
    }
  }

  Future<void> filterTransactions(
      String? labelId, int? month, int? year) async {
    final apiService = ref.read(apiServiceProvider);
    final transactions =
        await apiService.filterTransactions(labelId, month, year);
    state = transactions;
  }

  // Funzione di pulizia
  void clearTransactions() {
    state = [];
  }
}

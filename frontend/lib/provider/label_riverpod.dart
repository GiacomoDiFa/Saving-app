// StateNotifier per la gestione delle etichette
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/model/label.dart';
import 'package:frontend/provider/provider.dart';

class LabelState extends StateNotifier<List<Label>> {
  LabelState(this.ref) : super([]) {
    fetchLabels();
  }

  final Ref ref;

  bool isLoading = false;

  Future<void> fetchLabels() async {
    try {
      isLoading = true;
      final _apiService = ref.read(apiServiceProvider);
      final fetchedLabels = await _apiService.getLabels();
      state = fetchedLabels;
      isLoading = false;
    } catch (e) {
      isLoading = false;
      // Gestione dell'errore
    }
  }

  Future<void> addLabel(String label, String fieldValue) async {
    isLoading = true;
    try {
      final _apiService = ref.read(apiServiceProvider);
      final success = await _apiService.addLabel(label, fieldValue);
      if (success) {
        await fetchLabels();
      } else {
        isLoading = false;
        // Gestione dell'errore
      }
    } catch (e) {
      isLoading = false;
      // Gestione dell'errore
    }
  }

  Future<void> updateLabel(
      Label label, String newLabel, String newFieldValue) async {
    isLoading = true;
    try {
      final _apiService = ref.read(apiServiceProvider);
      final success =
          await _apiService.updateLabel(label.label, newLabel, newFieldValue);
      if (success) {
        await fetchLabels();
      } else {
        isLoading = false;
        // Gestione dell'errore
      }
    } catch (e) {
      isLoading = false;
      // Gestione dell'errore
    }
  }

  Future<void> deleteLabel(String label) async {
    isLoading = true;
    try {
      final _apiService = ref.read(apiServiceProvider);
      final success = await _apiService.deleteLabel(label);
      if (success) {
        await fetchLabels();
      } else {
        isLoading = false;
        // Gestione dell'errore
      }
    } catch (e) {
      isLoading = false;
      // Gestione dell'errore
    }
  }

  // Funzione di pulizia
  void clearLabels() {
    state = [];
  }
}

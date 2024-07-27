import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/model/label_expense.dart';
import 'package:frontend/provider/provider.dart';
import 'package:frontend/services/api_service.dart';

class LabelExpencesState extends StateNotifier<List<LabelExpense>> {
  LabelExpencesState(this.ref) : super([]) {
    fetchLabelExpences();
  }

  final Ref ref;
  bool isLoading = false;

  Future<void> fetchLabelExpences() async {
    try {
      isLoading = true;
      final apiService = ref.read(apiServiceProvider);
      final labelexpences = await apiService.getLabelsExpenses();
      state = labelexpences;
      isLoading = false;
    } catch (error) {
      print('failed to load labelexpences');
    }
  }

  void clearLabelsExpences() {
    state = [];
  }
}

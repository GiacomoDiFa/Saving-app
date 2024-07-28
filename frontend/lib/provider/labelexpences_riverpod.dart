import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/model/label_expense.dart';
import 'package:frontend/provider/provider.dart';
import 'package:frontend/services/api_service.dart';

class LabelExpencesState extends StateNotifier<List<LabelExpense>> {
  LabelExpencesState(this.ref) : super([]) {
    fetchLabelExpences(
        ref.watch(selectedMonthProvider), ref.watch(selectedYearProvider));
  }

  final Ref ref;
  bool isLoading = false;

  Future<void> fetchLabelExpences(month, year) async {
    try {
      isLoading = true;
      final apiService = ref.read(apiServiceProvider);
      final String date;
      final monthString = month.toString();
      if (monthString.length == 1) {
        date = "$year-0$monthString-01";
      } else {
        date = "$year-$month-01";
      }
      final labelexpences = await apiService.getLabelsExpenses(date);
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

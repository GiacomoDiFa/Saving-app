import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/model/statistical.dart';
import 'package:frontend/provider/provider.dart';

class StatisticalState extends StateNotifier<Statistical> {
  StatisticalState(this.ref) : super(Statistical()) {
    fetchStatistical(
        ref.watch(selectedMonthProvider), ref.watch(selectedYearProvider));
  }
  final Ref ref;

  bool isLoading = false;
  Future<void> fetchStatistical(month, year) async {
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
      final fondamental = await apiService.getFundamentalMonthly(date);
      final fun = await apiService.getFunMonthly(date);
      final future = await apiService.getFutureYouMonthly(date);
      final income = await apiService.getMonthlyIncome(date);

      final stat = Statistical(
          fundamental: fondamental, fun: fun, future: future, income: income);
      state = stat;
      isLoading = false;
    } catch (error) {
      print('failed to load statistical');
    }
  }

  void clearStatistical() {
    state = Statistical();
  }
}

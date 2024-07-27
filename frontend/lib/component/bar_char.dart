import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:frontend/provider/provider.dart';

class BarChartSample extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final labelExpenses = ref.watch(labelexpencesProvider);

    return labelExpenses.isEmpty
        ? Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(8.0),
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: labelExpenses
                        .map((e) => e.totalAmount)
                        .reduce((a, b) => a > b ? a : b) +
                    10,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final expense = labelExpenses[group.x.toInt()];
                      final label = expense.label;
                      final amount = expense.totalAmount;
                      return BarTooltipItem(
                        '$label\n\$${amount.toStringAsFixed(2)}',
                        TextStyle(color: Colors.white),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          space: 16,
                          child: Text(
                            labelExpenses[value.toInt()].label,
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 14),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          space: 16,
                          child: Text(
                            value == 0
                                ? '0'
                                : value % 10 == 0
                                    ? value.toString()
                                    : '',
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 14),
                          ),
                        );
                      },
                      reservedSize: 40,
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: false,
                ),
                barGroups: labelExpenses
                    .asMap()
                    .map((index, expense) => MapEntry(
                          index,
                          BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: expense.totalAmount.toDouble(),
                                color: Colors.greenAccent,
                              ),
                            ],
                          ),
                        ))
                    .values
                    .toList(),
              ),
            ),
          );
  }
}

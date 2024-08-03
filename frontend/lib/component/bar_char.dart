import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:frontend/provider/provider.dart';

class BarChartSample extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final labelExpenses = ref.watch(labelexpencesProvider);
    final isLoading = ref.watch(labelexpencesProvider.notifier).isLoading;

    // Definisci una lista di colori distinti
    final List<Color> barColors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.yellow,
      Colors.pink,
      Colors.cyan,
      Colors.lime,
      Colors.teal,
    ];

    return isLoading
        ? Center(child: CircularProgressIndicator())
        : labelExpenses.isEmpty
            ? Center(
                child: Text(
                  'No bar chart available',
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              )
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
                          showTitles: false, // Nascondi i titoli in basso
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: false, // Nascondi i titoli a sinistra
                        ),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: false, // Nascondi i titoli in alto
                        ),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: false, // Nascondi i titoli a destra
                        ),
                      ),
                    ),
                    gridData: FlGridData(
                      show: true, // Mostra la griglia
                    ),
                    borderData: FlBorderData(
                      show: false, // Rimuovi il piano cartesiano
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
                                    color: barColors[index %
                                        barColors
                                            .length], // Assegna un colore diverso ad ogni barra
                                    width:
                                        20, // Aumenta la larghezza delle barre
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

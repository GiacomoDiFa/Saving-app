import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/provider/provider.dart';

class PieChartSample3 extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statistical = ref.watch(statisticalProvider);
    final isLoading = ref.watch(statisticalProvider.notifier).isLoading;
    final income = statistical.income ?? 0;
    final showNoChartMessage = income == 0;

    final List<PieChartSectionData> chartData = showNoChartMessage
        ? []
        : [
            PieChartSectionData(
              color: Colors.blue,
              value: (statistical.fundamental! / income * 100).toDouble(),
              title:
                  '${(statistical.fundamental! / income * 100).toStringAsFixed(1)}%',
              radius: 100.0,
              titleStyle: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff),
              ),
            ),
            PieChartSectionData(
              color: Colors.yellow,
              value: (statistical.fun! / income * 100).toDouble(),
              title: '${(statistical.fun! / income * 100).toStringAsFixed(1)}%',
              radius: 100.0,
              titleStyle: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff),
              ),
            ),
            PieChartSectionData(
              color: Colors.purple,
              value: (statistical.future! / income * 100).toDouble(),
              title:
                  '${(statistical.future! / income * 100).toStringAsFixed(1)}%',
              radius: 100.0,
              titleStyle: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
                color: const Color(0xffffffff),
              ),
            ),
          ];

    return AspectRatio(
      aspectRatio: 1.3,
      child: Column(
        children: [
          Expanded(
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : showNoChartMessage
                    ? Center(
                        child: Text(
                          'No pie chart available',
                          style: TextStyle(fontSize: 16, color: Colors.black),
                        ),
                      )
                    : PieChart(
                        PieChartData(
                          borderData: FlBorderData(show: false),
                          sectionsSpace: 0,
                          centerSpaceRadius: 0,
                          sections: chartData.isNotEmpty
                              ? chartData
                              : [
                                  PieChartSectionData(
                                      color: Colors.grey,
                                      value: 100,
                                      title: 'Loading')
                                ],
                        ),
                      ),
          ),
          if (!showNoChartMessage && !isLoading) ...[
            SizedBox(height: 16), // Space between the chart and the legend
            Container(
              margin: EdgeInsets.only(top: 100),
              color: Colors.grey[200],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Legend(color: Colors.blue, text: 'Fundamentals'),
                  SizedBox(height: 10),
                  Legend(color: Colors.yellow, text: 'Fun'),
                  SizedBox(height: 10),
                  Legend(color: Colors.purple, text: 'Future You'),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class Legend extends StatelessWidget {
  final Color color;
  final String text;

  const Legend({Key? key, required this.color, required this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          color: color,
        ),
        SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

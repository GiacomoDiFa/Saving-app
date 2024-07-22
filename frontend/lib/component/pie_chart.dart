import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:frontend/services/api_service.dart';

class PieChartSample3 extends StatefulWidget {
  final String selectedMonth;

  const PieChartSample3({super.key, required this.selectedMonth});

  @override
  State<StatefulWidget> createState() => PieChartSample3State();
}

class PieChartSample3State extends State<PieChartSample3> {
  int touchedIndex = -1;
  List<PieChartSectionData> chartData = [];
  bool showNoChartMessage = false;
  final ApiService _apiService = ApiService();

  final Map<int, String> colorNames = {
    0: 'Fundamentals',
    1: 'Fun',
    2: 'Future You',
  };

  @override
  void initState() {
    super.initState();
    fetchData(widget.selectedMonth);
  }

  @override
  void didUpdateWidget(PieChartSample3 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedMonth != widget.selectedMonth) {
      fetchData(widget.selectedMonth);
    }
  }

  Future<void> fetchData(String month) async {
    month = "$month-01";
    final num response1 = await _apiService.getFundamentalMonthly(month);
    final num response2 = await _apiService.getFunMonthly(month);
    final num response3 = await _apiService.getFutureYouMonthly(month);
    final num income = await _apiService.getMonthlyIncome(month);

    setState(() {
      if (income == 0) {
        showNoChartMessage = true;
        chartData = [];
      } else {
        showNoChartMessage = false;
        chartData = [
          PieChartSectionData(
            color: Colors.blue,
            value: (response1 / income * 100).toDouble(),
            title: '${(response1 / income * 100).toStringAsFixed(1)}%',
            radius: touchedIndex == 0 ? 120.0 : 100.0,
            titleStyle: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
              color: const Color(0xffffffff),
            ),
            badgeWidget: touchedIndex == 0
                ? Badge(color: Colors.blue, text: colorNames[0]!)
                : null,
          ),
          PieChartSectionData(
            color: Colors.yellow,
            value: (response2 / income * 100).toDouble(),
            title: '${(response2 / income * 100).toStringAsFixed(1)}%',
            radius: touchedIndex == 1 ? 120.0 : 100.0,
            titleStyle: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
              color: const Color(0xffffffff),
            ),
            badgeWidget: touchedIndex == 1
                ? Badge(color: Colors.yellow, text: colorNames[1]!)
                : null,
          ),
          PieChartSectionData(
            color: Colors.purple,
            value: (response3 / income * 100).toDouble(),
            title: '${(response3 / income * 100).toStringAsFixed(1)}%',
            radius: touchedIndex == 2 ? 120.0 : 100.0,
            titleStyle: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
              color: const Color(0xffffffff),
            ),
            badgeWidget: touchedIndex == 2
                ? Badge(color: Colors.purple, text: colorNames[2]!)
                : null,
          ),
        ];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.3,
      child: Column(
        children: [
          Expanded(
            child: showNoChartMessage
                ? Center(
                    child: Text(
                      'No pie chart available',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  )
                : PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (FlTouchEvent event, pieTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              touchedIndex = -1;
                              return;
                            }
                            touchedIndex = pieTouchResponse
                                .touchedSection!.touchedSectionIndex;
                          });
                        },
                      ),
                      borderData: FlBorderData(
                        show: false,
                      ),
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
          if (!showNoChartMessage) ...[
            SizedBox(height: 16), // Spazio tra il grafico e la legenda
            Container(
              margin: EdgeInsets.only(top: 100),
              color: Colors.grey[200],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Legend(color: Colors.blue, text: colorNames[0]!),
                  SizedBox(height: 10),
                  Legend(color: Colors.yellow, text: colorNames[1]!),
                  SizedBox(height: 10),
                  Legend(color: Colors.purple, text: colorNames[2]!),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class Badge extends StatelessWidget {
  final Color color;
  final String text;

  const Badge({Key? key, required this.color, required this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
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

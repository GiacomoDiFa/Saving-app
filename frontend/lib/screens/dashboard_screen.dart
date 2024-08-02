import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/component/bar_char.dart';
import 'package:frontend/component/pie_chart.dart';
import 'package:frontend/provider/provider.dart';
import 'package:frontend/services/api_service.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int selectedIndex = 0; // Indice per il PageView

  Future<void> _selectMonthYear(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        int tempYear = ref.read(selectedYearProvider);
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            void _incrementYear() {
              setModalState(() {
                tempYear += 1;
              });
            }

            void _decrementYear() {
              setModalState(() {
                tempYear -= 1;
              });
            }

            return Container(
              height: 400,
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: _decrementYear,
                      ),
                      Text(
                        '$tempYear',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.arrow_forward),
                        onPressed: _incrementYear,
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        childAspectRatio: 2,
                      ),
                      itemCount: 12,
                      itemBuilder: (BuildContext context, int index) {
                        return GestureDetector(
                          onTap: () {
                            ref.read(selectedMonthProvider.notifier).state =
                                index + 1;
                            ref.read(selectedYearProvider.notifier).state =
                                tempYear;

                            Navigator.pop(context);
                          },
                          child: Container(
                            alignment: Alignment.center,
                            margin: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: ref.read(selectedMonthProvider) ==
                                          index + 1 &&
                                      ref.read(selectedYearProvider) == tempYear
                                  ? Colors.blueAccent
                                  : Colors.grey[300],
                            ),
                            child: Text(
                              DateFormat('MMM').format(DateTime(0, index + 1)),
                              style: TextStyle(
                                color: ref.read(selectedMonthProvider) ==
                                            index + 1 &&
                                        ref.read(selectedYearProvider) ==
                                            tempYear
                                    ? Colors.white
                                    : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _previousMonth() {
    if (ref.read(selectedMonthProvider) == 1) {
      ref.read(selectedMonthProvider.notifier).state = 12;
      ref.read(selectedYearProvider.notifier).state -= 1;
    } else {
      ref.read(selectedMonthProvider.notifier).state -= 1;
    }
  }

  void _nextMonth() {
    if (ref.read(selectedMonthProvider) == 12) {
      ref.read(selectedMonthProvider.notifier).state = 1;
      ref.read(selectedYearProvider.notifier).state += 1;
    } else {
      ref.read(selectedMonthProvider.notifier).state += 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              bool success = await ApiService().logoutUser();
              if (success) {
                Navigator.pushReplacementNamed(context, '/login');
              } else {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text('Logout fallito.')));
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _previousMonth,
                  icon: Icon(Icons.arrow_left),
                ),
                GestureDetector(
                  onTap: () => _selectMonthYear(context),
                  child: Text(
                    '${ref.watch(selectedMonthProvider)}/${ref.watch(selectedYearProvider)}',
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  onPressed: _nextMonth,
                  icon: Icon(Icons.arrow_right),
                ),
              ],
            ),
            Expanded(
              child: PageView(
                onPageChanged: (int index) {
                  setState(() {
                    selectedIndex = index;
                  });
                },
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Pie Chart',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 20),
                        Expanded(
                          child: PieChartSample3(),
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Label Expenses Bar Chart',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 20),
                        Expanded(
                          child: BarChartSample(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  selectedIndex == 0 ? Icons.circle : Icons.circle_outlined,
                  color: Colors.blue,
                ),
                SizedBox(width: 10),
                Icon(
                  selectedIndex == 1 ? Icons.circle : Icons.circle_outlined,
                  color: Colors.blue,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:frontend/component/pie_chart.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DateTime selectedDate = DateTime.now();

  void _incrementMonth() {
    setState(() {
      selectedDate = DateTime(selectedDate.year, selectedDate.month + 1);
    });
  }

  void _decrementMonth() {
    setState(() {
      selectedDate = DateTime(selectedDate.year, selectedDate.month - 1);
    });
  }

  Future<void> _selectMonthYear(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        int tempYear = selectedDate.year;
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
                            setState(() {
                              selectedDate = DateTime(tempYear, index + 1);
                            });
                            Navigator.pop(context);
                          },
                          child: Container(
                            alignment: Alignment.center,
                            margin: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: selectedDate.year == tempYear &&
                                      selectedDate.month == index + 1
                                  ? Colors.blueAccent
                                  : Colors.grey[300],
                            ),
                            child: Text(
                              DateFormat('MMM').format(DateTime(0, index + 1)),
                              style: TextStyle(
                                color: selectedDate.year == tempYear &&
                                        selectedDate.month == index + 1
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: _decrementMonth,
          ),
          InkWell(
            onTap: () => _selectMonthYear(context),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  DateFormat('MMM yyyy').format(selectedDate),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward),
            onPressed: _incrementMonth,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: PieChartSample3(
            selectedMonth: DateFormat('yyyy-MM').format(selectedDate),
          ),
        ),
      ),
    );
  }
}

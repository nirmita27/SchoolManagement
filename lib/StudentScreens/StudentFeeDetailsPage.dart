import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';

class StudentFeeDetailsPage extends StatefulWidget {
  final int studentId;
  final String financialYear;

  StudentFeeDetailsPage({required this.studentId, required this.financialYear});

  @override
  _StudentFeeDetailsPageState createState() => _StudentFeeDetailsPageState();
}

class _StudentFeeDetailsPageState extends State<StudentFeeDetailsPage> {
  List<dynamic> feeStatus = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFeeStatus();
  }

  Future<void> _fetchFeeStatus() async {
    final url = Uri.parse('http://localhost:3000/feestatus/${widget.studentId}?financialYear=${widget.financialYear}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          feeStatus = data;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load fee status');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog('Failed to fetch fee status. Please try again.');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return feeStatus.map((fee) {
      return PieChartSectionData(
        color: Colors.primaries[feeStatus.indexOf(fee) % Colors.primaries.length],
        value: double.parse(fee['total_fee'].toString()),
        title: '${fee['quarter']}',
        radius: 60,
        titleStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fee Details'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchFeeStatus,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Fee Details for ${widget.financialYear}',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueAccent),
              ),
              SizedBox(height: 20),
              _buildFeeTable(),
              SizedBox(height: 20),
              _buildFeeStatusSection(),
              // SizedBox(height: 20),
              // _buildPieChart(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeeTable() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      shadowColor: Colors.grey.withOpacity(0.5),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Quarterly Fee Breakdown',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent),
            ),
            SizedBox(height: 10),
            Table(
              border: TableBorder(
                horizontalInside: BorderSide(width: 1, color: Colors.grey[300]!),
                verticalInside: BorderSide(width: 1, color: Colors.grey[300]!),
              ),
              columnWidths: {
                0: FractionColumnWidth(0.15),
                1: FractionColumnWidth(0.15),
                2: FractionColumnWidth(0.12),
                3: FractionColumnWidth(0.12),
                4: FractionColumnWidth(0.12),
                5: FractionColumnWidth(0.12),
                6: FractionColumnWidth(0.15),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(color: Colors.blueAccent),
                  children: [
                    _buildTableHeader('Quarter'),
                    _buildTableHeader('Tuition'),
                    _buildTableHeader('Exam'),
                    _buildTableHeader('Sports'),
                    _buildTableHeader('Electricity'),
                    _buildTableHeader('Bus'),
                    _buildTableHeader('No Bus'),
                    _buildTableHeader('Total'),
                  ],
                ),
                ...feeStatus.map((fee) {
                  return TableRow(
                    decoration: BoxDecoration(
                      color: feeStatus.indexOf(fee) % 2 == 0 ? Colors.grey[100] : Colors.white,
                    ),
                    children: [
                      _buildTableCell(fee['quarter'] ?? 'N/A'),
                      _buildTableCell(fee['tuition_fee']?.toString() ?? '0'),
                      _buildTableCell(fee['exam_fee']?.toString() ?? '0'),
                      _buildTableCell(fee['sports_fee']?.toString() ?? '0'),
                      _buildTableCell(fee['electricity_fee']?.toString() ?? '0'),
                      _buildTableCell(fee['transport_with_bus_fee']?.toString() ?? '0'),
                      _buildTableCell(fee['transport_without_bus_fee']?.toString() ?? '0'),
                      _buildTableCell(fee['total_fee']?.toString() ?? '0'),
                    ],
                  );
                }).toList(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeeStatusSection() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      shadowColor: Colors.grey.withOpacity(0.5),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fee Payment Status',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent),
            ),
            SizedBox(height: 10),
            Table(
              border: TableBorder(
                horizontalInside: BorderSide(width: 1, color: Colors.grey[300]!),
                verticalInside: BorderSide(width: 1, color: Colors.grey[300]!),
              ),
              columnWidths: {
                0: FractionColumnWidth(0.5),
                1: FractionColumnWidth(0.5),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(color: Colors.blueAccent),
                  children: [
                    _buildTableHeader('Quarter'),
                    _buildTableHeader('Status'),
                  ],
                ),
                ...feeStatus.map((status) {
                  return TableRow(
                    decoration: BoxDecoration(
                      color: feeStatus.indexOf(status) % 2 == 0 ? Colors.grey[100] : Colors.white,
                    ),
                    children: [
                      _buildTableCell(status['quarter'] ?? 'N/A'),
                      _buildTableCell(status['status'] ?? 'Unknown'),
                    ],
                  );
                }).toList(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      shadowColor: Colors.grey.withOpacity(0.5),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fee Distribution',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent),
            ),
            SizedBox(height: 10),
            AspectRatio(
              aspectRatio: 1.2,
              child: PieChart(
                PieChartData(
                  sections: showingSections(),
                  centerSpaceRadius: 40,
                  sectionsSpace: 0,
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          return;
                        }
                        final touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                        feeStatus[touchedIndex]['radius'] = 70.0;
                      });
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTableCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: TextStyle(fontSize: 14, color: Colors.black87),
        textAlign: TextAlign.center,
      ),
    );
  }
}

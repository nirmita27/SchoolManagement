import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:excel/excel.dart';
import 'dart:html' as html;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class FeesDashboardScreen extends StatefulWidget {
  final String schoolRange;

  FeesDashboardScreen({required this.schoolRange});

  @override
  _FeesDashboardScreenState createState() => _FeesDashboardScreenState();
}

class _FeesDashboardScreenState extends State<FeesDashboardScreen> {
  String? _selectedClass;
  String? _selectedMonth;
  String? _selectedYear;
  List<Map<String, dynamic>> _feesRecords = [];

  List<String> _classOptions() {
    return widget.schoolRange == '6-8' ? ['6', '7', '8'] : ['9', '10', '11', '12'];
  }

  final List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  final List<String> _years = List<String>.generate(10, (int index) {
    return (DateTime.now().year - index).toString();
  });

  Future<void> _fetchFeesRecords() async {
    var response = await http.get(Uri.parse('http://localhost:3000/fees-records'));
    if (response.statusCode == 200) {
      setState(() {
        _feesRecords = List<Map<String, dynamic>>.from(json.decode(response.body));
      });
    } else {
      print('Failed to fetch fees records');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchFeesRecords();
  }

  List<Map<String, dynamic>> _filteredFeesRecords() {
    return _feesRecords.where((record) {
      final matchesClass = _selectedClass == null || record['class'] == _selectedClass;
      final matchesYear = _selectedYear == null || record['year'] == _selectedYear;
      final recordMonthIndex = record['month'] is int ? record['month'] - 1 : _months.indexOf(record['month']);
      final recordMonth = recordMonthIndex >= 0 && recordMonthIndex < _months.length ? _months[recordMonthIndex] : null;
      final matchesMonth = _selectedMonth == null || recordMonth == _selectedMonth;
      return matchesClass && matchesYear && matchesMonth;
    }).toList();
  }

  Future<void> _generateExcel() async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Sheet1'];
    sheetObject.appendRow([
      'Class', 'Student Name', 'Parent Name', 'Contact Number', 'Address', 'Payment Mode',
      'Submitted To', 'Total Fee', 'Paid', 'Pending', 'Date'
    ]);

    for (var record in _filteredFeesRecords()) {
      double totalFee = record['total_fee'] is String ? double.tryParse(record['total_fee']) ?? 0.0 : record['total_fee'];
      double feesAmount = record['fees_amount'] is String ? double.tryParse(record['fees_amount']) ?? 0.0 : record['fees_amount'];
      double pendingFee = totalFee - feesAmount;
      sheetObject.appendRow([
        record['class'], record['student_name'], record['parent_name'], record['contact_number'],
        record['address'], record['payment_mode'], record['submitted_to'], totalFee,
        feesAmount, pendingFee, record['date']
      ]);
    }

    final bytes = excel.encode();
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', 'fees_records.xlsx')
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  Future<void> _generatePdf() async {
    final pdf = pw.Document();
    final headers = [
      'Class', 'Student Name', 'Parent Name', 'Contact Number', 'Address', 'Payment Mode',
      'Submitted To', 'Total Fee', 'Paid', 'Pending', 'Date'
    ];
    final data = _filteredFeesRecords().map((record) {
      double totalFee = record['total_fee'] is String ? double.tryParse(record['total_fee']) ?? 0.0 : record['total_fee'];
      double feesAmount = record['fees_amount'] is String ? double.tryParse(record['fees_amount']) ?? 0.0 : record['fees_amount'];
      double pendingFee = totalFee - feesAmount;
      return [
        record['class'], record['student_name'], record['parent_name'], record['contact_number'],
        record['address'], record['payment_mode'], record['submitted_to'], totalFee,
        feesAmount, pendingFee, record['date']
      ];
    }).toList();

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Table.fromTextArray(
          headers: headers,
          data: data,
        ),
      ),
    );

    final bytes = await pdf.save();
    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', 'fees_records.pdf')
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    final filteredFeesRecords = _filteredFeesRecords();
    filteredFeesRecords.sort((a, b) => DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));

    return Scaffold(
      appBar: AppBar(
        title: Text('Fees Dashboard (फीस डैशबोर्ड)'),
        backgroundColor: Colors.teal,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade300, Colors.teal.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedYear,
                      decoration: InputDecoration(
                        labelText: 'Select Year (वर्ष चुनें)',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                      ),
                      items: _years.map((String year) {
                        return DropdownMenuItem<String>(
                          value: year,
                          child: Text(year),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          _selectedYear = value;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 16.0),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedMonth,
                      decoration: InputDecoration(
                        labelText: 'Select Month (महीना चुनिए)',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                      ),
                      items: _months.map((String month) {
                        return DropdownMenuItem<String>(
                          value: month,
                          child: Text(month),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          _selectedMonth = value;
                        });
                      },
                    ),
                  ),
                  SizedBox(width: 16.0),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedClass,
                      decoration: InputDecoration(
                        labelText: 'Select Class (कक्षा का चयन करें)',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                      ),
                      items: _classOptions().map((String className) {
                        return DropdownMenuItem<String>(
                          value: className,
                          child: Text(className),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          _selectedClass = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _generateExcel,
                  child: Text('Download Excel'),
                ),
                SizedBox(width: 16.0),
                ElevatedButton(
                  onPressed: _generatePdf,
                  child: Text('Download PDF'),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: DataTable(
                      columns: [
                        DataColumn(label: Text('Class (कक्षा)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                        DataColumn(label: Text('Student Name (छात्र का नाम)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                        DataColumn(label: Text('Parent Name (अभिभावक का नाम)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                        DataColumn(label: Text('Contact Number (संपर्क संख्या)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                        DataColumn(label: Text('Address (पता)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                        DataColumn(label: Text('Payment Mode (भुगतान का प्रकार)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                        DataColumn(label: Text('Submitted To (को प्रस्तुत)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                        DataColumn(label: Text('Total Fee (कुल शुल्क)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                        DataColumn(label: Text('Paid (चुकाया गया)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                        DataColumn(label: Text('Pending (लंबित)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                        DataColumn(label: Text('Date (तारीख)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                      ],
                      rows: filteredFeesRecords.map((record) {
                        double totalFee = record['total_fee'] is String ? double.tryParse(record['total_fee']) ?? 0.0 : record['total_fee'];
                        double feesAmount = record['fees_amount'] is String ? double.tryParse(record['fees_amount']) ?? 0.0 : record['fees_amount'];
                        double pendingFee = totalFee - feesAmount;

                        return DataRow(cells: [
                          DataCell(Text(record['class'] ?? '')),
                          DataCell(Text(record['student_name'] ?? '')),
                          DataCell(Text(record['parent_name'] ?? '')),
                          DataCell(Text(record['contact_number'] ?? '')),
                          DataCell(Text(record['address'] ?? '')),
                          DataCell(Text(record['payment_mode'] ?? '')),
                          DataCell(Text(record['submitted_to'] ?? '')),
                          DataCell(Text('${totalFee.toStringAsFixed(2)}')),
                          DataCell(Text('${feesAmount.toStringAsFixed(2)}')),
                          DataCell(Text('${pendingFee.toStringAsFixed(2)}')),
                          DataCell(Text(record['date'] != null ? DateTime.parse(record['date']).toLocal().toString().split(' ')[0] : '')),
                        ]);
                      }).toList(),
                      dataRowColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
                        if (states.contains(MaterialState.selected)) return Theme.of(context).colorScheme.primary.withOpacity(0.08);
                        return null;
                      }),
                      headingRowColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
                        return Colors.teal.shade800;
                      }),
                      headingTextStyle: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      dataTextStyle: TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                      columnSpacing: 12,
                      dividerThickness: 2,
                      showBottomBorder: true,
                      headingRowHeight: 56,
                      dataRowHeight: 56,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

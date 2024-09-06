import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:excel/excel.dart';
import 'dart:html' as html;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ExpenditureDashboardScreen extends StatefulWidget {
  @override
  _ExpenditureDashboardScreenState createState() => _ExpenditureDashboardScreenState();
}

class _ExpenditureDashboardScreenState extends State<ExpenditureDashboardScreen> {
  String? _selectedCategory;
  String? _selectedMonth;
  String? _selectedYear;

  final List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  final List<String> _years = List<String>.generate(10, (int index) {
    return (DateTime.now().year - index).toString();
  });

  List<Map<String, dynamic>> _expenditures = [];

  Future<void> _fetchExpenditures() async {
    var response = await http.get(Uri.parse('http://localhost:3000/expenditures'));
    if (response.statusCode == 200) {
      setState(() {
        _expenditures = List<Map<String, dynamic>>.from(json.decode(response.body));
      });
    } else {
      print('Failed to fetch expenditures');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchExpenditures();
  }

  List<Map<String, dynamic>> _filteredExpenditures() {
    return _expenditures.where((expenditure) {
      final matchesYear = _selectedYear == null || expenditure['year'].toString() == _selectedYear;
      final matchesMonth = _selectedMonth == null || expenditure['month'] == _selectedMonth;
      final matchesCategory = _selectedCategory == null || expenditure['category'] == _selectedCategory;
      return matchesYear && matchesMonth && matchesCategory;
    }).toList();
  }

  Future<void> _generateExcel() async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Sheet1'];
    sheetObject.appendRow([
      'Category', 'Description', 'Amount', 'Payment Mode', 'Date', 'Staff Name', 'Staff ID'
    ]);

    for (var expenditure in _filteredExpenditures()) {
      sheetObject.appendRow([
        expenditure['category'], expenditure['description'], expenditure['amount'],
        expenditure['payment_mode'], expenditure['date'],
        expenditure['staff_name'] ?? '', expenditure['staff_id'] ?? ''
      ]);
    }

    final bytes = excel.encode();
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', 'expenditures.xlsx')
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  Future<void> _generatePdf() async {
    final pdf = pw.Document();
    final headers = [
      'Category', 'Description', 'Amount', 'Payment Mode', 'Date', 'Staff Name', 'Staff ID'
    ];
    final data = _filteredExpenditures().map((expenditure) {
      return [
        expenditure['category'], expenditure['description'], expenditure['amount'],
        expenditure['payment_mode'], expenditure['date'],
        expenditure['staff_name'] ?? '', expenditure['staff_id'] ?? ''
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
      ..setAttribute('download', 'expenditures.pdf')
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  Future<void> _editExpenditure(int index) async {
    final expenditure = _expenditures[index];
    final updatedExpenditure = await _showEditDialog(context, expenditure);
    if (updatedExpenditure != null) {
      print("Updated Expenditure: $updatedExpenditure");  // Debugging line
      try {
        final response = await http.patch(
          Uri.parse('http://localhost:3000/expenditures/${expenditure['id']}'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(updatedExpenditure),
        );
        if (response.statusCode == 200) {
          setState(() {
            _expenditures[index] = updatedExpenditure;
          });
        } else {
          print('Failed to update expenditure with status code: ${response.statusCode}');
          print('Response body: ${response.body}');
        }
      } catch (e) {
        print('Error updating expenditure: $e');
      }
    }
  }

  void _deleteExpenditure(int id, int index) async {
    try {
      final response = await http.delete(Uri.parse('http://localhost:3000/expenditures/$id'));
      if (response.statusCode == 200) {
        setState(() {
          _expenditures.removeAt(index);
        });
      } else {
        print('Failed to delete expenditure: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error deleting expenditure: $e');
    }
  }

  Future<Map<String, dynamic>?> _showEditDialog(BuildContext context, Map<String, dynamic> expenditure) {
    TextEditingController categoryController = TextEditingController(text: expenditure['category']);
    TextEditingController descriptionController = TextEditingController(text: expenditure['description']);
    TextEditingController amountController = TextEditingController(text: expenditure['amount'].toString());
    TextEditingController paymentModeController = TextEditingController(text: expenditure['payment_mode'] ?? '');
    TextEditingController dateController = TextEditingController(text: expenditure['date']);
    TextEditingController staffNameController = TextEditingController(text: expenditure['staff_name'] ?? '');
    TextEditingController staffIdController = TextEditingController(text: expenditure['staff_id'] ?? '');

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Expenditure (व्यय संपादित करें)'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: categoryController,
                  decoration: InputDecoration(labelText: 'Category (श्रेणी)'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: 'Description (विवरण)'),
                ),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Amount (रकम)'),
                ),
                TextField(
                  controller: paymentModeController,
                  decoration: InputDecoration(labelText: 'Payment Mode (भुगतान का प्रकार)'),
                ),
                TextField(
                  controller: dateController,
                  keyboardType: TextInputType.datetime,
                  decoration: InputDecoration(labelText: 'Date (तिथि)'),
                ),
                if (categoryController.text == 'Salary') ...[
                  TextField(
                    controller: staffNameController,
                    decoration: InputDecoration(labelText: 'Staff Name (स्टाफ का नाम)'),
                  ),
                  TextField(
                    controller: staffIdController,
                    decoration: InputDecoration(labelText: 'Staff ID (स्टाफ आईडी)'),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Save'),
              onPressed: () {
                final updatedExpenditure = {
                  'category': categoryController.text,
                  'description': descriptionController.text,
                  'amount': double.tryParse(amountController.text) ?? 0.0,
                  'payment_mode': paymentModeController.text,
                  'date': dateController.text,
                  'staff_name': categoryController.text == 'Salary' ? staffNameController.text : expenditure['staff_name'],
                  'staff_id': categoryController.text == 'Salary' ? staffIdController.text : expenditure['staff_id'],
                  'month': expenditure['month'],
                  'year': expenditure['year'],
                };
                Navigator.of(context).pop(updatedExpenditure);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredExpenditures = _filteredExpenditures();
    filteredExpenditures.sort((a, b) => DateTime.parse(b['date']).compareTo(DateTime.parse(a['date'])));

    return Scaffold(
      appBar: AppBar(
        title: Text('Expenditure Dashboard (व्यय डैशबोर्ड)'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ExpenditureChartScreen(expenditures: _expenditures),
                ),
              );
            },
          ),
        ],
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
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Select Category (श्रेणी चुनना)',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                ),
                items: ['Salary', 'Building', 'Electricity', 'Event', 'Miscellaneous'].map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: DataTable(
                      columns: [
                        DataColumn(label: Text('Category (श्रेणी)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                        DataColumn(label: Text('Description (विवरण)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                        DataColumn(label: Text('Amount (रकम)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                        DataColumn(label: Text('Payment Mode (भुगतान का प्रकार)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                        DataColumn(label: Text('Date (तिथि)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                        DataColumn(label: Text('Staff Name (स्टाफ का नाम)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                        DataColumn(label: Text('Staff ID (स्टाफ आईडी)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                        DataColumn(label: Text('Actions (कार्रवाई)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                      ],
                      rows: filteredExpenditures.map((expenditure) {
                        int index = _expenditures.indexOf(expenditure);
                        return DataRow(cells: [
                          DataCell(Text(expenditure['category'] ?? '')),
                          DataCell(Text(expenditure['description'] ?? '')),
                          DataCell(Text(expenditure['amount']?.toString() ?? '')),
                          DataCell(Text(expenditure['payment_mode'] ?? '')),
                          DataCell(Text(expenditure['date'] != null ? DateTime.parse(expenditure['date']).toLocal().toString().split(' ')[0] : '')),
                          DataCell(Text(expenditure['category'] == 'Salary' ? expenditure['staff_name'] ?? '' : '')),
                          DataCell(Text(expenditure['category'] == 'Salary' ? expenditure['staff_id'] ?? '' : '')),
                          DataCell(
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _editExpenditure(index),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteExpenditure(expenditure['id'], index),
                                ),
                              ],
                            ),
                          ),
                        ]);
                      }).toList(),
                      dataRowColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
                        if (states.contains(MaterialState.selected)) return Theme.of(context).colorScheme.primary.withOpacity(0.08);
                        return null;  // Use the default value.
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

class ExpenditureChartScreen extends StatelessWidget {
  final List<Map<String, dynamic>> expenditures;

  ExpenditureChartScreen({required this.expenditures});

  @override
  Widget build(BuildContext context) {
    final List<String> months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    Map<String, double> monthlyExpenditures = _calculateMonthlyExpenditures(months);

    List<BarChartGroupData> barGroups = monthlyExpenditures.entries.map((entry) {
      return BarChartGroupData(
        x: months.indexOf(entry.key),
        barRods: [
          BarChartRodData(
            toY: entry.value,
            color: Colors.lightBlueAccent,
          ),
        ],
      );
    }).toList();

    double totalExpenditure = monthlyExpenditures.values.fold(0, (sum, element) => sum + element);

    return Scaffold(
      appBar: AppBar(
        title: Text('Expenditure Chart'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Total Expenditure: \$${totalExpenditure.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Expanded(
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barGroups: barGroups,
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          );
                        },
                        reservedSize: 40,
                        interval: 1,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              value >= 0 && value < months.length ? months[value.toInt()] : '',
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          );
                        },
                        reservedSize: 40,
                        interval: 1,
                      ),
                    ),
                  ),
                ),
              )
            ),
          ],
        ),
      ),
    );
  }

  Map<String, double> _calculateMonthlyExpenditures(List<String> months) {
    Map<String, double> monthlyExpenditures = {
      for (var month in months) month: 0.0
    };

    for (var expenditure in expenditures) {
      var monthName = expenditure['month'];
      if (months.contains(monthName)) {
        monthlyExpenditures[monthName] = (monthlyExpenditures[monthName] ?? 0.0) + (double.tryParse(expenditure['amount'].toString()) ?? 0.0);
      }
    }

    return monthlyExpenditures;
  }
}

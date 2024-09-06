import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;

class StudentICardScreen extends StatefulWidget {
  final String schoolRange;

  StudentICardScreen({required this.schoolRange});

  @override
  _StudentICardScreenState createState() => _StudentICardScreenState();
}

class _StudentICardScreenState extends State<StudentICardScreen> {
  List students = [];
  List<int> selectedStudents = [];
  int currentPage = 1; // Start pages from 1
  final int pageSize = 20;
  bool isLoading = false;
  bool allLoaded = false;

  @override
  void initState() {
    super.initState();
    _fetchStudents();
  }

  Future<void> _fetchStudents() async {
    if (isLoading || (allLoaded && currentPage == 1)) return;
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(
          'http://localhost:3000/studentList?offset=${(currentPage - 1) * pageSize}&limit=$pageSize&schoolRange=${widget.schoolRange}')); // Page adjusted for zero index API
      if (response.statusCode == 200) {
        List newStudents = json.decode(response.body);
        setState(() {
          isLoading = false;
          if (currentPage == 1) {
            students = newStudents;
          } else {
            students.addAll(newStudents);
          }
          if (newStudents.length < pageSize) {
            allLoaded = true;
          } else {
            allLoaded = false;
          }
        });
      } else {
        setState(() {
          isLoading = false;
        });
        throw Exception('Failed to load students');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        print('Error: $e'); // Debug statement
      });
    }
  }

  Future<void> _generateIdCards() async {
    final pdf = pw.Document();
    final hindiFont = await rootBundle.load("fonts/NotoSans-Regular.ttf");
    final ttf = pw.Font.ttf(hindiFont);

    for (var student in students.where((s) => selectedStudents.contains(s['serial_no']))) {
      pdf.addPage(
        pw.Page(
          build: (context) => pw.Container(
            padding: pw.EdgeInsets.all(20),
            child: pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(width: 2, color: PdfColors.black),
                borderRadius: pw.BorderRadius.all(pw.Radius.circular(15)),
                color: PdfColors.white,
              ),
              padding: pw.EdgeInsets.all(10),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text(
                    'महर्षि विद्या पीठ पटेल श्री पी.एस.एस. कन्या इण्टर कालेज बवेरू-वाँदा (उ० प्र०)',
                    style: pw.TextStyle(
                      font: ttf,
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.red,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                  pw.SizedBox(height: 10),
                  pw.Container(
                    width: 80,
                    height: 100,
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(width: 1, color: PdfColors.black),
                      borderRadius: pw.BorderRadius.all(pw.Radius.circular(5)),
                    ),
                    child: pw.Center(
                      child: pw.Text(
                        'Photo',
                        style: pw.TextStyle(fontSize: 10, color: PdfColors.black),
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Divider(color: PdfColors.black, thickness: 1),
                  pw.SizedBox(height: 10),
                  _buildInfoRow('Admission No:', '${student['serial_no']}', ttf),
                  _buildInfoRow('Name:', '${student['student_name']}', ttf),
                  _buildInfoRow('Class:', '${student['class_section']}', ttf),
                  _buildInfoRow('Address:', '${student['address']}', ttf),
                  _buildInfoRow('Phone:', '${student['mobile_number']}', ttf),
                  _buildInfoRow('Father:', '${student['father_name']}', ttf),
                  _buildInfoRow('Mother:', '${student['mother_name']}', ttf),
                ],
              ),
            ),
          ),
        ),
      );
    }

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  pw.Widget _buildInfoRow(String label, String value, pw.Font font) {
    return pw.Padding(
      padding: pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.start,
        children: [
          pw.Expanded(
            flex: 2,
            child: pw.Text(
              label,
              style: pw.TextStyle(font: font, fontSize: 12),
            ),
          ),
          pw.Expanded(
            flex: 3,
            child: pw.Text(
              value,
              style: pw.TextStyle(font: font, fontSize: 12, fontWeight: pw.FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _goToPreviousPage() {
    if (currentPage > 1) {
      setState(() {
        currentPage--;
        _fetchStudents();
      });
    }
  }

  void _goToNextPage() {
    if (!allLoaded) {
      setState(() {
        currentPage++;
        _fetchStudents();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student I-Card'),
        backgroundColor: Colors.blueAccent,
        actions: [
          if (selectedStudents.isNotEmpty)
            IconButton(
              icon: Icon(Icons.download),
              onPressed: _generateIdCards,
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blue[50]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: DataTable(
                  showCheckboxColumn: true, // Shows checkboxes in the first column
                  columns: [
                    DataColumn(label: Text('Select')),
                    DataColumn(label: Text('Admission No')),
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('Class & Section')),
                    DataColumn(label: Text('Father\'s Name')),
                    DataColumn(label: Text('Mother\'s Name')),
                    DataColumn(label: Text('Mobile No.')),
                    DataColumn(label: Text('Address')),
                  ],
                  rows: students.map<DataRow>((student) {
                    return DataRow(
                      selected: selectedStudents.contains(student['serial_no']),
                      onSelectChanged: (bool? selected) {
                        setState(() {
                          if (selected ?? false) {
                            selectedStudents.add(student['serial_no']);
                          } else {
                            selectedStudents.remove(student['serial_no']);
                          }
                        });
                      },
                      cells: [
                        DataCell(Text('')), // Placeholder for checkbox handled by `onSelectChanged`
                        DataCell(Text(student['serial_no'].toString())),
                        DataCell(Text(student['student_name'] ?? 'N/A')),
                        DataCell(Text(student['class_section'] ?? 'N/A')),
                        DataCell(Text(student['father_name'] ?? 'N/A')),
                        DataCell(Text(student['mother_name'] ?? 'N/A')),
                        DataCell(Text(student['mobile_number'] ?? 'N/A')),
                        DataCell(Text(student['address'] ?? 'N/A')),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
            if (isLoading)
              CircularProgressIndicator(),
            if (!isLoading && (currentPage > 1 || !allLoaded))
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                    onPressed: _goToPreviousPage,
                    child: Icon(Icons.arrow_back),
                  ),
                  Text('Page $currentPage'),
                  OutlinedButton(
                    onPressed: _goToNextPage,
                    child: Icon(Icons.arrow_forward),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

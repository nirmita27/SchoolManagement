import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MonthlyIssuedReportScreen extends StatefulWidget {
  @override
  _MonthlyIssuedReportScreenState createState() => _MonthlyIssuedReportScreenState();
}

class _MonthlyIssuedReportScreenState extends State<MonthlyIssuedReportScreen> {
  DateTime? fromDate;
  DateTime? toDate;
  String bookName = '';
  String issueType = '';
  String studentName = '';
  String classSection = '';
  List issueTypes = ['All', 'Student', 'Staff'];

  Future<void> _selectFromDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: fromDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != fromDate)
      setState(() {
        fromDate = picked;
      });
  }

  Future<void> _selectToDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: toDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != toDate)
      setState(() {
        toDate = picked;
      });
  }

  Future<void> _downloadReport(String format) async {
    final response = await http.get(Uri.parse(
        'http://localhost:3000/issued_books_report/$format?fromDate=${fromDate?.toIso8601String() ?? ''}&toDate=${toDate?.toIso8601String() ?? ''}&bookName=$bookName&issueType=$issueType&studentName=$studentName&classSection=$classSection'));

    if (response.statusCode == 200) {
      // Handle the file download
      // For simplicity, here we are not implementing the file download logic
      print('$format report downloaded successfully');
    } else {
      // Handle error
      print('Failed to download $format report');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Monthly Issued Report'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'From Date',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.calendar_today),
                        onPressed: () => _selectFromDate(context),
                      ),
                    ),
                    controller: TextEditingController(
                      text: fromDate != null
                          ? "${fromDate!.toLocal()}".split(' ')[0]
                          : '',
                    ),
                  ),
                ),
                SizedBox(width: 16.0),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'To Date',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.calendar_today),
                        onPressed: () => _selectToDate(context),
                      ),
                    ),
                    controller: TextEditingController(
                      text: toDate != null
                          ? "${toDate!.toLocal()}".split(' ')[0]
                          : '',
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            TextField(
              decoration: InputDecoration(
                labelText: 'Enter Book Name/Accession No.',
              ),
              onChanged: (value) {
                setState(() {
                  bookName = value;
                });
              },
            ),
            SizedBox(height: 16.0),
            DropdownButtonFormField(
              decoration: InputDecoration(
                labelText: 'Select Issue Type',
              ),
              value: issueType.isNotEmpty ? issueType : null,
              items: issueTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  issueType = value as String;
                });
              },
            ),
            SizedBox(height: 16.0),
            TextField(
              decoration: InputDecoration(
                labelText: 'Enter Student/Staff Name...',
              ),
              onChanged: (value) {
                setState(() {
                  studentName = value;
                });
              },
            ),
            SizedBox(height: 16.0),
            TextField(
              decoration: InputDecoration(
                labelText: 'Select Class & Section',
              ),
              onChanged: (value) {
                setState(() {
                  classSection = value;
                });
              },
            ),
            SizedBox(height: 32.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => _downloadReport('pdf'),
                  child: Text('DOWNLOAD PDF'),
                ),
                SizedBox(width: 16.0),
                ElevatedButton(
                  onPressed: () => _downloadReport('excel'),
                  child: Text('DOWNLOAD EXCEL'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

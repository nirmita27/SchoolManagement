import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UploadedStudentReportCardScreen extends StatefulWidget {
  @override
  _UploadedStudentReportCardScreenState createState() => _UploadedStudentReportCardScreenState();
}

class _UploadedStudentReportCardScreenState extends State<UploadedStudentReportCardScreen> {
  List<Map<String, dynamic>> reportCards = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchReportCards();
  }

  Future<void> _fetchReportCards() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/uploadedReportCards'));
      if (response.statusCode == 200) {
        setState(() {
          reportCards = List<Map<String, dynamic>>.from(json.decode(response.body));
          isLoading = false;
        });
      } else {
        print('Failed to fetch report cards');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _showReportCardDialog({Map<String, dynamic>? reportCard}) {
    final enrollmentNoController = TextEditingController(text: reportCard?['enrollment_no']);
    final rollNoController = TextEditingController(text: reportCard?['roll_no']);
    final nameController = TextEditingController(text: reportCard?['name']);
    final classSectionController = TextEditingController(text: reportCard?['class_section']);
    final reportCardController = TextEditingController(text: reportCard?['report_card']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(reportCard == null ? 'Add Report Card' : 'Edit Report Card'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: enrollmentNoController,
                  decoration: InputDecoration(labelText: 'Enrollment No.'),
                ),
                TextField(
                  controller: rollNoController,
                  decoration: InputDecoration(labelText: 'Roll No.'),
                ),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: classSectionController,
                  decoration: InputDecoration(labelText: 'Class & Section'),
                ),
                TextField(
                  controller: reportCardController,
                  decoration: InputDecoration(labelText: 'Report Card'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (reportCard == null) {
                  _addReportCard(
                    enrollmentNoController.text,
                    rollNoController.text,
                    nameController.text,
                    classSectionController.text,
                    reportCardController.text,
                  );
                } else {
                  _updateReportCard(
                    reportCard['id'],
                    enrollmentNoController.text,
                    rollNoController.text,
                    nameController.text,
                    classSectionController.text,
                    reportCardController.text,
                  );
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addReportCard(String enrollmentNo, String rollNo, String name, String classSection, String reportCard) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/addReportCard'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'enrollment_no': enrollmentNo,
          'roll_no': rollNo,
          'name': name,
          'class_section': classSection,
          'report_card': reportCard,
          'student_id': 1, // Replace with actual student ID
        }),
      );

      if (response.statusCode == 201) {
        _fetchReportCards();
      } else {
        print('Failed to add report card');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _updateReportCard(int id, String enrollmentNo, String rollNo, String name, String classSection, String reportCard) async {
    try {
      final response = await http.put(
        Uri.parse('http://localhost:3000/updateReportCard/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'enrollment_no': enrollmentNo,
          'roll_no': rollNo,
          'name': name,
          'class_section': classSection,
          'report_card': reportCard,
          'student_id': 1, // Replace with actual student ID
        }),
      );

      if (response.statusCode == 200) {
        _fetchReportCards();
      } else {
        print('Failed to update report card');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _deleteReportCard(int id) async {
    try {
      final response = await http.delete(Uri.parse('http://localhost:3000/deleteReportCard/$id'));

      if (response.statusCode == 204) {
        _fetchReportCards();
      } else {
        print('Failed to delete report card');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Uploaded Student Report Card'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(),
            SizedBox(height: 20),
            _buildReportCardTable(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showReportCardDialog(),
        child: Icon(Icons.add),
        backgroundColor: Colors.teal,
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        labelText: 'Search Student',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.search),
      ),
    );
  }

  Widget _buildReportCardTable() {
    return Expanded(
      child: isLoading
          ? Center(child: CircularProgressIndicator())
          : reportCards.isEmpty
          ? Center(child: Text('No Records Found.'))
          : DataTable(
        columns: [
          DataColumn(label: Text('S.No.')),
          DataColumn(label: Text('Enrollment No.')),
          DataColumn(label: Text('Roll No.')),
          DataColumn(label: Text('Name')),
          DataColumn(label: Text('Class & Section')),
          DataColumn(label: Text('Report Card')),
          DataColumn(label: Text('Actions')),
        ],
        rows: reportCards
            .asMap()
            .entries
            .map(
              (entry) => DataRow(
            cells: [
              DataCell(Text((entry.key + 1).toString())),
              DataCell(Text(entry.value['enrollment_no'])),
              DataCell(Text(entry.value['roll_no'])),
              DataCell(Text(entry.value['name'])),
              DataCell(Text(entry.value['class_section'])),
              DataCell(Text(entry.value['report_card'])),
              DataCell(
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => _showReportCardDialog(reportCard: entry.value),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _deleteReportCard(entry.value['id']),
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
            .toList(),
      ),
    );
  }
}

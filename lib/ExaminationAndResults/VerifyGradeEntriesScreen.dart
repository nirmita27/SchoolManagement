import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class VerifyGradeEntriesScreen extends StatefulWidget {
  @override
  _VerifyGradeEntriesScreenState createState() => _VerifyGradeEntriesScreenState();
}

class _VerifyGradeEntriesScreenState extends State<VerifyGradeEntriesScreen> {
  List classSections = [];
  List assessments = [];
  String? selectedClassSection;
  String? selectedAssessment;

  @override
  void initState() {
    super.initState();
    fetchInitialData();
  }

  Future<void> fetchInitialData() async {
    await fetchClassSections();
    await fetchAssessments();
  }

  Future<void> fetchClassSections() async {
    final response = await http.get(Uri.parse('http://localhost:3000/class-sections'));
    if (response.statusCode == 200) {
      setState(() {
        classSections = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load class sections');
    }
  }

  Future<void> fetchAssessments() async {
    final response = await http.get(Uri.parse('http://localhost:3000/assessments'));
    if (response.statusCode == 200) {
      setState(() {
        assessments = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load assessments');
    }
  }

  void _downloadPdf() {
    // Implement PDF download functionality
  }

  void _downloadExcel() {
    // Implement Excel download functionality
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verify Grade Entries'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField(
              value: selectedClassSection,
              decoration: InputDecoration(labelText: 'Select Class & Section'),
              items: classSections.map<DropdownMenuItem<String>>((section) {
                return DropdownMenuItem<String>(
                  value: section['class_section'],
                  child: Text(section['class_section']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedClassSection = value as String?;
                });
              },
            ),
            SizedBox(height: 20),
            DropdownButtonFormField(
              value: selectedAssessment,
              decoration: InputDecoration(labelText: 'Select Assessment'),
              items: assessments.map<DropdownMenuItem<String>>((assessment) {
                return DropdownMenuItem<String>(
                  value: assessment['id'].toString(),
                  child: Text(assessment['name']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedAssessment = value as String?;
                });
              },
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _downloadPdf,
                  child: Text('DOWNLOAD PDF'),
                ),
                ElevatedButton(
                  onPressed: _downloadExcel,
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

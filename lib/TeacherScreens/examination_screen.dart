import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ExaminationScreen extends StatefulWidget {
  @override
  _ExaminationScreenState createState() => _ExaminationScreenState();
}

class _ExaminationScreenState extends State<ExaminationScreen> {
  List<dynamic> examinations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchExaminations();
  }

  Future<void> _fetchExaminations() async {
    final url = Uri.parse('http://localhost:3000/examinations');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          examinations = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load examinations');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog('Failed to fetch examinations. Please try again.');
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
          )
        ],
      ),
    );
  }

  void _showCreateExaminationDialog() {
    final _classIdController = TextEditingController();
    final _subjectIdController = TextEditingController();
    final _examDateController = TextEditingController();
    final _durationController = TextEditingController();
    final _totalMarksController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Create Examination'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _classIdController,
              decoration: InputDecoration(labelText: 'Class ID'),
            ),
            TextField(
              controller: _subjectIdController,
              decoration: InputDecoration(labelText: 'Subject ID'),
            ),
            TextField(
              controller: _examDateController,
              decoration: InputDecoration(labelText: 'Exam Date'),
              keyboardType: TextInputType.datetime,
            ),
            TextField(
              controller: _durationController,
              decoration: InputDecoration(labelText: 'Duration (minutes)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _totalMarksController,
              decoration: InputDecoration(labelText: 'Total Marks'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
          ElevatedButton(
            child: Text('Create'),
            onPressed: () {
              final classId = _classIdController.text;
              final subjectId = _subjectIdController.text;
              final examDate = _examDateController.text;
              final duration = _durationController.text;
              final totalMarks = _totalMarksController.text;

              if (classId.isNotEmpty && subjectId.isNotEmpty && examDate.isNotEmpty && duration.isNotEmpty && totalMarks.isNotEmpty) {
                _createExamination(int.parse(classId), int.parse(subjectId), examDate, int.parse(duration), int.parse(totalMarks));
                Navigator.of(ctx).pop();
              } else {
                _showErrorDialog('Please fill all the fields.');
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _createExamination(int classId, int subjectId, String examDate, int duration, int totalMarks) async {
    final url = Uri.parse('http://localhost:3000/examinations');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'class_id': classId,
          'subject_id': subjectId,
          'exam_date': examDate,
          'duration': duration,
          'total_marks': totalMarks,
        }),
      );
      if (response.statusCode == 201) {
        _fetchExaminations();
      } else {
        throw Exception('Failed to create examination');
      }
    } catch (error) {
      _showErrorDialog('Failed to create examination. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Examinations'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showCreateExaminationDialog,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: examinations.length,
        itemBuilder: (ctx, index) {
          final examination = examinations[index];
          return Card(
            margin: EdgeInsets.all(10),
            child: ListTile(
              title: Text('Class ID: ${examination['class_id']}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Subject ID: ${examination['subject_id']}'),
                  Text('Exam Date: ${examination['exam_date']}'),
                  Text('Duration: ${examination['duration']} minutes'),
                  Text('Total Marks: ${examination['total_marks']}'),
                ],
              ),
              trailing: IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  // Implement the edit functionality here
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

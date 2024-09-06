import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AssignSubjectScreen extends StatefulWidget {
  @override
  _AssignSubjectScreenState createState() => _AssignSubjectScreenState();
}

class _AssignSubjectScreenState extends State<AssignSubjectScreen> {
  List<dynamic> assignedSubjects = [];
  List<dynamic> students = [];
  List<dynamic> subjects = [];
  bool isLoading = true;
  bool isDropdownLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAssignedSubjects();
    _fetchDropdownData();
  }

  Future<void> _fetchAssignedSubjects() async {
    final url = Uri.parse('http://localhost:3000/assigned-subjects');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          assignedSubjects = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load assigned subjects');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog('Failed to fetch assigned subjects. Please try again.');
    }
  }

  Future<void> _fetchDropdownData() async {
    try {
      final studentsResponse = await http.get(Uri.parse('http://localhost:3000/student-directory'));
      final subjectsResponse = await http.get(Uri.parse('http://localhost:3000/subjects'));

      if (studentsResponse.statusCode == 200 && subjectsResponse.statusCode == 200) {
        setState(() {
          students = json.decode(studentsResponse.body);
          subjects = json.decode(subjectsResponse.body);
          isDropdownLoading = false;
        });
      } else {
        throw Exception('Failed to load dropdown data');
      }
    } catch (error) {
      setState(() {
        isDropdownLoading = false;
      });
      _showErrorDialog('Failed to fetch dropdown data. Please try again.');
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

  void _showCreateEditDialog({Map<String, dynamic>? assignment}) {
    final _studentController = TextEditingController(text: assignment?['student_id']?.toString() ?? '');
    final _subjectController = TextEditingController(text: assignment?['subject_id']?.toString() ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(assignment == null ? 'Assign Subject' : 'Edit Assignment'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _studentController.text.isEmpty ? null : _studentController.text,
                items: students.map<DropdownMenuItem<String>>((student) {
                  return DropdownMenuItem<String>(
                    value: student['serial_no'].toString(),
                    child: Text(student['student_name'] ?? ''),
                  );
                }).toList(),
                onChanged: (value) {
                  _studentController.text = value ?? '';
                },
                decoration: InputDecoration(labelText: 'Select Student'),
              ),
              DropdownButtonFormField<String>(
                value: _subjectController.text.isEmpty ? null : _subjectController.text,
                items: subjects.map<DropdownMenuItem<String>>((subject) {
                  return DropdownMenuItem<String>(
                    value: subject['id'].toString(),
                    child: Text(subject['subject_name']),
                  );
                }).toList(),
                onChanged: (value) {
                  _subjectController.text = value ?? '';
                },
                decoration: InputDecoration(labelText: 'Select Subject'),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
          ElevatedButton(
            child: Text(assignment == null ? 'Assign' : 'Save'),
            onPressed: () {
              final studentId = int.parse(_studentController.text);
              final subjectId = int.parse(_subjectController.text);

              if (assignment == null) {
                _assignSubject(studentId, subjectId);
              } else {
                _editAssignment(assignment['id'], studentId, subjectId);
              }
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  void _assignSubject(int studentId, int subjectId) async {
    final url = Uri.parse('http://localhost:3000/assigned-subjects');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'student_id': studentId,
          'subject_id': subjectId,
        }),
      );
      if (response.statusCode == 201) {
        _fetchAssignedSubjects();
      } else {
        throw Exception('Failed to assign subject');
      }
    } catch (error) {
      _showErrorDialog('Failed to assign subject. Please try again.');
    }
  }

  void _editAssignment(int id, int studentId, int subjectId) async {
    final url = Uri.parse('http://localhost:3000/assigned-subjects/$id');
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'student_id': studentId,
          'subject_id': subjectId,
        }),
      );
      if (response.statusCode == 200) {
        _fetchAssignedSubjects();
      } else {
        throw Exception('Failed to edit assignment');
      }
    } catch (error) {
      _showErrorDialog('Failed to edit assignment. Please try again.');
    }
  }

  void _deleteAssignment(int id) async {
    final url = Uri.parse('http://localhost:3000/assigned-subjects/$id');
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        _fetchAssignedSubjects();
      } else {
        throw Exception('Failed to delete assignment');
      }
    } catch (error) {
      _showErrorDialog('Failed to delete assignment. Please try again.');
    }
  }

  Widget _buildAssignmentTable() {
    return DataTable(
      columns: [
        DataColumn(label: Text('S.No.')),
        DataColumn(label: Text('Class & Section')),
        DataColumn(label: Text('Enrollment No.')),
        DataColumn(label: Text('Student')),
        DataColumn(label: Text('Subject')),
        DataColumn(label: Text('Actions')),
      ],
      rows: assignedSubjects
          .asMap()
          .map((index, assignment) {
        // Find the matching student from the students list
        var student = students.firstWhere(
                (s) => s['serial_no'].toString() == assignment['student_id'].toString(),
            orElse: () => null
        );

        return MapEntry(
            index,
            DataRow(cells: [
              DataCell(Text((index + 1).toString())),
              DataCell(Text(student != null ? student['class_section'] : 'N/A')),
              DataCell(Text(student != null ? student['serial_no'].toString() : 'N/A')),
              DataCell(Text(student != null ? student['student_name'] : 'N/A')),
              DataCell(Text(subjects.firstWhere(
                      (s) => s['id'].toString() == assignment['subject_id'].toString(),
                  orElse: () => {'subject_name': 'N/A'}
              )['subject_name'])),
              DataCell(Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      _showCreateEditDialog(assignment: assignment);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      _deleteAssignment(assignment['id']);
                    },
                  ),
                ],
              )),
            ])
        );
      })
          .values
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assign Subject to Student'),
        actions: [
          IconButton(
            icon: Icon(FontAwesomeIcons.plus),
            onPressed: () {
              _showCreateEditDialog();
            },
          ),
        ],
      ),
      body: isLoading || isDropdownLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: _buildAssignmentTable(),
        ),
      ),
    );
  }
}

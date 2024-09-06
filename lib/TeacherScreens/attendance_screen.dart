import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AttendanceScreen extends StatefulWidget {
  @override
  _AttendanceScreenState createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  List<dynamic> students = [];
  Map<int, bool> attendanceStatus = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final studentsUrl = Uri.parse('http://localhost:3000/students');
    final attendanceUrl = Uri.parse('http://localhost:3000/attendance/1'); // Assuming class_id is 1
    try {
      final studentsResponse = await http.get(studentsUrl);
      final attendanceResponse = await http.get(attendanceUrl);

      if (studentsResponse.statusCode == 200 && attendanceResponse.statusCode == 200) {
        List<dynamic> attendanceData = json.decode(attendanceResponse.body);
        setState(() {
          students = json.decode(studentsResponse.body);
          attendanceStatus = {
            for (var att in attendanceData) att['student_id']: att['status'] == true
          };
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog('Failed to fetch data. Please try again.');
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

  void _markAttendance(int studentId, bool isPresent) async {
    final url = Uri.parse('http://localhost:3000/attendance');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'student_id': studentId,
          'date': DateTime.now().toIso8601String().split('T').first,
          'status': isPresent
        }),
      );
      if (response.statusCode == 201) {
        setState(() {
          attendanceStatus[studentId] = isPresent;
        });
      } else {
        throw Exception('Failed to mark attendance');
      }
    } catch (error) {
      _showErrorDialog('Failed to mark attendance. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: students.length,
        itemBuilder: (ctx, index) {
          final student = students[index];
          final isPresent = attendanceStatus[student['student_id']] ?? false;

          return Card(
            margin: EdgeInsets.all(10),
            child: ListTile(
              title: Text('${student['first_name']} ${student['last_name']}'),
              subtitle: Text('Class: ${student['class']}, Section: ${student['section']}'),
              trailing: Switch(
                value: isPresent,
                onChanged: (value) {
                  _markAttendance(student['student_id'], value);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

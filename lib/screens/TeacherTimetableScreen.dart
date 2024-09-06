import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TeacherTimetableScreen extends StatefulWidget {
  @override
  _TeacherTimetableScreenState createState() => _TeacherTimetableScreenState();
}

class _TeacherTimetableScreenState extends State<TeacherTimetableScreen> {
  List<dynamic> timetable = [];
  bool isLoading = true;
  String? username;

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username');
    });
    if (username != null) {
      _fetchTimetable();
    }
  }

  Future<void> _fetchTimetable() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');  // Assuming email is stored in SharedPreferences
    if (email != null) {
      try {
        final response = await http.get(Uri.parse('http://localhost:3000/teacherTimetable/$email'));
        if (response.statusCode == 200) {
          setState(() {
            timetable = json.decode(response.body);
            isLoading = false;
          });
        } else {
          throw Exception('Failed to load timetable');
        }
      } catch (e) {
        print('Error fetching timetable: $e');
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Widget buildTimetableCell(String text, {Color color = Colors.white}) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: Colors.grey),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Timetable'),
        backgroundColor: Colors.teal,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: DataTable(
                columns: [
                  DataColumn(label: Text('Day')),
                  ...List.generate(13, (index) => DataColumn(label: Text('${6 + index}:00'))),
                ],
                rows: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday']
                    .map((day) => DataRow(cells: [
                  DataCell(Text(day)),
                  ...List.generate(13, (index) {
                    final cellEntries = timetable.where((entry) =>
                    entry['day'] == day &&
                        int.parse(entry['start_time'].split(':')[0]) <= (6 + index) &&
                        int.parse(entry['end_time'].split(':')[0]) > (6 + index)).toList();
                    return DataCell(
                      cellEntries.isNotEmpty
                          ? buildTimetableCell(
                        '${cellEntries.first['subject']}\n${cellEntries.first['class_section']}',
                        color: Colors.teal.withOpacity(0.3),
                      )
                          : buildTimetableCell(''),
                    );
                  }),
                ]))
                    .toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class TimetableScreen extends StatefulWidget {
  @override
  _TimetableScreenState createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  Map<String, List<dynamic>> timetableByDay = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTimetable();
  }

  Future<void> _fetchTimetable() async {
    final url = Uri.parse('http://localhost:3000/timetable');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> timetable = json.decode(response.body);
        final Map<String, List<dynamic>> groupedByDay = {};
        for (var entry in timetable) {
          final day = entry['day_of_week'];
          if (groupedByDay[day] == null) {
            groupedByDay[day] = [];
          }
          groupedByDay[day]!.add(entry);
        }
        setState(() {
          timetableByDay = groupedByDay;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load timetable');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog('Failed to fetch timetable. Please try again.');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Timetable'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: timetableByDay.keys.map((day) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  day,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Table(
                  border: TableBorder.all(),
                  children: [
                    TableRow(
                      decoration: BoxDecoration(color: Colors.blue),
                      children: [
                        TableCell(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Class',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Subject',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Start Time',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'End Time',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                    ...timetableByDay[day]!.map((item) {
                      return TableRow(
                        children: [
                          TableCell(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(item['class_name']),
                            ),
                          ),
                          TableCell(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(item['subject_name']),
                            ),
                          ),
                          TableCell(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(item['start_time']),
                            ),
                          ),
                          TableCell(
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(item['end_time']),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                ),
                SizedBox(height: 20),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

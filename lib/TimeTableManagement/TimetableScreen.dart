import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TimetableScreen extends StatefulWidget {
  @override
  _TimetableScreenState createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  List<dynamic> teachers = [];
  List<dynamic> timetable = [];
  List<dynamic> classSections = [];
  List<dynamic> subjects = [];
  int? selectedTeacherId;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchTeachers();
    fetchClassSections();
    fetchSubjects();
  }

  Future<void> fetchTeachers() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/staffList'));
      if (response.statusCode == 200) {
        setState(() {
          teachers = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load teachers');
      }
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchClassSections() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/classSections'));
      if (response.statusCode == 200) {
        setState(() {
          classSections = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to load class sections');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> fetchSubjects() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/subjects'));
      if (response.statusCode == 200) {
        setState(() {
          subjects = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to load subjects');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> fetchTimetable(int teacherId) async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(Uri.parse('http://localhost:3000/timetable/$teacherId'));
      if (response.statusCode == 200) {
        setState(() {
          timetable = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load timetable');
      }
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> addTimetable(Map<String, dynamic> timetableEntry) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/timetable'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(timetableEntry),
      );
      if (response.statusCode == 201) {
        if (selectedTeacherId != null) {
          fetchTimetable(selectedTeacherId!);
        }
      } else {
        throw Exception('Failed to add timetable');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> updateTimetable(int id, Map<String, dynamic> timetableEntry) async {
    try {
      final response = await http.put(
        Uri.parse('http://localhost:3000/timetable/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(timetableEntry),
      );
      if (response.statusCode == 200) {
        if (selectedTeacherId != null) {
          fetchTimetable(selectedTeacherId!);
        }
      } else {
        throw Exception('Failed to update timetable');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> deleteTimetable(int id) async {
    try {
      final response = await http.delete(Uri.parse('http://localhost:3000/timetable/$id'));
      if (response.statusCode == 204) {
        if (selectedTeacherId != null) {
          fetchTimetable(selectedTeacherId!);
        }
      } else {
        throw Exception('Failed to delete timetable');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> pickTime(
      BuildContext context, TimeOfDay initialTime, ValueChanged<TimeOfDay> onTimePicked) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null && picked != initialTime) {
      onTimePicked(picked);
    }
  }

  void showAddEditDialog({Map<String, dynamic>? entry}) {
    final isEditing = entry != null;
    final formKey = GlobalKey<FormState>();
    String day = isEditing ? entry!['day'] : 'Monday';
    TimeOfDay startTime = isEditing
        ? TimeOfDay(hour: int.parse(entry!['start_time'].split(":")[0]), minute: int.parse(entry['start_time'].split(":")[1]))
        : TimeOfDay(hour: 8, minute: 0);
    TimeOfDay endTime = isEditing
        ? TimeOfDay(hour: int.parse(entry!['end_time'].split(":")[0]), minute: int.parse(entry['end_time'].split(":")[1]))
        : TimeOfDay(hour: 9, minute: 0);
    String subject = isEditing ? entry['subject'] : subjects.first['subject_name'];
    String classSection = isEditing ? entry['class_section'] : classSections.first['class_section'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Timetable' : 'Add Timetable'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: day,
                  onChanged: (value) {
                    setState(() {
                      day = value!;
                    });
                  },
                  items: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday']
                      .map((day) => DropdownMenuItem(value: day, child: Text(day)))
                      .toList(),
                  decoration: InputDecoration(labelText: 'Day'),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(labelText: 'Start Time'),
                        controller: TextEditingController(text: startTime.format(context)),
                        onTap: () {
                          pickTime(context, startTime, (picked) {
                            setState(() {
                              startTime = picked;
                            });
                          });
                        },
                        readOnly: true,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(labelText: 'End Time'),
                        controller: TextEditingController(text: endTime.format(context)),
                        onTap: () {
                          pickTime(context, endTime, (picked) {
                            setState(() {
                              endTime = picked;
                            });
                          });
                        },
                        readOnly: true,
                      ),
                    ),
                  ],
                ),
                DropdownButtonFormField<String>(
                  value: subject,
                  onChanged: (value) {
                    setState(() {
                      subject = value!;
                    });
                  },
                  items: subjects
                      .map((subject) => DropdownMenuItem<String>(
                    value: subject['subject_name'],
                    child: Container(
                      width: 200,
                      child: Text(subject['subject_name'], overflow: TextOverflow.ellipsis),
                    ),
                  ))
                      .toList(),
                  decoration: InputDecoration(labelText: 'Subject'),
                ),
                DropdownButtonFormField<String>(
                  value: classSection,
                  onChanged: (value) {
                    setState(() {
                      classSection = value!;
                    });
                  },
                  items: classSections
                      .map((section) => DropdownMenuItem<String>(
                    value: section['class_section'],
                    child: Text(section['class_section']),
                  ))
                      .toList(),
                  decoration: InputDecoration(labelText: 'Class Section'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text(isEditing ? 'Update' : 'Add'),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  final timetableEntry = {
                    'teacherId': selectedTeacherId,
                    'day': day,
                    'startTime': '${startTime.hour}:${startTime.minute}',
                    'endTime': '${endTime.hour}:${endTime.minute}',
                    'subject': subject,
                    'classSection': classSection,
                  };
                  if (isEditing) {
                    updateTimetable(entry['id'], timetableEntry);
                  } else {
                    addTimetable(timetableEntry);
                  }
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
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
        title: Text('Timetable Management'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => showAddEditDialog(),
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButtonFormField<int>(
              value: selectedTeacherId,
              onChanged: (value) {
                setState(() {
                  selectedTeacherId = value;
                  fetchTimetable(value!);
                });
              },
              items: teachers
                  .map((teacher) => DropdownMenuItem<int>(
                value: teacher['id'],
                child: Text(teacher['name']),
              ))
                  .toList(),
              decoration: InputDecoration(
                labelText: 'Select Teacher',
                contentPadding: EdgeInsets.all(16.0),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
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
        ],
      ),
    );
  }
}

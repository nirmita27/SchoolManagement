import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DailyMarksEntryScreen extends StatefulWidget {
  @override
  _DailyMarksEntryScreenState createState() => _DailyMarksEntryScreenState();
}

class _DailyMarksEntryScreenState extends State<DailyMarksEntryScreen> {
  List dailyMarksEntries = [];
  List classSections = [];
  List subjects = [];
  int currentPage = 1;
  int itemsPerPage = 10;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchInitialData();
  }

  Future<void> fetchInitialData() async {
    await fetchDailyMarksEntries();
    await fetchClassSections();
    await fetchSubjects();
  }

  Future<void> fetchDailyMarksEntries() async {
    final response = await http.get(Uri.parse('http://localhost:3000/daily-marks-entries'));
    if (response.statusCode == 200) {
      setState(() {
        dailyMarksEntries = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load daily marks entries');
    }
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

  Future<void> fetchSubjects() async {
    final response = await http.get(Uri.parse('http://localhost:3000/subjects'));
    if (response.statusCode == 200) {
      setState(() {
        subjects = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load subjects');
    }
  }

  Future<void> addDailyMarksEntry(Map<String, dynamic> entry) async {
    final response = await http.post(
      Uri.parse('http://localhost:3000/daily-marks-entries'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(entry),
    );
    if (response.statusCode == 201) {
      fetchDailyMarksEntries();
    } else {
      throw Exception('Failed to add daily marks entry');
    }
  }

  Future<void> editDailyMarksEntry(int id, Map<String, dynamic> entry) async {
    final response = await http.put(
      Uri.parse('http://localhost:3000/daily-marks-entries/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(entry),
    );
    if (response.statusCode == 200) {
      fetchDailyMarksEntries();
    } else {
      throw Exception('Failed to edit daily marks entry');
    }
  }

  Future<void> deleteDailyMarksEntry(int id) async {
    final response = await http.delete(Uri.parse('http://localhost:3000/daily-marks-entries/$id'));
    if (response.statusCode == 200) {
      fetchDailyMarksEntries();
    } else {
      throw Exception('Failed to delete daily marks entry');
    }
  }

  Widget buildDataTable() {
    final filteredEntries = dailyMarksEntries.where((entry) {
      final date = entry['date'].toString().toLowerCase();
      return date.contains(searchQuery.toLowerCase());
    }).toList();

    final paginatedEntries = filteredEntries.skip((currentPage - 1) * itemsPerPage).take(itemsPerPage).toList();

    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: [
            DataColumn(label: Text('S.No.')),
            DataColumn(label: Text('Date')),
            DataColumn(label: Text('Class & Section')),
            DataColumn(label: Text('Subject Name')),
            DataColumn(label: Text('Maximum Mark')),
            DataColumn(label: Text('Student List')),
            DataColumn(label: Text('Actions')),
          ],
          rows: List.generate(
            paginatedEntries.length,
                (index) {
              final entry = paginatedEntries[index];
              return DataRow(
                cells: [
                  DataCell(Text('${(currentPage - 1) * itemsPerPage + index + 1}')),
                  DataCell(Text(entry['date'])),
                  DataCell(Text(entry['class_section'])),
                  DataCell(Text(entry['subject_name'])),
                  DataCell(Text(entry['max_marks'].toString())),
                  DataCell(
                    GestureDetector(
                      onTap: () {
                        // Implement student list view functionality
                      },
                      child: Text(
                        'View',
                        style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                      ),
                    ),
                  ),
                  DataCell(
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            _showAddEditDialog(entry);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            _confirmDelete(entry['id']);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _showAddEditDialog([Map<String, dynamic>? entry]) {
    showDialog(
      context: context,
      builder: (context) {
        return AddEditDailyMarksEntryDialog(
          classSections: classSections,
          subjects: subjects,
          entry: entry,
          onSave: (entry) {
            if (entry != null && entry['id'] != null) {
              editDailyMarksEntry(entry['id'], entry);
            } else {
              addDailyMarksEntry(entry);
            }
          },
        );
      },
    );
  }

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this daily marks entry?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                deleteDailyMarksEntry(id);
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daily Marks Entry List'),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search Entry',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
          buildDataTable(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: currentPage > 1
                    ? () {
                  setState(() {
                    currentPage--;
                  });
                }
                    : null,
              ),
              Text('$currentPage / ${(dailyMarksEntries.length / itemsPerPage).ceil()}'),
              IconButton(
                icon: Icon(Icons.arrow_forward),
                onPressed: currentPage < (dailyMarksEntries.length / itemsPerPage).ceil()
                    ? () {
                  setState(() {
                    currentPage++;
                  });
                }
                    : null,
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddEditDialog();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.teal,
      ),
    );
  }
}

class AddEditDailyMarksEntryDialog extends StatefulWidget {
  final List classSections;
  final List subjects;
  final Map<String, dynamic>? entry;
  final void Function(Map<String, dynamic>) onSave;

  AddEditDailyMarksEntryDialog({
    required this.classSections,
    required this.subjects,
    this.entry,
    required this.onSave,
  });

  @override
  _AddEditDailyMarksEntryDialogState createState() => _AddEditDailyMarksEntryDialogState();
}

class _AddEditDailyMarksEntryDialogState extends State<AddEditDailyMarksEntryDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _classSection;
  String? _subjectId;
  String? _date;
  String? _maxMarks;

  @override
  void initState() {
    super.initState();
    if (widget.entry != null) {
      _classSection = widget.entry!['class_section'];
      _subjectId = widget.entry!['subject_id'].toString();
      _date = widget.entry!['date'];
      _maxMarks = widget.entry!['max_marks'].toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.entry == null ? 'Add Daily Marks Entry' : 'Edit Daily Marks Entry'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              DropdownButtonFormField(
                value: _classSection,
                decoration: InputDecoration(labelText: 'Select Class & Section'),
                items: widget.classSections.map<DropdownMenuItem<String>>((section) {
                  return DropdownMenuItem<String>(
                    value: section['class_section'],
                    child: Text(section['class_section']),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a class & section';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _classSection = value as String?;
                  });
                },
              ),
              DropdownButtonFormField(
                value: _subjectId,
                decoration: InputDecoration(labelText: 'Select Subject'),
                items: widget.subjects.map<DropdownMenuItem<String>>((subject) {
                  return DropdownMenuItem<String>(
                    value: subject['id'].toString(),
                    child: Text(subject['subject_name']),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a subject';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _subjectId = value as String?;
                  });
                },
              ),
              TextFormField(
                initialValue: _date,
                decoration: InputDecoration(labelText: 'Date'),
                keyboardType: TextInputType.datetime,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a date';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _date = value;
                  });
                },
              ),
              TextFormField(
                initialValue: _maxMarks,
                decoration: InputDecoration(labelText: 'Max Marks'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter maximum marks';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _maxMarks = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final entry = {
                'class_section': _classSection,
                'subject_id': int.tryParse(_subjectId!),
                'date': _date,
                'max_marks': int.tryParse(_maxMarks!),
              };
              if (widget.entry != null) {
                entry['id'] = widget.entry!['id'];
              }
              widget.onSave(entry);
              Navigator.of(context).pop();
            }
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}

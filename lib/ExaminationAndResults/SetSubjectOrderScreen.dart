import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SetSubjectOrderScreen extends StatefulWidget {
  @override
  _SetSubjectOrderScreenState createState() => _SetSubjectOrderScreenState();
}

class _SetSubjectOrderScreenState extends State<SetSubjectOrderScreen> {
  List classSubjects = [];
  List classes = [];
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
    await fetchClassSubjects();
    await fetchClasses();
    await fetchSubjects();
  }

  Future<void> fetchClassSubjects() async {
    final response = await http.get(Uri.parse('http://localhost:3000/class-subjects'));
    if (response.statusCode == 200) {
      setState(() {
        classSubjects = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load class subjects');
    }
  }

  Future<void> fetchClasses() async {
    final response = await http.get(Uri.parse('http://localhost:3000/classes'));
    if (response.statusCode == 200) {
      setState(() {
        classes = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load classes');
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

  Future<void> addClassSubject(Map<String, dynamic> classSubject) async {
    final response = await http.post(
      Uri.parse('http://localhost:3000/class-subjects'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(classSubject),
    );
    if (response.statusCode == 201) {
      fetchClassSubjects();
    } else {
      throw Exception('Failed to add class subject');
    }
  }

  Future<void> editClassSubject(int id, Map<String, dynamic> classSubject) async {
    final response = await http.put(
      Uri.parse('http://localhost:3000/class-subjects/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(classSubject),
    );
    if (response.statusCode == 200) {
      fetchClassSubjects();
    } else {
      throw Exception('Failed to edit class subject');
    }
  }

  Future<void> deleteClassSubject(int id) async {
    final response = await http.delete(Uri.parse('http://localhost:3000/class-subjects/$id'));
    if (response.statusCode == 200) {
      fetchClassSubjects();
    } else {
      throw Exception('Failed to delete class subject');
    }
  }

  Widget buildDataTable() {
    final filteredClassSubjects = classSubjects.where((classSubject) {
      final className = classSubject['class_name'].toString().toLowerCase();
      return className.contains(searchQuery.toLowerCase());
    }).toList();

    final paginatedClassSubjects = filteredClassSubjects.skip((currentPage - 1) * itemsPerPage).take(itemsPerPage).toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          DataColumn(label: Text('S.No.')),
          DataColumn(label: Text('Class')),
          DataColumn(label: Text('Subjects')),
          DataColumn(label: Text('Actions')),
        ],
        rows: List.generate(
          paginatedClassSubjects.length,
              (index) {
            final classSubject = paginatedClassSubjects[index];
            return DataRow(
              cells: [
                DataCell(Text('${(currentPage - 1) * itemsPerPage + index + 1}')),
                DataCell(Text(classSubject['class_name'])),
                DataCell(
                  GestureDetector(
                    onTap: () {
                      _showSubjectListDialog(classSubject['class_name']);
                    },
                    child: Text(
                      '${classSubject['subject_count']} subjects',
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
                          _showAddEditDialog(classSubject);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _confirmDelete(classSubject['id']);
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
    );
  }

  void _showAddEditDialog([Map<String, dynamic>? classSubject]) {
    showDialog(
      context: context,
      builder: (context) {
        return AddEditClassSubjectDialog(
          classes: classes,
          subjects: subjects,
          classSubject: classSubject,
          onSave: (classSubject) {
            if (classSubject != null && classSubject['id'] != null) {
              editClassSubject(classSubject['id'], classSubject);
            } else {
              addClassSubject(classSubject);
            }
          },
        );
      },
    );
  }

  void _showSubjectListDialog(String className) {
    showDialog(
      context: context,
      builder: (context) {
        final subjectsForClass = classSubjects.where((cs) => cs['class_name'] == className).toList();
        return AlertDialog(
          title: Text('Subjects for $className'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: subjectsForClass.map((subject) => Text(subject['subject_name'])).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
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
          content: Text('Are you sure you want to delete this class subject?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                deleteClassSubject(id);
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
        title: Text('Set Subject Order'),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search',
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
              Text('$currentPage / ${(classSubjects.length / itemsPerPage).ceil()}'),
              IconButton(
                icon: Icon(Icons.arrow_forward),
                onPressed: currentPage < (classSubjects.length / itemsPerPage).ceil()
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

class AddEditClassSubjectDialog extends StatefulWidget {
  final List classes;
  final List subjects;
  final Map<String, dynamic>? classSubject;
  final void Function(Map<String, dynamic>) onSave;

  AddEditClassSubjectDialog({
    required this.classes,
    required this.subjects,
    this.classSubject,
    required this.onSave,
  });

  @override
  _AddEditClassSubjectDialogState createState() => _AddEditClassSubjectDialogState();
}

class _AddEditClassSubjectDialogState extends State<AddEditClassSubjectDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _classId;
  List<Map<String, dynamic>> _subjects = [];

  @override
  void initState() {
    super.initState();
    if (widget.classSubject != null) {
      _classId = widget.classSubject!['class_id'].toString();
      _subjects = List<Map<String, dynamic>>.from(widget.classSubject!['subjects']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.classSubject == null ? 'Add Class Subject' : 'Edit Class Subject'),
      content: Form(
        key: _formKey,
        child: Container(
          width: 300,
          child: SingleChildScrollView(
            child: Column(
              children: [
                DropdownButtonFormField(
                  value: _classId,
                  items: widget.classes.map<DropdownMenuItem<String>>((classData) {
                    return DropdownMenuItem<String>(
                      value: classData['id'].toString(),
                      child: Text(classData['class_name']),
                    );
                  }).toList(),
                  decoration: InputDecoration(labelText: 'Class'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a class';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      _classId = value as String?;
                    });
                  },
                ),
                Text('Subjects'),
                Container(
                  height: 300,
                  child: ListView.builder(
                    itemCount: widget.subjects.length,
                    itemBuilder: (context, index) {
                      final subjectData = widget.subjects[index];
                      final subjectName = subjectData['subject_name'];
                      final existingSubject = _subjects.firstWhere(
                            (subject) => subject['subject_id'] == subjectData['id'],
                        orElse: () => {'order_no': null},
                      );
                      return Row(
                        children: [
                          Expanded(
                            child: CheckboxListTile(
                              title: Text(subjectName),
                              value: existingSubject['order_no'] != null,
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value == true) {
                                    _subjects.add({'subject_id': subjectData['id'], 'order_no': 0});
                                  } else {
                                    _subjects.removeWhere((subject) => subject['subject_id'] == subjectData['id']);
                                  }
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: existingSubject['order_no'] != null
                                ? TextFormField(
                              initialValue: existingSubject['order_no']?.toString() ?? '0',
                              decoration: InputDecoration(labelText: 'Order No'),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                setState(() {
                                  existingSubject['order_no'] = int.tryParse(value);
                                });
                              },
                            )
                                : Container(),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
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
              final classSubject = {
                'class_id': int.tryParse(_classId!),
                'subjects': _subjects,
              };
              if (widget.classSubject != null) {
                classSubject['id'] = widget.classSubject!['id'];
              }
              widget.onSave(classSubject);
              Navigator.of(context).pop();
            }
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}

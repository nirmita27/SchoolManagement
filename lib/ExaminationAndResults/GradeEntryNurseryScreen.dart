import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class GradeEntryScreen extends StatefulWidget {
  @override
  _GradeEntryScreenState createState() => _GradeEntryScreenState();
}

class _GradeEntryScreenState extends State<GradeEntryScreen> {
  List grades = [];
  List assessments = [];
  List students = [];
  int currentPage = 1;
  int itemsPerPage = 10;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchInitialData();
  }

  Future<void> fetchInitialData() async {
    await fetchGrades();
    await fetchAssessments();
    await fetchStudents();
  }

  Future<void> fetchGrades() async {
    final response = await http.get(Uri.parse('http://localhost:3000/nurseryGrades'));
    if (response.statusCode == 200) {
      setState(() {
        grades = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load grades');
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

  Future<void> fetchStudents() async {
    final response = await http.get(Uri.parse('http://localhost:3000/students_all'));
    if (response.statusCode == 200) {
      setState(() {
        students = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load students');
    }
  }

  Future<void> addGrade(Map<String, dynamic> grade) async {
    final response = await http.post(
      Uri.parse('http://localhost:3000/nurseryGrades'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(grade),
    );
    if (response.statusCode == 201) {
      fetchGrades();
    } else {
      throw Exception('Failed to add grade');
    }
  }

  Future<void> editGrade(int id, Map<String, dynamic> grade) async {
    final response = await http.put(
      Uri.parse('http://localhost:3000/nurseryGrades/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(grade),
    );
    if (response.statusCode == 200) {
      fetchGrades();
    } else {
      throw Exception('Failed to edit grade');
    }
  }

  Future<void> deleteGrade(int id) async {
    final response = await http.delete(Uri.parse('http://localhost:3000/nurseryGrades/$id'));
    if (response.statusCode == 200) {
      fetchGrades();
    } else {
      throw Exception('Failed to delete grade');
    }
  }

  Widget buildDataTable() {
    final filteredGrades = grades.where((grade) {
      final studentName = grade['student']?.toString().toLowerCase() ?? '';
      return studentName.contains(searchQuery.toLowerCase());
    }).toList();

    final paginatedGrades = filteredGrades.skip((currentPage - 1) * itemsPerPage).take(itemsPerPage).toList();

    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: [
            DataColumn(label: Text('S.No.')),
            DataColumn(label: Text('Class')),
            DataColumn(label: Text('Student')),
            DataColumn(label: Text('Assessment')),
            DataColumn(label: Text('Actions')),
          ],
          rows: List.generate(
            paginatedGrades.length,
                (index) {
              final grade = paginatedGrades[index];
              return DataRow(
                cells: [
                  DataCell(Text('${(currentPage - 1) * itemsPerPage + index + 1}')),
                  DataCell(Text(grade['class'] ?? '')),
                  DataCell(Text(grade['student'] ?? '')),
                  DataCell(Text(grade['assessment_name'] ?? '')),  // Use assessment_name instead of assessment_id
                  DataCell(
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            _showAddEditDialog(grade);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            _confirmDelete(grade['id']);
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

  void _showAddEditDialog([Map<String, dynamic>? grade]) {
    showDialog(
      context: context,
      builder: (context) {
        return AddEditGradeDialog(
          assessments: assessments,
          students: students,
          grade: grade,
          onSave: (grade) {
            if (grade != null && grade['id'] != null) {
              editGrade(grade['id'], grade);
            } else {
              addGrade(grade);
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
          content: Text('Are you sure you want to delete this grade?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                deleteGrade(id);
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
        title: Text('Grade Entry (Nursery)'),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Page Items'),
              Text('$currentPage - ${itemsPerPage * currentPage} of ${grades.length}'),
            ],
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
              Text('$currentPage / ${(grades.length / itemsPerPage).ceil()}'),
              IconButton(
                icon: Icon(Icons.arrow_forward),
                onPressed: currentPage < (grades.length / itemsPerPage).ceil()
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

class AddEditGradeDialog extends StatefulWidget {
  final List assessments;
  final List students;
  final Map<String, dynamic>? grade;
  final void Function(Map<String, dynamic>) onSave;

  AddEditGradeDialog({
    required this.assessments,
    required this.students,
    this.grade,
    required this.onSave,
  });

  @override
  _AddEditGradeDialogState createState() => _AddEditGradeDialogState();
}

class _AddEditGradeDialogState extends State<AddEditGradeDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _className;
  String? _studentId;
  String? _assessmentId;

  @override
  void initState() {
    super.initState();
    if (widget.grade != null) {
      _className = widget.grade!['class']?.toString();
      _studentId = widget.grade!['student_id']?.toString();
      _assessmentId = widget.grade!['assessment_id']?.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.grade == null ? 'Add Grade' : 'Edit Grade'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                initialValue: _className,
                decoration: InputDecoration(labelText: 'Class'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a class';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _className = value;
                  });
                },
              ),
              DropdownButtonFormField(
                value: _studentId,
                items: widget.students.map<DropdownMenuItem<String>>((student) {
                  return DropdownMenuItem<String>(
                    value: student['serial_no'].toString(),
                    child: Text(student['student_name'] ?? ''),
                  );
                }).toList(),
                decoration: InputDecoration(labelText: 'Student'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a student';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _studentId = value as String?;
                  });
                },
              ),
              DropdownButtonFormField(
                value: _assessmentId,
                items: widget.assessments.map<DropdownMenuItem<String>>((assessment) {
                  return DropdownMenuItem<String>(
                    value: assessment['id'].toString(),
                    child: Text(assessment['name']),
                  );
                }).toList(),
                decoration: InputDecoration(labelText: 'Assessment'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select an assessment';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _assessmentId = value as String?;
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
              final grade = {
                'class': _className,
                'student_id': int.tryParse(_studentId!),
                'assessment_id': int.tryParse(_assessmentId!),
              };
              if (widget.grade != null) {
                grade['id'] = widget.grade!['id'];
              }
              widget.onSave(grade);
              Navigator.of(context).pop();
            }
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}

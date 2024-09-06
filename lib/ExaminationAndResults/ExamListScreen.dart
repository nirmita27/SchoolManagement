import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ExaminationListScreen extends StatefulWidget {
  @override
  _ExaminationListScreenState createState() => _ExaminationListScreenState();
}

class _ExaminationListScreenState extends State<ExaminationListScreen> {
  List assessments = [];
  List categories = [];
  List subjects = [];
  List classes = [];
  List exams = [];
  int currentPage = 1;
  int itemsPerPage = 10;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchInitialData();
  }

  Future<void> fetchInitialData() async {
    await fetchAssessments();
    await fetchCategories();
    await fetchSubjects();
    await fetchClasses();
    await fetchExams();
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

  Future<void> fetchCategories() async {
    final response = await http.get(Uri.parse('http://localhost:3000/grade-categories'));
    if (response.statusCode == 200) {
      setState(() {
        categories = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load categories');
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

  Future<void> fetchExams() async {
    final response = await http.get(Uri.parse('http://localhost:3000/exams'));
    if (response.statusCode == 200) {
      setState(() {
        exams = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load exams');
    }
  }

  Future<void> addExam(Map<String, dynamic> exam) async {
    final response = await http.post(
      Uri.parse('http://localhost:3000/exams'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(exam),
    );
    if (response.statusCode == 201) {
      fetchExams();
    } else {
      throw Exception('Failed to add exam');
    }
  }

  Future<void> editExam(int id, Map<String, dynamic> exam) async {
    final response = await http.put(
      Uri.parse('http://localhost:3000/exams/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(exam),
    );
    if (response.statusCode == 200) {
      fetchExams();
    } else {
      throw Exception('Failed to edit exam');
    }
  }

  Future<void> deleteExam(int id) async {
    final response = await http.delete(Uri.parse('http://localhost:3000/exams/$id'));
    if (response.statusCode == 200) {
      fetchExams();
    } else {
      throw Exception('Failed to delete exam');
    }
  }

  Widget buildDataTable() {
    final filteredExams = exams.where((exam) {
      final examName = exam['assessment'].toString().toLowerCase();
      return examName.contains(searchQuery.toLowerCase());
    }).toList();

    final paginatedExams = filteredExams.skip((currentPage - 1) * itemsPerPage).take(itemsPerPage).toList();

    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: [
            DataColumn(label: Text('S.No.')),
            DataColumn(label: Text('Assessment')),
            DataColumn(label: Text('Grade Category')),
            DataColumn(label: Text('Display In')),
            DataColumn(label: Text('Subject')),
            DataColumn(label: Text('Class & Section')),
            DataColumn(label: Text('Actions')),
          ],
          rows: List.generate(
            paginatedExams.length,
                (index) {
              final exam = paginatedExams[index];
              return DataRow(
                cells: [
                  DataCell(Text('${(currentPage - 1) * itemsPerPage + index + 1}')),
                  DataCell(Text(exam['assessment'])),
                  DataCell(Text(exam['grade_category'])),
                  DataCell(Text(exam['display_in'])),
                  DataCell(Text(exam['subject_name'])),
                  DataCell(
                    GestureDetector(
                      onTap: () {
                        _showClassSectionDialog(exam['class_section']);
                      },
                      child: Text(
                        exam['class_section'],
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
                            _showEditExamDialog(exam);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            deleteExam(exam['id']);
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

  void _showEditExamDialog(Map<String, dynamic> exam) {
    showDialog(
      context: context,
      builder: (context) {
        return AddEditExamDialog(
          assessments: assessments,
          categories: categories,
          subjects: subjects,
          classes: classes,
          exam: exam,
          onSave: (updatedExam) {
            editExam(exam['id'], updatedExam);
          },
        );
      },
    );
  }

  void _showClassSectionDialog(String classSection) {
    final classSections = classSection.split(' ');
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('View Class Sections'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: classSections.map((cs) => Text(cs)).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showAddExamDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AddEditExamDialog(
          assessments: assessments,
          categories: categories,
          subjects: subjects,
          classes: classes,
          onSave: (newExam) {
            addExam(newExam);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Exam List Master'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showAddExamDialog,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: 'Search Exam',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                  ),
                ),
                SizedBox(width: 16),
                Text('Page Items'),
                SizedBox(width: 8),
                DropdownButton<int>(
                  value: itemsPerPage,
                  items: [10, 20, 50, 100].map((e) => DropdownMenuItem<int>(value: e, child: Text(e.toString()))).toList(),
                  onChanged: (value) {
                    setState(() {
                      itemsPerPage = value!;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 16),
            buildDataTable(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: currentPage > 1 ? () {
                    setState(() {
                      currentPage--;
                    });
                  } : null,
                ),
                Text('$currentPage / ${(exams.length / itemsPerPage).ceil()}'),
                IconButton(
                  icon: Icon(Icons.arrow_forward),
                  onPressed: currentPage < (exams.length / itemsPerPage).ceil() ? () {
                    setState(() {
                      currentPage++;
                    });
                  } : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class AddEditExamDialog extends StatefulWidget {
  final List assessments;
  final List categories;
  final List subjects;
  final List classes;
  final Map<String, dynamic>? exam;
  final void Function(Map<String, dynamic>) onSave;

  AddEditExamDialog({
    required this.assessments,
    required this.categories,
    required this.subjects,
    required this.classes,
    this.exam,
    required this.onSave,
  });

  @override
  _AddEditExamDialogState createState() => _AddEditExamDialogState();
}

class _AddEditExamDialogState extends State<AddEditExamDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _assessmentId;
  String? _gradeCategoryId;
  String? _subjectId;
  String? _displayIn;
  String? _classSection;
  String? _activity;
  String? _subjectType;
  String? _grade;
  String? _passingMarks;
  String? _maximumMarks;
  bool _hideFromReportCard = false;
  String? _displayCharacter;

  @override
  void initState() {
    super.initState();
    if (widget.exam != null) {
      _assessmentId = widget.exam!['assessment_id'].toString();
      _gradeCategoryId = widget.exam!['grade_category_id'].toString();
      _subjectId = widget.exam!['subject_id'].toString();
      _displayIn = widget.exam!['display_in'];
      _classSection = widget.exam!['class_section'];
      _activity = widget.exam!['activity'];
      _subjectType = widget.exam!['subject_type'];
      _grade = widget.exam!['grade'];
      _passingMarks = widget.exam!['passing_marks'].toString();
      _maximumMarks = widget.exam!['maximum_marks'].toString();
      _hideFromReportCard = widget.exam!['hide_from_report_card'];
      _displayCharacter = widget.exam!['display_character'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.exam == null ? 'Add Exam' : 'Edit Exam'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
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
              DropdownButtonFormField(
                value: _gradeCategoryId,
                items: widget.categories.map<DropdownMenuItem<String>>((category) {
                  return DropdownMenuItem<String>(
                    value: category['id'].toString(),
                    child: Text(category['name']),
                  );
                }).toList(),
                decoration: InputDecoration(labelText: 'Grade Category'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a grade category';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _gradeCategoryId = value as String?;
                  });
                },
              ),
              DropdownButtonFormField(
                value: _subjectId,
                items: widget.subjects.map<DropdownMenuItem<String>>((subject) {
                  return DropdownMenuItem<String>(
                    value: subject['id'].toString(),
                    child: Text(subject['subject_name']),
                  );
                }).toList(),
                decoration: InputDecoration(labelText: 'Subject'),
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
              DropdownButtonFormField(
                value: _classSection,
                items: widget.classes.map<DropdownMenuItem<String>>((classData) {
                  return DropdownMenuItem<String>(
                    value: classData['class_name'],
                    child: Text(classData['class_name']),
                  );
                }).toList(),
                decoration: InputDecoration(labelText: 'Class & Section'),
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
              TextFormField(
                initialValue: _displayIn,
                decoration: InputDecoration(labelText: 'Display In'),
                onChanged: (value) {
                  setState(() {
                    _displayIn = value;
                  });
                },
              ),
              TextFormField(
                initialValue: _activity,
                decoration: InputDecoration(labelText: 'Activity'),
                onChanged: (value) {
                  setState(() {
                    _activity = value;
                  });
                },
              ),
              TextFormField(
                initialValue: _subjectType,
                decoration: InputDecoration(labelText: 'Subject Type'),
                onChanged: (value) {
                  setState(() {
                    _subjectType = value;
                  });
                },
              ),
              TextFormField(
                initialValue: _grade,
                decoration: InputDecoration(labelText: 'Grade'),
                onChanged: (value) {
                  setState(() {
                    _grade = value;
                  });
                },
              ),
              TextFormField(
                initialValue: _passingMarks,
                decoration: InputDecoration(labelText: 'Passing Marks'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    _passingMarks = value;
                  });
                },
              ),
              TextFormField(
                initialValue: _maximumMarks,
                decoration: InputDecoration(labelText: 'Maximum Marks'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    _maximumMarks = value;
                  });
                },
              ),
              CheckboxListTile(
                title: Text('Hide from Report Card'),
                value: _hideFromReportCard,
                onChanged: (value) {
                  setState(() {
                    _hideFromReportCard = value!;
                  });
                },
              ),
              TextFormField(
                initialValue: _displayCharacter,
                decoration: InputDecoration(labelText: 'Display Character'),
                onChanged: (value) {
                  setState(() {
                    _displayCharacter = value;
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
              final exam = {
                'assessment_id': _assessmentId,
                'grade_category_id': _gradeCategoryId,
                'display_in': _displayIn,
                'subject_id': _subjectId,
                'class_section': _classSection,
                'activity': _activity,
                'subject_type': _subjectType,
                'grade': _grade,
                'passing_marks': double.tryParse(_passingMarks!),
                'maximum_marks': double.tryParse(_maximumMarks!),
                'hide_from_report_card': _hideFromReportCard,
                'display_character': _displayCharacter,
              };
              widget.onSave(exam);
              Navigator.of(context).pop();
            }
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}

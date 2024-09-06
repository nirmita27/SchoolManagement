import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MarksEntryScreen extends StatefulWidget {
  @override
  _MarksEntryScreenState createState() => _MarksEntryScreenState();
}

class _MarksEntryScreenState extends State<MarksEntryScreen> {
  List<Map<String, dynamic>> marksEntries = [];
  List<Map<String, dynamic>> terms = [];
  List<Map<String, dynamic>> assessments = [];
  List<String> classSections = [];
  List<Map<String, dynamic>> subjects = [];
  int currentPage = 1;
  int itemsPerPage = 10;
  String searchQuery = '';
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchInitialData();
  }

  Future<void> fetchInitialData() async {
    try {
      await fetchMarksEntries();
      await fetchTerms();
      await fetchAssessments();
      await fetchClassSections();
      await fetchSubjects();
    } catch (error) {
      setState(() {
        errorMessage = error.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchMarksEntries() async {
    final response = await http.get(Uri.parse('http://localhost:3000/marks-entries'));
    if (response.statusCode == 200) {
      setState(() {
        marksEntries = List<Map<String, dynamic>>.from(json.decode(response.body));
      });
    } else {
      throw Exception('Failed to load marks entries');
    }
  }

  Future<void> fetchTerms() async {
    final response = await http.get(Uri.parse('http://localhost:3000/terms'));
    if (response.statusCode == 200) {
      setState(() {
        terms = List<Map<String, dynamic>>.from(json.decode(response.body));
      });
    } else {
      throw Exception('Failed to load terms');
    }
  }

  Future<void> fetchAssessments() async {
    final response = await http.get(Uri.parse('http://localhost:3000/assessments'));
    if (response.statusCode == 200) {
      setState(() {
        assessments = List<Map<String, dynamic>>.from(json.decode(response.body));
      });
    } else {
      throw Exception('Failed to load assessments');
    }
  }

  Future<void> fetchClassSections() async {
    final response = await http.get(Uri.parse('http://localhost:3000/class-sections'));
    if (response.statusCode == 200) {
      setState(() {
        classSections = List<String>.from(json.decode(response.body));
      });
    } else {
      throw Exception('Failed to load class sections');
    }
  }

  Future<void> fetchSubjects() async {
    final response = await http.get(Uri.parse('http://localhost:3000/subjects'));
    if (response.statusCode == 200) {
      setState(() {
        subjects = List<Map<String, dynamic>>.from(json.decode(response.body));
      });
    } else {
      throw Exception('Failed to load subjects');
    }
  }

  Future<void> addMarksEntry(Map<String, dynamic> entry) async {
    final response = await http.post(
      Uri.parse('http://localhost:3000/marks-entries'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(entry),
    );
    if (response.statusCode == 201) {
      fetchMarksEntries();
    } else {
      throw Exception('Failed to add marks entry');
    }
  }

  Future<void> editMarksEntry(int id, Map<String, dynamic> entry) async {
    final response = await http.put(
      Uri.parse('http://localhost:3000/marks-entries/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(entry),
    );
    if (response.statusCode == 200) {
      fetchMarksEntries();
    } else {
      throw Exception('Failed to edit marks entry');
    }
  }

  Future<void> deleteMarksEntry(int id) async {
    final response = await http.delete(Uri.parse('http://localhost:3000/marks-entries/$id'));
    if (response.statusCode == 200) {
      fetchMarksEntries();
    } else {
      throw Exception('Failed to delete marks entry');
    }
  }

  Widget buildDataTable() {
    final filteredEntries = marksEntries.where((entry) {
      final studentList = entry['student_list']?.toString().toLowerCase() ?? '';
      return studentList.contains(searchQuery.toLowerCase());
    }).toList();

    final paginatedEntries = filteredEntries.skip((currentPage - 1) * itemsPerPage).take(itemsPerPage).toList();

    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: [
            DataColumn(label: Text('S.No.')),
            DataColumn(label: Text('Term Name')),
            DataColumn(label: Text('Class & Section')),
            DataColumn(label: Text('Assessment')),
            DataColumn(label: Text('Subject Name')),
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
                  DataCell(Text(entry['term_name'] ?? '')),
                  DataCell(Text(entry['class_section'] ?? '')),
                  DataCell(Text(entry['assessment_name'] ?? '')),
                  DataCell(Text(entry['subject_name'] ?? '')),
                  DataCell(Text('${entry['student_list'] ?? ''} Students')),
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
        return AddEditMarksEntryDialog(
          terms: terms,
          assessments: assessments,
          classSections: classSections,
          subjects: subjects,
          entry: entry,
          onSave: (entry) {
            if (entry != null && entry['id'] != null) {
              editMarksEntry(entry['id'], entry);
            } else {
              addMarksEntry(entry);
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
          content: Text('Are you sure you want to delete this marks entry?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                deleteMarksEntry(id);
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
        title: Text('Marks Entry List'),
        backgroundColor: Colors.teal,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage))
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search Marks Entry',
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
              Text('$currentPage - ${itemsPerPage * currentPage} of ${marksEntries.length}'),
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
              Text('$currentPage / ${(marksEntries.length / itemsPerPage).ceil()}'),
              IconButton(
                icon: Icon(Icons.arrow_forward),
                onPressed: currentPage < (marksEntries.length / itemsPerPage).ceil()
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

class AddEditMarksEntryDialog extends StatefulWidget {
  final List<Map<String, dynamic>> terms;
  final List<Map<String, dynamic>> assessments;
  final List<String> classSections;
  final List<Map<String, dynamic>> subjects;
  final Map<String, dynamic>? entry;
  final void Function(Map<String, dynamic>) onSave;

  AddEditMarksEntryDialog({
    required this.terms,
    required this.assessments,
    required this.classSections,
    required this.subjects,
    this.entry,
    required this.onSave,
  });

  @override
  _AddEditMarksEntryDialogState createState() => _AddEditMarksEntryDialogState();
}

class _AddEditMarksEntryDialogState extends State<AddEditMarksEntryDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _termId;
  String? _classSection;
  String? _assessmentId;
  String? _subjectId;

  @override
  void initState() {
    super.initState();
    if (widget.entry != null) {
      _termId = widget.entry!['term_id']?.toString();
      _classSection = widget.entry!['class_section'];
      _assessmentId = widget.entry!['assessment_id']?.toString();
      _subjectId = widget.entry!['subject_id']?.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.entry == null ? 'Add Marks Entry' : 'Edit Marks Entry'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: _termId,
                items: widget.terms.map<DropdownMenuItem<String>>((term) {
                  return DropdownMenuItem<String>(
                    value: term['id'].toString(),
                    child: Text(term['term_name']),
                  );
                }).toList(),
                decoration: InputDecoration(labelText: 'Term'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a term';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _termId = value;
                  });
                },
              ),
              DropdownButtonFormField<String>(
                value: _classSection,
                items: widget.classSections.map<DropdownMenuItem<String>>((classSection) {
                  return DropdownMenuItem<String>(
                    value: classSection,
                    child: Text(classSection),
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
                    _classSection = value;
                  });
                },
              ),
              DropdownButtonFormField<String>(
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
                    _assessmentId = value;
                  });
                },
              ),
              DropdownButtonFormField<String>(
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
                    _subjectId = value;
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
                'term_id': int.tryParse(_termId!),
                'class_section': _classSection,
                'assessment_id': int.tryParse(_assessmentId!),
                'subject_id': int.tryParse(_subjectId!),
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

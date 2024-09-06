import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AssessmentListScreen extends StatefulWidget {
  @override
  _AssessmentListScreenState createState() => _AssessmentListScreenState();
}

class _AssessmentListScreenState extends State<AssessmentListScreen> {
  List assessments = [];
  List terms = [];
  String searchQuery = '';
  int currentPage = 1;
  int itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    fetchAssessments();
    fetchTerms();
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

  Future<void> fetchTerms() async {
    final response = await http.get(Uri.parse('http://localhost:3000/terms'));
    if (response.statusCode == 200) {
      setState(() {
        terms = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load terms');
    }
  }

  void _showAddAssessmentDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AddEditAssessmentDialog(
          terms: terms,
          onSave: (assessment) {
            addAssessment(assessment);
          },
        );
      },
    );
  }

  Future<void> addAssessment(Map<String, dynamic> assessment) async {
    final response = await http.post(
      Uri.parse('http://localhost:3000/assessments'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(assessment),
    );
    if (response.statusCode == 201) {
      fetchAssessments();
    } else {
      throw Exception('Failed to add assessment');
    }
  }

  Future<void> editAssessment(int id, Map<String, dynamic> assessment) async {
    final response = await http.put(
      Uri.parse('http://localhost:3000/assessments/$id'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode(assessment),
    );
    if (response.statusCode == 200) {
      fetchAssessments();
    } else {
      throw Exception('Failed to edit assessment');
    }
  }

  Future<void> deleteAssessment(int id) async {
    final response = await http.delete(
      Uri.parse('http://localhost:3000/assessments/$id'),
    );
    if (response.statusCode == 200) {
      fetchAssessments();
    } else {
      throw Exception('Failed to delete assessment');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assessment List'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSearchBar(),
            _buildPaginationControls(),
            SizedBox(height: 10),
            _buildDataTable(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddAssessmentDialog,
        child: Icon(Icons.add),
        backgroundColor: Colors.teal,
      ),
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            onChanged: (value) {
              setState(() {
                searchQuery = value;
                currentPage = 1;
              });
            },
            decoration: InputDecoration(
              labelText: 'Search Assessment',
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaginationControls() {
    final int totalItems = assessments.length;
    final int totalPages = (totalItems / itemsPerPage).ceil();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Page $currentPage of $totalPages'),
        Row(
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
            IconButton(
              icon: Icon(Icons.arrow_forward),
              onPressed: currentPage < totalPages
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
    );
  }

  Widget _buildDataTable() {
    final filteredAssessments = assessments
        .where((assessment) =>
    assessment['name']
        .toString()
        .toLowerCase()
        .contains(searchQuery.toLowerCase()) ||
        assessment['code']
            .toString()
            .toLowerCase()
            .contains(searchQuery.toLowerCase()))
        .toList();

    final int totalItems = filteredAssessments.length;
    final int startItem = (currentPage - 1) * itemsPerPage;
    final int endItem = startItem + itemsPerPage;
    final List displayedAssessments = filteredAssessments.sublist(
      startItem,
      endItem > totalItems ? totalItems : endItem,
    );

    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: [
            DataColumn(label: Text('S.No.')),
            DataColumn(label: Text('Term')),
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Code')),
            DataColumn(label: Text('Actions')),
          ],
          rows: List.generate(
            displayedAssessments.length,
                (index) {
              final assessment = displayedAssessments[index];
              return DataRow(
                cells: [
                  DataCell(Text('${startItem + index + 1}')),
                  DataCell(Text(assessment['term'])),
                  DataCell(Text(assessment['name'])),
                  DataCell(Text(assessment['code'])),
                  DataCell(
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            _showEditAssessmentDialog(assessment);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            deleteAssessment(assessment['id']);
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

  void _showEditAssessmentDialog(Map<String, dynamic> assessment) {
    showDialog(
      context: context,
      builder: (context) {
        return AddEditAssessmentDialog(
          assessment: assessment,
          terms: terms,
          onSave: (updatedAssessment) {
            editAssessment(assessment['id'], updatedAssessment);
          },
        );
      },
    );
  }
}

class AddEditAssessmentDialog extends StatefulWidget {
  final Map<String, dynamic>? assessment;
  final List terms;
  final Function(Map<String, dynamic>) onSave;

  AddEditAssessmentDialog({this.assessment, required this.terms, required this.onSave});

  @override
  _AddEditAssessmentDialogState createState() => _AddEditAssessmentDialogState();
}

class _AddEditAssessmentDialogState extends State<AddEditAssessmentDialog> {
  final _formKey = GlobalKey<FormState>();
  int? _termId;
  String? _name;
  String? _code;

  @override
  void initState() {
    super.initState();
    if (widget.assessment != null) {
      _termId = widget.assessment!['term_id'];
      _name = widget.assessment!['name'];
      _code = widget.assessment!['code'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.assessment != null ? 'Edit Assessment' : 'Add New Assessment'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<int>(
              value: _termId,
              items: widget.terms.map<DropdownMenuItem<int>>((term) {
                return DropdownMenuItem<int>(
                  value: term['id'],
                  child: Text(term['term_name']),
                );
              }).toList(),
              decoration: InputDecoration(labelText: 'Select Term'),
              validator: (value) {
                if (value == null) {
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
            TextFormField(
              initialValue: _name,
              decoration: InputDecoration(labelText: 'Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
              onSaved: (value) {
                _name = value;
              },
            ),
            TextFormField(
              initialValue: _code,
              decoration: InputDecoration(labelText: 'Code'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a code';
                }
                return null;
              },
              onSaved: (value) {
                _code = value;
              },
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              widget.onSave({
                'term_id': _termId,
                'name': _name,
                'code': _code,
              });
              Navigator.of(context).pop();
            }
          },
          child: Text(widget.assessment != null ? 'Save' : 'Add'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
      ],
    );
  }
}

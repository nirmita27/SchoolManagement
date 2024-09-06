import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ReportCardDesignScreen extends StatefulWidget {
  @override
  _ReportCardDesignScreenState createState() => _ReportCardDesignScreenState();
}

class _ReportCardDesignScreenState extends State<ReportCardDesignScreen> {
  List reportCardDesigns = [];
  List assessments = [];
  List classes = [];
  int currentPage = 1;
  int itemsPerPage = 10;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchInitialData();
  }

  Future<void> fetchInitialData() async {
    await fetchReportCardDesigns();
    await fetchAssessments();
    await fetchClasses();
  }

  Future<void> fetchReportCardDesigns() async {
    final response = await http.get(Uri.parse('http://localhost:3000/report-card-designs'));
    if (response.statusCode == 200) {
      setState(() {
        reportCardDesigns = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load report card designs');
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

  Future<void> addReportCardDesign(Map<String, dynamic> design) async {
    final response = await http.post(
      Uri.parse('http://localhost:3000/report-card-designs'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(design),
    );
    if (response.statusCode == 201) {
      fetchReportCardDesigns();
    } else {
      throw Exception('Failed to add report card design');
    }
  }

  Future<void> editReportCardDesign(int id, Map<String, dynamic> design) async {
    final response = await http.put(
      Uri.parse('http://localhost:3000/report-card-designs/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(design),
    );
    if (response.statusCode == 200) {
      fetchReportCardDesigns();
    } else {
      throw Exception('Failed to edit report card design');
    }
  }

  Future<void> deleteReportCardDesign(int id) async {
    final response = await http.delete(Uri.parse('http://localhost:3000/report-card-designs/$id'));
    if (response.statusCode == 200) {
      fetchReportCardDesigns();
    } else {
      throw Exception('Failed to delete report card design');
    }
  }

  Widget buildDataTable() {
    final filteredDesigns = reportCardDesigns.where((design) {
      final designName = design['name'].toString().toLowerCase();
      return designName.contains(searchQuery.toLowerCase());
    }).toList();

    final paginatedDesigns = filteredDesigns.skip((currentPage - 1) * itemsPerPage).take(itemsPerPage).toList();

    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: [
            DataColumn(label: Text('S.No.')),
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Design Code')),
            DataColumn(label: Text('Assessment')),
            DataColumn(label: Text('Class & Section')),
            DataColumn(label: Text('Actions')),
          ],
          rows: List.generate(
            paginatedDesigns.length,
                (index) {
              final design = paginatedDesigns[index];
              return DataRow(
                cells: [
                  DataCell(Text('${(currentPage - 1) * itemsPerPage + index + 1}')),
                  DataCell(Text(design['name'])),
                  DataCell(
                    GestureDetector(
                      onTap: () {
                        _showDesignCodeDialog(design['design_code']);
                      },
                      child: Text(
                        'View',
                        style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                      ),
                    ),
                  ),
                  DataCell(
                    GestureDetector(
                      onTap: () {
                        _showAssessmentDialog(design['assessment']);
                      },
                      child: Text(
                        'View Assessment',
                        style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                      ),
                    ),
                  ),
                  DataCell(
                    GestureDetector(
                      onTap: () {
                        _showClassSectionDialog(design['class_sections']);
                      },
                      child: Text(
                        'View Class & Section',
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
                            _showAddEditDialog(design);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            _confirmDelete(design['id']);
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

  void _showAddEditDialog([Map<String, dynamic>? design]) {
    showDialog(
      context: context,
      builder: (context) {
        return AddEditReportCardDesignDialog(
          assessments: assessments,
          classes: classes,
          design: design,
          onSave: (design) {
            if (design != null && design['id'] != null) {
              editReportCardDesign(design['id'], design);
            } else {
              addReportCardDesign(design);
            }
          },
        );
      },
    );
  }

  void _showDesignCodeDialog(String designCode) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Design Code'),
          content: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 300, maxHeight: 300),
              child: Text(designCode),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showAssessmentDialog(String assessment) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Assessment'),
          content: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 300, maxHeight: 300),
              child: Text(assessment),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showClassSectionDialog(String classSections) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Class & Section'),
          content: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 300, maxHeight: 300),
              child: Text(classSections),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
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
          content: Text('Are you sure you want to delete this report card design?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                deleteReportCardDesign(id);
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
        title: Text('Report Card Design'),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search Report Card',
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
          Expanded(child: buildDataTable()),
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
              Text('$currentPage / ${(reportCardDesigns.length / itemsPerPage).ceil()}'),
              IconButton(
                icon: Icon(Icons.arrow_forward),
                onPressed: currentPage < (reportCardDesigns.length / itemsPerPage).ceil()
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

class AddEditReportCardDesignDialog extends StatefulWidget {
  final List assessments;
  final List classes;
  final Map<String, dynamic>? design;
  final void Function(Map<String, dynamic>) onSave;

  AddEditReportCardDesignDialog({
    required this.assessments,
    required this.classes,
    this.design,
    required this.onSave,
  });

  @override
  _AddEditReportCardDesignDialogState createState() => _AddEditReportCardDesignDialogState();
}

class _AddEditReportCardDesignDialogState extends State<AddEditReportCardDesignDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _name;
  bool _allowStudentToSee = false;
  String? _pageNo;
  String? _reportsPerPage;
  String? _assessmentId;
  List<String> _classSections = [];

  @override
  void initState() {
    super.initState();
    if (widget.design != null) {
      _name = widget.design!['name'];
      _allowStudentToSee = widget.design!['allow_student_to_see'];
      _pageNo = widget.design!['page_no'].toString();
      _reportsPerPage = widget.design!['reports_per_page'].toString();
      _assessmentId = widget.design!['assessment_id'].toString();
      _classSections = List<String>.from(widget.design!['class_sections']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.design == null ? 'Add Report Card Design' : 'Edit Report Card Design'),
      content: Form(
        key: _formKey,
        child: Container(
          width: 300, // Ensure dialog has a fixed width
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  initialValue: _name,
                  decoration: InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      _name = value;
                    });
                  },
                ),
                SwitchListTile(
                  title: Text('Allow Student to See Report'),
                  value: _allowStudentToSee,
                  onChanged: (value) {
                    setState(() {
                      _allowStudentToSee = value;
                    });
                  },
                ),
                TextFormField(
                  initialValue: _pageNo,
                  decoration: InputDecoration(labelText: 'Page No.'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      _pageNo = value;
                    });
                  },
                ),
                TextFormField(
                  initialValue: _reportsPerPage,
                  decoration: InputDecoration(labelText: 'How Many Reports On Single Page'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      _reportsPerPage = value;
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
                Text('Class & Section'),
                Container(
                  height: 150,
                  child: ListView.builder(
                    itemCount: widget.classes.length,
                    itemBuilder: (context, index) {
                      final classData = widget.classes[index];
                      final className = classData['class_name'];
                      return CheckboxListTile(
                        title: Text(className),
                        value: _classSections.contains(className),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              _classSections.add(className);
                            } else {
                              _classSections.remove(className);
                            }
                          });
                        },
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
              final design = {
                'name': _name,
                'allow_student_to_see': _allowStudentToSee,
                'page_no': int.tryParse(_pageNo!),
                'reports_per_page': int.tryParse(_reportsPerPage!),
                'assessment_id': int.tryParse(_assessmentId!),
                'class_sections': _classSections,
              };
              if (widget.design != null) {
                design['id'] = widget.design!['id'];
              }
              widget.onSave(design);
              Navigator.of(context).pop();
            }
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}

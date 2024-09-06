import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ReportCardMarksListScreen extends StatefulWidget {
  @override
  _ReportCardMarksListScreenState createState() => _ReportCardMarksListScreenState();
}

class _ReportCardMarksListScreenState extends State<ReportCardMarksListScreen> {
  List reportCardMarks = [];
  List reportSections = [];
  List designs = [];
  List classSections = [];
  List examTypes = [];
  List assessments = [];
  int currentPage = 1;
  int itemsPerPage = 10;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchInitialData();
  }

  Future<void> fetchInitialData() async {
    await fetchReportCardMarks();
    await fetchReportSections();
    await fetchDesigns();
    await fetchClassSections();
    await fetchExamTypes();
    await fetchAssessments();
  }

  Future<void> fetchReportCardMarks() async {
    final response = await http.get(Uri.parse('http://localhost:3000/report-card-marks'));
    if (response.statusCode == 200) {
      setState(() {
        reportCardMarks = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load report card marks');
    }
  }

  Future<void> fetchReportSections() async {
    final response = await http.get(Uri.parse('http://localhost:3000/report-sections'));
    if (response.statusCode == 200) {
      setState(() {
        reportSections = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load report sections');
    }
  }

  Future<void> fetchDesigns() async {
    final response = await http.get(Uri.parse('http://localhost:3000/designs'));
    if (response.statusCode == 200) {
      setState(() {
        designs = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load designs');
    }
  }

  Future<void> fetchClassSections() async {
    final response = await http.get(Uri.parse('http://localhost:3000/class-sections'));
    if (response.statusCode == 200) {
      var rawData = json.decode(response.body);
      setState(() {
        classSections = rawData.map((data) {
          return {
            ...data,
            'id': int.parse(data['id']) // Convert id to int immediately
          };
        }).toList();
      });
    } else {
      throw Exception('Failed to load class sections');
    }
  }

  Future<void> fetchExamTypes() async {
    final response = await http.get(Uri.parse('http://localhost:3000/exam-types'));
    if (response.statusCode == 200) {
      setState(() {
        examTypes = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load exam types');
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

  Future<void> addReportCardMark(Map<String, dynamic> mark) async {
    final response = await http.post(
      Uri.parse('http://localhost:3000/report-card-marks'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(mark),
    );
    if (response.statusCode == 201) {
      fetchReportCardMarks();
    } else {
      throw Exception('Failed to add report card mark');
    }
  }

  Future<void> editReportCardMark(int id, Map<String, dynamic> mark) async {
    final response = await http.put(
      Uri.parse('http://localhost:3000/report-card-marks/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(mark),
    );
    if (response.statusCode == 200) {
      fetchReportCardMarks();
    } else {
      throw Exception('Failed to edit report card mark');
    }
  }

  Future<void> deleteReportCardMark(int id) async {
    final response = await http.delete(Uri.parse('http://localhost:3000/report-card-marks/$id'));
    if (response.statusCode == 200) {
      fetchReportCardMarks();
    } else {
      throw Exception('Failed to delete report card mark');
    }
  }

  Widget buildDataTable() {
    final filteredMarks = reportCardMarks.where((mark) {
      final markName = mark['display_name'].toString().toLowerCase();
      return markName.contains(searchQuery.toLowerCase());
    }).toList();

    final paginatedMarks = filteredMarks.skip((currentPage - 1) * itemsPerPage).take(itemsPerPage).toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          DataColumn(label: Text('S.No.')),
          DataColumn(label: Text('Report Section')),
          DataColumn(label: Text('Display Name')),
          DataColumn(label: Text('Design Name')),
          DataColumn(label: Text('Assessment List')),
          DataColumn(label: Text('Class & Section List')),
          DataColumn(label: Text('Exam Type List')),
          DataColumn(label: Text('Actions')),
        ],
        rows: List.generate(
          paginatedMarks.length,
              (index) {
            final mark = paginatedMarks[index];
            return DataRow(
              cells: [
                DataCell(Text('${(currentPage - 1) * itemsPerPage + index + 1}')),
                DataCell(Text(mark['report_section'])),
                DataCell(Text(mark['display_name'])),
                DataCell(Text(mark['design_name'])),
                DataCell(
                  GestureDetector(
                    onTap: () {
                      _showAssessmentListDialog(mark['id']);
                    },
                    child: Text(
                      '${mark['assessment_list']} Assessments',
                      style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                    ),
                  ),
                ),
                DataCell(
                  GestureDetector(
                    onTap: () {
                      _showClassSectionListDialog(mark['id']);
                    },
                    child: Text(
                      '${mark['class_section_list']} Classes & Sections',
                      style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                    ),
                  ),
                ),
                DataCell(
                  GestureDetector(
                    onTap: () {
                      _showExamTypeListDialog(mark['id']);
                    },
                    child: Text(
                      '${mark['exam_type_list']} Exam Types',
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
                          _showAddEditDialog(mark);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _confirmDelete(mark['id']);
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

  void _showAddEditDialog([Map<String, dynamic>? mark]) {
    showDialog(
      context: context,
      builder: (context) {
        return AddEditReportCardMarkDialog(
          reportSections: reportSections,
          designs: designs,
          classSections: classSections,
          examTypes: examTypes,
          assessments: assessments,
          mark: mark,
          onSave: (mark) {
            if (mark != null && mark['id'] != null) {
              editReportCardMark(mark['id'], mark);
            } else {
              addReportCardMark(mark);
            }
          },
        );
      },
    );
  }

  void _showAssessmentListDialog(int reportCardMarkId) {
    showDialog(
      context: context,
      builder: (context) {
        return AssessmentListDialog(reportCardMarkId: reportCardMarkId);
      },
    );
  }

  void _showClassSectionListDialog(int reportCardMarkId) {
    showDialog(
      context: context,
      builder: (context) {
        return ClassSectionListDialog(reportCardMarkId: reportCardMarkId);
      },
    );
  }

  void _showExamTypeListDialog(int reportCardMarkId) {
    showDialog(
      context: context,
      builder: (context) {
        return ExamTypeListDialog(reportCardMarkId: reportCardMarkId);
      },
    );
  }

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this report card mark?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                deleteReportCardMark(id);
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
        title: Text('Report Card Marks List'),
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
              Text('$currentPage / ${(reportCardMarks.length / itemsPerPage).ceil()}'),
              IconButton(
                icon: Icon(Icons.arrow_forward),
                onPressed: currentPage < (reportCardMarks.length / itemsPerPage).ceil()
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

class AddEditReportCardMarkDialog extends StatefulWidget {
  final List reportSections;
  final List designs;
  final List classSections;
  final List examTypes;
  final List assessments;
  final Map<String, dynamic>? mark;
  final void Function(Map<String, dynamic>) onSave;

  AddEditReportCardMarkDialog({
    required this.reportSections,
    required this.designs,
    required this.classSections,
    required this.examTypes,
    required this.assessments,
    this.mark,
    required this.onSave,
  });

  @override
  _AddEditReportCardMarkDialogState createState() => _AddEditReportCardMarkDialogState();
}

class _AddEditReportCardMarkDialogState extends State<AddEditReportCardMarkDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _reportSectionId;
  String? _designId;
  String? _displayName;
  String? _columnType;
  int? _displayPosition;
  bool _displayPercentageSeparately = false;
  bool _displayGradesSeparately = false;
  bool _displayMaxMarks = false;
  bool _generatePercentageTotalGrade = false;
  bool _generateSmallGraph = false;
  String? _smallGraphColor;
  bool _generateBigGraph = false;
  String? _bigGraphName;
  bool _displayOnGreenSheet = false;
  bool _displayOnReportCard = false;
  int? _resultSheetOrderNo;
  String? _resultSheetHeaderName;
  List<int> _classSectionIds = [];
  List<int> _examTypeIds = [];
  List<int> _assessmentIds = [];

  @override
  void initState() {
    super.initState();
    if (widget.mark != null) {
      _reportSectionId = widget.mark!['report_section_id'].toString();
      _designId = widget.mark!['design_id'].toString();
      _displayName = widget.mark!['display_name'];
      _columnType = widget.mark!['column_type'];
      _displayPosition = widget.mark!['display_position'];
      _displayPercentageSeparately = widget.mark!['display_percentage_separately'];
      _displayGradesSeparately = widget.mark!['display_grades_separately'];
      _displayMaxMarks = widget.mark!['display_max_marks'];
      _generatePercentageTotalGrade = widget.mark!['generate_percentage_total_grade'];
      _generateSmallGraph = widget.mark!['generate_small_graph'];
      _smallGraphColor = widget.mark!['small_graph_color'];
      _generateBigGraph = widget.mark!['generate_big_graph'];
      _bigGraphName = widget.mark!['big_graph_name'];
      _displayOnGreenSheet = widget.mark!['display_on_green_sheet'];
      _displayOnReportCard = widget.mark!['display_on_report_card'];
      _resultSheetOrderNo = widget.mark!['result_sheet_order_no'];
      _resultSheetHeaderName = widget.mark!['result_sheet_header_name'];
      _classSectionIds = List<int>.from(widget.mark!['class_section_ids']);
      _examTypeIds = List<int>.from(widget.mark!['exam_type_ids']);
      _assessmentIds = List<int>.from(widget.mark!['assessment_ids']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.mark == null ? 'Add Report Card Mark' : 'Edit Report Card Mark'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              DropdownButtonFormField(
                value: _reportSectionId,
                decoration: InputDecoration(labelText: 'Select Report Section'),
                items: widget.reportSections.map<DropdownMenuItem<String>>((section) {
                  return DropdownMenuItem<String>(
                    value: section['id'].toString(),
                    child: Text(section['name']),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a report section';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _reportSectionId = value as String?;
                  });
                },
              ),
              DropdownButtonFormField(
                value: _designId,
                decoration: InputDecoration(labelText: 'Select Design'),
                items: widget.designs.map<DropdownMenuItem<String>>((design) {
                  return DropdownMenuItem<String>(
                    value: design['id'].toString(),
                    child: Text(design['name']),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a design';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _designId = value as String?;
                  });
                },
              ),
              TextFormField(
                initialValue: _displayName,
                decoration: InputDecoration(labelText: 'Display Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a display name';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    _displayName = value;
                  });
                },
              ),
              Column(
                children: [
                  ListTile(
                    title: Text('Marks'),
                    leading: Radio<String>(
                      value: 'marks',
                      groupValue: _columnType ?? 'marks', // Default value to avoid null
                      onChanged: (String? value) {
                        if (value != null) {
                          setState(() {
                            _columnType = value;
                          });
                        }
                      },
                    ),
                  ),
                  ListTile(
                    title: Text('Grade'),
                    leading: Radio<String>(
                      value: 'grade',
                      groupValue: _columnType ?? 'grade',
                      onChanged: (String? value) {
                        if (value != null) {
                          setState(() {
                            _columnType = value;
                          });
                        }
                      },
                    ),
                  ),
                  ListTile(
                    title: Text('Weightage'),
                    leading: Radio<String>(
                      value: 'weightage',
                      groupValue: _columnType ?? 'weightage',
                      onChanged: (String? value) {
                        if (value != null) {
                          setState(() {
                            _columnType = value;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              DropdownButtonFormField(
                value: _columnType,
                decoration: InputDecoration(labelText: 'Select Column Type'),
                items: ['single', 'combine'].map<DropdownMenuItem<String>>((type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _columnType = value as String?;
                  });
                },
              ),
              DropdownButtonFormField(
                value: _displayPosition?.toString(),
                decoration: InputDecoration(labelText: 'Select Position'),
                items: List.generate(13, (index) {
                  return DropdownMenuItem<String>(
                    value: (index + 1).toString(),
                    child: Text((index + 1).toString()),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _displayPosition = int.tryParse(value as String);
                  });
                },
              ),
              CheckboxListTile(
                title: Text('Also Display Percentage Separately'),
                value: _displayPercentageSeparately,
                onChanged: (value) {
                  setState(() {
                    _displayPercentageSeparately = value!;
                  });
                },
              ),
              CheckboxListTile(
                title: Text('Also Display Grades Separately'),
                value: _displayGradesSeparately,
                onChanged: (value) {
                  setState(() {
                    _displayGradesSeparately = value!;
                  });
                },
              ),
              CheckboxListTile(
                title: Text('Also Display Maximum Marks'),
                value: _displayMaxMarks,
                onChanged: (value) {
                  setState(() {
                    _displayMaxMarks = value!;
                  });
                },
              ),
              CheckboxListTile(
                title: Text('Allow to Generate Percentage, Total & Overall Grade'),
                value: _generatePercentageTotalGrade,
                onChanged: (value) {
                  setState(() {
                    _generatePercentageTotalGrade = value!;
                  });
                },
              ),
              CheckboxListTile(
                title: Text('Allow to Generate Small Graph'),
                value: _generateSmallGraph,
                onChanged: (value) {
                  setState(() {
                    _generateSmallGraph = value!;
                  });
                },
              ),
              if (_generateSmallGraph)
                TextFormField(
                  initialValue: _smallGraphColor,
                  decoration: InputDecoration(labelText: 'Color for Small Graph'),
                  onChanged: (value) {
                    setState(() {
                      _smallGraphColor = value;
                    });
                  },
                ),
              CheckboxListTile(
                title: Text('Allow to Generate Big Graph'),
                value: _generateBigGraph,
                onChanged: (value) {
                  setState(() {
                    _generateBigGraph = value!;
                  });
                },
              ),
              if (_generateBigGraph)
                TextFormField(
                  initialValue: _bigGraphName,
                  decoration: InputDecoration(labelText: 'Name For Graph'),
                  onChanged: (value) {
                    setState(() {
                      _bigGraphName = value;
                    });
                  },
                ),
              CheckboxListTile(
                title: Text('Display on Green Sheet'),
                value: _displayOnGreenSheet,
                onChanged: (value) {
                  setState(() {
                    _displayOnGreenSheet = value!;
                  });
                },
              ),
              CheckboxListTile(
                title: Text('Display on Report Card'),
                value: _displayOnReportCard,
                onChanged: (value) {
                  setState(() {
                    _displayOnReportCard = value!;
                  });
                },
              ),
              TextFormField(
                initialValue: _resultSheetOrderNo?.toString(),
                decoration: InputDecoration(labelText: 'Result Sheet Order No'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    _resultSheetOrderNo = int.tryParse(value);
                  });
                },
              ),
              TextFormField(
                initialValue: _resultSheetHeaderName,
                decoration: InputDecoration(labelText: 'Result Sheet Header Name'),
                onChanged: (value) {
                  setState(() {
                    _resultSheetHeaderName = value;
                  });
                },
              ),
              MultiSelectFormField(
                autovalidate: false,
                title: 'Class & Sections',
                dataSource: widget.classSections,
                textField: 'class_section_name',
                valueField: 'id',
                okButtonLabel: 'OK',
                cancelButtonLabel: 'CANCEL',
                initialValue: _classSectionIds,
                onSaved: (value) {
                  if (value == null) return;
                  setState(() {
                    _classSectionIds = List<int>.from(value);
                  });
                },
              ),
              MultiSelectFormField(
                autovalidate: false,
                title: 'Exam Types',
                dataSource: widget.examTypes,
                textField: 'name',
                valueField: 'id',
                okButtonLabel: 'OK',
                cancelButtonLabel: 'CANCEL',
                initialValue: _examTypeIds,
                onSaved: (value) {
                  if (value == null) return;
                  setState(() {
                    _examTypeIds = List<int>.from(value);
                  });
                },
              ),
              MultiSelectFormField(
                autovalidate: false,
                title: 'Assessments',
                dataSource: widget.assessments,
                textField: 'name',
                valueField: 'id',
                okButtonLabel: 'OK',
                cancelButtonLabel: 'CANCEL',
                initialValue: _assessmentIds,
                onSaved: (value) {
                  if (value == null) return;
                  setState(() {
                    _assessmentIds = List<int>.from(value);
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
              final mark = {
                'report_section_id': int.tryParse(_reportSectionId!),
                'design_id': int.tryParse(_designId!),
                'display_name': _displayName,
                'column_type': _columnType,
                'display_position': _displayPosition,
                'display_percentage_separately': _displayPercentageSeparately,
                'display_grades_separately': _displayGradesSeparately,
                'display_max_marks': _displayMaxMarks,
                'generate_percentage_total_grade': _generatePercentageTotalGrade,
                'generate_small_graph': _generateSmallGraph,
                'small_graph_color': _smallGraphColor,
                'generate_big_graph': _generateBigGraph,
                'big_graph_name': _bigGraphName,
                'display_on_green_sheet': _displayOnGreenSheet,
                'display_on_report_card': _displayOnReportCard,
                'result_sheet_order_no': _resultSheetOrderNo,
                'result_sheet_header_name': _resultSheetHeaderName,
                'class_section_ids': _classSectionIds,
                'exam_type_ids': _examTypeIds,
                'assessment_ids': _assessmentIds,
              };
              if (widget.mark != null) {
                mark['id'] = widget.mark!['id'];
              }
              widget.onSave(mark);
              Navigator.of(context).pop();
            }
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}

class MultiSelectFormField extends FormField<List> {
  final List dataSource;
  final String textField;
  final String valueField;
  final String title;
  final String okButtonLabel;
  final String cancelButtonLabel;
  final FormFieldSetter<List>? onSaved;
  final AutovalidateMode autovalidate;

  MultiSelectFormField({
    required this.dataSource,
    required this.textField,
    required this.valueField,
    required this.title,
    this.okButtonLabel = 'OK',
    this.cancelButtonLabel = 'CANCEL',
    FormFieldSetter<List>? onSaved,
    FormFieldValidator<List>? validator,
    List? initialValue,
    bool autovalidate = false,
  })  : this.onSaved = onSaved,
        this.autovalidate = autovalidate ? AutovalidateMode.always : AutovalidateMode.disabled,
        super(
        onSaved: onSaved,
        validator: validator,
        initialValue: initialValue ?? [],
        autovalidateMode: autovalidate ? AutovalidateMode.always : AutovalidateMode.disabled,
        builder: (FormFieldState<List> state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ElevatedButton(
                child: Text(title),
                onPressed: () async {
                  final selectedValues = await showDialog<List<String>>(
                    context: state.context,
                    builder: (context) {
                      return MultiSelectDialog(
                        dataSource: dataSource.map<Map<String, dynamic>>((item) => {
                          'id': item['id'].toString(), // Convert id to string if necessary
                          'name': item['name'],
                        }).toList(),
                        textField: textField,
                        valueField: valueField,
                        title: title,
                        okButtonLabel: okButtonLabel,
                        cancelButtonLabel: cancelButtonLabel,
                        initialSelectedValues: state.value?.cast<String>() ?? [], // Cast as List<String> or provide an empty list
                      );
                    },
                  );
                  if (selectedValues != null) {
                    state.didChange(selectedValues);
                  }
                },
              ),
              state.hasError
                  ? Text(
                state.errorText!,
                style: TextStyle(color: Colors.red),
              )
                  : Container(),
            ],
          );
        },
      );
}

class MultiSelectDialog extends StatefulWidget {
  final List<Map<String, dynamic>> dataSource;
  final String textField;
  final String valueField;
  final String title;
  final String okButtonLabel;
  final String cancelButtonLabel;
  final List<String> initialSelectedValues; // Ensure IDs are treated as strings

  MultiSelectDialog({
    required this.dataSource,
    required this.textField,
    required this.valueField,
    required this.title,
    this.okButtonLabel = 'OK',
    this.cancelButtonLabel = 'CANCEL',
    required this.initialSelectedValues,
  });

  @override
  _MultiSelectDialogState createState() => _MultiSelectDialogState();
}

class _MultiSelectDialogState extends State<MultiSelectDialog> {
  late List<String> _selectedValues; // Handle IDs as strings

  @override
  void initState() {
    super.initState();
    _selectedValues = List.from(widget.initialSelectedValues);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: ListBody(
          children: widget.dataSource.map((item) {
            bool isSelected = _selectedValues.contains(item[widget.valueField].toString());
            return CheckboxListTile(
              value: isSelected,
              title: Text(item[widget.textField]),
              onChanged: (bool? checked) {
                setState(() {
                  String idAsString = item[widget.valueField].toString();
                  if (checked ?? false) {
                    if (!isSelected) _selectedValues.add(idAsString);
                  } else {
                    _selectedValues.remove(idAsString);
                  }
                });
              },
            );
          }).toList(),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(widget.cancelButtonLabel),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(_selectedValues),
          child: Text(widget.okButtonLabel),
        ),
      ],
    );
  }
}

class AssessmentListDialog extends StatelessWidget {
  final int reportCardMarkId;

  AssessmentListDialog({required this.reportCardMarkId});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Assessment List'),
      content: Text('List of assessments for report card mark ID: $reportCardMarkId'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('OK'),
        ),
      ],
    );
  }
}

class ClassSectionListDialog extends StatelessWidget {
  final int reportCardMarkId;

  ClassSectionListDialog({required this.reportCardMarkId});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Class & Section List'),
      content: Text('List of class & sections for report card mark ID: $reportCardMarkId'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('OK'),
        ),
      ],
    );
  }
}

class ExamTypeListDialog extends StatelessWidget {
  final int reportCardMarkId;

  ExamTypeListDialog({required this.reportCardMarkId});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Exam Type List'),
      content: Text('List of exam types for report card mark ID: $reportCardMarkId'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('OK'),
        ),
      ],
    );
  }
}

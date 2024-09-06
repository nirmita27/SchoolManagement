import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AssignedClassScreen extends StatefulWidget {
  @override
  _AssignedClassScreenState createState() => _AssignedClassScreenState();
}

class _AssignedClassScreenState extends State<AssignedClassScreen> {
  List<dynamic> assignedClasses = [];
  List<dynamic> classes = [];
  List<dynamic> sections = [];
  bool isLoading = true;
  bool isDropdownLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAssignedClasses();
    _fetchDropdownData();
  }

  Future<void> _fetchAssignedClasses() async {
    final url = Uri.parse('http://localhost:3000/assigned-classes');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          assignedClasses = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load assigned classes');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog('Failed to fetch assigned classes. Please try again.');
    }
  }

  Future<void> _fetchDropdownData() async {
    try {
      final classResponse = await http.get(Uri.parse('http://localhost:3000/classes'));
      final sectionResponse = await http.get(Uri.parse('http://localhost:3000/sections'));

      if (classResponse.statusCode == 200 && sectionResponse.statusCode == 200) {
        setState(() {
          classes = json.decode(classResponse.body);
          sections = json.decode(sectionResponse.body);
          isDropdownLoading = false;
        });
      } else {
        throw Exception('Failed to load dropdown data');
      }
    } catch (error) {
      setState(() {
        isDropdownLoading = false;
      });
      _showErrorDialog('Failed to fetch dropdown data. Please try again.');
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

  void _showCreateEditDialog({Map<String, dynamic>? assignedClass}) {
    final _classController = TextEditingController(text: assignedClass?['class_id']?.toString() ?? '');
    final _sectionController = TextEditingController(text: assignedClass?['section_id']?.toString() ?? '');
    final _teacherNameController = TextEditingController(text: assignedClass?['teacher_name'] ?? '');
    final _classCapacityController = TextEditingController(text: assignedClass?['class_capacity']?.toString() ?? '');
    final _reportTemplateTypeController = TextEditingController(text: assignedClass?['report_template_type']?.toString() ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(assignedClass == null ? 'Add New Assignment' : 'Edit Assignment'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField(
                items: classes.map<DropdownMenuItem<String>>((classItem) {
                  return DropdownMenuItem<String>(
                    value: classItem['id'].toString(),
                    child: Text(classItem['class_name']),
                  );
                }).toList(),
                decoration: InputDecoration(labelText: 'Select Class'),
                onChanged: (value) {
                  _classController.text = value.toString();
                },
                value: _classController.text.isEmpty ? null : _classController.text,
              ),
              DropdownButtonFormField(
                items: sections.map<DropdownMenuItem<String>>((sectionItem) {
                  return DropdownMenuItem<String>(
                    value: sectionItem['id'].toString(),
                    child: Text(sectionItem['section_name']),
                  );
                }).toList(),
                decoration: InputDecoration(labelText: 'Select Section'),
                onChanged: (value) {
                  _sectionController.text = value.toString();
                },
                value: _sectionController.text.isEmpty ? null : _sectionController.text,
              ),
              TextField(
                controller: _teacherNameController,
                decoration: InputDecoration(labelText: 'Assigned Teacher'),
              ),
              TextField(
                controller: _classCapacityController,
                decoration: InputDecoration(labelText: 'Class Capacity'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: _reportTemplateTypeController,
                decoration: InputDecoration(labelText: 'Report Template Type'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
          ElevatedButton(
            child: Text(assignedClass == null ? 'Add' : 'Save'),
            onPressed: () {
              final classId = int.parse(_classController.text);
              final sectionId = int.parse(_sectionController.text);
              final teacherName = _teacherNameController.text;
              final classCapacity = int.parse(_classCapacityController.text);
              final reportTemplateType = int.parse(_reportTemplateTypeController.text);

              if (assignedClass == null) {
                _assignClass(classId, sectionId, teacherName, classCapacity, reportTemplateType);
              } else {
                _editAssignment(assignedClass['id'], classId, sectionId, teacherName, classCapacity, reportTemplateType);
              }
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  void _assignClass(int classId, int sectionId, String teacherName, int classCapacity, int reportTemplateType) async {
    final url = Uri.parse('http://localhost:3000/assigned-classes');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'class_id': classId,
          'section_id': sectionId,
          'teacher_name': teacherName,
          'class_capacity': classCapacity,
          'report_template_type': reportTemplateType,
        }),
      );
      if (response.statusCode == 201) {
        _fetchAssignedClasses();
      } else {
        throw Exception('Failed to assign class');
      }
    } catch (error) {
      _showErrorDialog('Failed to assign class. Please try again.');
    }
  }

  void _editAssignment(int id, int classId, int sectionId, String teacherName, int classCapacity, int reportTemplateType) async {
    final url = Uri.parse('http://localhost:3000/assigned-classes/$id');
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'class_id': classId,
          'section_id': sectionId,
          'teacher_name': teacherName,
          'class_capacity': classCapacity,
          'report_template_type': reportTemplateType,
        }),
      );
      if (response.statusCode == 200) {
        _fetchAssignedClasses();
      } else {
        throw Exception('Failed to edit assignment');
      }
    } catch (error) {
      _showErrorDialog('Failed to edit assignment. Please try again.');
    }
  }

  void _deleteAssignment(int id) async {
    final url = Uri.parse('http://localhost:3000/assigned-classes/$id');
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        _fetchAssignedClasses();
      } else {
        throw Exception('Failed to delete assignment');
      }
    } catch (error) {
      _showErrorDialog('Failed to delete assignment. Please try again.');
    }
  }

  Widget _buildAssignedClassTable() {
    return DataTable(
      columns: [
        DataColumn(label: Text('S.No.')),
        DataColumn(label: Text('Class')),
        DataColumn(label: Text('Section')),
        DataColumn(label: Text('Assigned Teacher')),
        DataColumn(label: Text('Class Capacity')),
        DataColumn(label: Text('Report Template Type')),
        DataColumn(label: Text('Actions')),
      ],
      rows: assignedClasses
          .asMap()
          .map((index, assignedClass) => MapEntry(
        index,
        DataRow(cells: [
          DataCell(Text((index + 1).toString())),
          DataCell(Text(assignedClass['class_name'] ?? 'N/A')),
          DataCell(Text(assignedClass['section_name'] ?? 'N/A')),
          DataCell(Text(assignedClass['teacher_name'] ?? 'N/A')),
          DataCell(Text(assignedClass['class_capacity']?.toString() ?? 'N/A')),
          DataCell(Text(assignedClass['report_template_type']?.toString() ?? 'N/A')),
          DataCell(Row(
            children: [
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  _showCreateEditDialog(assignedClass: assignedClass);
                },
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  _deleteAssignment(assignedClass['id']);
                },
              ),
            ],
          )),
        ]),
      ))
          .values
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('List of Assigned Class & Section'),
        actions: [
          IconButton(
            icon: Icon(FontAwesomeIcons.plus),
            onPressed: () {
              _showCreateEditDialog();
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: _buildAssignedClassTable(),
        ),
      ),
    );
  }
}

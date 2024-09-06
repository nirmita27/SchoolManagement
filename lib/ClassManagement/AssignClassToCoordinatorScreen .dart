import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AssignClassToCoordinatorScreen extends StatefulWidget {
  @override
  _AssignClassToCoordinatorScreenState createState() => _AssignClassToCoordinatorScreenState();
}

class _AssignClassToCoordinatorScreenState extends State<AssignClassToCoordinatorScreen> {
  List<dynamic> assignments = [];
  List<String> classes = [
    'Cocoon BLUE', 'Cocoon Plus BLUE', 'Cocoon Plus GREEN', 'Cocoon Plus RED',
    'Cocoon (Suncity) A', 'Cocoon Plus (Suncity) A', 'Cocoon Plus (Suncity) ORANGE',
    'Nursery BLUE', 'Nursery GREEN', 'Nursery RED', 'K.G BLUE', 'K.G GREEN', 'K.G RED',
    'K.G YELLOW', 'I BLUE', 'I GREEN', 'I RED', 'I VELLOW', 'II BLUE', 'II GREEN', 'II RED',
    'II YELLOW', 'III BLUE', 'III GREEN', 'III RED', 'III YELLOW', 'IV BLUE', 'IV GREEN',
    'IV RED', 'IV YELLOW', 'V BLUE', 'V GREEN', 'V RED', 'V YELLOW', 'VIA', 'VIB', 'VIC',
    'VII A', 'VII B', 'VII C', 'VIII A', 'VIII B', 'VIII C', 'IX A', 'IX B', 'IX C', 'IX D',
    'X A', 'X B', 'X C', 'XI A', 'XI B', 'XI C', 'XI Commerce', 'XI Science', 'XII C', 'XII Commerce',
    'XII Science', 'XII outgoing'
  ];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAssignments();
  }

  Future<void> _fetchAssignments() async {
    final url = Uri.parse('http://localhost:3000/coordinator-assignments');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          assignments = json.decode(response.body);
          // Ensure the class_section is treated as List<String>
          assignments.forEach((assignment) {
            assignment['class_section'] = List<String>.from(assignment['class_section']);
          });
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load assignments');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog('Failed to fetch assignments. Please try again.');
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

  void _showCreateEditDialog({Map<String, dynamic>? assignment}) {
    final _staffController = TextEditingController(text: assignment?['staff_name'] ?? '');
    final List<String> selectedClasses = assignment?['class_section'] != null
        ? List<String>.from(assignment!['class_section'])
        : [];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) {
          return AlertDialog(
            title: Text(assignment == null ? 'Assign Class to Coordinator' : 'Edit Assignment'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _staffController,
                    decoration: InputDecoration(labelText: 'Staff Name'),
                  ),
                  SizedBox(height: 16),
                  ...classes.map((className) {
                    return CheckboxListTile(
                      title: Text(className),
                      value: selectedClasses.contains(className),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            selectedClasses.add(className);
                          } else {
                            selectedClasses.remove(className);
                          }
                        });
                      },
                    );
                  }).toList(),
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
                child: Text(assignment == null ? 'Assign' : 'Save'),
                onPressed: () {
                  final staffName = _staffController.text;

                  if (assignment == null) {
                    _assignClass(staffName, selectedClasses);
                  } else {
                    _editAssignment(assignment['id'], staffName, selectedClasses);
                  }
                  Navigator.of(ctx).pop();
                },
              ),
            ],
          );
        },
      ),
    );
  }

  void _assignClass(String staffName, List<String> selectedClasses) async {
    final url = Uri.parse('http://localhost:3000/coordinator-assignments');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'staff_name': staffName,
          'class_section': selectedClasses,
        }),
      );
      if (response.statusCode == 201) {
        _fetchAssignments();
      } else {
        throw Exception('Failed to assign class');
      }
    } catch (error) {
      _showErrorDialog('Failed to assign class. Please try again.');
    }
  }

  void _editAssignment(int id, String staffName, List<String> selectedClasses) async {
    final url = Uri.parse('http://localhost:3000/coordinator-assignments/$id');
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'staff_name': staffName,
          'class_section': selectedClasses,
        }),
      );
      if (response.statusCode == 200) {
        _fetchAssignments();
      } else {
        throw Exception('Failed to edit assignment');
      }
    } catch (error) {
      _showErrorDialog('Failed to edit assignment. Please try again.');
    }
  }

  void _deleteAssignment(int id) async {
    final url = Uri.parse('http://localhost:3000/coordinator-assignments/$id');
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        _fetchAssignments();
      } else {
        throw Exception('Failed to delete assignment');
      }
    } catch (error) {
      _showErrorDialog('Failed to delete assignment. Please try again.');
    }
  }

  Widget _buildAssignmentTable() {
    return DataTable(
      columns: [
        DataColumn(label: Text('S.No.')),
        DataColumn(label: Text('Teacher Name')),
        DataColumn(label: Text('Total')),
        DataColumn(label: Text('Actions')),
      ],
      rows: assignments
          .asMap()
          .map((index, assignment) => MapEntry(
        index,
        DataRow(cells: [
          DataCell(Text((index + 1).toString())),
          DataCell(Text(assignment['staff_name'] ?? 'N/A')),
          DataCell(
            GestureDetector(
              onTap: () {
                _showAssignedClassesDialog(assignment['class_section']);
              },
              child: Text('${assignment['class_section']?.length ?? 0} Classes', style: TextStyle(color: Colors.blue),),
            ),
          ),
          DataCell(Row(
            children: [
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  _showCreateEditDialog(assignment: assignment);
                },
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  _deleteAssignment(assignment['id']);
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

  void _showAssignedClassesDialog(List<String> assignedClasses) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Assigned Classes'),
        content: SingleChildScrollView(
          child: Column(
            children: assignedClasses.map((className) => Text(className)).toList(),
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assign Class to Coordinator'),
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
          child: _buildAssignmentTable(),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DesignationMasterScreen extends StatefulWidget {
  @override
  _DesignationMasterScreenState createState() => _DesignationMasterScreenState();
}

class _DesignationMasterScreenState extends State<DesignationMasterScreen> {
  List<dynamic> designations = [];
  List<dynamic> departments = [];
  bool isLoading = true;
  bool isDropdownLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDesignations();
    _fetchDepartments();
  }

  Future<void> _fetchDesignations() async {
    final url = Uri.parse('http://localhost:3000/designations');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          designations = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load designations');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog('Failed to fetch designations. Please try again.');
    }
  }

  Future<void> _fetchDepartments() async {
    final url = Uri.parse('http://localhost:3000/departments');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          departments = json.decode(response.body);
          isDropdownLoading = false;
        });
      } else {
        throw Exception('Failed to load departments');
      }
    } catch (error) {
      setState(() {
        isDropdownLoading = false;
      });
      _showErrorDialog('Failed to fetch departments. Please try again.');
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

  void _showCreateEditDialog({Map<String, dynamic>? designation}) {
    final _departmentController = TextEditingController();
    final _nameController = TextEditingController(text: designation?['designation_name']);
    final _orderNoController = TextEditingController(text: designation?['order_no']?.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(designation == null ? 'Add Designation' : 'Edit Designation'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField(
                items: departments.map<DropdownMenuItem<String>>((department) {
                  return DropdownMenuItem<String>(
                    value: department['id'].toString(),
                    child: Text(department['department_name']),
                  );
                }).toList(),
                decoration: InputDecoration(labelText: 'Select Department'),
                onChanged: (value) {
                  _departmentController.text = value.toString();
                },
                value: designation == null ? null : designation['department_id']?.toString(),
              ),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Designation Name'),
              ),
              TextField(
                controller: _orderNoController,
                decoration: InputDecoration(labelText: 'Order No'),
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
            child: Text(designation == null ? 'Add' : 'Save'),
            onPressed: () {
              final departmentId = int.parse(_departmentController.text);
              final name = _nameController.text;
              final orderNo = int.parse(_orderNoController.text);

              if (designation == null) {
                _createDesignation(departmentId, name, orderNo);
              } else {
                _editDesignation(designation['id'], departmentId, name, orderNo);
              }
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  void _createDesignation(int departmentId, String name, int orderNo) async {
    final url = Uri.parse('http://localhost:3000/designations');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'department_id': departmentId,
          'designation_name': name,
          'order_no': orderNo,
        }),
      );
      if (response.statusCode == 201) {
        _fetchDesignations();
      } else {
        throw Exception('Failed to create designation');
      }
    } catch (error) {
      _showErrorDialog('Failed to create designation. Please try again.');
    }
  }

  void _editDesignation(int id, int departmentId, String name, int orderNo) async {
    final url = Uri.parse('http://localhost:3000/designations/$id');
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'department_id': departmentId,
          'designation_name': name,
          'order_no': orderNo,
        }),
      );
      if (response.statusCode == 200) {
        _fetchDesignations();
      } else {
        throw Exception('Failed to edit designation');
      }
    } catch (error) {
      _showErrorDialog('Failed to edit designation. Please try again.');
    }
  }

  void _deleteDesignation(int id) async {
    final url = Uri.parse('http://localhost:3000/designations/$id');
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        _fetchDesignations();
      } else {
        throw Exception('Failed to delete designation');
      }
    } catch (error) {
      _showErrorDialog('Failed to delete designation. Please try again.');
    }
  }

  Widget _buildDesignationTable() {
    return DataTable(
      columns: [
        DataColumn(label: Text('S.No.')),
        DataColumn(label: Text('Department Name')),
        DataColumn(label: Text('Designation Name')),
        DataColumn(label: Text('Order No')),
        DataColumn(label: Text('Actions')),
      ],
      rows: designations
          .asMap()
          .map((index, designation) => MapEntry(
        index,
        DataRow(cells: [
          DataCell(Text((index + 1).toString())),
          DataCell(Text(designation['department_name'])),
          DataCell(Text(designation['designation_name'])),
          DataCell(Text(designation['order_no'].toString())),
          DataCell(Row(
            children: [
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  _showCreateEditDialog(designation: designation);
                },
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  _deleteDesignation(designation['id']);
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
        title: Text('Designation Master'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: _buildDesignationTable(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreateEditDialog();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.deepPurpleAccent,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DepartmentMasterScreen extends StatefulWidget {
  @override
  _DepartmentMasterScreenState createState() => _DepartmentMasterScreenState();
}

class _DepartmentMasterScreenState extends State<DepartmentMasterScreen> {
  List<dynamic> departments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDepartments();
  }

  Future<void> _fetchDepartments() async {
    final url = Uri.parse('http://localhost:3000/departments');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          departments = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load departments');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
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

  void _showCreateEditDialog({Map<String, dynamic>? department}) {
    final _nameController = TextEditingController(text: department?['department_name']);
    final _orderNoController = TextEditingController(text: department?['order_no']?.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(department == null ? 'Add Department' : 'Edit Department'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Department Name'),
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
            child: Text(department == null ? 'Add' : 'Save'),
            onPressed: () {
              final name = _nameController.text;
              final orderNo = int.parse(_orderNoController.text);

              if (department == null) {
                _createDepartment(name, orderNo);
              } else {
                _editDepartment(department['id'], name, orderNo);
              }
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  void _createDepartment(String name, int orderNo) async {
    final url = Uri.parse('http://localhost:3000/departments');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'department_name': name,
          'order_no': orderNo,
        }),
      );
      if (response.statusCode == 201) {
        _fetchDepartments(); // Refresh list
      } else {
        throw Exception('Failed to create department. Status code: ${response.statusCode}');
      }
    } catch (error) {
      _showErrorDialog('Failed to create department. Please try again. Error: $error');
    }
  }

  void _editDepartment(int id, String name, int orderNo) async {
    final url = Uri.parse('http://localhost:3000/departments/$id');
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'department_name': name,
          'order_no': orderNo,
        }),
      );
      if (response.statusCode == 200) {
        _fetchDepartments();
      } else {
        throw Exception('Failed to edit department');
      }
    } catch (error) {
      _showErrorDialog('Failed to edit department. Please try again.');
    }
  }

  void _deleteDepartment(int id) async {
    final url = Uri.parse('http://localhost:3000/departments/$id');
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        _fetchDepartments();
      } else {
        throw Exception('Failed to delete department');
      }
    } catch (error) {
      _showErrorDialog('Failed to delete department. Please try again.');
    }
  }

  Widget _buildDepartmentTable() {
    return DataTable(
      columns: [
        DataColumn(label: Text('S.No.')),
        DataColumn(label: Text('Department Name')),
        DataColumn(label: Text('Order No')),
        DataColumn(label: Text('Actions')),
      ],
      rows: departments
          .asMap()
          .map((index, department) => MapEntry(
        index,
        DataRow(cells: [
          DataCell(Text((index + 1).toString())),
          DataCell(Text(department['department_name'])),
          DataCell(Text(department['order_no'].toString())),
          DataCell(Row(
            children: [
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  _showCreateEditDialog(department: department);
                },
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  _deleteDepartment(department['id']);
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
        title: Text('Department Master'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: _buildDepartmentTable(),
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

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ReleasedStaffListScreen extends StatefulWidget {
  @override
  _ReleasedStaffListScreenState createState() => _ReleasedStaffListScreenState();
}

class _ReleasedStaffListScreenState extends State<ReleasedStaffListScreen> {
  List<dynamic> releasedStaffList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchReleasedStaffList();
  }

  Future<void> _fetchReleasedStaffList() async {
    final url = Uri.parse('http://localhost:3000/released-staff');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          releasedStaffList = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load released staff list');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog('Failed to fetch released staff list. Please try again.');
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

  void _showCreateEditDialog({Map<String, dynamic>? staff}) {
    final _nameController = TextEditingController(text: staff?['name']);
    final _employeeNoController = TextEditingController(text: staff?['employee_no']);
    final _mobileNoController = TextEditingController(text: staff?['mobile_no']);
    final _emailController = TextEditingController(text: staff?['email']);
    final _addressController = TextEditingController(text: staff?['address']);
    final _isTeachingController = TextEditingController(text: staff?['is_teaching'].toString());
    final _departmentController = TextEditingController(text: staff?['department']);
    final _designationController = TextEditingController(text: staff?['designation']);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(staff == null ? 'Add Released Staff' : 'Edit Released Staff'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: _employeeNoController,
                decoration: InputDecoration(labelText: 'Employee No.'),
              ),
              TextField(
                controller: _mobileNoController,
                decoration: InputDecoration(labelText: 'Mobile No.'),
                keyboardType: TextInputType.phone,
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: _addressController,
                decoration: InputDecoration(labelText: 'Address'),
              ),
              TextField(
                controller: _isTeachingController,
                decoration: InputDecoration(labelText: 'Teaching Faculty?'),
              ),
              TextField(
                controller: _departmentController,
                decoration: InputDecoration(labelText: 'Department'),
              ),
              TextField(
                controller: _designationController,
                decoration: InputDecoration(labelText: 'Designation'),
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
            child: Text(staff == null ? 'Add' : 'Save'),
            onPressed: () {
              final name = _nameController.text;
              final employeeNo = _employeeNoController.text;
              final mobileNo = _mobileNoController.text;
              final email = _emailController.text;
              final address = _addressController.text;
              final isTeaching = _isTeachingController.text.toLowerCase() == 'true';
              final department = _departmentController.text;
              final designation = _designationController.text;

              if (staff == null) {
                _createReleasedStaff(name, employeeNo, mobileNo, email, address, isTeaching, department, designation);
              } else {
                _editReleasedStaff(staff['id'], name, employeeNo, mobileNo, email, address, isTeaching, department, designation);
              }
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  void _createReleasedStaff(String name, String employeeNo, String mobileNo, String email, String address, bool isTeaching, String department, String designation) async {
    final url = Uri.parse('http://localhost:3000/released-staff');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'employee_no': employeeNo,
          'mobile_no': mobileNo,
          'email': email,
          'address': address,
          'is_teaching': isTeaching,
          'department': department,
          'designation': designation,
        }),
      );
      if (response.statusCode == 201) {
        _fetchReleasedStaffList();
      } else {
        throw Exception('Failed to create released staff');
      }
    } catch (error) {
      _showErrorDialog('Failed to create released staff. Please try again.');
    }
  }

  void _editReleasedStaff(int id, String name, String employeeNo, String mobileNo, String email, String address, bool isTeaching, String department, String designation) async {
    final url = Uri.parse('http://localhost:3000/released-staff/$id');
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'employee_no': employeeNo,
          'mobile_no': mobileNo,
          'email': email,
          'address': address,
          'is_teaching': isTeaching,
          'department': department,
          'designation': designation,
        }),
      );
      if (response.statusCode == 200) {
        _fetchReleasedStaffList();
      } else {
        throw Exception('Failed to edit released staff');
      }
    } catch (error) {
      _showErrorDialog('Failed to edit released staff. Please try again.');
    }
  }

  void _deleteReleasedStaff(int id) async {
    final url = Uri.parse('http://localhost:3000/released-staff/$id');
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        _fetchReleasedStaffList();
      } else {
        throw Exception('Failed to delete released staff');
      }
    } catch (error) {
      _showErrorDialog('Failed to delete released staff. Please try again.');
    }
  }

  Widget _buildReleasedStaffTable() {
    return DataTable(
      columns: [
        DataColumn(label: Text('S.No.')),
        DataColumn(label: Text('Name')),
        DataColumn(label: Text('Employee No./Staff No.')),
        DataColumn(label: Text('Mobile No')),
        DataColumn(label: Text('Email')),
        DataColumn(label: Text('Address')),
        DataColumn(label: Text('Teaching Faculty?')),
        DataColumn(label: Text('Department')),
        DataColumn(label: Text('Designation')),
        DataColumn(label: Text('Actions')),
      ],
      rows: releasedStaffList
          .asMap()
          .map((index, staff) => MapEntry(
        index,
        DataRow(cells: [
          DataCell(Text((index + 1).toString())),
          DataCell(Text(staff['name'] ?? '')),
          DataCell(Text(staff['employee_no'] ?? '')),
          DataCell(Text(staff['mobile_no'] ?? '')),
          DataCell(Text(staff['email'] ?? '')),
          DataCell(Text(staff['address'] ?? '')),
          DataCell(Text(staff['is_teaching'] ? 'True' : 'False')),
          DataCell(Text(staff['department'] ?? '')),
          DataCell(Text(staff['designation'] ?? '')),
          DataCell(Row(
            children: [
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  _showCreateEditDialog(staff: staff);
                },
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  _deleteReleasedStaff(staff['id']);
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
        title: Text('Released Staff List'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: _buildReleasedStaffTable(),
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

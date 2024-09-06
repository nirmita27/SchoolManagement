import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PermissionForOtherStaffScreen extends StatefulWidget {
  @override
  _PermissionForOtherStaffScreenState createState() => _PermissionForOtherStaffScreenState();
}

class _PermissionForOtherStaffScreenState extends State<PermissionForOtherStaffScreen> {
  List<dynamic> permissionList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPermissionList();
  }

  Future<void> _fetchPermissionList() async {
    final url = Uri.parse('http://localhost:3000/permission-for-other-staff');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          permissionList = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load permission list');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog('Failed to fetch permission list. Please try again.');
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

  void _showCreateEditDialog({Map<String, dynamic>? permission}) {
    final _staffController = TextEditingController(text: permission?['staff_name']);
    final _reasons = [
      'absent',
      'casual leave',
      'compensatory leave',
      'earned leave',
      'half day',
      'holiday'
    ];
    List<bool> _selectedReasons = List<bool>.filled(_reasons.length, false);
    if (permission != null) {
      final reasonIndex = _reasons.indexOf(permission['leave_reason']);
      if (reasonIndex != -1) {
        _selectedReasons[reasonIndex] = true;
      }
    }

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 16,
        child: Container(
          padding: EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  permission == null ? 'Add Permission' : 'Edit Permission',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _staffController,
                  decoration: InputDecoration(labelText: 'Staff Name'),
                ),
                SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _reasons
                      .asMap()
                      .map((index, reason) => MapEntry(
                    index,
                    CheckboxListTile(
                      title: Text(reason),
                      value: _selectedReasons[index],
                      onChanged: (bool? value) {
                        setState(() {
                          _selectedReasons[index] = value!;
                        });
                      },
                    ),
                  ))
                      .values
                      .toList(),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      child: Text('Cancel'),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                    ),
                    ElevatedButton(
                      child: Text(permission == null ? 'Add' : 'Save'),
                      onPressed: () {
                        final staffName = _staffController.text;
                        final leaveReason = _reasons[_selectedReasons.indexOf(true)];
                        if (permission == null) {
                          _createPermission(staffName, leaveReason);
                        } else {
                          _editPermission(permission['id'], staffName, leaveReason);
                        }
                        Navigator.of(ctx).pop();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _createPermission(String staffName, String leaveReason) async {
    final url = Uri.parse('http://localhost:3000/permission-for-other-staff');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'staff_name': staffName,
          'leave_reason': leaveReason,
        }),
      );
      if (response.statusCode == 201) {
        _fetchPermissionList();
      } else {
        throw Exception('Failed to create permission');
      }
    } catch (error) {
      _showErrorDialog('Failed to create permission. Please try again.');
    }
  }

  void _editPermission(int id, String staffName, String leaveReason) async {
    final url = Uri.parse('http://localhost:3000/permission-for-other-staff/$id');
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'staff_name': staffName,
          'leave_reason': leaveReason,
        }),
      );
      if (response.statusCode == 200) {
        _fetchPermissionList();
      } else {
        throw Exception('Failed to edit permission');
      }
    } catch (error) {
      _showErrorDialog('Failed to edit permission. Please try again.');
    }
  }

  void _deletePermission(int id) async {
    final url = Uri.parse('http://localhost:3000/permission-for-other-staff/$id');
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        _fetchPermissionList();
      } else {
        throw Exception('Failed to delete permission');
      }
    } catch (error) {
      _showErrorDialog('Failed to delete permission. Please try again.');
    }
  }

  Widget _buildPermissionTable() {
    return DataTable(
      columns: [
        DataColumn(label: Text('S.No.')),
        DataColumn(label: Text('Staff Name')),
        DataColumn(label: Text('Leave Reason')),
        DataColumn(label: Text('Actions')),
      ],
      rows: permissionList
          .asMap()
          .map((index, permission) => MapEntry(
        index,
        DataRow(cells: [
          DataCell(Text((index + 1).toString())),
          DataCell(Text(permission['staff_name'] ?? '')),
          DataCell(Text(permission['leave_reason'] ?? '')),
          DataCell(Row(
            children: [
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  _showCreateEditDialog(permission: permission);
                },
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  _deletePermission(permission['id']);
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
        title: Text('Permission for Other Staff (Leave)'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: _buildPermissionTable(),
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

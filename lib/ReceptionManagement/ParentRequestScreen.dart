import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ParentRequestScreen extends StatefulWidget {
  @override
  _ParentRequestScreenState createState() => _ParentRequestScreenState();
}

class _ParentRequestScreenState extends State<ParentRequestScreen> {
  List<dynamic> requests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    final url = Uri.parse('http://localhost:3000/parent-requests');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          requests = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load requests');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog('Failed to fetch requests. Please try again.');
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

  void _showCreateEditDialog({Map<String, dynamic>? request}) {
    final _studentNameController = TextEditingController(text: request?['student_name']);
    final _requestNameController = TextEditingController(text: request?['request_name']);
    final _requestDateController = TextEditingController(text: request?['request_date']);
    final _parentNameController = TextEditingController(text: request?['parent_name']);
    final _actionTakenController = TextEditingController(text: request?['action_taken']);
    final _staffRemarkController = TextEditingController(text: request?['staff_remark']);
    final _staffTransferredController = TextEditingController(text: request?['staff_transferred']);
    final _adminRemarkController = TextEditingController(text: request?['admin_remark']);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(request == null ? 'Add Parent Request' : 'Edit Parent Request'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _studentNameController,
                decoration: InputDecoration(labelText: 'Student Name'),
              ),
              TextField(
                controller: _requestNameController,
                decoration: InputDecoration(labelText: 'Name of Request'),
              ),
              TextField(
                controller: _requestDateController,
                decoration: InputDecoration(labelText: 'Request Date'),
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    _requestDateController.text = pickedDate.toString().split(' ')[0];
                  }
                },
              ),
              TextField(
                controller: _parentNameController,
                decoration: InputDecoration(labelText: 'Parent Name'),
              ),
              TextField(
                controller: _actionTakenController,
                decoration: InputDecoration(labelText: 'Action Taken On Request'),
              ),
              TextField(
                controller: _staffRemarkController,
                decoration: InputDecoration(labelText: 'Staff Remark\'s'),
              ),
              TextField(
                controller: _staffTransferredController,
                decoration: InputDecoration(labelText: 'Transferred To Staff'),
              ),
              TextField(
                controller: _adminRemarkController,
                decoration: InputDecoration(labelText: 'Admin Remark'),
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
            child: Text(request == null ? 'Add' : 'Save'),
            onPressed: () {
              final studentName = _studentNameController.text;
              final requestName = _requestNameController.text;
              final requestDate = _requestDateController.text;
              final parentName = _parentNameController.text;
              final actionTaken = _actionTakenController.text;
              final staffRemark = _staffRemarkController.text;
              final staffTransferred = _staffTransferredController.text;
              final adminRemark = _adminRemarkController.text;

              if (request == null) {
                _createRequest(studentName, requestName, requestDate, parentName, actionTaken, staffRemark, staffTransferred, adminRemark);
              } else {
                _editRequest(request['id'], studentName, requestName, requestDate, parentName, actionTaken, staffRemark, staffTransferred, adminRemark);
              }
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  void _createRequest(String studentName, String requestName, String requestDate, String parentName, String actionTaken, String staffRemark, String staffTransferred, String adminRemark) async {
    final url = Uri.parse('http://localhost:3000/parent-requests');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'student_name': studentName,
          'request_name': requestName,
          'request_date': requestDate,
          'parent_name': parentName,
          'action_taken': actionTaken,
          'staff_remark': staffRemark,
          'staff_transferred': staffTransferred,
          'admin_remark': adminRemark,
        }),
      );
      if (response.statusCode == 201) {
        _fetchRequests();
      } else {
        throw Exception('Failed to create request');
      }
    } catch (error) {
      _showErrorDialog('Failed to create request. Please try again.');
    }
  }

  void _editRequest(int id, String studentName, String requestName, String requestDate, String parentName, String actionTaken, String staffRemark, String staffTransferred, String adminRemark) async {
    final url = Uri.parse('http://localhost:3000/parent-requests/$id');
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'student_name': studentName,
          'request_name': requestName,
          'request_date': requestDate,
          'parent_name': parentName,
          'action_taken': actionTaken,
          'staff_remark': staffRemark,
          'staff_transferred': staffTransferred,
          'admin_remark': adminRemark,
        }),
      );
      if (response.statusCode == 200) {
        _fetchRequests();
      } else {
        throw Exception('Failed to edit request');
      }
    } catch (error) {
      _showErrorDialog('Failed to edit request. Please try again.');
    }
  }

  void _deleteRequest(int id) async {
    final url = Uri.parse('http://localhost:3000/parent-requests/$id');
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        _fetchRequests();
      } else {
        throw Exception('Failed to delete request');
      }
    } catch (error) {
      _showErrorDialog('Failed to delete request. Please try again.');
    }
  }

  Widget _buildRequestTable() {
    return DataTable(
      columns: [
        DataColumn(label: Text('S.No.')),
        DataColumn(label: Text('Request Date')),
        DataColumn(label: Text('Student Name')),
        DataColumn(label: Text('Parent Name')),
        DataColumn(label: Text('Request Type')),
        DataColumn(label: Text('Action Taken')),
        DataColumn(label: Text('Staff Remark')),
        DataColumn(label: Text('Admin Remark')),
        DataColumn(label: Text('Change Status')),
        DataColumn(label: Text('Actions')),
      ],
      rows: requests
          .asMap()
          .map((index, request) => MapEntry(
        index,
        DataRow(cells: [
          DataCell(Text((index + 1).toString())),
          DataCell(Text(request['request_date'] ?? '')),
          DataCell(Text(request['student_name'] ?? '')),
          DataCell(Text(request['parent_name'] ?? '')),
          DataCell(Text(request['request_name'] ?? '')),
          DataCell(Text(request['action_taken'] ?? '')),
          DataCell(Text(request['staff_remark'] ?? '')),
          DataCell(Text(request['admin_remark'] ?? '')),
          DataCell(Text('')),
          DataCell(Row(
            children: [
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  _showCreateEditDialog(request: request);
                },
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  _deleteRequest(request['id']);
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
        title: Text('Parent Requests'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: _buildRequestTable(),
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

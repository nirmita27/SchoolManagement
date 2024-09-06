import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LeaveRulesMasterScreen extends StatefulWidget {
  @override
  _LeaveRulesMasterScreenState createState() => _LeaveRulesMasterScreenState();
}

class _LeaveRulesMasterScreenState extends State<LeaveRulesMasterScreen> {
  List<dynamic> leaveRulesMasterList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLeaveRulesMasterList();
  }

  Future<void> _fetchLeaveRulesMasterList() async {
    final url = Uri.parse('http://localhost:3000/leave-rules-master');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          leaveRulesMasterList = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load leave rules master list');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog('Failed to fetch leave rules master list. Please try again.');
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

  void _showCreateEditDialog({Map<String, dynamic>? leaveRulesMaster}) {
    final _leaveTypeController = TextEditingController(text: leaveRulesMaster?['leave_type']);
    final _leaveCounterController = TextEditingController(text: leaveRulesMaster?['leave_counter'].toString());
    final _marksAsController = TextEditingController(text: leaveRulesMaster?['marks_as']);
    final _marksLeaveCounterController = TextEditingController(text: leaveRulesMaster?['marks_leave_counter'].toString());
    final _executeOrderController = TextEditingController(text: leaveRulesMaster?['execute_order'].toString());

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
                  leaveRulesMaster == null ? 'Add Leave Rules' : 'Edit Leave Rules',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _leaveTypeController,
                  decoration: InputDecoration(labelText: 'Leave Type'),
                ),
                TextField(
                  controller: _leaveCounterController,
                  decoration: InputDecoration(labelText: 'Leave Counter'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _marksAsController,
                  decoration: InputDecoration(labelText: 'Marks As'),
                ),
                TextField(
                  controller: _marksLeaveCounterController,
                  decoration: InputDecoration(labelText: 'Marks Leave Counter'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _executeOrderController,
                  decoration: InputDecoration(labelText: 'Execute Order'),
                  keyboardType: TextInputType.number,
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
                      child: Text(leaveRulesMaster == null ? 'Add' : 'Save'),
                      onPressed: () {
                        final leaveType = _leaveTypeController.text;
                        final leaveCounter = int.parse(_leaveCounterController.text);
                        final marksAs = _marksAsController.text;
                        final marksLeaveCounter = int.parse(_marksLeaveCounterController.text);
                        final executeOrder = int.parse(_executeOrderController.text);

                        if (leaveRulesMaster == null) {
                          _createLeaveRulesMaster(leaveType, leaveCounter, marksAs, marksLeaveCounter, executeOrder);
                        } else {
                          _editLeaveRulesMaster(leaveRulesMaster['id'], leaveType, leaveCounter, marksAs, marksLeaveCounter, executeOrder);
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

  void _createLeaveRulesMaster(String leaveType, int leaveCounter, String marksAs, int marksLeaveCounter, int executeOrder) async {
    final url = Uri.parse('http://localhost:3000/leave-rules-master');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'leave_type': leaveType,
          'leave_counter': leaveCounter,
          'marks_as': marksAs,
          'marks_leave_counter': marksLeaveCounter,
          'execute_order': executeOrder,
        }),
      );
      if (response.statusCode == 201) {
        _fetchLeaveRulesMasterList();
      } else {
        throw Exception('Failed to create leave rules master');
      }
    } catch (error) {
      _showErrorDialog('Failed to create leave rules master. Please try again.');
    }
  }

  void _editLeaveRulesMaster(int id, String leaveType, int leaveCounter, String marksAs, int marksLeaveCounter, int executeOrder) async {
    final url = Uri.parse('http://localhost:3000/leave-rules-master/$id');
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'leave_type': leaveType,
          'leave_counter': leaveCounter,
          'marks_as': marksAs,
          'marks_leave_counter': marksLeaveCounter,
          'execute_order': executeOrder,
        }),
      );
      if (response.statusCode == 200) {
        _fetchLeaveRulesMasterList();
      } else {
        throw Exception('Failed to edit leave rules master');
      }
    } catch (error) {
      _showErrorDialog('Failed to edit leave rules master. Please try again.');
    }
  }

  void _deleteLeaveRulesMaster(int id) async {
    final url = Uri.parse('http://localhost:3000/leave-rules-master/$id');
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        _fetchLeaveRulesMasterList();
      } else {
        throw Exception('Failed to delete leave rules master');
      }
    } catch (error) {
      _showErrorDialog('Failed to delete leave rules master. Please try again.');
    }
  }

  Widget _buildLeaveRulesMasterTable() {
    return DataTable(
      columns: [
        DataColumn(label: Text('S.No.')),
        DataColumn(label: Text('Leave Type')),
        DataColumn(label: Text('Leave Counter')),
        DataColumn(label: Text('Marks As')),
        DataColumn(label: Text('Marks Leave Counter')),
        DataColumn(label: Text('Execute Order')),
        DataColumn(label: Text('Actions')),
      ],
      rows: leaveRulesMasterList
          .asMap()
          .map((index, leaveRulesMaster) => MapEntry(
        index,
        DataRow(cells: [
          DataCell(Text((index + 1).toString())),
          DataCell(Text(leaveRulesMaster['leave_type'] ?? '')),
          DataCell(Text(leaveRulesMaster['leave_counter'].toString())),
          DataCell(Text(leaveRulesMaster['marks_as'] ?? '')),
          DataCell(Text(leaveRulesMaster['marks_leave_counter'].toString())),
          DataCell(Text(leaveRulesMaster['execute_order'].toString())),
          DataCell(Row(
            children: [
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  _showCreateEditDialog(leaveRulesMaster: leaveRulesMaster);
                },
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  _deleteLeaveRulesMaster(leaveRulesMaster['id']);
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
        title: Text('Leave Rules Master List'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: _buildLeaveRulesMasterTable(),
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

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LeaveApproveMasterScreen extends StatefulWidget {
  @override
  _LeaveApproveMasterScreenState createState() => _LeaveApproveMasterScreenState();
}

class _LeaveApproveMasterScreenState extends State<LeaveApproveMasterScreen> {
  List<dynamic> leaveApproveMasterList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLeaveApproveMasterList();
  }

  Future<void> _fetchLeaveApproveMasterList() async {
    final url = Uri.parse('http://localhost:3000/leave-approve-master');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          leaveApproveMasterList = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load leave approve master list');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog('Failed to fetch leave approve master list. Please try again.');
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

  void _showCreateEditDialog({Map<String, dynamic>? leaveApproveMaster}) {
    String? _selectedLevel = leaveApproveMaster?['level'];
    String? _selectedType = leaveApproveMaster?['type'];
    final _staffController = TextEditingController(text: leaveApproveMaster?['staff']);

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
                  leaveApproveMaster == null ? 'Add Leave Approve Master' : 'Edit Leave Approve Master',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                Text('Level', style: TextStyle(fontSize: 16)),
                ListTile(
                  title: const Text('Level 1'),
                  leading: Radio<String>(
                    value: 'Level 1',
                    groupValue: _selectedLevel,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedLevel = value;
                      });
                    },
                  ),
                ),
                ListTile(
                  title: const Text('Level 2'),
                  leading: Radio<String>(
                    value: 'Level 2',
                    groupValue: _selectedLevel,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedLevel = value;
                      });
                    },
                  ),
                ),
                TextField(
                  controller: _staffController,
                  decoration: InputDecoration(labelText: 'Staff'),
                ),
                Text('Type', style: TextStyle(fontSize: 16)),
                ListTile(
                  title: const Text('Student'),
                  leading: Radio<String>(
                    value: 'Student',
                    groupValue: _selectedType,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedType = value;
                      });
                    },
                  ),
                ),
                ListTile(
                  title: const Text('Staff'),
                  leading: Radio<String>(
                    value: 'Staff',
                    groupValue: _selectedType,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedType = value;
                      });
                    },
                  ),
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
                      child: Text(leaveApproveMaster == null ? 'Add' : 'Save'),
                      onPressed: () {
                        final level = _selectedLevel;
                        final type = _selectedType;
                        final staff = _staffController.text;

                        if (leaveApproveMaster == null) {
                          _createLeaveApproveMaster(level!, type!, staff);
                        } else {
                          _editLeaveApproveMaster(leaveApproveMaster['id'], level!, type!, staff);
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

  void _createLeaveApproveMaster(String level, String type, String staff) async {
    final url = Uri.parse('http://localhost:3000/leave-approve-master');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'level': level,
          'type': type,
          'staff': staff,
        }),
      );
      if (response.statusCode == 201) {
        _fetchLeaveApproveMasterList();
      } else {
        throw Exception('Failed to create leave approve master');
      }
    } catch (error) {
      _showErrorDialog('Failed to create leave approve master. Please try again.');
    }
  }

  void _editLeaveApproveMaster(int id, String level, String type, String staff) async {
    final url = Uri.parse('http://localhost:3000/leave-approve-master/$id');
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'level': level,
          'type': type,
          'staff': staff,
        }),
      );
      if (response.statusCode == 200) {
        _fetchLeaveApproveMasterList();
      } else {
        throw Exception('Failed to edit leave approve master');
      }
    } catch (error) {
      _showErrorDialog('Failed to edit leave approve master. Please try again.');
    }
  }

  void _deleteLeaveApproveMaster(int id) async {
    final url = Uri.parse('http://localhost:3000/leave-approve-master/$id');
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        _fetchLeaveApproveMasterList();
      } else {
        throw Exception('Failed to delete leave approve master');
      }
    } catch (error) {
      _showErrorDialog('Failed to delete leave approve master. Please try again.');
    }
  }

  void _showDetailsDialog(List<dynamic> details) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 16,
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Details',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              ...details.map((detail) => Text(detail)).toList(),
              SizedBox(height: 20),
              TextButton(
                child: Text('Close'),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeaveApproveMasterTable() {
    return DataTable(
      columns: [
        DataColumn(label: Text('S.No.')),
        DataColumn(label: Text('Level')),
        DataColumn(label: Text('Type')),
        DataColumn(label: Text('Staff')),
        DataColumn(label: Text('Details')),
        DataColumn(label: Text('Actions')),
      ],
      rows: leaveApproveMasterList
          .asMap()
          .map((index, leaveApproveMaster) => MapEntry(
        index,
        DataRow(cells: [
          DataCell(Text((index + 1).toString())),
          DataCell(Text(leaveApproveMaster['level'] ?? '')),
          DataCell(Text(leaveApproveMaster['type'] ?? '')),
          DataCell(Text('${leaveApproveMaster['staff']} Staff')),
          DataCell(
            InkWell(
              child: Text('View', style: TextStyle(color: Colors.blue)),
              onTap: () => _showDetailsDialog(leaveApproveMaster['details'] ?? []),
            ),
          ),
          DataCell(Row(
            children: [
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  _showCreateEditDialog(leaveApproveMaster: leaveApproveMaster);
                },
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  _deleteLeaveApproveMaster(leaveApproveMaster['id']);
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
        title: Text('Leave Approve Master List'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: _buildLeaveApproveMasterTable(),
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

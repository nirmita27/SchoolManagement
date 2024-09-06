import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class InchargeListScreen extends StatefulWidget {
  @override
  _InchargeListScreenState createState() => _InchargeListScreenState();
}

class _InchargeListScreenState extends State<InchargeListScreen> {
  List<dynamic> inchargeList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchInchargeList();
  }

  Future<void> _fetchInchargeList() async {
    final url = Uri.parse('http://localhost:3000/incharge-list');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          inchargeList = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load incharge list');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog('Failed to fetch incharge list. Please try again.');
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

  void _showCreateEditDialog({Map<String, dynamic>? incharge}) {
    final _dateController = TextEditingController(text: incharge?['date']);
    final _teacherController = TextEditingController(text: incharge?['teacher']);
    final _studentController = TextEditingController(text: incharge?['student']);
    final _classController = TextEditingController(text: incharge?['class']);
    final _remarksController = TextEditingController(text: incharge?['remarks']);
    final _statusController = TextEditingController(text: incharge?['status'] ?? 'Pending');

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
                  incharge == null ? 'Add Incharge' : 'Edit Incharge',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _dateController,
                  decoration: InputDecoration(labelText: 'Date'),
                  readOnly: true,
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      _dateController.text = pickedDate.toString().split(' ')[0];
                    }
                  },
                ),
                TextField(
                  controller: _teacherController,
                  decoration: InputDecoration(labelText: 'Teacher'),
                ),
                TextField(
                  controller: _studentController,
                  decoration: InputDecoration(labelText: 'Student'),
                ),
                TextField(
                  controller: _classController,
                  decoration: InputDecoration(labelText: 'Class'),
                ),
                TextField(
                  controller: _remarksController,
                  decoration: InputDecoration(labelText: 'Remarks'),
                ),
                DropdownButtonFormField<String>(
                  value: _statusController.text,
                  decoration: InputDecoration(labelText: 'Status'),
                  items: ['Pending', 'Complete']
                      .map((status) => DropdownMenuItem(
                    value: status,
                    child: Text(status),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _statusController.text = value!;
                    });
                  },
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
                      child: Text(incharge == null ? 'Add' : 'Save'),
                      onPressed: () {
                        final date = _dateController.text;
                        final teacher = _teacherController.text;
                        final student = _studentController.text;
                        final className = _classController.text;
                        final remarks = _remarksController.text;
                        final status = _statusController.text;

                        if (incharge == null) {
                          _createIncharge(date, teacher, student, className, remarks, status);
                        } else {
                          _editIncharge(incharge['id'], date, teacher, student, className, remarks, status);
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

  void _createIncharge(String date, String teacher, String student, String className, String remarks, String status) async {
    final url = Uri.parse('http://localhost:3000/incharge-list');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'date': date,
          'teacher': teacher,
          'student': student,
          'class': className,
          'remarks': remarks,
          'status': status,
        }),
      );
      if (response.statusCode == 201) {
        _fetchInchargeList();
      } else {
        throw Exception('Failed to create incharge');
      }
    } catch (error) {
      _showErrorDialog('Failed to create incharge. Please try again.');
    }
  }

  void _editIncharge(int id, String date, String teacher, String student, String className, String remarks, String status) async {
    final url = Uri.parse('http://localhost:3000/incharge-list/$id');
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'date': date,
          'teacher': teacher,
          'student': student,
          'class': className,
          'remarks': remarks,
          'status': status,
        }),
      );
      if (response.statusCode == 200) {
        _fetchInchargeList();
      } else {
        throw Exception('Failed to edit incharge');
      }
    } catch (error) {
      _showErrorDialog('Failed to edit incharge. Please try again.');
    }
  }

  void _deleteIncharge(int id) async {
    final url = Uri.parse('http://localhost:3000/incharge-list/$id');
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        _fetchInchargeList();
      } else {
        throw Exception('Failed to delete incharge');
      }
    } catch (error) {
      _showErrorDialog('Failed to delete incharge. Please try again.');
    }
  }

  void _showRemarkDialog(Map<String, dynamic> incharge) {
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
                'Remark',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text(incharge['remarks'] ?? ''),
              SizedBox(height: 20),
              Text('Status: ${incharge['status'] ?? ''}'),
              Text('Posted By: ${incharge['posted_by'] ?? ''}'),
              Text('Posted On: ${incharge['date'] ?? ''}'),
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

  void _showChangeStatusDialog(Map<String, dynamic> incharge) {
    final _statusController = TextEditingController(text: incharge['status']);
    final _remarksController = TextEditingController(text: incharge['remarks']);

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
            children: [
              Text(
                'Change Status',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _statusController.text,
                decoration: InputDecoration(labelText: 'Status'),
                items: ['Pending', 'Complete']
                    .map((status) => DropdownMenuItem(
                  value: status,
                  child: Text(status),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _statusController.text = value!;
                  });
                },
              ),
              TextField(
                controller: _remarksController,
                decoration: InputDecoration(labelText: 'Remarks'),
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
                    child: Text('Save'),
                    onPressed: () {
                      _changeStatus(incharge['id'], _statusController.text, _remarksController.text);
                      Navigator.of(ctx).pop();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _changeStatus(int id, String status, String remarks) async {
    final url = Uri.parse('http://localhost:3000/incharge-list/status/$id');
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'status': status,
          'remarks': remarks,
        }),
      );
      if (response.statusCode == 200) {
        _fetchInchargeList();
      } else {
        throw Exception('Failed to change status');
      }
    } catch (error) {
      _showErrorDialog('Failed to change status. Please try again.');
    }
  }

  void _viewAttachment(String attachment) async {
    final url = 'http://localhost:3000/uploads/$attachment';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      _showErrorDialog('Could not open attachment');
    }
  }

  Widget _buildInchargeTable() {
    return DataTable(
      columns: [
        DataColumn(label: Text('S.No.')),
        DataColumn(label: Text('Teacher')),
        DataColumn(label: Text('Student')),
        DataColumn(label: Text('Class')),
        DataColumn(label: Text('Date')),
        DataColumn(label: Text('Posted By')),
        DataColumn(label: Text('Attachment')),
        DataColumn(label: Text('Remarks')),
        DataColumn(label: Text('Status')),
        DataColumn(label: Text('Actions')),
      ],
      rows: inchargeList
          .asMap()
          .map((index, incharge) => MapEntry(
        index,
        DataRow(cells: [
          DataCell(Text((index + 1).toString())),
          DataCell(Text(incharge['teacher'] ?? '')),
          DataCell(Text(incharge['student'] ?? '')),
          DataCell(Text(incharge['class'] ?? '')),
          DataCell(Text(incharge['date'] ?? '')),
          DataCell(Text(incharge['posted_by'] ?? '')),
          DataCell(InkWell(
            child: Text('View', style: TextStyle(color: Colors.blue)),
            onTap: () {
              _viewAttachment(incharge['attachment']);
            },
          )),
          DataCell(
            InkWell(
              child: Text('View', style: TextStyle(color: Colors.blue)),
              onTap: () => _showRemarkDialog(incharge),
            ),
          ),
          DataCell(
            InkWell(
              child: Text(incharge['status'] ?? '', style: TextStyle(color: Colors.blue)),
              onTap: () => _showChangeStatusDialog(incharge),
            ),
          ),
          DataCell(Row(
            children: [
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  _showCreateEditDialog(incharge: incharge);
                },
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  _deleteIncharge(incharge['id']);
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
        title: Text('Incharge List'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: _buildInchargeTable(),
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

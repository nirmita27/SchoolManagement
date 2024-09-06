import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class WalkInRecordsScreen extends StatefulWidget {
  @override
  _WalkInRecordsScreenState createState() => _WalkInRecordsScreenState();
}

class _WalkInRecordsScreenState extends State<WalkInRecordsScreen> {
  List<dynamic> records = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRecords();
  }

  Future<void> _fetchRecords() async {
    final url = Uri.parse('http://localhost:3000/walk-in-records');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          records = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load records');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog('Failed to fetch records. Please try again.');
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

  void _showCreateEditDialog({Map<String, dynamic>? record}) {
    final _dateController = TextEditingController(text: record?['date']);
    final _personNameController = TextEditingController(text: record?['person_name']);
    final _walkInTypeController = TextEditingController(text: record?['walk_in_type']);
    final _purposeController = TextEditingController(text: record?['purpose']);
    final _whomToMeetController = TextEditingController(text: record?['whom_to_meet']);
    final _mobileNoController = TextEditingController(text: record?['mobile_no']);
    final _emailController = TextEditingController(text: record?['email']);
    final _remarksController = TextEditingController(text: record?['remarks']);
    bool _scheduled = record?['scheduled'] ?? false;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(record == null ? 'Add New Record' : 'Edit Record'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                controller: _personNameController,
                decoration: InputDecoration(labelText: 'Person Name'),
              ),
              TextField(
                controller: _walkInTypeController,
                decoration: InputDecoration(labelText: 'Walk-In Type (visitor/parent)'),
              ),
              TextField(
                controller: _purposeController,
                decoration: InputDecoration(labelText: 'Purpose'),
              ),
              TextField(
                controller: _whomToMeetController,
                decoration: InputDecoration(labelText: 'Whom to Meet'),
              ),
              TextField(
                controller: _mobileNoController,
                decoration: InputDecoration(labelText: 'Mobile No'),
                keyboardType: TextInputType.phone,
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              CheckboxListTile(
                title: Text('Was it scheduled?'),
                value: _scheduled,
                onChanged: (bool? value) {
                  setState(() {
                    _scheduled = value!;
                  });
                },
              ),
              TextField(
                controller: _remarksController,
                decoration: InputDecoration(labelText: 'Remarks'),
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
            child: Text(record == null ? 'Add' : 'Save'),
            onPressed: () {
              final date = _dateController.text;
              final personName = _personNameController.text;
              final walkInType = _walkInTypeController.text;
              final purpose = _purposeController.text;
              final whomToMeet = _whomToMeetController.text;
              final mobileNo = _mobileNoController.text;
              final email = _emailController.text;
              final remarks = _remarksController.text;

              if (record == null) {
                _createRecord(date, personName, walkInType, purpose, whomToMeet, mobileNo, email, _scheduled, remarks);
              } else {
                _editRecord(record['id'], date, personName, walkInType, purpose, whomToMeet, mobileNo, email, _scheduled, remarks);
              }
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  void _createRecord(String date, String personName, String walkInType, String purpose, String whomToMeet, String mobileNo, String email, bool scheduled, String remarks) async {
    final url = Uri.parse('http://localhost:3000/walk-in-records');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'date': date,
          'person_name': personName,
          'walk_in_type': walkInType,
          'purpose': purpose,
          'whom_to_meet': whomToMeet,
          'mobile_no': mobileNo,
          'email': email,
          'scheduled': scheduled,
          'remarks': remarks,
        }),
      );
      if (response.statusCode == 201) {
        _fetchRecords();
      } else {
        throw Exception('Failed to create record');
      }
    } catch (error) {
      _showErrorDialog('Failed to create record. Please try again.');
    }
  }

  void _editRecord(int id, String date, String personName, String walkInType, String purpose, String whomToMeet, String mobileNo, String email, bool scheduled, String remarks) async {
    final url = Uri.parse('http://localhost:3000/walk-in-records/$id');
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'date': date,
          'person_name': personName,
          'walk_in_type': walkInType,
          'purpose': purpose,
          'whom_to_meet': whomToMeet,
          'mobile_no': mobileNo,
          'email': email,
          'scheduled': scheduled,
          'remarks': remarks,
        }),
      );
      if (response.statusCode == 200) {
        _fetchRecords();
      } else {
        throw Exception('Failed to edit record');
      }
    } catch (error) {
      _showErrorDialog('Failed to edit record. Please try again.');
    }
  }

  void _deleteRecord(int id) async {
    final url = Uri.parse('http://localhost:3000/walk-in-records/$id');
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        _fetchRecords();
      } else {
        throw Exception('Failed to delete record');
      }
    } catch (error) {
      _showErrorDialog('Failed to delete record. Please try again.');
    }
  }

  Widget _buildRecordTable() {
    return DataTable(
      columns: [
        DataColumn(label: Text('S.No.')),
        DataColumn(label: Text('Person Name')),
        DataColumn(label: Text('Walk-In Type')),
        DataColumn(label: Text('Whom to Meet')),
        DataColumn(label: Text('Mobile No')),
        DataColumn(label: Text('Email')),
        DataColumn(label: Text('Purpose')),
        DataColumn(label: Text('Scheduled?')),
        DataColumn(label: Text('Remarks')),
        DataColumn(label: Text('Actions')),
      ],
      rows: records
          .asMap()
          .map((index, record) => MapEntry(
        index,
        DataRow(cells: [
          DataCell(Text((index + 1).toString())),
          DataCell(Text(record['person_name'] ?? '')),
          DataCell(Text(record['walk_in_type'] ?? '')),
          DataCell(Text(record['whom_to_meet'] ?? '')),
          DataCell(Text(record['mobile_no'] ?? '')),
          DataCell(Text(record['email'] ?? '')),
          DataCell(Text(record['purpose'] ?? '')),
          DataCell(Text(record['scheduled'] ? 'Yes' : 'No')),
          DataCell(Text(record['remarks'] ?? '')),
          DataCell(Row(
            children: [
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  _showCreateEditDialog(record: record);
                },
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  _deleteRecord(record['id']);
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
        title: Text('Walk In Records'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: _buildRecordTable(),
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
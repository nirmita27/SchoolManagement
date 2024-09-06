import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class EmailRecordScreen extends StatefulWidget {
  @override
  _EmailRecordScreenState createState() => _EmailRecordScreenState();
}

class _EmailRecordScreenState extends State<EmailRecordScreen> {
  List<dynamic> emailRecords = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEmailRecords();
  }

  Future<void> _fetchEmailRecords() async {
    final url = Uri.parse('http://localhost:3000/email-records');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          emailRecords = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load email records');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog('Failed to fetch email records. Please try again.');
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

  void _showCreateEditDialog({Map<String, dynamic>? emailRecord}) {
    final _receivedFromController = TextEditingController(text: emailRecord?['received_from']);
    final _receivedDateController = TextEditingController(text: emailRecord?['received_date']);
    final _receivedTimeController = TextEditingController(text: emailRecord?['received_time']);
    final _mailForController = TextEditingController(text: emailRecord?['mail_for']);
    final _subjectController = TextEditingController(text: emailRecord?['subject']);
    final _actionTakenController = TextEditingController(text: emailRecord?['action_taken']);
    final _remarksController = TextEditingController(text: emailRecord?['remarks']);

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
                emailRecord == null ? 'Add New Email Record' : 'Edit Email Record',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _receivedFromController,
                decoration: InputDecoration(labelText: 'Received From'),
              ),
              TextField(
                controller: _receivedDateController,
                decoration: InputDecoration(labelText: 'Received Date'),
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    _receivedDateController.text = pickedDate.toString().split(' ')[0];
                  }
                },
              ),
              TextField(
                controller: _receivedTimeController,
                decoration: InputDecoration(labelText: 'Received Time'),
                readOnly: true,
                onTap: () async {
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (pickedTime != null) {
                    _receivedTimeController.text = pickedTime.format(context);
                  }
                },
              ),
              TextField(
                controller: _mailForController,
                decoration: InputDecoration(labelText: 'Mail For'),
              ),
              TextField(
                controller: _subjectController,
                decoration: InputDecoration(labelText: 'Subject'),
              ),
              TextField(
                controller: _actionTakenController,
                decoration: InputDecoration(labelText: 'Action Taken'),
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
                    child: Text(emailRecord == null ? 'Add' : 'Save'),
                    onPressed: () {
                      final receivedFrom = _receivedFromController.text;
                      final receivedDate = _receivedDateController.text;
                      final receivedTime = _receivedTimeController.text;
                      final mailFor = _mailForController.text;
                      final subject = _subjectController.text;
                      final actionTaken = _actionTakenController.text;
                      final remarks = _remarksController.text;

                      if (emailRecord == null) {
                        _createEmailRecord(receivedFrom, receivedDate, receivedTime, mailFor, subject, actionTaken, remarks);
                      } else {
                        _editEmailRecord(emailRecord['id'], receivedFrom, receivedDate, receivedTime, mailFor, subject, actionTaken, remarks);
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
    );
  }

  void _createEmailRecord(String receivedFrom, String receivedDate, String receivedTime, String mailFor, String subject, String actionTaken, String remarks) async {
    final url = Uri.parse('http://localhost:3000/email-records');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'received_from': receivedFrom,
          'received_date': receivedDate,
          'received_time': receivedTime,
          'mail_for': mailFor,
          'subject': subject,
          'action_taken': actionTaken,
          'remarks': remarks,
        }),
      );
      if (response.statusCode == 201) {
        _fetchEmailRecords();
      } else {
        throw Exception('Failed to create email record');
      }
    } catch (error) {
      _showErrorDialog('Failed to create email record. Please try again.');
    }
  }

  void _editEmailRecord(int id, String receivedFrom, String receivedDate, String receivedTime, String mailFor, String subject, String actionTaken, String remarks) async {
    final url = Uri.parse('http://localhost:3000/email-records/$id');
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'received_from': receivedFrom,
          'received_date': receivedDate,
          'received_time': receivedTime,
          'mail_for': mailFor,
          'subject': subject,
          'action_taken': actionTaken,
          'remarks': remarks,
        }),
      );
      if (response.statusCode == 200) {
        _fetchEmailRecords();
      } else {
        throw Exception('Failed to edit email record');
      }
    } catch (error) {
      _showErrorDialog('Failed to edit email record. Please try again.');
    }
  }

  void _deleteEmailRecord(int id) async {
    final url = Uri.parse('http://localhost:3000/email-records/$id');
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        _fetchEmailRecords();
      } else {
        throw Exception('Failed to delete email record');
      }
    } catch (error) {
      _showErrorDialog('Failed to delete email record. Please try again.');
    }
  }

  Widget _buildEmailTable() {
    return DataTable(
      columns: [
        DataColumn(label: Text('S.No.')),
        DataColumn(label: Text('Email Subject')),
        DataColumn(label: Text('Received From')),
        DataColumn(label: Text('Received Date')),
        DataColumn(label: Text('Received Time')),
        DataColumn(label: Text('Mail For')),
        DataColumn(label: Text('Action Taken')),
        DataColumn(label: Text('Remark')),
        DataColumn(label: Text('Actions')),
      ],
      rows: emailRecords
          .asMap()
          .map((index, email) => MapEntry(
        index,
        DataRow(cells: [
          DataCell(Text((index + 1).toString())),
          DataCell(Text(email['subject'] ?? '')),
          DataCell(Text(email['received_from'] ?? '')),
          DataCell(Text(email['received_date'] ?? '')),
          DataCell(Text(email['received_time'] ?? '')),
          DataCell(Text(email['mail_for'] ?? '')),
          DataCell(Text(email['action_taken'] ?? '')),
          DataCell(Text(email['remarks'] ?? '')),
          DataCell(Row(
            children: [
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  _showCreateEditDialog(emailRecord: email);
                },
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  _deleteEmailRecord(email['id']);
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

  void _showEmailDetails(Map<String, dynamic> email) {
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
                'Email Details',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text('Email Subject: ${email['subject'] ?? ''}'),
              Text('Received From: ${email['received_from'] ?? ''}'),
              Text('Received Date: ${email['received_date'] ?? ''}'),
              Text('Received Time: ${email['received_time'] ?? ''}'),
              Text('Mail For: ${email['mail_for'] ?? ''}'),
              Text('Action Taken: ${email['action_taken'] ?? ''}'),
              Text('Remarks: ${email['remarks'] ?? ''}'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Email Record List'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: _buildEmailTable(),
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

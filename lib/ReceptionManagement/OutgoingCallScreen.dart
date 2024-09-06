import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class OutgoingCallScreen extends StatefulWidget {
  @override
  _OutgoingCallScreenState createState() => _OutgoingCallScreenState();
}

class _OutgoingCallScreenState extends State<OutgoingCallScreen> {
  List<dynamic> callList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCallList();
  }

  Future<void> _fetchCallList() async {
    final url = Uri.parse('http://localhost:3000/outgoing-calls');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          callList = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load call list');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog('Failed to fetch call list. Please try again.');
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

  void _showCreateEditDialog({Map<String, dynamic>? call}) {
    final _callMadeByController = TextEditingController(text: call?['call_made_by']);
    final _callDateController = TextEditingController(text: call?['call_date']);
    final _callTimeController = TextEditingController(text: call?['call_time']);
    final _callMadeToController = TextEditingController(text: call?['call_made_to']);
    final _purposeOfCallController = TextEditingController(text: call?['purpose_of_call']);
    final _remarksController = TextEditingController(text: call?['remarks']);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(call == null ? 'Add New Call' : 'Edit Call'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _callMadeByController,
                decoration: InputDecoration(labelText: 'Call Made By'),
              ),
              TextField(
                controller: _callDateController,
                decoration: InputDecoration(labelText: 'Call Date'),
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    _callDateController.text = pickedDate.toString().split(' ')[0];
                  }
                },
              ),
              TextField(
                controller: _callTimeController,
                decoration: InputDecoration(labelText: 'Call Time'),
                readOnly: true,
                onTap: () async {
                  TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (pickedTime != null) {
                    _callTimeController.text = pickedTime.format(context);
                  }
                },
              ),
              TextField(
                controller: _callMadeToController,
                decoration: InputDecoration(labelText: 'Call Made To'),
              ),
              TextField(
                controller: _purposeOfCallController,
                decoration: InputDecoration(labelText: 'Purpose of Call'),
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
            child: Text(call == null ? 'Add' : 'Save'),
            onPressed: () {
              final callMadeBy = _callMadeByController.text;
              final callDate = _callDateController.text;
              final callTime = _callTimeController.text;
              final callMadeTo = _callMadeToController.text;
              final purposeOfCall = _purposeOfCallController.text;
              final remarks = _remarksController.text;

              if (call == null) {
                _createCall(callMadeBy, callDate, callTime, callMadeTo, purposeOfCall, remarks);
              } else {
                _editCall(call['id'], callMadeBy, callDate, callTime, callMadeTo, purposeOfCall, remarks);
              }
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  void _createCall(String callMadeBy, String callDate, String callTime, String callMadeTo, String purposeOfCall, String remarks) async {
    final url = Uri.parse('http://localhost:3000/outgoing-calls');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'call_made_by': callMadeBy,
          'call_date': callDate,
          'call_time': callTime,
          'call_made_to': callMadeTo,
          'purpose_of_call': purposeOfCall,
          'remarks': remarks,
        }),
      );
      if (response.statusCode == 201) {
        _fetchCallList();
      } else {
        throw Exception('Failed to create call');
      }
    } catch (error) {
      _showErrorDialog('Failed to create call. Please try again.');
    }
  }

  void _editCall(int id, String callMadeBy, String callDate, String callTime, String callMadeTo, String purposeOfCall, String remarks) async {
    final url = Uri.parse('http://localhost:3000/outgoing-calls/$id');
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'call_made_by': callMadeBy,
          'call_date': callDate,
          'call_time': callTime,
          'call_made_to': callMadeTo,
          'purpose_of_call': purposeOfCall,
          'remarks': remarks,
        }),
      );
      if (response.statusCode == 200) {
        _fetchCallList();
      } else {
        throw Exception('Failed to edit call');
      }
    } catch (error) {
      _showErrorDialog('Failed to edit call. Please try again.');
    }
  }

  void _deleteCall(int id) async {
    final url = Uri.parse('http://localhost:3000/outgoing-calls/$id');
    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        _fetchCallList();
      } else {
        throw Exception('Failed to delete call');
      }
    } catch (error) {
      _showErrorDialog('Failed to delete call. Please try again.');
    }
  }

  Widget _buildCallTable() {
    return DataTable(
      columns: [
        DataColumn(label: Text('S.No.')),
        DataColumn(label: Text('Made By')),
        DataColumn(label: Text('Call Date')),
        DataColumn(label: Text('Call Time')),
        DataColumn(label: Text('Made To')),
        DataColumn(label: Text('Purpose Of Call')),
        DataColumn(label: Text('Remark')),
        DataColumn(label: Text('Actions')),
      ],
      rows: callList
          .asMap()
          .map((index, call) => MapEntry(
        index,
        DataRow(cells: [
          DataCell(Text((index + 1).toString())),
          DataCell(
            InkWell(
              child: Text(call['call_made_by'] ?? ''),
              onTap: () {
                _showCallDetails(call);
              },
            ),
          ),
          DataCell(Text(call['call_date'] ?? '')),
          DataCell(Text(call['call_time'] ?? '')),
          DataCell(Text(call['call_made_to'] ?? '')),
          DataCell(Text(call['purpose_of_call'] ?? '')),
          DataCell(Text(call['remarks'] ?? '')),
          DataCell(Row(
            children: [
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  _showCreateEditDialog(call: call);
                },
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  _deleteCall(call['id']);
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

  void _showCallDetails(Map<String, dynamic> call) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Call Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Call Made By: ${call['call_made_by'] ?? ''}'),
              Text('Call Date: ${call['call_date'] ?? ''}'),
              Text('Call Time: ${call['call_time'] ?? ''}'),
              Text('Call Made To: ${call['call_made_to'] ?? ''}'),
              Text('Purpose of Call: ${call['purpose_of_call'] ?? ''}'),
              Text('Remarks: ${call['remarks'] ?? ''}'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Close'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Outgoing Call List'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: _buildCallTable(),
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

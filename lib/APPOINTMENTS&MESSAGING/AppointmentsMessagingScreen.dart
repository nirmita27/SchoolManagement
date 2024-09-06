import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AppointmentsMessagingScreen extends StatefulWidget {
  @override
  _AppointmentsMessagingScreenState createState() => _AppointmentsMessagingScreenState();
}

class _AppointmentsMessagingScreenState extends State<AppointmentsMessagingScreen> {
  List<dynamic> appointmentsList = [];
  bool isLoading = true;
  String? selectedType;
  String? message;
  String? reason;

  @override
  void initState() {
    super.initState();
    _fetchAppointmentsList();
  }

  Future<void> _fetchAppointmentsList() async {
    final url = Uri.parse('http://localhost:3000/appointments-messaging');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          appointmentsList = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load appointments and messaging');
      }
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog('Failed to fetch appointments and messaging. Please try again.');
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

  void _showAssignDialog() {
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
                'Assign To',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(labelText: 'Staff Details'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text('Assign'),
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

  void _showChatBox(String message, String postedBy, String postedOn) {
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
                'View Remark',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text(message),
              SizedBox(height: 20),
              Text('Posted By: $postedBy'),
              Text('Posted On: $postedOn'),
              SizedBox(height: 20),
              TextButton(
                child: Text('OK'),
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

  void _showApplyDialog() {
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
                'Add New',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Appointment'),
                      value: 'Appointment',
                      groupValue: selectedType,
                      onChanged: (value) {
                        setState(() {
                          selectedType = value;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Message'),
                      value: 'Message',
                      groupValue: selectedType,
                      onChanged: (value) {
                        setState(() {
                          selectedType = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Message'),
                onChanged: (value) {
                  message = value;
                },
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Reason'),
                onChanged: (value) {
                  reason = value;
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
                    child: Text('Apply'),
                    onPressed: () {
                      _applyNewAppointment();
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

  Future<void> _applyNewAppointment() async {
    final url = Uri.parse('http://localhost:3000/appointments-messaging');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'type': selectedType,
          'message': message,
          'reason': reason,
          'requested_by': 'user_name', // Replace with actual user name
          'class': 'user_class', // Replace with actual user class
          'date_time': DateTime.now().toString(),
          'requested_on': DateTime.now().toString(),
          'assign_to': 'assign_to', // Replace with actual assignee
          'status': 'Pending'
        }),
      );
      if (response.statusCode == 201) {
        _fetchAppointmentsList();
      } else {
        throw Exception('Failed to apply new appointment');
      }
    } catch (error) {
      _showErrorDialog('Failed to apply new appointment. Please try again.');
    }
  }

  Widget _buildAppointmentsTable() {
    return DataTable(
      columns: [
        DataColumn(label: Text('S.No.')),
        DataColumn(label: Text('Type')),
        DataColumn(label: Text('Appointment/Message For')),
        DataColumn(label: Text('Reason/Message')),
        DataColumn(label: Text('Requested By')),
        DataColumn(label: Text('Class')),
        DataColumn(label: Text('Date & Time')),
        DataColumn(label: Text('Requested On')),
        DataColumn(label: Text('Assign To')),
        DataColumn(label: Text('Status')),
        DataColumn(label: Text('Chat Box')),
      ],
      rows: appointmentsList
          .asMap()
          .map((index, appointment) => MapEntry(
        index,
        DataRow(cells: [
          DataCell(Text((index + 1).toString())),
          DataCell(Text(appointment['type'] ?? '')),
          DataCell(Text(appointment['appointment_for'] ?? '')),
          DataCell(Text(appointment['reason'] ?? '')),
          DataCell(Text(appointment['requested_by'] ?? '')),
          DataCell(Text(appointment['class'] ?? '')),
          DataCell(Text(appointment['date_time'] ?? '')),
          DataCell(Text(appointment['requested_on'] ?? '')),
          DataCell(InkWell(
            child: Text('Assign To', style: TextStyle(color: Colors.blue)),
            onTap: () {
              _showAssignDialog();
            },
          )),
          DataCell(Text(appointment['status'] ?? '')),
          DataCell(InkWell(
            child: Text('View', style: TextStyle(color: Colors.blue)),
            onTap: () {
              _showChatBox(appointment['message'], appointment['requested_by'], appointment['requested_on']);
            },
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
        title: Text('Appointments & Messaging'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: _buildAppointmentsTable(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showApplyDialog();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.deepPurpleAccent,
      ),
    );
  }
}

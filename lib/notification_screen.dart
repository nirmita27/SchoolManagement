import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final _formKey = GlobalKey<FormState>();
  String _notificationMessage = '';
  String _recipientType = 'All';
  String? _userId;
  List<String> _recipientTypes = ['All', 'Teachers', 'Accountants', 'Specific User'];

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> _sendNotification() async {
    final token = await _getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No token found')));
      return;
    }

    final url = 'http://localhost:3000/send_notification';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
      body: json.encode({
        'message': _notificationMessage,
        'recipient_type': _recipientType,
        'user_id': _recipientType == 'Specific User' ? int.tryParse(_userId!) : null,
      }),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Notification Sent')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to send notification')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Send Notification'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.purple[50]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Send a Notification',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Notification Message',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a message';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _notificationMessage = value!;
                  },
                ),
                SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: _recipientType,
                  items: _recipientTypes.map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _recipientType = newValue!;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Recipient Type',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                if (_recipientType == 'Specific User')
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Enter User ID',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a User ID';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _userId = value;
                    },
                  ),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        _sendNotification();
                      }
                    },
                    child: Text('Send Notification', style: TextStyle(color: Colors.white),),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      textStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:school_management/Transport/transport_request_dashboard.dart';

class TransportRequestForm extends StatefulWidget {
  @override
  _TransportRequestFormState createState() => _TransportRequestFormState();
}

class _TransportRequestFormState extends State<TransportRequestForm> {
  final _formKey = GlobalKey<FormState>();
  String _requestType = 'Fresh Application';
  String _startDate = '';
  String _pickupAddress = '';
  String _dropAddress = '';
  String _mobileNumber = '';
  String _fillingPerson = 'Father';
  String _remarks = '';

  Future<void> _submitForm() async {
    final response = await http.post(
      Uri.parse('http://localhost:3000/submit'), // Update with your actual backend URL
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'requestType': _requestType,
        'startDate': _startDate,
        'pickupAddress': _pickupAddress,
        'dropAddress': _dropAddress,
        'mobileNumber': _mobileNumber,
        'fillingPerson': _fillingPerson,
        'remarks': _remarks,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request submitted successfully!')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => RequestDashboard()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit request.')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transport Request Form'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              Text('Request Type:'),
              ListTile(
                title: const Text('Fresh Application'),
                leading: Radio<String>(
                  value: 'Fresh Application',
                  groupValue: _requestType,
                  onChanged: (String? value) {
                    setState(() {
                      _requestType = value!;
                    });
                  },
                ),
              ),
              ListTile(
                title: const Text('Change'),
                leading: Radio<String>(
                  value: 'Change',
                  groupValue: _requestType,
                  onChanged: (String? value) {
                    setState(() {
                      _requestType = value!;
                    });
                  },
                ),
              ),
              ListTile(
                title: const Text('Withdrawal'),
                leading: Radio<String>(
                  value: 'Withdrawal',
                  groupValue: _requestType,
                  onChanged: (String? value) {
                    setState(() {
                      _requestType = value!;
                    });
                  },
                ),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Start Date'),
                keyboardType: TextInputType.datetime,
                onSaved: (value) {
                  _startDate = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Pickup Address'),
                onSaved: (value) {
                  _pickupAddress = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Drop Address'),
                onSaved: (value) {
                  _dropAddress = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Mobile Number for SMS Alert'),
                keyboardType: TextInputType.phone,
                onSaved: (value) {
                  _mobileNumber = value!;
                },
              ),
              DropdownButtonFormField<String>(
                value: _fillingPerson,
                items: <String>['Father', 'Mother'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _fillingPerson = newValue!;
                  });
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Remarks'),
                onSaved: (value) {
                  _remarks = value!;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    _submitForm();
                  }
                },
                child: Text('Submit Request'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

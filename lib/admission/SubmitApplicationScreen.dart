import 'package:flutter/material.dart';

class SubmitApplicationScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text('Submit Application'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                'Submit Your Application',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueAccent),
              ),
              SizedBox(height: 20),
              _buildTextField('First Name'),
              _buildTextField('Last Name'),
              _buildTextField('Email'),
              _buildTextField('Phone Number'),
              _buildTextField('Address'),
              _buildTextField('Date of Birth'),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Submit application logic here
                    }
                  },
                  child: Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _employeeNoController = TextEditingController();
  final TextEditingController _mobileNoController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  String _selectedRole = 'admin';

  Future<void> _signup() async {
    final designation = _selectedRole; // Designation should match the selected role
    final response = await http.post(
      Uri.parse('http://localhost:3000/signup'),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        'username': _usernameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'role': _selectedRole,
        'employeeNo': _employeeNoController.text,
        'mobileNo': _mobileNoController.text,
        'address': _addressController.text,
        'department': _departmentController.text,
        'designation': designation,
      }),
    );

    if (response.statusCode == 201) {
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to sign up. Please try again.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up (साइन अप करें)'),
        backgroundColor: Colors.teal,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('signUp.jpeg'), // Replace with your image path
            fit: BoxFit.cover,
          ),
          gradient: LinearGradient(
            colors: [Colors.teal.shade300, Colors.teal.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.3, // Adjust as needed
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // Ensure the column only takes the minimum height necessary
                    children: [
                      Text(
                        'Sign Up (साइन अप करें)',
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.teal),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'Username (उपयोगकर्ता नाम)',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email (ईमेल)',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password (पासवर्ड)',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        obscureText: true,
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: _employeeNoController,
                        decoration: InputDecoration(
                          labelText: 'Employee No (कर्मचारी संख्या)',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: _mobileNoController,
                        decoration: InputDecoration(
                          labelText: 'Mobile No (मोबाइल नंबर)',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          labelText: 'Address (पता)',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: _departmentController,
                        decoration: InputDecoration(
                          labelText: 'Department (विभाग)',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedRole,
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedRole = newValue!;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Select Role(भूमिका चुनें)',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        items: <String>['admin', 'teacher', 'accountant']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _signup,
                        child: Text('Sign Up (साइन अप करें)'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                          textStyle: TextStyle(fontSize: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

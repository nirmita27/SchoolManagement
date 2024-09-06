import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'studentdashboard.dart';

class SLoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<SLoginPage> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';

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

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final url = Uri.parse('http://localhost:3000/login/student');
      try {
        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'email': _email,
            'password': _password,
          }),
        );

        if (response.statusCode == 200) {
          final student = json.decode(response.body)['student'];
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StudentDashboardPage(studentData: student),
            ),
          );
        } else {
          _showErrorDialog('Invalid email or password.');
        }
      } catch (error) {
        _showErrorDialog('Failed to log in. Please check your network connection and try again.');
      }
    } else {
      _showErrorDialog('Please fill all the mandatory fields.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.indigo],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20.0),
            child: Container(
              width: 300,
              padding: EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Student Login',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    SizedBox(height: 20),
                    Container(
                      width: 250,
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(color: Colors.white),
                        ),
                        style: TextStyle(color: Colors.white),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _email = value!;
                        },
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      width: 250,
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(color: Colors.white),
                        ),
                        style: TextStyle(color: Colors.white),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _password = value!;
                        },
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _login,
                      child: Text('Login'),
                    ),
                    SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/sforgotpass');
                      },
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/student');
                      },
                      child: Text(
                        "Didn't sign up yet? Sign Up",
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

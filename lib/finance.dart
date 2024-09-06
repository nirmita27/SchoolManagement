import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class FinanceUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<FinanceUpPage> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _firstName = '';
  String _lastName = '';
  String _age = '';
  String _gender = '';
  String _phoneNumber = '';
  String _email = '';
  String _password = '';
  String _confirmPassword = '';

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

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final url = Uri.parse('http://localhost:3000/signup/finance');
      try {
        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'firstName': _firstName,
            'lastName': _lastName,
            'email': _email,
            'password': _password,
          }),
        );

        if (response.statusCode == 201) {
          Navigator.pushNamed(context, '/flogin');
        } else {
          _showErrorDialog('Failed to sign up. Please try again.');
        }
      } catch (error) {
        _showErrorDialog('Failed to sign up. Please check your network connection and try again.');
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
                      'Sign Up',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    SizedBox(height: 20),
                    Container(
                      width: 250,
                      child: TextFormField(
                        decoration: InputDecoration(labelText: 'First Name', labelStyle: TextStyle(color: Colors.white)),
                        style: TextStyle(color: Colors.white),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your first name';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _firstName = value!;
                        },
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      width: 250,
                      child: TextFormField(
                        decoration: InputDecoration(labelText: 'Last Name', labelStyle: TextStyle(color: Colors.white)),
                        style: TextStyle(color: Colors.white),
                        onSaved: (value) {
                          _lastName = value!;
                        },
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      width: 250,
                      child: TextFormField(
                        decoration: InputDecoration(labelText: 'Email', labelStyle: TextStyle(color: Colors.white)),
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
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility : Icons.visibility_off,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        style: TextStyle(color: Colors.white),
                        obscureText: _obscurePassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          _password = value;
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      width: 250,
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          labelStyle: TextStyle(color: Colors.white),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                          ),
                        ),
                        style: TextStyle(color: Colors.white),
                        obscureText: _obscureConfirmPassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          } else if (value != _password) {
                            return 'Passwords do not match';
                          }
                          _confirmPassword = value;
                          return null;
                        },
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _signUp,
                      child: Text('Sign Up'),
                    ),
                    SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/flogin');
                      },
                      child: Text(
                        'Already signed up? Login',
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

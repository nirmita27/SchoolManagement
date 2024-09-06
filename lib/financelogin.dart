import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class FLoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<FLoginPage> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
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

      final url = Uri.parse('http://localhost:3000/login/finance');
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
          Navigator.pushNamed(context, '/');
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
            child: Form(
              key: _formKey,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Finance Login',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    SizedBox(height: 20),
                    Container(
                      padding: EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        children: [
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
                                } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                                  return 'Please enter a valid email address';
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
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _login,
                            child: Text('Login'),
                          ),
                          SizedBox(height: 10),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/finance');
                            },
                            child: Text(
                              'Don\'t have an account? Sign Up',
                              style: TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          ),
                        ],
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

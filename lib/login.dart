import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _login() async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/login'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          'email': _emailController.text,
          'password': _passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final token = data['token'];
        final role = data['role'];
        final status = data['status'];
        final userId = data['userId'];
        final email = data['email'] ?? ''; // Ensure email is not null

        // Admin can log in regardless of approval status
        if (role != 'admin' && status != 'approved') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Your account is not approved yet.'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('role', role);
        await prefs.setInt('userId', userId);
        await prefs.setString('email', email); // Save the email

        Navigator.pushReplacementNamed(context, '/mainmenuscreen');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid email or password'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print('Error during login: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred. Please try again.'),
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
        title: Text('Login (लॉग इन करें)'),
        backgroundColor: Colors.teal,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('login8.jpeg'), // Replace with your image path
            fit: BoxFit.cover,
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width > 600
                          ? 400
                          : MediaQuery.of(context).size.width * 0.3,
                      constraints: BoxConstraints(maxWidth: 400),
                      child: Card(
                        elevation: 10,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Login (लॉग इन करें)',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal,
                                ),
                              ),
                              SizedBox(height: 20),
                              _buildTextField(
                                controller: _emailController,
                                labelText: 'Email (ईमेल)',
                              ),
                              SizedBox(height: 16),
                              _buildTextField(
                                controller: _passwordController,
                                labelText: 'Password (पासवर्ड)',
                                obscureText: true,
                              ),
                              SizedBox(height: 20),
                              _buildLoginButton(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      obscureText: obscureText,
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: _login,
      child: Text('Login (लॉग इन करें)'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.teal,
        padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
        textStyle: TextStyle(fontSize: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

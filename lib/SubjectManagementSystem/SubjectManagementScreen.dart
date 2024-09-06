import 'package:flutter/material.dart';

import 'AssignSubjectScreen.dart';
import 'SubjectMaster.dart';
import 'SyllabusMaster.dart';

class SubjectManagementScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Subject Management'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MASTER SETTINGS',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurpleAccent,
                ),
              ),
              SizedBox(height: 24),
              _buildMenuButton(context, 'Subject Master', Icons.book),
              SizedBox(height: 24),
              _buildMenuButton(context, 'Syllabus Master', Icons.description),
              SizedBox(height: 24),
              _buildMenuButton(context, 'Assign Subject To Student', Icons.assignment),
              ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String title, IconData icon) {
    return GestureDetector(
      onTap: () {
        // Navigate to respective screen
        if (title == 'Subject Master') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SubjectMasterScreen()),
          );
        } else if (title == 'Syllabus Master') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SyllabusMasterScreen()),
          );
        } else if (title == 'Assign Subject To Student') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AssignSubjectScreen()),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DummyScreen(title: title)),
          );
        }
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurpleAccent, Colors.purpleAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurpleAccent.withOpacity(0.4),
              spreadRadius: 4,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(icon, color: Colors.white, size: 28),
              SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class DummyScreen extends StatelessWidget {
  final String title;

  DummyScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: Center(
        child: Text(
          '$title Screen',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

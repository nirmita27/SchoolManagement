import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:school_management/ClassManagement/AssignClassToCoordinatorScreen%20.dart';
import 'package:school_management/ClassManagement/AssignedClassScreen.dart';
import 'package:school_management/ClassManagement/SectionMasterScreen.dart';

import 'ClassMasterScreen.dart';

class ClassManagementScreen extends StatefulWidget {
  @override
  _ClassManagementScreenState createState() => _ClassManagementScreenState();
}

class _ClassManagementScreenState extends State<ClassManagementScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Class Management'),
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: ListView(
        children: [
          _buildMenuButton(context, "List Assigned Section & Class", Icons.list, Colors.blue),
          _buildMenuButton(context, "Class Coordinator List", Icons.person, Colors.green),
          _buildMenuButton(context, "Class Master", Icons.school, Colors.redAccent),
          _buildMenuButton(context, "Section Master", Icons.segment, Colors.orange),
        ],
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String title, IconData icon, Color color) {
    return Card(
      margin: EdgeInsets.all(8),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title),
        onTap: () {
          // Navigate to respective screens
          if (title == "Class Master") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ClassMasterScreen()),
            );
          } else if (title == "Class Coordinator List") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AssignClassToCoordinatorScreen()),
            );
          } else if (title == "Section Master") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SectionMasterScreen()),
            );
          } else if (title == "List Assigned Section & Class") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AssignedClassScreen()),
            );
          } else {
            // Handle other navigations if required
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Navigation not implemented for $title')),
            );
          }
        },
      ),
      elevation: 4,
      shadowColor: color.withOpacity(0.5),
    );
  }
}

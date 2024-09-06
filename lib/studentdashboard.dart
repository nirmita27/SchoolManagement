import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:school_management/StudentScreens/Homework.dart';
import 'StudentScreens/StudentFeeDetailsPage.dart';

class StudentDashboardPage extends StatelessWidget {
  final Map<String, dynamic> studentData;

  StudentDashboardPage({required this.studentData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Dashboard'),
        backgroundColor: Colors.blueAccent,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text('${studentData['first_name']} ${studentData['last_name']}'),
              accountEmail: Text(studentData['admission_number']),
              currentAccountPicture: CircleAvatar(
                backgroundImage: AssetImage('assets/profile.jpg'), // Placeholder for profile image
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blueAccent, Colors.lightBlueAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            _buildDrawerItem(Icons.assignment, 'Homework', context),
            _buildDrawerItem(Icons.schedule, 'Timetable', context),
            _buildDrawerItem(Icons.check_circle, 'Attendance', context),
            _buildDrawerItem(Icons.lock, 'Change Password', context),
            _buildDrawerItem(Icons.notifications, 'School Circular', context),
            _buildDrawerItem(Icons.directions_bus, 'Transport', context),
            _buildDrawerItem(Icons.calendar_today, 'Academic Calendar', context),
            _buildDrawerItem(Icons.attach_money, 'Fee Details', context),
            _buildDrawerItem(Icons.request_page, 'Leave Request', context),
            _buildDrawerItem(Icons.report, 'Report Card', context),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Section
            Center(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blueAccent, Colors.lightBlueAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage('assets/profile.jpg'), // Placeholder for profile image
                    ),
                    SizedBox(height: 10),
                    Text(
                      '${studentData['first_name']} ${studentData['last_name']}',
                      style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Admission No: ${studentData['admission_number']}',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    Text(
                      'Class-Section: ${studentData['class']}-${studentData['section']}',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Today's Attendance: Present", // Assuming attendance is fetched separately
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueAccent),
      title: Text(title),
      onTap: () => _onCardTap(title, context),
    );
  }

  void _onCardTap(String title, BuildContext context) {
    Navigator.pop(context); // Close the drawer
    switch (title) {
      case 'Report Card':
        _showReportDialog(context);
        break;
      case 'Homework':
        _showHomeworkDialog(context);
        break;
      case 'Academic Calendar':
        _showCalendarDialog(context);
        break;
      case 'Timetable':
        _showTimeTableDialog(context);
        break;
      case 'School Circular':
        _showNoticeDialog(context);
        break;
      case 'Fee Details':
        _showFeesDialog(context);
        break;
    // Add other cases as necessary
      default:
        break;
    }
  }

  void _showDialog(BuildContext context, String title, List<Widget> content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Text(title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: content,
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
          ElevatedButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  void _showReportDialog(BuildContext context) {
    _showDialog(context, 'Report Card', [
      Text('Modules'),
      SizedBox(height: 10),
      ListTile(
        title: Text('View Report Card'),
        onTap: () {
          // Add your functionality here
        },
      ),
      ListTile(
        title: Text('Download Report Card'),
        onTap: () {
          // Add your functionality here
        },
      ),
    ]);
  }

  void _showFeesDialog(BuildContext context) {
    _showDialog(context, 'Fees Details', [
      Text('Modules'),
      SizedBox(height: 10),
      ListTile(
        title: Text('View Fees Details'),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StudentFeeDetailsPage(
                studentId: studentData['student_id'],
                financialYear: '2023-2024',
              ),
            ),
          );
        },
      ),
    ]);
  }

  void _showHomeworkDialog(BuildContext context) {
    _showDialog(context, 'Homework', [
      Text('Modules'),
      SizedBox(height: 10),
      ListTile(
        title: Text('View Homework'),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StudentHomeworkPage(studentClass: '10B')
            ),
          );
        },
      ),
    ]);
  }

  void _showCalendarDialog(BuildContext context) {
    _showDialog(context, 'Academic Calendar', [
      Text('Modules'),
      SizedBox(height: 10),
      ListTile(
        title: Text('View Calendar'),
        onTap: () {
          // Add your functionality here
        },
      ),
    ]);
  }

  void _showTimeTableDialog(BuildContext context) {
    _showDialog(context, 'Timetable', [
      Text('Modules'),
      SizedBox(height: 10),
      ListTile(
        title: Text('View Timetable'),
        onTap: () {
          // Add your functionality here
        },
      ),
    ]);
  }

  void _showNoticeDialog(BuildContext context) {
    _showDialog(context, 'Announcements', [
      Text('Modules'),
      SizedBox(height: 10),
      ListTile(
        title: Text('View Announcement'),
        onTap: () {
          // Add your functionality here
        },
      ),
    ]);
  }
}

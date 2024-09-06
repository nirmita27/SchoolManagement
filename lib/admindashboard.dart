import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import 'AdminScreens/adminFeeManagementPage.dart';

class AdminDashboardPage extends StatelessWidget {
  final String adminName;

  AdminDashboardPage({
    required this.adminName,
  });

  final int activeStudents = 843; // Example value
  final int deletedStudents = 98; // Example value
  final int deactivatedStudents = 2927; // Example value
  final int freezedStudents = 208; // Example value
  final int nonTeaching = 33; // Example value
  final int supportStaff = 115; // Example value
  final int teaching = 101; // Example value
  final int todayAbsentStaff = 249; // Example value

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                icon: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: AssetImage(
                          'assets/profile.jpg'), // Placeholder for profile image
                    ),
                    SizedBox(width: 10),
                    Text(
                      adminName,
                      style: TextStyle(color: Colors.black),
                    ),
                    Icon(Icons.arrow_drop_down, color: Colors.black),
                  ],
                ),
                items: <String>['Logout'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue == 'Logout') {
                    // Add logout functionality here
                    Navigator.pushNamed(context, '/adlogin');
                  }
                },
              ),
            ),
            IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                _showSearchDialog(context);
              },
            ),
            IconButton(
              icon: Icon(Icons.mail),
              onPressed: () {
                // Add notification functionality here
              },
            ),
            IconButton(
              icon: Icon(Icons.notifications),
              onPressed: () {
                // Add notification functionality here
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatTile('Student\'s Details', [
                    'Active: $activeStudents',
                    'Deleted: $deletedStudents',
                    'Deactivated: $deactivatedStudents',
                    'Freezed: $freezedStudents'
                  ], Colors.purple),
                  _buildStatTile('Staff\'s Details', [
                    'Non Teaching: $nonTeaching',
                    'Support Staff: $supportStaff',
                    'Teaching: $teaching'
                  ], Colors.green),
                  _buildStatTile('Today\'s Fee Details', [], Colors.orange),
                ],
              ),
              SizedBox(height: 8,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatTile('Today\'s Student Attendance', [], Colors.red),
                  _buildStatTile('Staff\'s Attendance', [
                    'Today\'s Absent Staff Count: $todayAbsentStaff'
                  ], Colors.brown),
                  _buildStatTile('Staff on Leave', [], Colors.green),
                ],
              ),
              SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 300,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: PieChart(
                              PieChartData(
                                sections: [
                                  PieChartSectionData(
                                    color: Colors.blue,
                                    value: 15,
                                    title: '15%',
                                    radius: 145,
                                  ),
                                  PieChartSectionData(
                                    color: Colors.red,
                                    value: 10,
                                    title: '10%',
                                    radius: 145,
                                  ),
                                  PieChartSectionData(
                                    color: Colors.orange,
                                    value: 35,
                                    title: '35%',
                                    radius: 145,
                                  ),
                                  PieChartSectionData(
                                    color: Colors.green,
                                    value: 40,
                                    title: '40%',
                                    radius: 145,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildIndicator('Tution Fees', Colors.blue),
                                _buildIndicator('Other charge', Colors.red),
                                _buildIndicator('Transport fee', Colors.orange),
                                _buildIndicator('Fine', Colors.green),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      height: 300,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: PieChart(
                              PieChartData(
                                sections: [
                                  PieChartSectionData(
                                    color: Colors.blue,
                                    value: 20,
                                    title: '20%',
                                    radius: 145,
                                  ),
                                  PieChartSectionData(
                                    color: Colors.red,
                                    value: 35,
                                    title: '35%',
                                    radius: 145,
                                  ),
                                  PieChartSectionData(
                                    color: Colors.orange,
                                    value: 15,
                                    title: '15%',
                                    radius: 145,
                                  ),
                                  PieChartSectionData(
                                    color: Colors.green,
                                    value: 8,
                                    title: '8%',
                                    radius: 145,
                                  ),
                                  PieChartSectionData(
                                    color: Colors.purple,
                                    value: 22,
                                    title: '22%',
                                    radius: 145,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildIndicator('Cashfree', Colors.blue),
                                _buildIndicator('Cash', Colors.red),
                                _buildIndicator('ICICI Bank', Colors.orange),
                                _buildIndicator('Adjustment', Colors.green),
                                _buildIndicator(
                                    'DD/Bank Transfer', Colors.purple),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(
              height: 75, // Set a smaller height for the DrawerHeader
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
            _buildDrawerItem('Homework', Icons.assignment, Colors.red, context),
            _buildDrawerItem(
                'Timetable', Icons.table_chart_sharp, Colors.lightBlueAccent,
                context),
            _buildDrawerItem('Examination and Result', Icons.newspaper_sharp,
                Colors.orangeAccent, context),
            _buildDrawerItem(
                'Attendance Management', Icons.check_circle, Colors.blue,
                context),
            _buildDrawerItem(
                'Student Portal', Icons.school_outlined, Colors.green, context),
            _buildDrawerItem(
                'Learning Area', Icons.fact_check_outlined, Colors.blueGrey,
                context),
            _buildDrawerItem(
                'Change Password', Icons.lock, Colors.yellow, context),
            _buildDrawerItem(
                'Notice Board', Icons.notifications, Colors.purple, context),
            _buildDrawerItem('Transportation Management', Icons.directions_bus,
                Colors.orange, context),
            _buildDrawerItem(
                'Academic Calendar', Icons.calendar_today, Colors.pink,
                context),
            _buildDrawerItem(
                'Fee Management', Icons.attach_money, Colors.teal, context),
            _buildDrawerItem(
                'Subject Management', Icons.book, Colors.green, context),
            _buildDrawerItem(
                'I-Card Management', Icons.credit_card, Colors.blue, context),
            _buildDrawerItem(
                'Leave Management', Icons.request_page, Colors.brown, context),
            _buildDrawerItem(
                'Staff Management', Icons.account_box, Colors.redAccent,
                context),
            _buildDrawerItem('Student Registration', Icons.account_circle_sharp,
                Colors.brown, context),
            _buildDrawerItem('Student Certificate', Icons.receipt_long_sharp,
                Colors.lightGreen, context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatTile(String title, List<String> stats, Color color) {
    return Container(
      width: 300,
      height: stats.isNotEmpty ? 150 : 150,
      // Adjust height based on content
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 10),
          ...stats.map((stat) =>
              Text(
                stat,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              )).toList(),
        ],
      ),
    );
  }

  Widget _buildIndicator(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            color: color,
          ),
          SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(String title, IconData icon, Color iconColor,
      BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor,
      ),
      title: Text(title),
      onTap: () {
        // Handle navigation based on the title
        Future.delayed(Duration(milliseconds: 250), () {
          switch (title) {
            case 'Homework':
              _showHomeworkDialog(context);
              break;
            case 'Timetable':
              _showTimetableDialog(context);
              break;
            case 'Examination and Result':
              _showExaminationResultDialog(context);
              break;
            case 'Attendance Management':
              _showAttendenceManagement(context);
              break;
            case 'Student Portal':
              _showStudentPortalDialog(context);
              break;
            case 'Learning Area':
              _showLearningAreaDialog(context);
              break;
            case 'Change Password':
              _showChangePasswordDialog(context);
              break;
            case 'Notice Board':
              _showNoticeBoardDialog(context);
              break;
            case 'Transportation Management':
              _showTransportationDialog(context);
              break;
            case 'Academic Calendar':
              _showAcademicCalendarDialog(context);
              break;
            case 'Fee Management':
              _showFeeManagementDialog(context);
              break;
            case 'Subject Management':
              _showSubjectManagementDialog(context);
              break;
            case 'I-Card Management':
              _showICardManagementDialog(context);
              break;
            case 'Leave Management':
              _showLeaveManagementDialog(context);
              break;
            case 'Staff Management':
              _showStaffManagementDialog(context);
              break;
            case 'Student Registration':
              _showStudentRegistrationDialog(context);
              break;
            case 'Student Certificate':
              _showStudentCertificateDialog(context);
              break;
            default:
              Navigator.pop(context); // Close the drawer for unhandled cases
          }
        });
      },
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Search'),
          content: TextField(
            decoration: InputDecoration(hintText: 'Enter search term'),
            onSubmitted: (String value) {
              // Handle the search action
              Navigator.of(context).pop(); // Close the dialog
            },
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  void _showHomeworkDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) =>
          AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Text('Homework'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Modules'),
                SizedBox(height: 10),
                ListTile(
                  title: Text('Upload Homework'),
                  onTap: () {

                  },
                ),
                SizedBox(height: 5),
                ListTile(
                  title: Text('Approve Homework'),
                  onTap: () {

                  },
                ),
              ],
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

  void _showTimetableDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) =>
          AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Text('Time Table'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Modules'),
                SizedBox(height: 10),
                ListTile(
                  title: Text('View Time Table'),
                  onTap: () {

                  },
                ),
              ],
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

  void _showExaminationResultDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) =>
          AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Text('Examination and Result'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Modules'),
                SizedBox(height: 10),
                ListTile(
                  title: Text('View Examination Details'),
                  onTap: () {

                  },
                ),
                SizedBox(height: 5),
                ListTile(
                  title: Text('View Result'),
                  onTap: () {

                  },
                ),
              ],
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

  void _showAttendenceManagement(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) =>
          AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Text('Attendence'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Modules'),
                SizedBox(height: 10),
                ListTile(
                  title: Text('Manage Attendence'),
                  onTap: () {

                  },
                ),
              ],
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

  void _showStudentPortalDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) =>
          AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Text('Student Portal'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Options'),
                SizedBox(height: 10),
                ListTile(
                  title: Text('Student Login Details'),
                  onTap: () {
                    // Add functionality to view student portal
                    Navigator.of(ctx).pop(); // Close the dialog
                  },
                ),
                SizedBox(height: 5),
                ListTile(
                  title: Text('Login History Details'),
                  onTap: () {
                    // Add functionality to view student portal
                    Navigator.of(ctx).pop(); // Close the dialog
                  },
                ),
                SizedBox(height: 5),
                ListTile(
                  title: Text('SET LOGIN CREDENTIALS(student)'),
                  onTap: () {
                    // Add functionality to view student portal
                    Navigator.of(ctx).pop(); // Close the dialog
                  },
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(ctx).pop(); // Close the dialog
                },
              ),
              ElevatedButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(ctx).pop(); // Close the dialog
                },
              ),
            ],
          ),
    );
  }

  void _showLearningAreaDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) =>
          AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Text('Learning Area'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Modules'),
                ListTile(
                  title: Text('Tutorials by OnMouseClick.com'),
                  onTap: () {
                    // Add functionality to view learning area
                    Navigator.of(ctx).pop(); // Close the dialog
                  },
                ),
                ListTile(
                  title: Text('Tutorials by School'),
                  onTap: () {
                    // Add functionality to view learning area
                    Navigator.of(ctx).pop(); // Close the dialog
                  },
                ),
                Text('Master Setting'),
                ListTile(
                  title: Text('Upload New Tutorial'),
                  onTap: () {
                    // Add functionality to view learning area
                    Navigator.of(ctx).pop(); // Close the dialog
                  },
                ),
                ListTile(
                  title: Text('Category List'),
                  onTap: () {
                    // Add functionality to view learning area
                    Navigator.of(ctx).pop(); // Close the dialog
                  },
                ),
              ],
            ),

            actions: <Widget>[
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(ctx).pop(); // Close the dialog
                },
              ),
              ElevatedButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(ctx).pop(); // Close the dialog
                },
              ),
            ],
          ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) =>
          AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Text('Change Password'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Options'),
                SizedBox(height: 10),
                ListTile(
                  title: Text('Change Password'),
                  onTap: () {
                    // Add functionality to change password
                    Navigator.of(ctx).pop(); // Close the dialog
                  },
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(ctx).pop(); // Close the dialog
                },
              ),
              ElevatedButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(ctx).pop(); // Close the dialog
                },
              ),
            ],
          ),
    );
  }

  void _showNoticeBoardDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) =>
          AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Text('Notice Board'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Options'),
                SizedBox(height: 10),
                ListTile(
                  title: Text('View Notices'),
                  onTap: () {
                    // Add functionality to view notices
                    Navigator.of(ctx).pop(); // Close the dialog
                  },
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(ctx).pop(); // Close the dialog
                },
              ),
              ElevatedButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(ctx).pop(); // Close the dialog
                },
              ),
            ],
          ),
    );
  }

  void _showTransportationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) =>
          AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Text('Transportation Management'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Options'),
                SizedBox(height: 10),
                ListTile(
                  title: Text('Manage Transportation'),
                  onTap: () {
                    // Add functionality to manage transportation
                    Navigator.of(ctx).pop(); // Close the dialog
                  },
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(ctx).pop(); // Close the dialog
                },
              ),
              ElevatedButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(ctx).pop(); // Close the dialog
                },
              ),
            ],
          ),
    );
  }

  void _showAcademicCalendarDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) =>
          AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Text('Academic Calendar'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Options'),
                SizedBox(height: 10),
                ListTile(
                  title: Text('View Academic Calendar'),
                  onTap: () {
                    // Add functionality to view academic calendar
                    Navigator.of(ctx).pop(); // Close the dialog
                  },
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(ctx).pop(); // Close the dialog
                },
              ),
              ElevatedButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(ctx).pop(); // Close the dialog
                },
              ),
            ],
          ),
    );
  }

  void _showFeeManagementDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) =>
          AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Text('Fee Management'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Options'),
                SizedBox(height: 10),
                ListTile(
                  title: Text('Manage Fees'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AdminFeeManagementPage()),
                    );
                  },
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(ctx).pop(); // Close the dialog
                },
              ),
              ElevatedButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(ctx).pop(); // Close the dialog
                },
              ),
            ],
          ),
    );
  }

  void _showSubjectManagementDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) =>
          AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Text('Subject Management'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Options'),
                SizedBox(height: 10),
                ListTile(
                  title: Text('Manage Subjects'),
                  onTap: () {
                    // Add functionality to manage subjects
                    Navigator.of(ctx).pop(); // Close the dialog
                  },
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(ctx).pop(); // Close the dialog
                },
              ),
              ElevatedButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(ctx).pop(); // Close the dialog
                },
              ),
            ],
          ),
    );
  }

  void _showICardManagementDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) =>
          AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Text('I-Card Management'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Options'),
                SizedBox(height: 10),
                ListTile(
                  title: Text('Manage I-Cards'),
                  onTap: () {
                    // Add functionality to manage I-cards
                    Navigator.of(ctx).pop(); // Close the dialog
                  },
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(ctx).pop(); // Close the dialog
                },
              ),
              ElevatedButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(ctx).pop(); // Close the dialog
                },
              ),
            ],
          ),
    );
  }

  void _showLeaveManagementDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) =>
          AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Text('Leave Management'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Options'),
                SizedBox(height: 10),
                ListTile(
                  title: Text('Manage Leaves'),
                  onTap: () {
                    // Add functionality to manage leaves
                    Navigator.of(ctx).pop(); // Close the dialog
                  },
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(ctx).pop(); // Close the dialog
                },
              ),
              ElevatedButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(ctx).pop(); // Close the dialog
                },
              ),
            ],
          ),
    );
  }

  void _showStaffManagementDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) =>
          AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Text('Staff Management'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Options'),
                SizedBox(height: 10),
                ListTile(
                  title: Text('Manage Staff'),
                  onTap: () {
                    // Add functionality to manage staff
                    Navigator.of(ctx).pop(); // Close the dialog
                  },
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(ctx).pop(); // Close the dialog
                },
              ),
              ElevatedButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(ctx).pop(); // Close the dialog
                },
              ),
            ],
          ),
    );
  }

  void _showStudentRegistrationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) =>
          AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Text('Student Registration'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Options'),
                SizedBox(height: 10),
                ListTile(
                  title: Text('Register Student'),
                  onTap: () {
                    // Add functionality to register student
                    Navigator.of(ctx).pop(); // Close the dialog
                  },
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(ctx).pop(); // Close the dialog
                },
              ),
              ElevatedButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(ctx).pop(); // Close the dialog
                },
              ),
            ],
          ),
    );
  }

  void _showStudentCertificateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) =>
          AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Text('Student Certificate'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Options'),
                SizedBox(height: 10),
                ListTile(
                  title: Text('View Student Certificate'),
                  onTap: () {
                    // Add functionality to view student certificate
                    Navigator.of(ctx).pop(); // Close the dialog
                  },
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(ctx).pop(); // Close the dialog
                },
              ),
              ElevatedButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(ctx).pop(); // Close the dialog
                },
              ),
            ],
          ),
    );
  }

}
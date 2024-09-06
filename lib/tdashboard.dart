import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:school_management/TeacherScreens/academic_calendar_screen.dart';
import 'package:school_management/TeacherScreens/attendance_screen.dart';
import 'package:school_management/TeacherScreens/change_password_screen.dart';
import 'package:school_management/TeacherScreens/examination_screen.dart';
import 'package:school_management/TeacherScreens/fee_details_screen.dart';
import 'package:school_management/TeacherScreens/gate_pass_screen.dart';
import 'package:school_management/TeacherScreens/homework_screen.dart';
import 'package:school_management/TeacherScreens/notice_board_screen.dart';
import 'package:school_management/TeacherScreens/student_certificate_screen.dart';
import 'package:school_management/TeacherScreens/transport_screen.dart';
import 'package:school_management/adminhomework.dart';

import 'TeacherScreens/timetable_screen.dart';

class TeacherDashboardPage extends StatefulWidget {
  final String email;

  TeacherDashboardPage({required this.email});

  @override
  _TeacherDashboardPageState createState() => _TeacherDashboardPageState();
}

class _TeacherDashboardPageState extends State<TeacherDashboardPage> {
  late String teacherName = '';
  late String profilePictureUrl = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTeacherData();
  }

  Future<void> _fetchTeacherData() async {
    final url = Uri.parse('http://localhost:3000/teacher/${widget.email}');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          teacherName = '${data['first_name']} ${data['last_name']}';
          profilePictureUrl = 'http://localhost:3000${data['profile_picture']}';
          isLoading = false;
        });
      } else {
        print('Server responded with status code ${response.statusCode}');
        throw Exception('Failed to load teacher data');
      }
    } catch (error) {
      print('Error fetching teacher data: $error');
      setState(() {
        isLoading = false;
      });
      _showErrorDialog('Failed to fetch teacher data. Please try again.');
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Scaffold(
      appBar: AppBar(title: Text('Loading...')),
      body: Center(child: CircularProgressIndicator()),
    )
        : Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                icon: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: profilePictureUrl.isNotEmpty
                          ? NetworkImage(profilePictureUrl)
                          : AssetImage('assets/profile.jpg') as ImageProvider,
                    ),
                    SizedBox(width: 10),
                    Text(
                      teacherName,
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
                    Navigator.pushNamed(context, '/teacherlogin');
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
                  _buildStatTile('Classes', 10, Colors.blue),
                  _buildStatTile('Subjects', 5, Colors.green),
                  _buildStatTile('Students', 150, Colors.orange),
                  _buildStatTile('Assignments', 20, Colors.red),
                ],
              ),
              SizedBox(height: 20),
              _buildPieChart(),
              SizedBox(height: 20),
              _buildBarChart(),
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
            _buildDrawerItem('Timetable', Icons.schedule, Colors.green, context),
            _buildDrawerItem('Attendance', Icons.check_circle, Colors.blue, context),
            _buildDrawerItem('Change Password', Icons.lock, Colors.yellow, context),
            _buildDrawerItem('Notice Board', Icons.notifications, Colors.purple, context),
            _buildDrawerItem('Transport', Icons.directions_bus, Colors.orange, context),
            _buildDrawerItem('Academic Calendar', Icons.calendar_today, Colors.pink, context),
            _buildDrawerItem('Fee Details', Icons.attach_money, Colors.teal, context),
            _buildDrawerItem('Gate Pass', Icons.request_page, Colors.brown, context),
            _buildDrawerItem('Examination and Result', Icons.report, Colors.cyan, context),
            _buildDrawerItem('Student Certificate', Icons.report, Colors.lightGreen, context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatTile(String title, int count, Color color) {
    return Container(
      width: 150,
      height: 100,
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
          Text(
            '$count',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart() {
    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(
              value: 60,
              title: 'Male',
              color: Colors.blue,
              radius: 50,
              titleStyle: TextStyle(color: Colors.white),
            ),
            PieChartSectionData(
              value: 40,
              title: 'Female',
              color: Colors.pink,
              radius: 50,
              titleStyle: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          barGroups: [
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(toY: 30000, color: Colors.blue),
              ],
              showingTooltipIndicators: [0],
            ),
            BarChartGroupData(
              x: 2,
              barRods: [
                BarChartRodData(toY: 40000, color: Colors.blue),
              ],
              showingTooltipIndicators: [0],
            ),
            BarChartGroupData(
              x: 3,
              barRods: [
                BarChartRodData(toY: 35000, color: Colors.blue),
              ],
              showingTooltipIndicators: [0],
            ),
            BarChartGroupData(
              x: 4,
              barRods: [
                BarChartRodData(toY: 45000, color: Colors.blue),
              ],
              showingTooltipIndicators: [0],
            ),
            BarChartGroupData(
              x: 5,
              barRods: [
                BarChartRodData(toY: 50000, color: Colors.blue),
              ],
              showingTooltipIndicators: [0],
            ),
          ],
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final style = TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                  );
                  switch (value.toInt()) {
                    case 1:
                      return Text('2019', style: style);
                    case 2:
                      return Text('2020', style: style);
                    case 3:
                      return Text('2021', style: style);
                    case 4:
                      return Text('2022', style: style);
                    case 5:
                      return Text('2023', style: style);
                    default:
                      return const SizedBox.shrink(); // Empty widget if no match
                  }
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 10,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      )

    );
  }

  Widget _buildDrawerItem(String title, IconData icon, Color color, BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        if (title == 'Homework') {
          _showHomeworkDialog(context);
        }
        if (title == 'Timetable') {
          _showTimeTableDialog(context);
        }
        if (title == 'Attendance') {
          _showAttendanceDialog(context);
        }
        if (title == 'Change Password') {
          _showChangePasswordDialog(context);
        }
        if (title == 'Notice Board') {
          _showNoticeDialog(context);
        }
        if (title == 'Transport') {
          _showTransportDialog(context);
        }
        if (title == 'Academic Calendar') {
          _showCalendarDialog(context);
        }
        if (title == 'Fee Details') {
          _showFeeDetailsDialog(context);
        }
        if (title == 'Gate Pass') {
          _showGatePassDialog(context);
        }
        if (title == 'Examination and Result') {
          _showExaminationDialog(context);
        }
        if (title == 'Student Certificate') {
          _showStudentCertificateDialog(context);
        }
      },
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        String searchQuery = '';
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text('Search'),
          content: TextField(
            onChanged: (value) {
              searchQuery = value;
            },
            decoration: InputDecoration(
              hintText: 'Enter your search query',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: Text('Search'),
              onPressed: () {
                // Perform search operation
                Navigator.pop(context);
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
      builder: (ctx) => AlertDialog(
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
              title: Text('View Homework'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomeworkScreen()),
                );
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

  void _showTimeTableDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Text('Timetable'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Modules'),
            SizedBox(height: 10),
            ListTile(
              title: Text('View Timetable'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TimetableScreen()),
                );
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

  void _showAttendanceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Text('Attendance'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Modules'),
            SizedBox(height: 10),
            ListTile(
              title: Text('View Attendance'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AttendanceScreen()),
                );
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

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Modules'),
            SizedBox(height: 10),
            ListTile(
              title: Text('Change Password'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChangePasswordScreen()),
                );
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

  void _showNoticeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Text('Notice Board'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Modules'),
            SizedBox(height: 10),
            ListTile(
              title: Text('View Notices'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NoticeBoardScreen()),
                );
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

  void _showTransportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Text('Transport'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Modules'),
            SizedBox(height: 10),
            ListTile(
              title: Text('View Transport'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TransportScreen()),
                );              },
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

  void _showCalendarDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Text('Academic Calendar'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Modules'),
            SizedBox(height: 10),
            ListTile(
              title: Text('View Calendar'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AcademicCalendarScreen()),
                );
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

  void _showFeeDetailsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Text('Fee Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Modules'),
            SizedBox(height: 10),
            ListTile(
              title: Text('View Fee Details'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FeeDetailsScreen()),
                );
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

  void _showGatePassDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Text('Gate Pass'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Modules'),
            SizedBox(height: 10),
            ListTile(
              title: Text('View Gate Pass'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GatePassScreen()),
                );              },
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

  void _showExaminationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ExaminationScreen()),
                );              },
            ),
            ListTile(
              title: Text('View Results'),
              onTap: () {
                // Add your functionality here
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

  void _showStudentCertificateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Text('Student Certificate'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Modules'),
            SizedBox(height: 10),
            ListTile(
              title: Text('View Certificate'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StudentCertificateScreen()),
                );              },
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
}

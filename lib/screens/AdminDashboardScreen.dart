import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:school_management/Fees/fees.dart';
import 'package:school_management/Transport/transport.dart';
import 'package:school_management/academic_holidays.dart';
import 'package:school_management/admission/admission_screen.dart';
import 'package:school_management/expenditure/expenditure.dart';
import 'package:school_management/screens/student_list_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';

import '../APPOINTMENTS&MESSAGING/AppointmentsMessagingScreen.dart';
import '../ClassManagement/ClassManagementScreen.dart';
import '../DocumentationScreen.dart';
import '../ExaminationAndResults/ExaminationAndResults.dart';
import '../I_CARD_MANAGEMENT/iCardManagementScreen.dart';
import '../LeaveManagement/LeaveManagementScreen.dart';
import '../LibraryManagement/libraryManagement.dart';
import '../ReceptionManagement/ReceptionManagementScreen.dart';
import '../StaffManagement/StaffManagementScreen.dart';
import '../StockManagementSystem/stock_management_system_screen.dart';
import '../SubjectManagementSystem/SubjectManagementScreen.dart';
import '../TimeTableManagement/TimetableScreen.dart';
import '../approval_page.dart';
import '../notification_screen.dart';

class AdminDashboard extends StatefulWidget {
  final String schoolRange;

  AdminDashboard({required this.schoolRange});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String role = '';
  int userId = 0;
  List<Map<String, dynamic>> notifications = [];
  Map<String, dynamic> dashboardData = {};
  List<Map<String, dynamic>> expenditures = [];
  List<Map<String, dynamic>> feeRecords = [];
  List<Map<String, dynamic>> pendingApprovals = [];
  bool shouldNavigateToAdmin = false;
  String selectedClassRange = ''; // Initial range to display

  @override
  void initState() {
    super.initState();
    _loadRoleAndUserId();
  }

  Future<void> _loadRoleAndUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      role = prefs.getString('role') ?? '';
      userId = prefs.getInt('userId') ?? 0;
      selectedClassRange = widget.schoolRange == '6-8' ? '6-8' : '9-12';
    });
    print('Loaded role: $role, userId: $userId');
    if (role == 'admin') {
      setState(() {
        shouldNavigateToAdmin = true;
      });
      _fetchDashboardData();
      _fetchExpenditures();
      _fetchFeeRecords();
      _fetchPendingApprovals(); // Fetch pending approvals
      _fetchNotifications(); // Fetch notifications for admin as well
    } else {
      _fetchNotifications();
    }
  }

  Future<void> _fetchDashboardData() async {
    final url = 'http://localhost:3000/dashboard-data';
    final response = await http.get(Uri.parse(url), headers: {
      'Authorization': 'Bearer ${await _getToken()}', // Use the saved token
    });

    if (response.statusCode == 200) {
      setState(() {
        dashboardData = json.decode(response.body);
      });
    } else {
      print('Failed to fetch dashboard data');
    }
  }

  Future<void> _fetchExpenditures() async {
    final url = 'http://localhost:3000/expenditures';
    final response = await http.get(Uri.parse(url), headers: {
      'Authorization': 'Bearer ${await _getToken()}', // Use the saved token
    });

    if (response.statusCode == 200) {
      setState(() {
        expenditures = List<Map<String, dynamic>>.from(json.decode(response.body));
      });
    } else {
      print('Failed to fetch expenditures');
    }
  }

  Future<void> _fetchFeeRecords() async {
    final url = 'http://localhost:3000/dashboard-data';
    final response = await http.get(Uri.parse(url), headers: {
      'Authorization': 'Bearer ${await _getToken()}', // Use the saved token
    });

    if (response.statusCode == 200) {
      setState(() {
        feeRecords = List<Map<String, dynamic>>.from(json.decode(response.body)['recentFeeRecords']);
      });
    } else {
      print('Failed to fetch fee records');
    }
  }

  Future<void> _fetchPendingApprovals() async {
    final url = 'http://localhost:3000/pendingRequests';
    final response = await http.get(Uri.parse(url), headers: {
      'Authorization': 'Bearer ${await _getToken()}', // Use the saved token
    });

    if (response.statusCode == 200) {
      setState(() {
        pendingApprovals = List<Map<String, dynamic>>.from(json.decode(response.body));
      });
    } else {
      print('Failed to fetch pending approvals');
    }
  }

  Future<void> _fetchNotifications() async {
    final url = 'http://localhost:3000/get_notifications/$userId';
    final response = await http.get(Uri.parse(url), headers: {
      'Authorization': 'Bearer ${await _getToken()}', // Use the saved token
    });

    print('Fetch Notifications Status Code: ${response.statusCode}'); // Debug log
    print('Fetch Notifications Response Body: ${response.body}'); // Debug log

    if (response.statusCode == 200) {
      setState(() {
        notifications = List<Map<String, dynamic>>.from(json.decode(response.body));
      });
    } else {
      print('Failed to fetch notifications');
    }
  }

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  void _showNotifications() {
    Map<String, List<Map<String, dynamic>>> groupedNotifications = {};
    for (var notification in notifications) {
      String date = DateFormat('yyyy-MM-dd').format(DateTime.parse(notification['created_at']));
      if (!groupedNotifications.containsKey(date)) {
        groupedNotifications[date] = [];
      }
      groupedNotifications[date]!.add(notification);
    }

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView(
          children: groupedNotifications.entries.map((entry) {
            return ExpansionTile(
              title: Text(entry.key),
              children: entry.value.map((notification) {
                return ListTile(
                  title: Text(notification['message']),
                  subtitle: Text(DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.parse(notification['created_at']))),
                );
              }).toList(),
            );
          }).toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal, Colors.tealAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: _showNotifications,
          ),
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DocumentationScreen()),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.teal, Colors.tealAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Text(
                'Admin Dashboard',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            _buildDrawerItem(context, 'Admissions (दाखिले)', Icons.how_to_reg, () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AdmissionScreen(schoolRange: widget.schoolRange)),
              );
            }),
            _buildDrawerItem(context, 'Fees (फीस)', Icons.attach_money, () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FeesScreen(schoolRange: widget.schoolRange,)),
              );
            }),
            _buildDrawerItem(context, 'Expenditures (खर्च)', Icons.money_off, () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ExpenditurePage()),
              );
            }),
            _buildDrawerItem(context, 'Academic Calendar (शैक्षणिक कैलेंडर)', Icons.calendar_month, () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AcademicCalendarScreen()),
              );
            }),
            _buildDrawerItem(context, 'Approval Screen (अनुमोदन स्क्रीन)', Icons.approval_rounded, () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ApprovalPage()),
              );
            }),
            _buildDrawerItem(context, 'Send Notification (सूचना भेजें)', Icons.notifications, () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationScreen()),
              );
            }),
            _buildDrawerItem(context, 'Library Management (पुस्तकालय प्रबंधन)', Icons.library_books, () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LibraryManagementScreen()),
              );
            }),
            _buildDrawerItem(context, 'Student List (छात्र सूची)', Icons.library_books, () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => StudentListScreen(schoolRange: widget.schoolRange,)),
              );
            }),
            _buildDrawerItem(
              context,
              'TimeTable Management (टाइमटेबल प्रबंधन)',
              Icons.schedule,
                  () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TimetableScreen()),
                );
              },
            ),

            _buildDrawerItem(context, 'Transport (परिवहन)', Icons.directions_bus, () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TransportScreen()),
              );
            }),
            _buildDrawerItem(context, 'I-Card Management (आई-कार्ड प्रबंधन)', Icons.badge, () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ICardManagementScreen(schoolRange: widget.schoolRange,)),
              );
            }),
            _buildDrawerItem(context, 'Stock Management (स्टॉक प्रबंधन)', Icons.store, () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => StockManagementSystem()),
              );
            }),
            _buildDrawerItem(context, 'Subject Management (विषय प्रबंधन)', Icons.subject, () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SubjectManagementScreen()),
              );
            }),
            _buildDrawerItem(context, 'Class Management (कक्षा प्रबंधन)', Icons.class_outlined, () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ClassManagementScreen()),
              );
            }),
            _buildDrawerItem(context, 'Staff Management (कर्मचारी प्रबंधन)', Icons.work, () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => StaffManagementScreen()),
              );
            }),
            _buildDrawerItem(context, 'Reception Management (रिसेप्शन प्रबंधन)', Icons.room_service, () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ReceptionManagementScreen()),
              );
            }),
            _buildDrawerItem(context, 'Leave Management (अवकाश प्रबंधन)', Icons.calendar_today, () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LeaveManagementScreen()),
              );
            }),
            _buildDrawerItem(context, 'Appointments & Messaging (नियुक्तियाँ और संदेश)', Icons.schedule, () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AppointmentsMessagingScreen()),
              );
            }),
            _buildDrawerItem(context, 'Examination And Results (परीक्षा और परिणाम)', Icons.assignment, () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ExaminationResultScreen()),
              );
            }),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.teal[50]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: shouldNavigateToAdmin
            ? Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildSummaryCards(),
                SizedBox(height: 20),
                _buildClassRangeSelector(),
                _buildCharts(),
                SizedBox(height: 20),
                _buildExpenditures(),
                SizedBox(height: 20),
                _buildFeeRecords(),
                SizedBox(height: 20),
                _buildPendingApprovals(), // Add pending approvals section
              ],
            ),
          ),
        )
            : Center(
          child: Text(
            'Welcome to Admin Dashboard',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    // Filter students based on the selected school range
    int totalFilteredStudents = dashboardData['classDistribution']?.where((data) {
      if (selectedClassRange == '9-12') {
        return data['class'].startsWith('9') || data['class'].startsWith('10') || data['class'].startsWith('11') || data['class'].startsWith('12');
      } else {
        return data['class'].startsWith('6') || data['class'].startsWith('7') || data['class'].startsWith('8');
      }
    }).fold(0, (sum, data) => sum + data['count']) ?? 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildCard('Total Students (कुल छात्र)', totalFilteredStudents.toString(), Icons.people),
        _buildCard('Total Staff (कुल कर्मचारी)', dashboardData['totalStaff']?.toString() ?? '0', Icons.person),
        _buildCard('Total Classes (कुल कक्षाएँ)', dashboardData['totalClasses']?.toString() ?? '0', Icons.class_),
      ],
    );
  }

  Widget _buildCard(String title, String count, IconData icon) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: 200,
        height: 150,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal, Colors.tealAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.white),
            SizedBox(height: 10),
            Text(
              count,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            SizedBox(height: 10),
            Text(title, style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildClassRangeSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Select Class Range: "),
        DropdownButton<String>(
          value: selectedClassRange,
          items: widget.schoolRange == '6-8'
              ? [DropdownMenuItem(value: '6-8', child: Text('6 to 8'))]
              : [DropdownMenuItem(value: '9-12', child: Text('9 to 12'))],
          onChanged: (value) {
            setState(() {
              selectedClassRange = value!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildCharts() {
    return Column(
      children: [
        _buildChartCard('Class Distribution (कक्षा वितरण)', _buildClassDistributionChart()),
        _buildChartCard('Staff Distribution (कर्मचारी वितरण)', _buildStaffDistributionChart()),
      ],
    );
  }

  Widget _buildChartCard(String title, Widget chart) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Container(
              height: 200,
              child: chart,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassDistributionChart() {
    final filteredClasses = dashboardData['classDistribution']?.where((data) {
      if (selectedClassRange == '9-12') {
        return data['class'].startsWith('9') || data['class'].startsWith('10') || data['class'].startsWith('11') || data['class'].startsWith('12');
      } else {
        return data['class'].startsWith('6') || data['class'].startsWith('7') || data['class'].startsWith('8');
      }
    }).toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        width: filteredClasses != null ? filteredClasses.length * 60.0 : 200,
        height: 200,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: 100,
            barTouchData: BarTouchData(enabled: true),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value.toInt().toString(),
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    );
                  },
                  interval: 10,
                  reservedSize: 40,
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    if (filteredClasses != null && value.toInt() < filteredClasses.length) {
                      final className = filteredClasses[value.toInt()]['class'];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          className is String ? className : className.toString(),
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
            borderData: FlBorderData(
              show: false,
            ),
            barGroups: filteredClasses != null
                ? filteredClasses.map<BarChartGroupData>((data) {
              final String className = data['class'];
              final double count = data['count'] is String
                  ? double.tryParse(data['count']) ?? 0
                  : data['count'].toDouble();
              return BarChartGroupData(
                x: filteredClasses.indexOf(data),
                barRods: [
                  BarChartRodData(toY: count, color: Colors.teal)
                ],
                showingTooltipIndicators: [0],
              );
            }).toList()
                : [],
          ),
        )
      ),
    );
  }

  Widget _buildStaffDistributionChart() {
    return PieChart(
      PieChartData(
        sections: dashboardData['staffDistribution'] != null
            ? dashboardData['staffDistribution']
            .map<PieChartSectionData>((data) {
          final double count = data['count'] is String
              ? double.tryParse(data['count']) ?? 0
              : data['count'].toDouble();
          return PieChartSectionData(
            color: Colors.teal,
            value: count,
            title: data['department'],
            radius: 50,
            titleStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          );
        }).toList()
            : [],
      ),
    );
  }

  Widget _buildExpenditures() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Expenditures (हाल के खर्च)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: expenditures.length,
              itemBuilder: (context, index) {
                return ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 0),
                  leading: Icon(Icons.money_off, color: Colors.teal),
                  title: Text(
                      '${expenditures[index]['description']} - ₹${expenditures[index]['amount']}'),
                  subtitle: Text(
                      'Category: ${expenditures[index]['category']} | Date: ${expenditures[index]['date']}'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeeRecords() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Fee Records (हाल के शुल्क रिकॉर्ड)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: feeRecords.length,
              itemBuilder: (context, index) {
                return ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 0),
                  leading: Icon(Icons.attach_money, color: Colors.teal),
                  title: Text(
                      '${feeRecords[index]['student_name']} - ₹${feeRecords[index]['fees_amount']}'),
                  subtitle: Text(
                      'Payment Mode: ${feeRecords[index]['payment_mode']} | Date: ${feeRecords[index]['date']}'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingApprovals() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pending Approvals (लंबित अनुमोदन)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: pendingApprovals.length,
              itemBuilder: (context, index) {
                return ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 0),
                  leading: Icon(Icons.pending, color: Colors.teal),
                  title: Text(
                      '${pendingApprovals[index]['username']} - ${pendingApprovals[index]['role']}'),
                  subtitle: Text(
                      'Email: ${pendingApprovals[index]['email']} | Status: ${pendingApprovals[index]['status']}'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
      BuildContext context, String title, IconData icon, Function() onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }
}

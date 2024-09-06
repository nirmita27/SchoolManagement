import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:school_management/screens/AdminDashboardScreen.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'DocumentationScreen.dart';
import 'notification_screen.dart';

class MainMenuScreen extends StatefulWidget {
  @override
  _MainMenuScreenState createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  String role = '';
  int userId = 0;
  List<Map<String, dynamic>> notifications = [];
  bool showSchoolSelection = true; // Show school selection by default
  String selectedSchool = '';

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
    });
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    final url = 'http://localhost:3000/get_notifications/$userId';
    final response = await http.get(Uri.parse(url), headers: {
      'Authorization': 'Bearer ${await _getToken()}', // Use the saved token
    });

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

  void _selectSchool(String schoolRange) {
    setState(() {
      showSchoolSelection = false;
      selectedSchool = schoolRange;
    });

    if (role == 'admin') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AdminDashboard(schoolRange: selectedSchool)),
      );
    } else if (role == 'teacher') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => TeacherDashboardScreen(schoolRange: selectedSchool)),
      );
    } else if (role == 'accountant') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AccountantDashboardScreen(schoolRange: selectedSchool)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('School Management System', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DocumentationScreen()),
            ),
          ),
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: _showNotifications,
          ),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/adcal'),
            child: Text('ACADEMIC CALENDAR', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/about'),
            child: Text('ABOUT US', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/help'),
            child: Text('HELP', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: showSchoolSelection
          ? _buildSchoolSelectionScreen()
          : _buildMainMenu(),
    );
  }

  Widget _buildSchoolSelectionScreen() {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/Background.jpeg'),
          fit: BoxFit.cover,
        ),
        gradient: LinearGradient(
          colors: [Colors.white, Colors.blue[50]!],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSchoolCard(
              context,
              'महर्षि विद्यापीठ जूनियर हाईस्कूल, बबेरू - बाँदा for 6 - 8',
              Colors.orange,
                  () => _selectSchool('6-8'),
            ),
            SizedBox(height: 20),
            _buildSchoolCard(
              context,
              'महर्षि विद्या पीठ पटेल श्री पी.एस.एस. कन्या इण्टर कालेज बबेरू - बाँदा (उ0 प्र0) for 9 to 12',
              Colors.green,
                  () => _selectSchool('9-12'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSchoolCard(BuildContext context, String title, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.5),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20.0),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 22,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildMainMenu() {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/Background.jpeg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.all(20.0),
            children: <Widget>[
              _buildWelcomeSection(),
              SizedBox(height: 20),
              if (role == 'teacher') ...[
                _buildListCard(context, 'Fees (फीस)', Icons.attach_money, '/fees', [Colors.green, Colors.lightGreen]),
                SizedBox(height: 20),
                _buildListCard(context, 'Academic Calendar (शैक्षणिक कैलेंडर)', Icons.calendar_month, '/adcal', [Colors.purple, Colors.purpleAccent.shade100]),
                SizedBox(height: 20),
                _buildListCard(context, 'Student List', Icons.library_books, '/studentList', [Colors.lightBlueAccent, Colors.cyanAccent]),
                SizedBox(height: 20),
                _buildListCard(context, 'Student Certificate', Icons.library_books, '/studentCertificate', [Colors.brown.shade400, Colors.cyanAccent]),
                SizedBox(height: 20),
                _buildListCard(context, 'Subject Management', Icons.subject, '/subjectMgtSystem', [Color(0xFF43CEA2), Color(0xFF185A9D),],),
                SizedBox(height: 20),
                _buildListCard(context, 'Class Management', Icons.class_outlined, '/classMgtSystem', [Color(0xFF2196F3), Color(0xFFFFEB3B),],),
                SizedBox(height: 20),
                _buildListCard(context, 'Examination And Results (परीक्षा और परिणाम)', Icons.assignment, '/examinationAndResult', [Colors.purple, Colors.cyan],),
              ] else if (role == 'accountant') ...[
                _buildListCard(context, 'Fees (फीस)', Icons.attach_money, '/fees', [Colors.green, Colors.lightGreen]),
                SizedBox(height: 20),
                _buildListCard(context, 'Expenditures (खर्च)', Icons.money_off, '/expenditures', [Colors.redAccent, Colors.orangeAccent]),
                SizedBox(height: 20),
                _buildListCard(context, 'Stock Management', Icons.badge, '/stockMgtSys', [Colors.teal, Colors.lime],),
                SizedBox(height: 20),
                _buildListCard(context, 'Academic Calendar (शैक्षणिक कैलेंडर)', Icons.calendar_month, '/adcal', [Colors.purple, Colors.purpleAccent.shade100]),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to the School Management System',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Please select one of the options below to get started:',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListCard(BuildContext context, String title, IconData icon, String route, List<Color> gradientColors) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: <Widget>[
              Icon(icon, size: 40, color: Colors.white),
              SizedBox(width: 20),
              Text(title, style: TextStyle(fontSize: 22, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}

class TeacherDashboardScreen extends StatelessWidget {
  final String schoolRange;

  TeacherDashboardScreen({required this.schoolRange});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Teacher Dashboard'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal, Colors.tealAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/Background.jpeg'),
            fit: BoxFit.cover,
          ),
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blue[50]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 600),
            child: ListView(
              padding: const EdgeInsets.all(20.0),
              children: <Widget>[
                _buildListCard(context, 'Fees (फीस)', Icons.attach_money, '/fees', [Colors.green, Colors.lightGreen]),
                SizedBox(height: 20),
                _buildListCard(context, 'Academic Calendar (शैक्षणिक कैलेंडर)', Icons.calendar_month, '/adcal', [Colors.purple, Colors.purpleAccent.shade100]),
                SizedBox(height: 20),
                _buildListCard(context, 'Student List', Icons.library_books, '/studentList', [Colors.lightBlueAccent, Colors.cyanAccent]),
                SizedBox(height: 20),
                _buildListCard(context, 'View Timetable (समय सारणी देखें)', Icons.schedule, '/teacherTimeTable', [Colors.yellowAccent, Colors.cyan],),
                SizedBox(height: 20),
                _buildListCard(context, 'Student Certificate', Icons.library_books, '/studentCertificate', [Colors.brown.shade400, Colors.cyanAccent]),
                SizedBox(height: 20),
                _buildListCard(context, 'Subject Management', Icons.subject, '/subjectMgtSystem', [Color(0xFF43CEA2), Color(0xFF185A9D),],),
                SizedBox(height: 20),
                _buildListCard(context, 'Class Management', Icons.class_outlined, '/classMgtSystem', [Color(0xFF2196F3), Color(0xFFFFEB3B),],),
                SizedBox(height: 20),
                _buildListCard(context, 'Examination And Results (परीक्षा और परिणाम)', Icons.assignment, '/examinationAndResult', [Colors.purple, Colors.cyan],),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListCard(BuildContext context, String title, IconData icon, String route, List<Color> gradientColors) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: <Widget>[
              Icon(icon, size: 40, color: Colors.white),
              SizedBox(width: 20),
              Text(title, style: TextStyle(fontSize: 22, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}

class AccountantDashboardScreen extends StatelessWidget {
  final String schoolRange;

  AccountantDashboardScreen({required this.schoolRange});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Accountant Dashboard'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal, Colors.tealAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/Background.jpeg'),
            fit: BoxFit.cover,
          ),
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blue[50]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 600),
            child: ListView(
              padding: const EdgeInsets.all(20.0),
              children: <Widget>[
                _buildListCard(context, 'Fees (फीस)', Icons.attach_money, '/fees', [Colors.green, Colors.lightGreen]),
                SizedBox(height: 20),
                _buildListCard(context, 'Expenditures (खर्च)', Icons.money_off, '/expenditures', [Colors.redAccent, Colors.orangeAccent]),
                SizedBox(height: 20),
                _buildListCard(context, 'Stock Management', Icons.badge, '/stockMgtSys', [Colors.teal, Colors.lime],),
                SizedBox(height: 20),
                _buildListCard(context, 'Academic Calendar (शैक्षणिक कैलेंडर)', Icons.calendar_month, '/adcal', [Colors.purple, Colors.purpleAccent.shade100]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListCard(BuildContext context, String title, IconData icon, String route, List<Color> gradientColors) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 300),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: <Widget>[
              Icon(icon, size: 40, color: Colors.white),
              SizedBox(width: 20),
              Text(title, style: TextStyle(fontSize: 22, color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}

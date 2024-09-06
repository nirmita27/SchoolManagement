import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:school_management/APPOINTMENTS&MESSAGING/AppointmentsMessagingScreen.dart';
import 'package:school_management/ClassManagement/ClassManagementScreen.dart';
import 'package:school_management/I_CARD_MANAGEMENT/iCardManagementScreen.dart';
import 'package:school_management/LeaveManagement/LeaveManagementScreen.dart';
import 'package:school_management/ReceptionManagement/ReceptionManagementScreen.dart';
import 'package:school_management/StaffManagement/StaffManagementScreen.dart';
import 'package:school_management/StockManagementSystem/stock_management_system_screen.dart';
import 'package:school_management/screens/AdminDashboardScreen.dart';
import 'package:school_management/screens/TeacherTimetableScreen.dart';
import 'package:school_management/splah_screen.dart';
import 'package:school_management/LibraryManagement/libraryManagement.dart';
import 'package:school_management/academic_holidays.dart';
import 'package:school_management/approval_page.dart';
import 'package:school_management/screens/student_list_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:school_management/Fees/fees.dart';
import 'package:school_management/admission/AdmissionConfirmedScreen.dart';
import 'package:school_management/admission/DocumentVerificationScreen.dart';
import 'package:school_management/admission/SubmitApplicationScreen.dart';
import 'package:school_management/admission/UploadDocumentsScreen.dart';
import 'package:school_management/admission/admission_screen.dart';
import 'package:school_management/mainmenuscreen.dart';
import 'DocumentationScreen.dart';
import 'ExaminationAndResults/ExaminationAndResults.dart';
import 'LibraryManagement/StudentLibraryRecordScreen.dart';
import 'LibraryManagement/book_availability_screen.dart';
import 'LibraryManagement/book_master_screen.dart';
import 'LibraryManagement/book_publisher_screen.dart';
import 'LibraryManagement/category_master_screen.dart';
import 'LibraryManagement/issue_book_screen.dart';
import 'LibraryManagement/issued_books_screen.dart';
import 'LibraryManagement/monthly_issued_report_screen.dart';
import 'LibraryManagement/receive_book_screen.dart';
import 'LibraryManagement/scrap_book_screen.dart';
import 'LibraryManagement/staff_consolidation_report_screen.dart';
import 'LibraryManagement/stock_report_screen.dart';
import 'LibraryManagement/sub_category_master_screen.dart';
import 'LibraryManagement/top_user_report_screen.dart';
import 'LibraryManagement/track_fines_screen.dart';
import 'StudentCertificateScreen/StudentCertificateScreen.dart';
import 'SubjectManagementSystem/SubjectManagementScreen.dart';
import 'package:school_management/Transport/transport.dart';
import 'admission/dashboard_screen.dart';
import 'expenditure/expenditure.dart';
import 'finance.dart';
import 'login.dart';
import 'notification_screen.dart';
import 'signup_page.dart';
import 'teacher.dart';
import 'student.dart';
import 'aboutus.dart';
import 'help.dart';
import 'studentlogin.dart';
import 'adminlogin.dart';
import 'teacherlogin.dart';
import 'financelogin.dart';
import 'studentdashboard.dart';
import 'admindashboard.dart';
import 'tdashboard.dart';

void main() {
  runApp(SchoolManagementApp());
}

class SchoolManagementApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'School Management System',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: TextTheme(
          headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black),
          headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
          bodyMedium: TextStyle(fontSize: 14, color: Colors.black),
        ),
        cardTheme: CardTheme(
          elevation: 5,
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/home': (context) => HomePage(),
        '/help': (context) => HelpScreen(),
        '/about': (context) => AboutUsPage(),
        '/expenditures': (context) => ExpenditurePage(),
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignUpPage(),
        '/mainmenuscreen': (context) => MainMenuScreen(),
        '/adcal': (context) => AcademicCalendarScreen(),
        '/approval': (context) => ApprovalPage(),
        '/notification': (context) => NotificationScreen(),
        '/library': (context) => LibraryManagementScreen(),
        '/categoryMaster': (context) => CategoryMasterScreen(),
        '/subCategoryMaster': (context) => SubCategoryMasterScreen(),
        '/bookPublisher': (context) => BookPublisherScreen(),
        '/bookMaster': (context) => BookMasterScreen(),
        '/issueBook': (context) => IssueBookScreen(),
        '/issuedBooks': (context) => IssuedBooksScreen(),
        '/receiveBook': (context) => ReceiveBookScreen(),
        '/scrapBook': (context) => ScrapBookScreen(),
        '/checkAvailability': (context) => BookAvailabilityScreen(),
        '/studentLibraryRecord': (context) => StudentLibraryRecordScreen(),
        '/trackFines': (context) => TrackFinesScreen(),
        '/monthlyIssuedReport': (context) => MonthlyIssuedReportScreen(),
        '/stockReport': (context) => StockReportScreen(),
        '/topUserReport': (context) => TopUserReportScreen(),
        '/staffConsolidationReport': (context) => StaffConsolidationReportScreen(),
        '/transport': (context) => TransportScreen(),
        '/studentCertificate': (context) => StudentCertificateScreen(),
        '/stockMgtSys': (context) => StockManagementSystem(),
        '/subjectMgtSystem': (context) => SubjectManagementScreen(),
        '/classMgtSystem': (context) => ClassManagementScreen(),
        '/staffMgtSystem': (context) => StaffManagementScreen(),
        '/receptionMgtSystem': (context) => ReceptionManagementScreen(),
        '/leaveMgtSystem': (context) => LeaveManagementScreen(),
        '/appointment': (context) => AppointmentsMessagingScreen(),
        '/examinationAndResult': (context) => ExaminationResultScreen(),
        '/teacherTimeTable': (context) => TeacherTimetableScreen()
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/dashboard') {
          final args = settings.arguments as Map<String, String>;
          return MaterialPageRoute(
            builder: (context) {
              return AdminDashboard(schoolRange: args['schoolRange']!);
            },
          );
        } else if (settings.name == '/admissions') {
          final args = settings.arguments as Map<String, String>;
          return MaterialPageRoute(
            builder: (context) {
              return AdmissionScreen(schoolRange: args['schoolRange']!);
            },
          );
        }
        return null;
      },
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Maharishi Vidya Peeth Patel Shri P.S.S. Kanya Inter College Baweru-Vanda (U.P.)', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: <Widget>[
          TextButton(
              onPressed: () => Navigator.pushNamed(context, '/about'),
              child: Text('ABOUT US', style: TextStyle(color: Colors.black))),
          TextButton(
              onPressed: () => Navigator.pushNamed(context, '/help'),
              child: Text('HELP', style: TextStyle(color: Colors.black))),
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DocumentationScreen()),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('home.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 600),
            child: ListView(
              padding: const EdgeInsets.all(20.0),
              children: <Widget>[
                SizedBox(height: 300),
                _buildListCard(context, 'Login (लॉग इन करें)', Icons.login, '/login', [Colors.blueAccent, Colors.lightBlueAccent]),
                SizedBox(height: 20),
                _buildListCard(context, 'Sign Up (साइन अप करें)', Icons.person_add, '/signup', [Colors.green, Colors.lightGreen]),
                SizedBox(height: 20),
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

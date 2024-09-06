import 'package:flutter/material.dart';
import 'package:school_management/ExaminationAndResults/AssessmentListScreen.dart';
import 'package:school_management/ExaminationAndResults/DailyMarksEntryScreen.dart';
import 'package:school_management/ExaminationAndResults/ExamListScreen.dart';
import 'package:school_management/ExaminationAndResults/GenerateRankScreen.dart';
import 'package:school_management/ExaminationAndResults/GradeCategoryListScreen.dart';
import 'package:school_management/ExaminationAndResults/GradeEntryNurseryScreen.dart';
import 'package:school_management/ExaminationAndResults/GradeListScreen.dart';
import 'package:school_management/ExaminationAndResults/MarksEntryListScreen.dart';
import 'package:school_management/ExaminationAndResults/ReportCardDesignScreen.dart';
import 'package:school_management/ExaminationAndResults/ReportCardMarksListScreen.dart';
import 'package:school_management/ExaminationAndResults/SetSubjectOrderScreen.dart';
import 'package:school_management/ExaminationAndResults/UploadedStudentReportCardScreen.dart';
import 'package:school_management/ExaminationAndResults/VerifyGradeEntriesScreen.dart';

import 'TermMasterScreen.dart';

class ExaminationResultScreen extends StatelessWidget {
  final List<Color> _colors = [
    Colors.teal,
    Colors.blue,
    Colors.purple,
    Colors.orange,
    Colors.green,
    Colors.red,
    Colors.brown,
    Colors.indigo,
    Colors.pink,
    Colors.cyan,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Examination & Result'),
        backgroundColor: Colors.teal,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.teal,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            _buildDrawerItem(context, 'Upload Student Report Card', Icons.upload_file),
            _buildDrawerItem(context, 'Set Subject Order', Icons.sort),
            _buildDrawerItem(context, 'Verify Grade Entry', Icons.verified),
            _buildDrawerItem(context, 'Daily Marks Entry List', Icons.list),
            _buildDrawerItem(context, 'Marks Entry List', Icons.edit),
            _buildDrawerItem(context, 'Report Card Marks List', Icons.list_alt),
            _buildDrawerItem(context, 'Calculate Student Marks', Icons.calculate),
            _buildDrawerItem(context, 'Download Student Result', Icons.download),
            _buildDrawerItem(context, 'Top Students', Icons.star),
            _buildDrawerItem(context, 'SUBJECT WISE AVG. REPORT', Icons.report),
            _buildDrawerItem(context, 'Download Report Card', Icons.download),
            _buildDrawerItem(context, 'Download Student Marks Sheet', Icons.download),
            _buildDrawerItem(context, 'Date Sheet', Icons.date_range),
            _buildDrawerItem(context, 'Assign Subject Remarks to Students', Icons.note_add),
            _buildDrawerItem(context, 'Teacher Remarks', Icons.person),
            _buildDrawerItem(context, 'Subject Remarks', Icons.subject),
            _buildDrawerItem(context, 'Final Remarks', Icons.note),
            _buildDrawerItem(context, 'Raw Remarks', Icons.raw_on),
            _buildDrawerItem(context, 'Remarks Category', Icons.category),
            Divider(),
            _buildDrawerItem(context, 'Term List', Icons.list),
            _buildDrawerItem(context, 'Assessment List', Icons.assessment),
            _buildDrawerItem(context, 'Grade Category', Icons.category),
            _buildDrawerItem(context, 'Grade List', Icons.grade),
            _buildDrawerItem(context, 'Assessment, Examination & Subject List', Icons.list),
            _buildDrawerItem(context, 'Report Card Design', Icons.design_services),
          ],
        ),
      ),
      body: Center(
        child: Text(
          'Welcome to Examination & Result Management',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, String title, IconData icon) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context); // close the drawer
        if (title == 'Term List') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TermMasterScreen()),
          );
        } else if (title == 'Assessment List') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AssessmentListScreen()),
          );
        } else if (title == 'Grade Category') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => GradeCategoryListScreen()),
          );
        } else if (title == 'Grade List') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => GradeListScreen()),
          );
        } else if (title == 'Assessment, Examination & Subject List') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ExaminationListScreen()),
          );
        } else if (title == 'Report Card Design') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ReportCardDesignScreen()),
          );
        } else if (title == 'Upload Student Report Card') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => UploadedStudentReportCardScreen()),
          );
        } else if (title == 'Set Subject Order') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SetSubjectOrderScreen()),
          );
        } else if (title == 'Verify Grade Entry') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => VerifyGradeEntriesScreen()),
          );
        } else if (title == 'Daily Marks Entry List') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DailyMarksEntryScreen()),
          );
        } else if (title == 'Marks Entry List') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MarksEntryScreen()),
          );
        } else if (title == 'Report Card Marks List') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ReportCardMarksListScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Navigating to $title')),
          );
        }
      },
    );
  }
}

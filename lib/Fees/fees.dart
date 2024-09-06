import 'package:flutter/material.dart';
import 'package:school_management/Fees/studentFees.dart';

class FeesScreen extends StatefulWidget {
  final String schoolRange;

  FeesScreen({required this.schoolRange});

  @override
  State<FeesScreen> createState() => _FeesScreenState();
}

class _FeesScreenState extends State<FeesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Fees Submission (फीस जमा करना)',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/fees2.jpeg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.5),
              BlendMode.darken,
            ),
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 100.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildListCard(context, 'Student', Icons.school, Colors.blue),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListCard(BuildContext context, String title, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        if (title == 'Student') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => StudentFeesForm(schoolRange: widget.schoolRange,)),
          );
        }
      },
      child: Card(
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.4,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withOpacity(0.9), color.withOpacity(1.0)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 60, color: Colors.white),
                SizedBox(height: 15),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Roboto',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
